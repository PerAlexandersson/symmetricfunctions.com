-- gather.lua — traverse AST once; log + lower TeX to Pandoc nodes in-place

-- luacheck: globals PANDOC_STATE pandoc
---@diagnostic disable-next-line: undefined-global
local PANDOC_STATE = PANDOC_STATE
---@diagnostic disable-next-line: undefined-global
local pandoc = pandoc


local utils = dofile("utils.lua")
local trim = utils.trim
local normalize_url = utils.normalize_url
local capitalize_first = utils.capitalize_first
local slugify = utils.slugify
local set_add = utils.set_add
local set_to_sorted_list = utils.set_to_sorted_list
local print_todo = utils.print_todo
local print_warn = utils.print_warn
local print_error = utils.print_error
local has_errors = utils.has_errors

local figure_to_html = dofile("figure_to_html.lua")


local bib = dofile("bibhandler.lua")
local get_bibliography_label = bib.get_bibliography_label
local get_bibliography_tooltip = bib.get_bibliography_tooltip
local relation_registry = dofile("relation_registry.lua")

-- Derive current input filename/stem
local _INPUT = (PANDOC_STATE and PANDOC_STATE.input_files and PANDOC_STATE.input_files[1]) or "(stdin)"
local _BASENAME = _INPUT:match("([^/\\]+)$") or _INPUT
local _STEM = _BASENAME:gsub("%.[^.]+$", "")

-- ===== Lower block TeX macros/envs =========================================
-- Observe that proof -> symproof as pandoc eats that command
local theorem_envs = {
  "definition", "proposition",
  "theorem", "corollary", "problem",
  "example", "lemma",
  "conjecture", "remark",
  "symproof",
  "question", "solution"
}


-- ===== State to fill into meta ============================================
local metatitle = nil   -- \metatitle{...}
local metadesc  = nil   -- \metadescription{...}
local citations = {}    -- set
local labels    = {}    -- set
local todos     = {}    -- list (strings)
local polydata  = {}    -- map name -> { key = value, ... }
local custom_css= {}    -- inject custom css (List of strings)

-- preprocess.lua appends "@@file:line" to some macro arguments.
local SOURCE_LOC = "@@([%w%.%-_/]+:%d+)"

local function strip_source_loc(value)
  local s = tostring(value or "")
  local loc = s:match(SOURCE_LOC .. "$") or ""
  if loc ~= "" then
    s = s:gsub(SOURCE_LOC .. "$", "")
  end
  return s, loc
end

local function record_todo(s)
  local t = s:match("^%s*\\todo(%b{})%s*$")
  if t then
    -- Cites and refs inside the todo carry their own location markers.
    local body = trim((t:sub(2, -2):gsub(SOURCE_LOC, "")))
    todos[#todos + 1] = body
    print_todo(body)
    return {}
  else
    return nil
  end
end

--- Shortens a TeX snippet for an error message.
local function snippet(tex)
  tex = tostring(tex or ""):gsub("%s+", " ")
  if #tex > 120 then tex = tex:sub(1, 117) .. "..." end
  return tex
end

-- Sections must carry explicit labels, so automatic identifiers are off.
local READER_FORMAT = "latex+raw_tex-auto_identifiers"

-- To lazily define the custom handling.
local function make_filter()
  return {
    RawInline = RawInline,
    RawBlock  = RawBlock,
    Header    = Header,
    Image     = Image,
    Link      = Link,
    Cite      = Cite
  }
end


-- Parse a LaTeX fragment to blocks, then re-run our own filter on it
local function parse_blocks_walk(tex)
  local blocks = pandoc.read(tex, READER_FORMAT).blocks
  -- Wrap/unwrap div
  return pandoc.Div(blocks):walk(make_filter()).content
end

-- Parse a LaTeX inline fragment to inlines, then re-run our own filter.
-- The fragment must be a single paragraph; anything else would be lost.
local function parse_inlines_walk(tex)
  local blocks = pandoc.read(tex, READER_FORMAT).blocks
  if #blocks == 0 then return pandoc.List() end
  local first = blocks[1]
  if #blocks > 1 or (first.t ~= "Para" and first.t ~= "Plain") then
    print_error("Inline text must be a single paragraph (got %d block(s), first %s): %s",
                #blocks, first.t, snippet(tex))
  end
  local inlines = (first.t == "Para" or first.t == "Plain") and first.content or {}
  return pandoc.Span(inlines):walk(make_filter()).content -- unwrap the Span
end


-- Parse opt_text as LaTeX inlines and build a bold heading that can contain cites.
local function make_env_div(baseIn, opt_text, body_tex, starred)
  local base = (baseIn == "symproof") and "proof" or baseIn

  -- body blocks
  local body_blocks = parse_blocks_walk(body_tex or "")

  -- heading inlines: <strong>Base (Opt).</strong>
  local strong_inls = pandoc.List()
  strong_inls:insert(pandoc.Str(capitalize_first(base)))
  if opt_text and opt_text ~= "" then
    strong_inls:insert(pandoc.Space())
    strong_inls:insert(pandoc.Str("("))
    local opt_inls = parse_inlines_walk(opt_text)
    for _, x in ipairs(opt_inls) do strong_inls:insert(x) end
    strong_inls:insert(pandoc.Str(")."))
  end

  local head_inls = pandoc.List()
  head_inls:insert(pandoc.Strong(strong_inls))

  -- The renderer turn this into <summary>
  local head_para = pandoc.Para(head_inls)

  -- assemble
  local blocks = pandoc.List({ head_para })
  blocks:extend(body_blocks)

  -- classes: env, base, (optional) collapsible
  local classes = { "env", base }
  if starred then classes[#classes + 1] = "collapsible" end

  return pandoc.Div(blocks, pandoc.Attr("", classes))
end



local TEXTABLES = {
  { name = "ytableau",      pat = "^%s*(\\begin%s*%{ytableau%}%s*[%s%S]-%s*\\end%s*%{ytableau%})%s*$" },
  { name = "array",         pat = "^%s*(\\begin%s*%{array%}%s*%b{}%s*[%s%S]-%s*\\end%s*%{array%})%s*$" },
  { name = "rawtabular",    pat = "^%s*(\\begin%s*%{rawtabular%}%s*%b{}%s*[%s%S]-%s*\\end%s*%{rawtabular%})%s*$" },
  { name = "ytableaushort", pat = "^%s*(\\ytableaushort%b{})%s*$" }
}

local function match_textable(s)
  for _, m in ipairs(TEXTABLES) do
    local b = s:match(m.pat)
    if b then return m.name, b end
  end
  return nil, nil
end


--- Render a single inline TeX fragment to HTML via Pandoc.
--- Preserves special markers (\none, color *(...)  ) that figure_to_html needs.
--- @param tex string  Raw TeX cell content
--- @return string     HTML fragment (or original string if trivial)
local function render_cell_tex_to_html(tex)
  local s = trim(tex)
  if s == "" then return tex end

  -- Preserve markers that figure_to_html.lua handles structurally
  if s == "\\none" then return tex end
  if s:match("^\\[a-z]*rule$") then return tex end

  -- Extract color prefix *(color) if present — preserve it, process the rest
  local color_prefix = ""
  local rest = s
  local color_match = s:match("^(%*%b())")
  if color_match then
    color_prefix = color_match
    rest = trim(s:sub(#color_match + 1))
    if rest == "" then return tex end
  end

  -- Skip cells that are pure math (rendered by KaTeX client-side)
  if rest:match("^%$.*%$$") or rest:match("^\\%(.*\\%)$") then
    return tex
  end

  -- Hyperrefs need the site-wide label map, which is only available during
  -- rendering. Leave them as TeX so render.lua can resolve cross-page links.
  if rest:find("\\hyperref", 1, true) then
    return tex
  end

  -- Skip cells that are plain text (no backslashes at all)
  if not rest:find("\\") then
    return tex
  end

  -- Process through Pandoc + our filter
  local inlines = parse_inlines_walk(rest)
  if not inlines or #inlines == 0 then return tex end

  -- Render inlines to HTML; math stays as \(...\) for KaTeX, exactly like
  -- math in body text.
  local doc = pandoc.Pandoc({ pandoc.Plain(inlines) })
  local html = pandoc.write(doc, "html", { html_math_method = "mathjax" })

  -- pandoc.write wraps in <p>...</p> — strip that
  html = html:gsub("^%s*<p>", ""):gsub("</p>%s*$", "")

  -- Trim trailing whitespace/newlines; source locations are build-time only
  html = html:gsub("%s+$", ""):gsub('%s*data%-source%-loc="[^"]*"', "")

  if html == "" then return tex end

  return color_prefix .. html
end


--- Process all cell contents in a tabular/array body string.
--- Splits on \\ and &, processes each cell, reassembles.
--- @param body string  The full \begin{rawtabular}{spec}...\end{rawtabular} string
--- @return string      Same structure but with cell contents converted to HTML
local function process_tabular_cells(body)
  -- Extract environment wrapper and inner content
  local env_begin, inner, env_end =
    body:match("^(\\begin%s*%{[^}]+%}%s*%b{})(.-)(%s*\\end%s*%{[^}]+%})$")
  if not env_begin then
    -- Try without column spec (shouldn't happen for rawtabular/array, but be safe)
    env_begin, inner, env_end =
      body:match("^(\\begin%s*%{[^}]+%})(.-)(%s*\\end%s*%{[^}]+%})$")
  end
  if not inner then return body end

  -- Booktabs rules end a row of their own (as in figure_to_html.lua); then
  -- split rows and cells exactly as figure_to_html.lua will at render time.
  for _, rule in ipairs({ "toprule", "midrule", "bottomrule" }) do
    inner = inner:gsub("\\" .. rule, "\\" .. rule .. "\\\\")
  end
  local rows = {}
  for _, row_text in ipairs(figure_to_html.split_rows(inner)) do
    local trimmed = trim(row_text)
    -- Booktabs rules and empty rows pass through unchanged
    if trimmed == "\\toprule" or trimmed == "\\midrule"
        or trimmed == "\\bottomrule" or trimmed == "" then
      rows[#rows + 1] = row_text
    else
      local cells = figure_to_html.split_cells(row_text)
      for i, cell in ipairs(cells) do
        cells[i] = render_cell_tex_to_html(cell)
      end
      rows[#rows + 1] = table.concat(cells, "&")
    end
  end

  return env_begin .. table.concat(rows, "\\\\") .. env_end
end


local function normalize_polydata_key(key)
  return (trim(key):lower():gsub("%s+", " "))
end

local function normalize_relation_ref(ref)
  ref = trim(ref or "")
  if ref == "" then return "" end

  local cite_body = ref:match("^\\cite%s*(%b{})%s*$")
                 or ref:match("^\\cite%s*%b[]%s*(%b{})%s*$")
  if cite_body then
    ref = cite_body:sub(2, -2)
  end

  return trim((ref:gsub(SOURCE_LOC, "")))
end

local function split_trimmed(value, delimiter)
  local items = {}
  local pattern = "([^" .. delimiter .. "]*)"
  for item in (tostring(value or "") .. delimiter):gmatch(pattern .. delimiter) do
    item = trim(item)
    if item ~= "" then
      items[#items + 1] = item
    end
  end
  return items
end

local function split_pipe_fields(value)
  local fields = {}
  for field in (tostring(value or "") .. "|"):gmatch("(.-)|") do
    fields[#fields + 1] = trim(field)
  end
  return fields
end

local function parse_relation_refs(ref_text)
  local refs = {}
  ref_text = normalize_relation_ref(ref_text)
  if ref_text == "" then
    return refs
  end

  for ref in (ref_text .. ","):gmatch("(.-)%s*,") do
    ref = normalize_relation_ref(ref)
    if ref ~= "" then
      refs[#refs + 1] = ref
    end
  end

  return refs
end

local function parse_relation_attrs(attr_text)
  local attrs = {}
  local status = nil

  for item in (tostring(attr_text or "") .. ";"):gmatch("(.-)%s*;") do
    item = trim(item)
    if item ~= "" then
      local key, value = item:match("^([^=]-)%s*=%s*(.-)%s*$")
      key = relation_registry.normalize_attr_key(key or item)
      if value == nil or value == "" then
        value = true
      else
        value = trim(value)
      end

      if key == "status" then
        status = relation_registry.normalize_status(value)
      else
        attrs[key] = value
      end
    end
  end

  return attrs, status
end

local function table_is_empty(t)
  return next(t) == nil
end

local function relation_record(target, refs, attrs, status)
  target = trim(target or "")
  if target == "" then
    return nil
  end

  local record = {
    target = target,
    status = relation_registry.normalize_status(status)
  }

  if refs and #refs > 0 then
    record.refs = refs
    record.ref = table.concat(refs, ",")
  end

  if attrs and not table_is_empty(attrs) then
    record.attrs = attrs
  end

  return record
end

-- Relation rows have two forms (see CONVENTIONS.md):
--   structured: "target | Key[,Key...] | attr=value; attr=value"
--               (attribute values may themselves contain "|")
--   legacy:     "target | Key", "target [Key]" or "target", several of
--               which may be separated by semicolons.
-- Anything else is reported instead of being guessed at.
local function parse_relation_items(value, context)
  local items = {}
  local fields = split_pipe_fields(value)

  local function malformed(reason)
    print_error("%s: malformed relation row '%s' (%s)", context, value, reason)
    return {}
  end

  -- Attribute values may contain "|" (e.g. inside math), so everything
  -- after the second pipe is the attribute list.  A row is structured when
  -- that list starts with "key="; otherwise it is a legacy row such as
  -- "A | RefA; B | RefB".
  local attr_text = (#fields >= 3) and table.concat(fields, "|", 3) or ""
  if attr_text:match("^[^=;|]+=") then
    if fields[2]:find(";", 1, true) then
      return malformed("structured rows take one target; use one row per target")
    end
    local refs = parse_relation_refs(fields[2])
    local attrs, status = parse_relation_attrs(attr_text)
    for _, target in ipairs(split_trimmed(fields[1], ";")) do
      local record = relation_record(target, refs, attrs, status)
      if record then
        items[#items + 1] = record
      end
    end
    return items
  end

  for item in (value .. ";"):gmatch("(.-)%s*;") do
    item = trim(item)
    if item ~= "" then
      local _, pipes = item:gsub("|", "")
      if pipes > 1 then
        return malformed("more than one '|' in '" .. item .. "'")
      end
      local target, ref = item:match("^(.-)%s*|%s*(.-)%s*$")
      if not target then
        target, ref = item:match("^(.-)%s*%[(.-)%]%s*$")
      end

      target = trim(target or item)
      if target == "" or target:find("[%s%[%]|]") then
        return malformed("bad target in '" .. item .. "'")
      end
      local record = relation_record(target, parse_relation_refs(ref), nil, nil)
      if record then
        items[#items + 1] = record
      end
    end
  end

  return items
end

-- Family fields allowed in a polydata block besides relation rows.
local POLYDATA_FIELDS = {
  Name = true, Symbol = true, Space = true, Basis = true, Rating = true,
  Bib = true, Year = true, Category = true, Keywords = true
}

-- Parse polydata body "Key & Value \\" lines → table
local function parse_polydata_body(body, name)
  local map = {}
  local context = "polydata '" .. name .. "'"
  for line in (body .. "\n"):gmatch("([^\n\r]*)\n") do
    -- Comments are masked by preprocess.lua; an unescaped % is still a comment.
    local clean = line:gsub("^%%.*$", ""):gsub("([^\\])%%.*$", "%1")
    clean = trim((clean:gsub("\\\\%s*$", "")))
    if clean ~= "" then
      local k, v = clean:match("^([^&]-)%s*&%s*(.-)$")
      local key = trim(k or "")
      local value = trim(v or "")
      local relation_spec = key ~= "" and relation_registry.lookup_by_key(normalize_polydata_key(key))

      if not k or key == "" then
        print_error("%s: line without 'Key & value': %s", context, snippet(line))
      elseif value == "" then
        print_error("%s: empty value for '%s'", context, key)
      elseif relation_spec then
        map.Relations = map.Relations or {}
        for _, relation in ipairs(parse_relation_items(value, context)) do
          relation.type = relation_spec.type
          relation.label = relation_spec.label
          map.Relations[#map.Relations + 1] = relation
        end
      elseif not POLYDATA_FIELDS[key] then
        print_error("%s: unknown field or relation '%s'", context, key)
      elseif map[key] ~= nil then
        print_error("%s: field '%s' given twice", context, key)
      else
        map[key] = value
      end
    end
  end
  return map
end

local function latex_to_unicode(s, context)
  local ok, doc = pcall(pandoc.read, tostring(s or ""), "latex")
  if not ok then
    print_error("Could not parse %s as LaTeX: %s", context or "name", tostring(s or ""))
    return tostring(s or "")
  end
  return trim(pandoc.utils.stringify(doc))
end

local function first_unicode_codepoint(s)
  s = tostring(s or ""):gsub("^[%s%p]+", "")
  if s == "" then return "" end
  local next_pos = utf8.offset(s, 2)
  return next_pos and s:sub(1, next_pos - 1) or s
end

local function percent_encode(s)
  return (tostring(s or ""):gsub("[^A-Za-z0-9%-._~]", function(byte)
    return string.format("%%%02X", byte:byte())
  end))
end

local function parse_name(s)
  -- Try to match pattern with optional argument first: \name[Short Name]{Full Name}
  local opt_part, main_part = s:match("^%s*\\name%s*(%b[])%s*(%b{})%s*$")

  -- If not found, fall back to pattern with only mandatory argument: \name{Full Name}
  if not opt_part then
    main_part = s:match("^%s*\\name%s*(%b{})%s*$")
  end

  if main_part == nil then
    return nil
  end

  -- The mandatory argument is now the Full Name
  local full_name = latex_to_unicode(main_part:sub(2, -2))
  local display_text = ""

  if opt_part then
    -- If optional argument exists, use it directly for display
    display_text = latex_to_unicode(opt_part:sub(2, -2))
  else
    -- Auto-generate abbreviated form
    -- Split by spaces to get name parts
    local parts = {}
    for part in full_name:gmatch("%S+") do
      table.insert(parts, part)
    end

    if #parts < 2 then
      -- Single name (e.g., "Euclid") - use as-is
      display_text = full_name
    else
      -- Last part is the last name
      local last_name = parts[#parts]

      -- All other parts are first/middle names - abbreviate them
      local first_abbrevs = {}
      for i = 1, #parts - 1 do
        local name_part = parts[i]

        -- Check if this part is hyphenated (e.g., "Marcel-Paul" or "Augustin-Louis")
        if name_part:find("-") then
          -- Split by hyphen and abbreviate each part
          local hyphen_parts = {}
          for hp in name_part:gmatch("[^-]+") do
            table.insert(hyphen_parts, first_unicode_codepoint(hp) .. ".")
          end
          table.insert(first_abbrevs, table.concat(hyphen_parts, "-"))
        else
          -- Simple first/middle name - just take first letter
          table.insert(first_abbrevs, first_unicode_codepoint(name_part) .. ".")
        end
      end

      -- Join abbreviated first names with spaces, then add last name
      display_text = table.concat(first_abbrevs, " ") .. " " .. last_name
    end
  end

  -- Construct the search query using the Full Name
  -- A tie (~) becomes a no-break space; search engines want a plain space.
  local search_query = percent_encode(full_name:gsub("\u{00A0}", " ") .. " mathematics")
  local url = "https://scholar.google.com/scholar?q=" .. search_query

  return pandoc.Link(
    { pandoc.Str(display_text) },                -- Visible text (Short or Auto-short)
    url,                                         -- URL (Search using Full Name)
    "Search for " .. full_name,                  -- Tooltip title
    { class = "author-name", target = "_blank" } -- Attributes
  )
end

local function parse_svgimg(s)
  -- \svgimg
  -- \svgimg[0.8]{path}{alt}
  local opt, path, alt = s:match("^%s*\\svgimg%s*(%b[])%s*(%b{})%s*(%b{})%s*$")
  if not path then
    -- \svgimg{path}{alt}
    path, alt = s:match("^%s*\\svgimg%s*(%b{})%s*(%b{})%s*$")
    opt = "[]"
  end

  if not path then
    return nil
  end

  path              = path:sub(2, -2) or ""
  alt               = alt:sub(2, -2) or ""
  opt               = opt:sub(2, -2) or ""
  local source_loc
  path, source_loc = strip_source_loc(path)

  local styleVal    = ""

  -- The only option is width=<fraction>, optionally followed by a length
  -- macro such as \textwidth; it becomes a percentage of the text width.
  opt = trim(opt or "")
  if opt ~= "" then
    local num = opt:match("^width%s*=%s*(%d*%.?%d+)%s*$")
             or opt:match("^width%s*=%s*(%d*%.?%d+)%s*\\%a+%s*$")
    local f = tonumber(num or "")
    if f and f > 0 then
      styleVal = "width:" .. tostring(math.floor(f * 100 + 0.5)) .. "%;"
    else
      print_error("%s: unsupported \\svgimg option [%s]",
                  source_loc ~= "" and source_loc or path, opt)
    end
  end

  local kvs = {}
  if styleVal ~= "" then
    kvs[#kvs + 1] = { "style", styleVal }
  end
  if source_loc ~= "" then
    kvs[#kvs + 1] = { "data-source-loc", source_loc }
  end

  local attr = pandoc.Attr("", {}, kvs)

  return pandoc.Image(pandoc.Str(latex_to_unicode(alt, "image description")), path, "", attr)
end



local function parse_icon(s)
  local ico = s:match("^%s*\\icon%s*(%b{})%s*$")
  if not ico then
    return nil
  end

  ico = ico:sub(2, -2) or ""
  local source_loc
  ico, source_loc = strip_source_loc(ico)

  local path = "icons/icon-" .. ico .. ".svg"

  local kvs = {}
  if source_loc ~= "" then
    kvs[#kvs + 1] = { "data-source-loc", source_loc }
  end

  local attr = pandoc.Attr("", {"icon"}, kvs)

  return pandoc.Image(pandoc.Str("Icon: " .. ico), path, "", attr)
end


--\topiccard{ID}{Title}{Body}
-- <a href="ID" class="topic-card">
--   <p>Body</p>
--   <img src="nav-images/card-ID.svg" alt="Title"/>
-- </a>
local function topic_card(s)
 -- Capture ID, Title, Description
  local id, title, description = s:match("^%s*\\topiccard%s*(%b{})%s*(%b{})%s*(%b{})%s*$")

  if id and title and description then
    local id_inner    = trim(id:sub(2, -2))
    local title_inner = trim(title:sub(2, -2))
    local descr_inner = trim(description:sub(2, -2))
    local source_loc
    id_inner, source_loc = strip_source_loc(id_inner)

    --  Create the Image
    local img_path  = string.format("nav-images/card-%s.svg", id_inner)
    -- We set intrinsic dimensions, but CSS will handle the actual layout
    local img_kvs   = { { "style", "height: 4rem; width: auto; max-width: 100%;" } }
    if source_loc ~= "" then
      img_kvs[#img_kvs + 1] = { "data-source-loc", source_loc }
    end
    local img_attr  = pandoc.Attr("", {}, img_kvs)
    local img       = pandoc.Image(pandoc.Str(title_inner), img_path, "", img_attr)

    --  Process Text
    -- Visible Title (Rich Text with Math support)
    local title_doc = pandoc.read(title_inner, "latex")
    -- Safety check: ensure we got blocks back
    local title_content = title_doc.blocks[1] and title_doc.blocks[1].content or {}

    -- Tooltip Description (Plain Text for title="" attribute)
    local desc_doc  = pandoc.read(descr_inner, "latex")
    local desc_text = pandoc.utils.stringify(desc_doc)

    -- Create span for CSS styling
    local title_span = pandoc.Span(title_content, {class="card-title"})
    
    -- Wrap text in a container span (Flexbox helper)
    local text_wrapper = pandoc.Span({title_span}, {class="card-text"})

    -- Create Link: 
    -- Content: [Text Wrapper] + [Image]
    -- Title Attribute: desc_text
    local link = pandoc.Link(
      {text_wrapper, img},
      '#' .. id_inner, 
      desc_text,
      pandoc.Attr("", { "topic-card", "hyperref" }, {})
    )

    -- Return as Paragraph to sit in the grid
    return pandoc.Para({link})
  else
    return nil
  end
end


-- ===== Pandoc node handlers ===============================================
function Header(el)
  -- Increase level
  el.level = math.min((el.level or 1) + 1, 6)
  if el.identifier and el.identifier ~= "" then
    set_add(labels, el.identifier)
  else
    print_error("Section without a label: %s (use \\section[label]{...})",
                pandoc.utils.stringify(el.content))
  end
  return el
end

function Image(el)
  local src, source_loc = strip_source_loc(el.src or "")
  if source_loc ~= "" then
    el.src = src
    el.attr = el.attr or pandoc.Attr("", {}, {})
    el.attr.attributes = el.attr.attributes or {}
    el.attr.attributes["data-source-loc"] = source_loc
  end
  return el
end

function Cite(el)
  -- Pandoc natively parses \cite → Cite node containing RawInline children.
  -- We handle citations here and return a Span so the walker does not
  -- descend into the RawInline children (which would double-process).
  local cite_parts = {}
  local any_missing = false
  local cite_loc_first = ""
  local citation_nodes = el.citations or {}
  local prefix = (#citation_nodes > 0 and citation_nodes[1].prefix) or {}
  local suffix = (#citation_nodes > 0 and citation_nodes[#citation_nodes].suffix) or {}

  for _, c in ipairs(el.citations or {}) do
    if c.id and c.id ~= "" then
      -- Strip source location annotation (@@file:line) injected by preprocess
      local cite_loc = c.id:match(SOURCE_LOC .. "$") or ""
      local key = c.id:gsub(SOURCE_LOC .. "$", "")
      if cite_loc_first == "" then cite_loc_first = cite_loc end
      local mode = tostring(c.mode or "NormalCitation")
      if mode ~= "NormalCitation" then
        if cite_loc ~= "" then
          print_error("%s: Unsupported citation mode %s for key: %s",
                      cite_loc, mode, key)
        else
          print_error("Unsupported citation mode %s for key: %s", mode, key)
        end
        any_missing = true
      end
      local lbl = get_bibliography_label(key)
      if not lbl then
        if cite_loc ~= "" then
          print_error("%s: Missing citation key: %s", cite_loc, key)
        else
          print_error("Missing citation key: %s", key)
        end
        cite_parts[#cite_parts + 1] = pandoc.Str("UNDEF:" .. key)
        any_missing = true
      else
        set_add(citations, key)
        local tooltip = get_bibliography_tooltip(key) or ""
        cite_parts[#cite_parts + 1] = pandoc.Link(
            { pandoc.Str(lbl) },
            "#" .. key,
            tooltip,
            { class = "cite" }
        )
      end
    end
  end

  local inlines = { pandoc.Str("[") }
  for _, node in ipairs(prefix) do
    inlines[#inlines + 1] = node
  end
  if #prefix > 0 then
    inlines[#inlines + 1] = pandoc.Space()
  end
  for i, node in ipairs(cite_parts) do
    if i > 1 then inlines[#inlines + 1] = pandoc.Str(", ") end
    inlines[#inlines + 1] = node
  end
  if #suffix > 0 then
    inlines[#inlines + 1] = pandoc.Str(", ")
    for _, node in ipairs(suffix) do
      inlines[#inlines + 1] = node
    end
  end
  inlines[#inlines + 1] = pandoc.Str("]")

  local classes = any_missing and { "citeSpan", "missing" } or { "citeSpan" }
  return pandoc.Span(inlines, pandoc.Attr("", classes))
end

-----------------
-- pandoc recognizes href and hyperref, and converts to link directly
-----------------
function Link(el)
  local text = pandoc.utils.stringify(el.content)
  local url  = (type(el.target) == "string" and el.target)
      or (type(el.target) == "table" and (el.target[1] or el.target.url))
      or el.target or ""

  el.classes = el.classes or {}
  el.attributes = el.attributes or {}

  local function has_class(class_name)
    for _, existing in ipairs(el.classes) do
      if existing == class_name then return true end
    end
    return false
  end

  local is_autolink = has_class("uri") or text == url
  if is_autolink and type(url) == "string" then
    local href, display = normalize_url(url)
    url = href
    if type(el.target) == "table" then
      el.target[1] = href
    else
      el.target = href
    end
    el.content = { pandoc.Str(display) }
    text = display
  end

  local link_loc = ""
  if type(url) == "string" then
    link_loc = url:match("^#.-" .. SOURCE_LOC .. "$") or ""
    if link_loc ~= "" then
      url = url:gsub(SOURCE_LOC .. "$", "")
      if type(el.target) == "string" then
        el.target = url
      elseif type(el.target) == "table" then
        el.target[1] = url
      else
        el.target = url
      end
      el.attributes["data-source-loc"] = link_loc
    end
  end

  local already_classified = has_class("cite") or has_class("hyperref")
      or has_class("href") or has_class("oeis")
  if not already_classified then
    if url:match("^https?://oeis%.org/") then
      table.insert(el.classes, "oeis")
    elseif url:match("^#") then
      table.insert(el.classes, "hyperref") -- internal anchors
    else
      table.insert(el.classes, "href")     -- generic external link
    end
  end
  return el
end

function RawInline(el)
  if not el.format:match("tex") then return nil end
  local s = el.text


  -- \defin{...} → Span(class=defin)
  do
    local b = s:match("^%s*\\defin(%b{})%s*$")
    if b then
      local inner = b:sub(2, -2)
      return pandoc.Span(parse_inlines_walk(inner), pandoc.Attr("", { "defin" }))
    end
  end

  -- \name{...} → Span(class=author-name)
  do
    local n = parse_name(s)
    if n then
      return n
    end
  end

  -- \icon{...} → Image(class=icon)
  do
    local ico = parse_icon(s)
    if ico then
      return ico
    end
  end

  -- \svgimg
  do
    local img = parse_svgimg(s)
    if img then
      return img
    end
  end

  -- \oeis{Axxxxxx} → Link(id, https://oeis.org/id), class="oeis"
  -- <a title="The On-Line Encyclopedia of Integer Sequences" class="oeis" href="https://oeis.org/A000085">A000085</a>
  do
    local b = s:match("^%s*\\oeis(%b{})%s*$")
    if b then
      local id  = b:sub(2, -2)
      local url = "https://oeis.org/" .. id
      return pandoc.Link(
        { pandoc.Str(id) },
        url,
        "The On-Line Encyclopedia of Integer Sequences",
        pandoc.Attr("", { "oeis" }, {})
      )
    end
  end

  -- \filelink{path}{label} → Link(label, path), class="dataFile"
  do
    local path, label = s:match("^%s*\\filelink(%b{})(%b{})%s*$")
    if path and label then
      local path_inner = path:sub(2, -2)
      local label_inner = label:sub(2, -2)
      return pandoc.Link(
        parse_inlines_walk(label_inner),
        path_inner,
        "",
        pandoc.Attr("", { "dataFile" }, {})
      )
    end
  end

  -- \label{...} → a label span
  do
    local b = s:match("^%s*\\label(%b{})%s*$")
    if b then
      local id = b:sub(2, -2)
      set_add(labels, id)
      -- Empty span with id; content left empty on purpose
      return pandoc.Span({}, pandoc.Attr(id, { "label" }))
    end
  end

  -- \enquote{...} → Quoted(DoubleQuote, …)
  do
    local b = s:match("^%s*\\enquote(%b{})%s*$")
    if b then
      return pandoc.Quoted("DoubleQuote", parse_inlines_walk(b:sub(2, -2)))
    end
  end

  -- \cite — handled by the Cite() filter (Pandoc parses \cite natively).
  -- RawInline fires before Cite in the bottom-up walk, so we suppress it here
  -- to avoid double-processing.
  do
    if s:match("^%s*\\cite") then
      return pandoc.Str("")
    end
  end


  -- \bigskip / \medskip / \smallskip inline: treat as span
  do
    local size = s:match("^%s*\\(%a-)skip%s*$")
    if size == "big" or size == "med" or size == "small" then
      print_warn("Inline skip of size %s", size)
      return pandoc.Span(
        { pandoc.RawInline("html", "&#8203;") },
        pandoc.Attr("", { "vskip", size })
      )
    end
  end


  -- \ytableaushort and friends appearing as inline
  do
    local name, body = match_textable(s)
    if name and body then
      if name == "rawtabular" then
        body = process_tabular_cells(body)
      end
      return pandoc.Span(
        { pandoc.RawInline("latextable", body) },
        pandoc.Attr("", { "latextable-inline", name })
      )
    end
  end

  -- \topiccard as inline
  do
    local topiccardLink = topic_card(s)
    if topiccardLink then
      return topiccardLink
    end
  end

  -- \todo inline -- record & drop
  if record_todo(s) then
    return {}
  end

  print_error("Unsupported inline TeX (it would be dropped): %s", snippet(s))

  return nil
end

-- Block TeX: meta, family, theorem-like envs, polydata, todo
function RawBlock(el)
  if not el.format:match("tex") then return nil end
  local s = el.text or ""

  -- \bigskip / \medskip / \smallskip
  do
    local size = s:match("^%s*\\(%a-)skip%s*$")
    if size == "big" or size == "med" or size == "small" then
      return pandoc.Div({ pandoc.RawInline("html", "&#8203;") }, pandoc.Attr("", { "vskip", size }))
    end
  end

  -- \metatitle{...}
  do
    local mt = s:match("^%s*\\metatitle(%b{})%s*$")
    if mt then
      metatitle = latex_to_unicode(mt:sub(2, -2), "page title")
      return {}
    end
  end

  -- \metadescription{...}
  do
    local md = s:match("^%s*\\metadescription(%b{})%s*$")
    if md then
      metadesc = latex_to_unicode(md:sub(2, -2), "page description")
      return {}
    end
  end

  -- \metakeywords{...} — not used, discard
  do
    local md = s:match("^%s*\\metakeywords(%b{})%s*$")
    if md then
      return {}
    end
  end

 -- \specialblock{...}
 do
  local sb = s:match("^%s*\\specialblock(%b{})%s*$")
  if sb then
    return pandoc.Div(
        {},  -- Empty content
        pandoc.Attr(
          "",  -- No ID
          {"specialblock"},  -- Class for identification
          {{"data-type", sb:sub(2,-2)}}  -- Store the page ID
        )
      )
  end
end

  -- \searchbox: the Pagefind search widget, rendered by render.lua
  if s:match("^%s*\\searchbox%s*$") then
    return pandoc.Div({}, pandoc.Attr("", {"specialblock"}, {{"data-type", "search"}}))
  end

-- \begin{cssvars} ... \end{cssvars}
  do
    local body = s:match("^%s*\\begin%s*%{cssvars%}%s*([%s%S]-)\\end%s*%{cssvars%}%s*$")
    if body then
      table.insert(custom_css, body)
      return {}
    end
  end

  -- \svgimg as block
  do
    local img = parse_svgimg(s)
    if img then
      -- Return a block-level image: wrap in a paragraph (or Plain)
      return pandoc.Para { img }
    end
  end

  -- \todo{...} — log & drop
  do
    local t = record_todo(s)
    if t then return {} end
  end

  -- blockquote
  do
    local body = s:match("^%s*\\begin%s*%{blockquote%}%s*([%s%S]-)\\end%s*%{blockquote%}%s*$")
    if body then
      return pandoc.BlockQuote(parse_blocks_walk(body))
    end
  end


  -- theorem-like envs: with [opt] or without
  for _, env in ipairs(theorem_envs) do
    -- with [opt]
    local O, B = s:match("^%s*\\begin%s*%{" .. env .. "%}%s*(%b[])%s*([%s%S]-)\\end%s*%{" .. env .. "%}%s*$")
    if O and B then
      return make_env_div(env, O:sub(2, -2), B, false)
    end

    -- * with [opt]
    O, B = s:match("^%s*\\begin%s*%{" .. env .. "%*%}%s*(%b[])%s*([%s%S]-)\\end%s*%{" .. env .. "%*%}%s*$")
    if O and B then
      return make_env_div(env, O:sub(2, -2), B, true)
    end

    -- without [opt]
    local B2 = s:match("^%s*\\begin%s*%{" .. env .. "%}%s*([%s%S]-)\\end%s*%{" .. env .. "%}%s*$")
    if B2 then
      return make_env_div(env, "", B2, false)
    end

    -- * without [opt]
    B2 = s:match("^%s*\\begin%s*%{" .. env .. "%*%}%s*([%s%S]-)\\end%s*%{" .. env .. "%*%}%s*$")
    if B2 then
      return make_env_div(env, "", B2, true)
    end
  end


  -- \begin{polydata}{name} ... \end{polydata} → meta.polydata[name] = {k=v,...}; drop block
  do
    local N, B = s:match("^%s*\\begin%s*%{polydata%}%s*(%b{})%s*([%s%S]-)\\end%s*%{polydata%}%s*$")
    if N and B then
      local name = trim(N:sub(2, -2))
      local map = parse_polydata_body(B, name)
      polydata[name] = map
      set_add(labels, name)
      -- Emit an anchor so the #name fragment resolves on the page
      return pandoc.Div({}, pandoc.Attr(name, { "polydata-anchor" }))
    end
  end

  -- \begin{symfig} ... \end{symfig}
  do
    local content = s:match("^%s*\\begin%s*%{symfig%}%s*([%s%S]-)\\end%s*%{symfig%}%s*$")
    if content then
      --TODO use proper Figure tag with later Lua version
      return pandoc.Div(parse_blocks_walk(content), pandoc.Attr("", { "figure" }))
    end
  end


  -- \begin{topicssection}{Title} ... \end{topicssection}
  do
    local title, body = s:match("^%s*\\begin%s*%{topicsection%}%s*(%b{})%s*([%s%S]-)\\end%s*%{topicsection%}%s*$")

    if title and body then
      -- strip outer { } from title and parse as inlines
      local heading  = pandoc.Header(2,
        parse_inlines_walk(title:sub(2, -2)),
        pandoc.Attr("topic-header-" .. slugify(title:sub(2, -2)))
      )

      -- inner grid wrapper for cards
      local grid_div = pandoc.Div(parse_blocks_walk(body), pandoc.Attr("", { "topic-card-grid" }))

      -- combine heading + grid into one block list
      local blocks   = pandoc.List({ heading, grid_div })

      -- outer wrapper div for the whole section
      return pandoc.Div(blocks, pandoc.Attr("", { "topicsection" }))
    end
  end

  --\topiccard{ID}{Title}{Body}
  do
    local topiccardLink = topic_card(s)
    if topiccardLink then
      return { topiccardLink }
    end
  end


  --latextable (ytableau, array, rawtabular, ytableaushort)
  do
    local name, body = match_textable(s)
    if name and body then
      -- Process cell contents for tabular (not array/ytableau: their cells are math)
      if name == "rawtabular" then
        body = process_tabular_cells(body)
      end
      return pandoc.RawBlock("latextable", body)
    end
  end


  print_error("Unsupported TeX block (it would be dropped): %s", snippet(s))

  return nil
end

-- ===== Finalizer ===========================================================
-- Collect human-readable definition terms after all TeX lowering. A label
-- immediately following a definition gives its precise reference; otherwise
-- the exporter links to the page. Do not turn general formulae into keywords.
local function definition_keywords(doc)
  local entries, seen = {}, {}
  doc:walk({ Inlines = function(inlines)
    for i, inline in ipairs(inlines) do
      if inline.t == "Span" and inline.classes:includes("defin") then
        local readable = true
        local plain = pandoc.walk_inline(inline, {
          Math = function(el)
            if el.text:match("^[A-Za-z]$") then return pandoc.Str(el.text) end
            readable = false
          end,
          RawInline = function() readable = false end,
        })
        local phrase = trim(pandoc.utils.stringify(plain):gsub("%s+", " "))
        local label = ""
        local next_index = i + 1
        while inlines[next_index] and
            (inlines[next_index].t == "Space" or inlines[next_index].t == "SoftBreak") do
          next_index = next_index + 1
        end
        local following = inlines[next_index]
        if following and following.t == "Span" and
            following.classes:includes("label") then
          label = following.identifier
        end
        local key = phrase .. "\0" .. label
        if readable and phrase ~= "" and not seen[key] then
          seen[key] = true
          entries[#entries + 1] = { phrase = phrase, label = label }
        end
      end
    end
  end })
  return pandoc.MetaList(entries)
end

-- A polydata block emits an anchor for its id, which is unnecessary (and a
-- duplicate id) when a section or \label already defines that id.
local function drop_redundant_polydata_anchors(doc)
  local defined = {}
  doc:walk({
    Header = function(el) defined[el.identifier] = true end,
    Span = function(el) if el.identifier ~= "" then defined[el.identifier] = true end end,
  })
  return doc:walk({
    Div = function(el)
      if el.classes:includes("polydata-anchor") and defined[el.identifier] then
        return {}
      end
    end,
  })
end

function Pandoc(doc)
  local m = doc.meta

  if not metatitle then
    print_error("Missing \\metatitle{...}")
  else
    m.metatitle = pandoc.MetaString(metatitle)
  end

  if not metadesc then
    print_error("Missing \\metadescription{...}")
  else
    m.metadescription = pandoc.MetaString(metadesc)
  end

  doc = drop_redundant_polydata_anchors(doc)

  m.citations  = set_to_sorted_list(citations)
  m.labels     = set_to_sorted_list(labels)
  m.keywords   = definition_keywords(doc)
  m.todos      = todos
  m.polydata   = polydata
  
  if #custom_css > 0 then
    m.custom_css = pandoc.MetaString(table.concat(custom_css, "\n"))
  end

  m.sourcestem = pandoc.MetaString(_STEM or "")

  if has_errors() then
    error("gather.lua reported " .. tostring(utils.get_error_count()) .. " error(s)")
  end

  return pandoc.Pandoc(doc.blocks, m)
end
