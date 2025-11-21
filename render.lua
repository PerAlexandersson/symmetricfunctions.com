-- Pure Lua renderer for Pandoc JSON → template HTML

-- The point of this pass, is to make sure all internal
-- links are resolved, and the .bib data is inserted.
-- youngtableau and tabular environments are converted to HTML.
-- Existence of files is also checked here.


local json = require("dkjson")

local utils = dofile("utils.lua")
local trim         = utils.trim
local html_escape  = utils.html_escape
local slugify      = utils.slugify
local CONSOLE      = utils.CONSOLE
local print_warn   = utils.print_warn
local print_info   = utils.print_info
local print_error  = utils.print_error
local load_json    = utils.load_json_file
local json_lib     = utils.json_lib
local file_exists  = utils.file_exists


local bibhandler = dofile("bibhandler.lua")
local build_bibliography_HTML = bibhandler.build_bibliography_HTML

local M = dofile("figure_to_html.lua")
local transform_tex_snippet = M.transform_tex_snippet
local svgimg_to_html        = M.svgimg_to_html

local TEMP_DIR    = os.getenv("TEMP_DIR") or "temp"
local REFS_JSON   = os.getenv("REFS_JSON") or (TEMP_DIR .. "/bibliography.json")
local LABELS_JSON = os.getenv("LABELS_JSON") or (TEMP_DIR .. "/site-labels.json")
local TEMPLATE    = os.getenv("TEMPLATE") or "template.htm"
local WWW_DIR     = os.getenv("WWW_DIR") or "www"
local SOURCE_TS   = os.getenv("SOURCE_TS") or tostring(os.time()) --seconds since 1970


-- Read the global file with all labels
local SITE_LABELS_MAP = load_json(LABELS_JSON, "site-labels")
-- Example entry:
-- SITE_LABELS_MAP["schurS"] = { page = "schur", href = "schur.htm#schurS", title = "Schur polynomials"}


-- --- io helpers ------------------------------------------------------------
local function read_file(path, what)
  local f, err = io.open(path, "r")
  if not f then
    print_error("Could not open %s '%s': %s", what or "file", path, err or "")
    os.stderr:write("\n")
    os.exit(1)
  end
  local s = f:read("*a")
  f:close()
  return s
end



-- Replace -- and --- with correct character
local function typodash(s)
  return (s or ""):gsub("%-%-%-", "—"):gsub("%-%-", "–")
end



local function render_attr(attr)
  -- attr = { id, classes, keyvals }
  local id      = attr[1] or ""
  local classes = attr[2] or {}
  local kvs     = attr[3] or {}

  local out = {}
  if id ~= "" then
    table.insert(out, ' id="' .. html_escape(id) .. '"')
  end
  if #classes > 0 then
    table.insert(out, ' class="' .. table.concat(classes, " ") .. '"')
  end
  for _, kv in ipairs(kvs) do
    local k, v = kv[1], kv[2]
    if k and v and v ~= "" then
      table.insert(out, ' ' .. k .. '="' .. html_escape(v) .. '"')
    end
  end
  return table.concat(out)
end


-- --- inline/block renderers -----------------------------------------------
local function render_inlines_html(inl)

  if type(inl) ~= "table" then return "" end

  local out = {}

  for _, el in ipairs(inl) do
    local t, c = el.t, el.c
    if t == "Str" then
      local s = c
      -- Replace triple dash then double dash (order matters)
      s = s:gsub("%-%-%-", utf8.char(0x2014)):gsub("%-%-",  utf8.char(0x2013))
      table.insert(out, html_escape(s))
    elseif t == "Space" then
      table.insert(out, " ")
    elseif t == "SoftBreak" or t == "LineBreak" then
      table.insert(out, "\n")
    elseif t == "Emph" then
      table.insert(out, "<em>"..render_inlines_html(c).."</em>")
    elseif t == "Strong" then
      table.insert(out, "<strong>"..render_inlines_html(c).."</strong>")
    elseif t == "Code" then
      local code = c[2] or c.code or ""
      table.insert(out, "<code>"..html_escape(code).."</code>")
    elseif t == "Math" then
      local kind = c[1].t
      local body = c[2] or ""
      table.insert(out, (kind == "DisplayMath") and ("\\["..body.."\\]") or ("\\("..body.."\\)"))

    -----------------------------------------

    elseif t == "Link" then
      local attr   = c[1] or {"",{},{}}
      local inl    = c[2] or {}
      local target = c[3]
      local url, title = "#", ""

      -- Decode target (Pandoc 2.x/3.x can use string or table)
      if type(target) == "table" then
        url   = target[1] or target.url or "#"
        title = target[2] or ""
      elseif type(target) == "string" then
        url = target
      end

      local text = render_inlines_html(inl)

      -- Inspect classes
      local classes = attr[2] or {}
      local is_hyperref = false
      for _, cls in ipairs(classes) do
        if cls == "hyperref" then
          is_hyperref = true
          break
        end
      end

      -- Rewrite links with hyperref class to interpage links via SITE_LABELS_MAP
      if is_hyperref then
        -- Expect things like "#label" or "label"
        local label = tostring(url or ""):gsub("^#", "")
        local entry = SITE_LABELS_MAP[label]

        if not entry then
          -- Label never defined anywhere
          print_error("Internal link to unknown label '%s' (text: %s)", label, text)
          -- leave url as-is ("#label") so it degrades gracefully
          url = "#" .. label
        else
          -- entry.href already looks like "page.htm#label"
          url = entry.href or ("#" .. label)
        end
      end

      local attr_html = render_attr(attr)
      if title ~= "" then
        attr_html = attr_html .. ' title="'..html_escape(title)..'"'
      end
      table.insert(out,
        '<a href="'..html_escape(url)..'"'..attr_html..'>'..html_escape(text)..'</a>'
      )
-----------------------------------------


    elseif t == "RawInline" then
      if type(c) == "table" then
        local fmt, body = c[1], c[2]
        if fmt and fmt:match("latextable") then
          local latexTableHTML = transform_tex_snippet(body)
          table.insert(out, latexTableHTML)
        elseif fmt and fmt:match("tex") then
          print_error("TEX still present: %s", body)
        else
          table.insert(out, body or "")
        end
      else
        table.insert(out, c or "")
      end

    elseif t == "Span" then
      local attr = c[1] or {"", {}, {}}
      local inl  = c[2] or {}

      local id      = attr[1] or ""
      local classes = attr[2] or {}
      local kvs     = attr[3] or {}

      -- Check if this is one of our icon spans
      local is_icon = false
      for _, cls in ipairs(classes) do
        if cls == "icon" then
          is_icon = true
          break
        end
      end


      if is_icon then
        -- Extract data-icon and optional data-style
        local icon_name, icon_style
        for _, kv in ipairs(kvs) do
          local k, v = kv[1], kv[2]
          if k == "data-icon"  then icon_name  = v end
          if k == "data-style" then icon_style = v end
        end

        icon_style = icon_style or "regular"
        local fa_style
        if     icon_style == "solid"  then fa_style = "fas"
        elseif icon_style == "light"  then fa_style = "fal"
        elseif icon_style == "duotone" then fa_style = "fad"
        else  fa_style = "fas"  -- default: solid
        end

        if icon_name then
          -- Render as Font Awesome <i> element
          table.insert(out,
            string.format('<i class="%s fa-%s" aria-hidden="true"></i>',fa_style, icon_name)
          )
        else
          -- No data-icon? Fallback to normal <span>
          local inner = render_inlines_html(inl)
          table.insert(out, "<span" .. render_attr(attr) .. ">" .. inner .. "</span>")
        end
      else
        -- Normal span behaviour
        local inner = render_inlines_html(inl)
        table.insert(out, "<span" .. render_attr(attr) .. ">" .. inner .. "</span>")
      end
  
    elseif t == "Quoted" then
      table.insert(out, "<q>" .. render_inlines_html(c[2] or {}) .. "</q>")
    elseif t == "Cite" then
      table.insert(out, render_inlines_html(c[2] or {}))
    elseif t == "Image" then

      local attr    = c[1] or {"", {}, {}}
      local caption = c[2] or {}
      local target  = c[3]

      -- Decode target: can be string or {src, title}
      local src, title = "", ""
      if type(target) == "table" then
        src   = target[1] or target.src or ""
        title = target[2] or target.title or ""
      elseif type(target) == "string" then
        src = target
      end

      captionHTML = render_inlines_html(caption)

      if src ~= "" then
        if not file_exists(WWW_DIR .. "/" .. src) then
          print_error("Image file not found: %s", src)
        end
      else
        print_error("Image with src (caption: %s)", captionHTML)
      end
     
      local attr_html = render_attr(attr)

      --print_info("Image found (with opt): %s | %s | %s ", captionHTML, src, attr_html)

       table.insert(out,
        string.format('<img src="%s" title="%s" alt="%s" %s/>',
          src,
          captionHTML,
          captionHTML,
          attr_html
        ))
    else
      print_error("Exotic inline: %s", t)
    end
  end
  return table.concat(out)
end


local function render_blocks_html(blocks, header_collector)
  local buf = {}
  for _, b in ipairs(blocks or {}) do
    local t, c = b.t, b.c

    if t == "Para" or t == "Plain" then
      table.insert(buf, "<p>"..render_inlines_html(c).."</p>\n")

    elseif t == "Header" then
      local level, attrs, inl = c[1], (c[2] or {"",{},{} }), (c[3] or {})

      -- Ensure we have an id (Pandoc usually gives one)
      local id = attrs[1]
      if (not id) or id == "" then
        -- Build a slug from visible text
        print_error("Header missing ID")
        local labeltxt = {}
        for _, x in ipairs(inl) do
          if 
            x.t == "Str" then table.insert(labeltxt, x.c)
          end
        end
        id = slugify(table.concat(labeltxt, ""))
        attrs[1] = id
      end

      --TODO REFACTOR A BIT HERE!
      -- Section to heading tag
      local tag = ("h" .. tostring(level))

      if header_collector then
        -- plain text for TOC entry
        local txt = {}
        for _, x in ipairs(inl) do
          if x.t == "Str" then 
            table.insert(txt, x.c)
          elseif x.t == "Space" then 
            table.insert(txt, " ")
          elseif x.t == "Math" then
            local body = x.c[2] or ""
            table.insert(txt, body)
          end
        end
        header_collector(level, id, table.concat(txt))
      end
      --Insert the H-tag
      table.insert(buf, "<"..tag..render_attr(attrs)..">"..render_inlines_html(inl).."</"..tag..">\n")

    elseif t == "CodeBlock" then
      table.insert(buf, "<pre><code>"..html_escape(c[2] or "").."</code></pre>\n")
    elseif t == "BlockQuote" then
      table.insert(buf, "<blockquote>"..render_blocks_html(c).."</blockquote>\n")
    elseif t == "BulletList" then
      local items = {}
      for _, itemBlocks in ipairs(c) do
        table.insert(items, "<li>"..render_blocks_html(itemBlocks).."</li>")
      end
      table.insert(buf, "<ul>"..table.concat(items).."</ul>")
    elseif t == "OrderedList" then
      local items = c[2] or {}
      local lis = {}
      for _, itemBlocks in ipairs(items) do
        table.insert(lis, "<li>"..render_blocks_html(itemBlocks).."</li>")
      end
      table.insert(buf, "<ol>"..table.concat(lis).."</ol>")
    elseif t == "HorizontalRule" then
      table.insert(buf, "<hr/>")
    elseif t == "Div" then
      local attr = c[1] or {"",{},{}}
      local classes = attr[2] or {}
      local is_env = false
      local is_collapsible = false
      for _,cls in ipairs(classes) do
        if cls == "env" then is_env = true end
        if cls == "collapsible" then is_collapsible = true end
      end

      if is_env and is_collapsible then
        -- expect first block to be the heading we tagged as env-head
        local kids = c[2] or {}
        local head = kids[1]
        local rest = {}
        for i=2,#kids do rest[#rest+1] = kids[i] end

        -- render heading inlines WITHOUT wrapping <p> (summary can't contain a <p>)
        local head_html = ""
        if head and head.t == "Para" then
          head_html = render_inlines_html(head.c or {})
        elseif head and head.t == "Plain" then
          head_html = render_inlines_html(head.c or {})
        end

        local open = '<details'..render_attr(attr)..'>'
        -- drop env-head marker class from summary output CSS if you want, no harm keeping it
        local summary = '<summary>'..head_html..'</summary>'
        local body = render_blocks_html(rest)
        local close = '</details>'
        table.insert(buf, open..summary..body..close)
      else
        -- default <div> rendering
        local inner = render_blocks_html(c[2] or {})
        table.insert(buf, "<div"..render_attr(attr)..">"..inner.."</div>")
      end
    elseif t == "RawBlock" then
      local fmt, body = c[1], c[2]

      if fmt and fmt:match("latextable") then
        -- print_error("Render: Must parse %s", (body or ""):match("([^\n\r]*)"))
        local latexTableHTML = transform_tex_snippet(body)
        table.insert(buf,latexTableHTML)
      elseif fmt and fmt:match("tex") then
        print_error("Render: Unknown tex: %s", (body or ""):match("([^\n\r]*)"))
      else
        table.insert(buf, "<pre>"..html_escape(body or "").."</pre>")
        print_error("Render: Unknown tex: %s", (body or ""):match("([^\n\r]*)"))
      end

    else
      -- ignore exotic blocks (tables, figures, etc.) for now
      print_error("Render: Unhandled block type: %s", t)
    end
  end
  return table.concat(buf)
end



-- --- main ------------------------------------------------------------------

--TODO-can this be made nicer?
local function read_json_input()
  if arg and arg[1] and arg[1] ~= "-" then
    local doc = load_json(arg[1], "JSON data")
    if not doc or next(doc) == nil then
      print_error("JSON decode error reading %s", arg[1])
      os.exit(1)
    end
    return doc
  end

  local doc, _, err = json_lib.decode(io.read("*a"))
  if not doc or type(doc) ~= "table" then
    print_error("JSON decode error: %s", tostring(err))
    os.exit(1)
  end
  return doc
end

local pandoc_doc = read_json_input()


local meta = pandoc_doc.meta or {}
-- handle MetaString wrappers or plain strings
local function mget(m, key, fallback)
  local v = m[key]
  if type(v) == "table" and v.t == "MetaString" then return v.c end
  return v or fallback
end


local title     = mget(meta, "metatitle", "Untitled")
local desc      = mget(meta, "metadescription", title)
local canonical = mget(meta, "canonical", "index.htm")
local citations = meta.citations and (meta.citations.c or meta.citations) or {}
local labels    = meta.labels and (meta.labels.c or meta.labels) or {}
local families  = meta.families or {}


-- derive keywords
local keywords_list = {}
local function push_kw(x) if type(x) == "string" and x ~= "" then table.insert(keywords_list, x) end end
for _, f in ipairs(families) do
  if type(f) == "table" then
    push_kw(f.id or (f.c and f.c.id))
    push_kw(f.title or (f.c and f.c.title))
  end
end
for _, lab in ipairs(labels) do push_kw(type(lab)=="table" and lab.c or lab) end
local keywords = (#keywords_list>0) and table.concat(keywords_list, ", ") or title


-- render body + toc
local toc_items = {}
local function collect_header(level, id, text)
  if not id or id == "" then
    return
  end

  local lvlstr = ""
  if level == 2 then
    lvlstr = "section"
  elseif level == 3 then
    lvlstr = "subsection"
  end

  table.insert(
    toc_items,string.format(
    '<li><a href="#%s" class="' .. lvlstr .. '">%s</a></li>\n', id, (text or "")
    ))
end


-- Create main HTML, and while at it, collect stuff for TOC
local html_body = render_blocks_html(pandoc_doc.blocks or {}, collect_header)

-- Insert Bibliography link in navigation
if #toc_items>0 then
  table.insert(
    toc_items,
    '<li><a href="#bibliography" class="section">Bibliography</a></li>\n'
  )
end

local sidelinks_str = table.concat(toc_items, "\n")
local cite_html = build_bibliography_HTML(REFS_JSON, citations)
local lastmod = os.date("%Y-%m-%d", tonumber(SOURCE_TS))
local tpl = read_file(TEMPLATE,"html template")

local document_contents = {
  TITLE       = html_escape(title),
  DESCRIPTION = html_escape(desc),
  CANONICAL   = html_escape(canonical),
  SIDELINKS   = sidelinks_str,
  LASTMOD     = string.format(
                  '<time class="dateMod" datetime="%s">%s</time>',
                  lastmod, lastmod
                ),
  MAIN        = html_body,
  REFERENCES  = cite_html,
}
local used = {}

tpl = tpl:gsub("<!%-%-([A-Z_]+)%-%->", function(name)
  local val = document_contents[name]
  if not val then
    -- Template has a placeholder we don't know about → hard error.
    print_error("Unknown placeholder in template: <!--%s-->", name)
  end
  used[name] = true
  return val
end)


print(tpl)