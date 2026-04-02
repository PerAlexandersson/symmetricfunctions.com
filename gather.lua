-- gather.lua — traverse AST once; log + lower TeX to Pandoc nodes in-place

-- luacheck: globals PANDOC_STATE pandoc
---@diagnostic disable-next-line: undefined-global
local PANDOC_STATE = PANDOC_STATE
---@diagnostic disable-next-line: undefined-global
local pandoc = pandoc


local utils = dofile("utils.lua")
local trim = utils.trim
local capitalize_first = utils.capitalize_first
local slugify = utils.slugify
local set_add = utils.set_add
local set_to_sorted_list = utils.set_to_sorted_list
local print_todo = utils.print_todo
local print_warn = utils.print_warn
local print_info = utils.print_info
local print_error = utils.print_error


local bib = dofile("bibhandler.lua")
local get_bibliography_label = bib.get_bibliography_label
local get_bibliography_tooltip = bib.get_bibliography_tooltip

-- Derive current input filename/stem
local _INPUT = (PANDOC_STATE and PANDOC_STATE.input_files and PANDOC_STATE.input_files[1]) or "(stdin)"
local _BASENAME = _INPUT:match("([^/\\]+)$") or _INPUT
local _STEM = _BASENAME:gsub("%.[^.]+$", "")

-- ===== Lower block TeX macros/envs =========================================
-- Observe that proof -> symproof as pandoc eats that command
local theorem_envs = {
  "definition", "proposition",
  "theorem", "problem",
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
local urls_seen = {}    -- set (url -> true), for logging
local todos     = {}    -- list (strings)
local families  = {}    -- list of {id=..., title=...}
local polydata  = {}    -- map name -> { key = value, ... }
local custom_css= {}    -- inject custom css (List of strings)

local function record_todo(s)
  local t = s:match("^%s*\\todo(%b{})%s*$")
  if t then
    local body = trim(t:sub(2, -2))
    todos[#todos + 1] = body
    print_todo(body)
    return {}
  else
    return nil
  end
end

local function strip_source_loc(value)
  local s = tostring(value or "")
  local loc = s:match("@@([%w%.%-_/]+:%d+)$") or ""
  if loc ~= "" then
    s = s:gsub("@@[%w%.%-_/]+:%d+$", "")
  end
  return s, loc
end

-- ---- Unified link logging, in order to look for broken links perhaps -----------------------------------------
local function record_link(url, text)
  url       = url or ""
  text      = text or ""
  local key = url .. "||" .. text
  urls_seen[key] = true
end

-- To lazily define the custom handling.
local function make_filter()
  return {
    RawInline = RawInline,
    RawBlock  = RawBlock,
    Header    = Header,
    Image     = Image,
    Link      = Link,
    Cite      = Cite,
    Quoted    = Quoted
  }
end


-- Parse a LaTeX fragment to blocks, then re-run our own filter on it
local function parse_blocks_walk(tex)
  local blocks = pandoc.read(tex, "latex+raw_tex").blocks
  -- Wrap/unwrap div
  local walked = pandoc.walk_block(pandoc.Div(blocks), make_filter())
  return walked.content
end

-- Parse a LaTeX inline fragment to inlines, then re-run our own filter
local function parse_inlines_walk(tex)
  local doc     = pandoc.read(tex, "latex+raw_tex")
  local first   = doc.blocks[1]

  local inlines = (first and first.t == "Para") and first.c or {}
  local walked  = pandoc.walk_inline(pandoc.Span(inlines), make_filter())
  return walked.content -- unwrap the Span
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

  -- Skip cells that are pure math (already handled by MathJax client-side)
  if rest:match("^%$.*%$$") then
    return tex
  end

  -- Skip cells that are plain text (no backslashes at all)
  if not rest:find("\\") then
    return tex
  end

  -- Process through Pandoc + our filter
  local inlines = parse_inlines_walk(rest)
  if not inlines or #inlines == 0 then return tex end

  -- Render inlines to HTML
  local doc = pandoc.Pandoc({ pandoc.Plain(inlines) })
  local html = pandoc.write(doc, "html")

  -- pandoc.write wraps in <p>...</p> — strip that
  html = html:gsub("^%s*<p>", ""):gsub("</p>%s*$", "")

  -- Trim trailing whitespace/newlines
  html = html:gsub("%s+$", "")

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

  -- Normalize: add \\ after rule markers (same as figure_to_html.lua)
  -- so that splitting on \\ gives clean rows
  inner = inner:gsub("\\toprule", "\\toprule\\\\")
               :gsub("\\midrule", "\\midrule\\\\")
               :gsub("\\bottomrule", "\\bottomrule\\\\")
  if not inner:find("\\\\%s*$") then inner = inner .. "\\\\" end

  -- Process row by row: split on \\
  local result = {}
  local pos = 1
  local inner_len = #inner

  while pos <= inner_len do
    -- Find next \\
    local bs_start, bs_end = inner:find("\\\\", pos, true)
    local row_text
    if bs_start then
      row_text = inner:sub(pos, bs_start - 1)
      pos = bs_end + 1
    else
      row_text = inner:sub(pos)
      pos = inner_len + 1
    end

    local trimmed = trim(row_text)

    -- Skip structural markers and empty rows — pass through as-is
    if trimmed == "\\toprule" or trimmed == "\\midrule" or trimmed == "\\bottomrule"
       or trimmed == "" then
      table.insert(result, row_text)
    else
      -- Split cells on & (respecting brace depth)
      local cells = {}
      local buf = {}
      local depth = 0
      for i = 1, #row_text do
        local ch = row_text:sub(i, i)
        if ch == "{" then
          depth = depth + 1
          table.insert(buf, ch)
        elseif ch == "}" then
          depth = math.max(0, depth - 1)
          table.insert(buf, ch)
        elseif ch == "&" and depth == 0 then
          table.insert(cells, table.concat(buf))
          buf = {}
        else
          table.insert(buf, ch)
        end
      end
      table.insert(cells, table.concat(buf))

      -- Process each cell
      for i, cell in ipairs(cells) do
        cells[i] = render_cell_tex_to_html(cell)
      end

      table.insert(result, table.concat(cells, "&"))
    end

    -- Re-add the \\ delimiter if we consumed one
    if bs_start then
      table.insert(result, "\\\\")
    end
  end

  return env_begin .. table.concat(result) .. env_end
end


-- Parse polydata body "Key & Value \\" lines → table
local function parse_polydata_body(body)
  local map = {}
  for line in (body .. "\n"):gmatch("([^\n\r]+)\n") do
    local clean = line:gsub("%%.*$", ""):gsub("\\\\%s*$", "")
    local k, v = clean:match("^%s*([^&]-)%s*&%s*(.-)%s*$")
    if k and v and k ~= "" and v ~= "" then map[trim(k)] = trim(v) end
  end
  return map
end

function parse_name(s)
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
  local full_name = trim(main_part:sub(2, -2))
  local display_text = ""

  if opt_part then
    -- If optional argument exists, use it directly for display
    display_text = trim(opt_part:sub(2, -2))
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
            table.insert(hyphen_parts, hp:sub(1, 1) .. ".")
          end
          table.insert(first_abbrevs, table.concat(hyphen_parts, "-"))
        else
          -- Simple first/middle name - just take first letter
          table.insert(first_abbrevs, name_part:sub(1, 1) .. ".")
        end
      end

      -- Join abbreviated first names with spaces, then add last name
      display_text = table.concat(first_abbrevs, " ") .. " " .. last_name
    end
  end

  -- Construct the search query using the Full Name
  local search_query = full_name:gsub(" ", "+") .. "+mathematics"
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
  local widthString = "auto"

  if opt and opt ~= "" then
    -- TODO parse more options
    local num = opt:match("width%s*=%s*([%d]*%.?%d+)%s*\\%a+")
    if num then
      local f = tonumber(num)
      if f and f > 0 then
        local p = math.floor(f * 100 + 0.5)
        widthString = tostring(p) .. "%"
      end
    end
    styleVal = "width:" .. widthString .. ";"
  end

  local kvs = { { "style", styleVal } }
  if source_loc ~= "" then
    kvs[#kvs + 1] = { "data-source-loc", source_loc }
  end

  local attr = pandoc.Attr("", {}, kvs)

  return pandoc.Image(pandoc.Str(alt), path, "", attr)
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
  local id, title, description = s:match("\\topiccard%s*(%b{})%s*(%b{})%s*(%b{})")

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
  local extra = ""

  -- Check for optional extra text in citation suffix (e.g., \cite[Thm.~3]{key})
  if el.citations and #el.citations > 0 then
    local suf = pandoc.utils.stringify(el.citations[1].suffix or {})
    if suf ~= "" then extra = suf end
  end

  for _, c in ipairs(el.citations or {}) do
    if c.id and c.id ~= "" then
      -- Strip source location annotation (@@file:line) injected by preprocess
      local cite_loc = c.id:match("@@([%w%.%-_/]+:%d+)$") or ""
      local key = c.id:gsub("@@[%w%.%-_/]+:%d+$", "")
      if cite_loc_first == "" then cite_loc_first = cite_loc end
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
  if extra ~= "" then
    inlines[#inlines + 1] = pandoc.Str(extra)
    inlines[#inlines + 1] = pandoc.Str(", ")
  end
  for i, node in ipairs(cite_parts) do
    if i > 1 then inlines[#inlines + 1] = pandoc.Str(", ") end
    inlines[#inlines + 1] = node
  end
  inlines[#inlines + 1] = pandoc.Str("]")

  local classes = any_missing and { "citeSpan", "missing" } or { "citeSpan" }
  return pandoc.Span(inlines, pandoc.Attr("", classes))
end

function Quoted(el)
  local walked_span = pandoc.walk_inline(pandoc.Span(el.content or {}), make_filter())
  el.content = walked_span.content or {}
  return el
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

  local link_loc = ""
  if type(url) == "string" then
    link_loc = url:match("^#.-@@([%w%.%-_/]+:%d+)$") or ""
    if link_loc ~= "" then
      url = url:gsub("@@[%w%.%-_/]+:%d+$", "")
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

  if url:match("^https?://oeis%.org/") then
    table.insert(el.classes, "oeis")
  elseif url:match("^#") then
    table.insert(el.classes, "hyperref") -- internal anchors
  else
    table.insert(el.classes, "href")     -- generic external link
  end
  record_link(url, text)

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
      record_link(url, id)
      return pandoc.Link({ pandoc.Str(id) }, url, "The On-Line Encyclopedia of Integer Sequences", { "oeis" })
    end
  end

  -- \filelink{path}{label} → Link(label, path), class="dataFile"
  do
    local path, label = s:match("^%s*\\filelink(%b{})(%b{})%s*$")
    if path and label then
      local path_inner = path:sub(2, -2)
      local label_inner = label:sub(2, -2)
      record_link(path_inner, label_inner)
      return pandoc.Link(parse_inlines_walk(label_inner), path_inner, "", { "dataFile" })
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
    if size then
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

  print_warn("Tex Inline string %s is unparsed", s)

  return nil
end

-- Block TeX: meta, family, theorem-like envs, polydata, todo
function RawBlock(el)
  if not el.format:match("tex") then return nil end
  local s = el.text or ""

  -- \bigskip / \medskip / \smallskip
  do
    local size = s:match("^%s*\\(%a-)skip%s*$")
    if size then
      return pandoc.Div({ pandoc.RawInline("html", "&#8203;") }, pandoc.Attr("", { "vskip", size }))
    end
  end

  -- \metatitle{...}
  do
    local mt = s:match("^%s*\\metatitle(%b{})%s*$")
    if mt then
      metatitle = mt:sub(2, -2);
      --print_color(CONSOLE.green, "::: metatitle: %s", metatitle)
      return {}
    end
  end

  -- \metadescription{...}
  do
    local md = s:match("^%s*\\metadescription(%b{})%s*$")
    if md then
      metadesc = md:sub(2, -2);
      --print_color(CONSOLE.green, "::: metadescription: %s", metadesc)
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
      local map = parse_polydata_body(B)
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


  print_warn("Tex Block string %s is unparsed", s)

  return nil
end

-- ===== Finalizer ===========================================================

-- after you’ve built `families` (a list of {id=..., title=...}) and `polydata` (map)
local function _first_n_names_from_families(n)
  local names = {}
  for _, f in ipairs(families or {}) do
    local pd = polydata and polydata[f.id]
    local name = (pd and pd.Name) or f.title or f.id
    names[#names + 1] = name
    if #names == n then break end
  end
  return names
end

local function _clamp_descr(s)
  s = (s or ""):gsub("%s+", " "):match("^%s*(.-)%s*$") or ""
  if #s <= 155 then return s end
  s = s:sub(1, 155):gsub("%s+%S*$", "") .. "…"
  return s
end


-- Make meta info automatically if not specified.
local function synthesize_meta(meta)
  local title = nil
  if #(families or {}) > 0 then
    local names = _first_n_names_from_families(3)
    if #names == 1 then
      title = names[1]
    elseif #names == 2 then
      title = names[1] .. " & " .. names[2]
    else
      title = table.concat({ names[1], names[2] }, ", ") .. " & more"
    end
  end

  local descr = nil
  if #(families or {}) > 0 then
    local count = #families
    local parts = {}
    parts[#parts + 1] = string.format(
      "Overview of %d symmetric-function famil%s",
      count, count == 1 and "y" or "ies"
    )
    local sample = _first_n_names_from_families(3)
    if #sample > 0 then
      parts[#parts + 1] = " including " .. table.concat(sample, ", ")
    end
    descr = _clamp_descr(table.concat(parts, ". ") .. ".")
  end

  if title and (not meta.metatitle or meta.metatitle.t ~= "MetaString") then
    meta.metatitle = pandoc.MetaString(title)
  end
  if descr and (not meta.metadescription or meta.metadescription.t ~= "MetaString") then
    meta.metadescription = pandoc.MetaString(descr)
  end
end



-- ===== Finalizer ===========================================================
function Pandoc(doc)
  local m = doc.meta

  if not metatitle then
    print_warn("Meta title missing")
  else
    m.metatitle = metatitle
  end

  if not metadesc then
    print_warn("Meta description missing")
  else
    m.metadescription = metadesc
  end

  -- Try to invent a description
  synthesize_meta(m)


  m.citations  = set_to_sorted_list(citations)
  m.labels     = set_to_sorted_list(labels)
  m.todos      = todos
  m.families   = families
  m.polydata   = polydata
  
  if #custom_css > 0 then
    m.custom_css = pandoc.MetaString(table.concat(custom_css, "\n"))
  end

  m.sourcestem = pandoc.MetaString(_STEM or "")

  local urls   = {}
  for u, _ in pairs(urls_seen) do urls[#urls + 1] = u end
  table.sort(urls)
  m.urls = urls

  return pandoc.Pandoc(doc.blocks, m)
end
