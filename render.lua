-- Pure Lua renderer for Pandoc JSON → template HTML
--
-- This module converts Pandoc's JSON AST into HTML, handling:
-- - Internal link resolution via site-wide label map
-- - Bibliography insertion from .bib data
-- - LaTeX table environments (ytableau, tabular, etc.) → HTML tables
-- - File existence validation for images
-- - Table of contents generation from headers
-- - Lazy template placeholder evaluation
-- - Injection of custom CSS variables defined in LaTeX

-- ========== DEPENDENCIES ==========

local bibhandler   = dofile("bibhandler.lua")
local file_reading = dofile("file_reading.lua")
local fig_to_html  = dofile("figure_to_html.lua")
local poly_to_html = dofile("polydata_to_html.lua")

local utils        = dofile("utils.lua")
local html_escape  = utils.html_escape
local slugify      = utils.slugify
local print_warn   = utils.print_warn
local print_info   = utils.print_info
local print_error  = utils.print_error

local transform_tex_snippet = fig_to_html.transform_tex_snippet


-- ========== CONFIGURATION ==========

local TEMP_DIR      = os.getenv("TEMP_DIR") or "temp"
local REFS_JSON     = os.getenv("REFS_JSON") or (TEMP_DIR .. "/bibliography.json")
local LABELS_JSON   = os.getenv("LABELS_JSON") or (TEMP_DIR .. "/site-labels.json")
local POLYDATA_JSON = os.getenv("POLYDATA_JSON") or (TEMP_DIR .. "/site-polydata.json")
local TEMPLATE      = os.getenv("TEMPLATE") or "template.htm"
local WWW_DIR       = os.getenv("WWW_DIR") or "www"
local SOURCE_TS     = os.getenv("SOURCE_TS") or tostring(os.time())

-- Site-wide label mapping for cross-page references
local SITE_LABELS_MAP = file_reading.load_json_file(LABELS_JSON, "site-labels")


-- ========== CONSTANTS ==========

-- Unicode characters for typography
local EM_DASH = utf8.char(0x2014)  -- —
local EN_DASH = utf8.char(0x2013)  -- –


-- ========== UTILITY FUNCTIONS ==========

--- Renders Pandoc attributes as HTML attribute string.
local function render_attr(attr)
  local id      = attr[1] or ""
  local classes = attr[2] or {}
  local kvs     = attr[3] or {}

  local parts = {}
  
  if id ~= "" then
    table.insert(parts, ' id="' .. html_escape(id) .. '"')
  end
  
  if #classes > 0 then
    table.insert(parts, ' class="' .. table.concat(classes, " ") .. '"')
  end
  
  for _, kv in ipairs(kvs) do
    local k, v = kv[1], kv[2]
    if k and v and v ~= "" then
      table.insert(parts, ' ' .. k .. '="' .. html_escape(v) .. '"')
    end
  end
  
  return table.concat(parts)
end


--- Extracts key-value pairs from Pandoc attributes.
local function extract_keyvals(kvs)
  local result = {}
  for _, kv in ipairs(kvs or {}) do
    local k, v = kv[1], kv[2]
    if k then
      result[k] = v
    end
  end
  return result
end


--- Checks if an array contains a specific value.
local function array_contains(arr, val)
  for _, v in ipairs(arr) do
    if v == val then
      return true
    end
  end
  return false
end


-- ========== INLINE ELEMENT RENDERERS ==========

local render_inlines_html
local render_blocks_html

--- DEPRECATED: Renders an icon span as Font Awesome element.
local function render_icon(kvs)
  local kv_map = extract_keyvals(kvs)
  local icon_name = kv_map["data-icon"]
  local icon_style = kv_map["data-style"] or "solid"
  
  if not icon_name then return nil end
  
  print_error("Font Awesome is not supported! %s", icon_name)

  local fa_style = ICON_STYLES[icon_style] or "fas"
  return string.format('<i class="%s fa-%s" aria-hidden="true"></i>', fa_style, icon_name)
end


--- Renders a link element, handling internal cross-references.
local function render_link(attr, inlines, target)
  local url, title = "#", ""
  
  if type(target) == "table" then
    url   = target[1] or target.url or "#"
    title = target[2] or ""
  elseif type(target) == "string" then
    url = target
  end
  
  local link_inner_html = render_inlines_html(inlines)
  local classes = attr[2] or {}
  
  -- Handle internal cross-references with .hyperref class
  if array_contains(classes, "hyperref") then
    local label = tostring(url or ""):gsub("^#", "")
    local entry = SITE_LABELS_MAP[label]
    
    if not entry then
      print_error("hyperref to unknown label '%s' (text: %s)", label, link_inner_html)
      url = "#" .. label
    else
      url = entry.href or ("#" .. label)
    end
  end
  
  local attr_html = render_attr(attr)
  if title ~= "" then
    attr_html = attr_html .. ' title="' .. html_escape(title) .. '"'
  end
  
  return '<a href="' .. html_escape(url) .. '"' .. attr_html .. '>' .. link_inner_html .. '</a>'
end


--- Renders an image element with validation.
local function render_image(attr, caption, target)
  local src, title = "", ""
  
  if type(target) == "table" then
    src   = target[1] or target.src or ""
    title = target[2] or target.title or ""
  elseif type(target) == "string" then
    src = target
  end
  
  local captionHTML = render_inlines_html(caption)
  
  if src ~= "" then
    if not file_reading.file_exists(WWW_DIR .. "/" .. src) then
      print_error("Image file not found: %s", src)
    end
  else
    print_error("Image missing src (caption: %s)", captionHTML)
  end
  
  local attr_html = render_attr(attr)

  return string.format(
    '<img src="%s" title="%s" alt="%s" %s/>',
    src,
    captionHTML,
    captionHTML,
    attr_html
  )
end


--- Renders a LaTeX table inline element.
local function render_latex_table_inline(body)
  local html, err = transform_tex_snippet(body)
  if err then
    print_error("Failed to convert LaTeX table (inline): %s", err)
    return "<code class='tex-error'>" .. html_escape(body) .. "</code>"
  end
  return html
end


--- Renders Pandoc inline elements to HTML.
function render_inlines_html(inlines)
  if type(inlines) ~= "table" then return "" end

  local buffer = {}

  for _, el in ipairs(inlines) do
    local t, c = el.t, el.c
    
    if t == "Str" then
      local s = c:gsub("%-%-%-", EM_DASH):gsub("%-%-", EN_DASH)
      table.insert(buffer, html_escape(s))
      
    elseif t == "Space" then
      table.insert(buffer, " ")
      
    elseif t == "SoftBreak" or t == "LineBreak" then
      table.insert(buffer, "\n")
      
    elseif t == "Emph" then
      table.insert(buffer, "<em>" .. render_inlines_html(c) .. "</em>")
      
    elseif t == "Strong" then
      table.insert(buffer, "<strong>" .. render_inlines_html(c) .. "</strong>")
   
--   --TODO: make expandable.
--     <details class="code-details">
--   <summary>script.py</summary>
  
--   <pre><code>def hello():
--     print("Hello World")</code></pre>
-- </details>
    elseif t == "Code" then
      local code = c[2] or c.code or ""
      table.insert(buffer, "<code>" .. html_escape(code) .. "</code>")
      

    elseif t == "Math" then
      local kind = c[1].t
      local body = c[2] or ""
      local delim = (kind == "DisplayMath") and {"\\[", "\\]"} or {"\\(", "\\)"}
      table.insert(buffer, delim[1] .. body .. delim[2])
      
    elseif t == "Link" then
      table.insert(buffer, render_link(c[1], c[2], c[3]))
      
    elseif t == "RawInline" then
      if type(c) == "table" then
        local fmt, body = c[1], c[2]
        if fmt and fmt:match("latextable") then
          table.insert(buffer, render_latex_table_inline(body))
        elseif fmt and fmt:match("tex") then
          print_error("TEX still present: %s", body)
        else
          table.insert(buffer, body or "")
        end
      else
        table.insert(buffer, c or "")
      end
      
    elseif t == "Span" then
      local attr = c[1] or { "", {}, {} }
      local inl  = c[2] or {}
      local classes = attr[2] or {}
      local kvs = attr[3] or {}
      
      if array_contains(classes, "icon") then
        local icon_html = render_icon(kvs)
        if icon_html then
          table.insert(buffer, icon_html)
        else
          table.insert(buffer, "<span" .. render_attr(attr) .. ">" .. render_inlines_html(inl) .. "</span>")
        end
      else
        table.insert(buffer, "<span" .. render_attr(attr) .. ">" .. render_inlines_html(inl) .. "</span>")
      end
      
    elseif t == "Quoted" then
      table.insert(buffer, "<q>" .. render_inlines_html(c[2] or {}) .. "</q>")
      
    elseif t == "Cite" then
      table.insert(buffer, render_inlines_html(c[2] or {}))
      
    elseif t == "Image" then
      table.insert(buffer, render_image(c[1], c[2], c[3]))
      
    else
      print_error("Unhandled inline type: %s", t)
    end
  end
  
  return table.concat(buffer)
end


-- ========== BLOCK ELEMENT RENDERERS ==========

--- Renders a collapsible environment (details/summary).
local function render_collapsible(attr, blocks)
  local head = blocks[1]
  local rest = {}
  for i = 2, #blocks do rest[#rest + 1] = blocks[i] end
  
  local head_html = ""
  if head and (head.t == "Para" or head.t == "Plain") then
    head_html = render_inlines_html(head.c or {})
  end
  
  local parts = {
    '<details' .. render_attr(attr) .. '>',
    '<summary>' .. head_html .. '</summary>',
    render_blocks_html(rest),
    '</details>'
  }
  return table.concat(parts)
end


--- Renders a LaTeX table block element.
local function render_latex_table_block(body)
  local html, err = transform_tex_snippet(body)
  if err then
    print_error("Failed to convert LaTeX table (block): %s", err)
    return "<pre class='tex-error'>" .. html_escape(body) .. "</pre>\n"
  end
  return html
end


--- Extracts plain text from inline elements (for TOC).
local function extract_text_from_inlines(inlines)
  local parts = {}
  for _, x in ipairs(inlines) do
    if x.t == "Str" then table.insert(parts, x.c)
    elseif x.t == "Space" then table.insert(parts, " ")
    elseif x.t == "Math" and x.c[2] then table.insert(parts, "\\(" .. x.c[2] .. "\\)")
    end
  end
  return table.concat(parts)
end


--- Renders a header element.
local function render_header(level, attr, inlines, header_collector)
  local id = attr[1]
  if (not id) or id == "" then
    print_error("Header missing ID")
    local text_parts = {}
    for _, x in ipairs(inlines) do
      if x.t == "Str" then table.insert(text_parts, x.c) end
    end
    id = slugify(table.concat(text_parts, ""))
    attr[1] = id
  end
  
  if header_collector then
    local text = extract_text_from_inlines(inlines)
    header_collector(level, id, text)
  end
  
  local tag = "h" .. tostring(level)
  return "<" .. tag .. render_attr(attr) .. ">" .. render_inlines_html(inlines) .. "</" .. tag .. ">\n"
end


--- Renders Pandoc block elements to HTML.
function render_blocks_html(blocks, header_collector)
  local buffer = {}
  
  for _, b in ipairs(blocks or {}) do
    local t, c = b.t, b.c
    
    if t == "Para" or t == "Plain" then
      table.insert(buffer, "<p>" .. render_inlines_html(c) .. "</p>\n")
      
    elseif t == "Header" then
      local level = c[1]
      local attr = c[2] or { "", {}, {} }
      local inlines = c[3] or {}
      table.insert(buffer, render_header(level, attr, inlines, header_collector))
      
    elseif t == "CodeBlock" then
      table.insert(buffer, "<pre><code>" .. html_escape(c[2] or "") .. "</code></pre>\n")
      
    elseif t == "BlockQuote" then
      table.insert(buffer, "<blockquote>" .. render_blocks_html(c) .. "</blockquote>\n")
      
    elseif t == "BulletList" then
      local items = {}
      for _, itemBlocks in ipairs(c) do
        table.insert(items, "<li>" .. render_blocks_html(itemBlocks) .. "</li>")
      end
      table.insert(buffer, "<ul>" .. table.concat(items) .. "</ul>")
      
    elseif t == "OrderedList" then
      local items = c[2] or {}
      local list_items = {}
      for _, itemBlocks in ipairs(items) do
        table.insert(list_items, "<li>" .. render_blocks_html(itemBlocks) .. "</li>")
      end
      table.insert(buffer, "<ol>" .. table.concat(list_items) .. "</ol>")
      
    elseif t == "HorizontalRule" then
      table.insert(buffer, "<hr/>")
      
    elseif t == "Div" then
      local attr = c[1] or { "", {}, {} }
      local classes = attr[2] or {}
      
      -- Check for special page divs
      if array_contains(classes, "specialblock") then
        local kvs = attr[3] or {} 
        local kv_map = extract_keyvals(kvs)
        local block_type = kv_map["data-type"]

        if block_type and block_type == "polynomialList" then
          local polydata = file_reading.load_json_file(POLYDATA_JSON)
          if polydata then
            local poly_list_html = poly_to_html.render_polynomial_table(polydata) or ""
            table.insert(buffer, poly_list_html )
          else 
            print_error("Could not open %s",POLYDATA_JSON)
          end
        else
          print_error("specialblock div missing data-type attribute")
        end
      end

      -- Check for collapsible divs
      if array_contains(classes, "collapsible") then
        table.insert(buffer, render_collapsible(attr, c[2] or {}))
      else
        local inner = render_blocks_html(c[2] or {})
        table.insert(buffer, "<div" .. render_attr(attr) .. ">" .. inner .. "</div>")
      end
      
    elseif t == "RawBlock" then
      local fmt, body = c[1], c[2]
      if fmt and fmt:match("latextable") then
        table.insert(buffer, render_latex_table_block(body))
      elseif fmt and fmt:match("tex") then
        print_error("Render: Unknown tex: %s", (body or ""):match("([^\n\r]*)"))
      else
        table.insert(buffer, "<pre>" .. html_escape(body or "") .. "</pre>")
        print_error("Render: Unknown raw block format: %s", fmt or "nil")
      end
      
    else
      print_error("Render: Unhandled block type: %s", t)
    end
  end
  
  return table.concat(buffer)
end


-- ========== METADATA EXTRACTION ==========

local function get_meta(meta, key, fallback)
  local v = meta[key]
  if type(v) == "table" and v.t == "MetaString" then 
    return v.c 
  end
  return v or fallback
end


-- ========== TABLE OF CONTENTS ==========

local function create_toc_collector()
  local toc_items = {}
  local function collector(level, id, text)
    if not id or id == "" then return end
    local css_class = ""
    if level == 2 then css_class = "section"
    elseif level == 3 then css_class = "subsection" end
    table.insert(toc_items, string.format('<li><a href="#%s" class="%s">%s</a></li>\n', id, css_class, text or ""))
  end
  return collector, toc_items
end

local function build_toc_html(toc_items, has_citations)
  if #toc_items == 0 and not has_citations then return "" end
  local items = {}
  for _, item in ipairs(toc_items) do table.insert(items, item) end
  if has_citations then
    table.insert(items, '<li><a href="#bibliography" class="section">Bibliography</a></li>\n')
  end
  return table.concat(items)
end


-- ========== BIBLIOGRAPHY ==========

local function build_bibliography_html(refs_json_path, citations)
  if not citations or #citations == 0 then return "" end
  return bibhandler.build_bibliography_HTML(refs_json_path, citations)
end


-- ========== METADATA FORMATTING ==========

local function format_lastmod_html(timestamp)
  local date = os.date("%Y-%m-%d", tonumber(timestamp))
  return string.format('<time class="dateMod" datetime="%s">%s</time>', date, date)
end


-- ========== LAZY TEMPLATE EVALUATION ==========

local function lazy(fn)
  return { _lazy = true, _fn = fn, _computed = false, _value = nil }
end

local function resolve_value(value)
  if type(value) == "table" and value._lazy then
    if not value._computed then
      value._value = value._fn()
      value._computed = true
    end
    return value._value
  end
  return value
end


-- ========== TEMPLATE RENDERING ==========

local function render_template(template, content)
  local used = {}
  -- Modified regex allows hyphens in placeholders (e.g. )
  local result = template:gsub("<!%-%-([A-Z_%-]+)%-%->", function(name)
    local val = content[name]
    if not val then
      print_error("Unknown placeholder in template: ", name)
      return ""
    end
    used[name] = true
    return resolve_value(val) or ""
  end)
  
  for name, val in pairs(content) do
    if not used[name] and type(val) == "table" and val._lazy and val._computed then
      print_warn("Computed lazy value '%s' was never used in template", name)
    end
  end
  return result
end


-- ========== MAIN EXECUTION ==========

local filename = arg[1];
local pandoc_doc = file_reading.load_json_file(filename, "json pandoc document")

-- Extract metadata
local meta      = pandoc_doc.meta or {}
local title     = get_meta(meta, "metatitle", "Untitled")
local desc      = get_meta(meta, "metadescription", title)
local canonical = get_meta(meta, "canonical", "index.htm")
local citations = meta.citations and (meta.citations.c or meta.citations) or {}
local custom_css= get_meta(meta, "custom_css", "")

-- Render body
local collect_header, toc_items = create_toc_collector()
local html_body = render_blocks_html(pandoc_doc.blocks or {}, collect_header)
local has_citations = (citations and #citations > 0)

-- Load template
local template = file_reading.read_file(TEMPLATE, "html template")

local document_content = {
  TITLE       = html_escape(title),
  DESCRIPTION = html_escape(desc),
  CANONICAL   = html_escape(canonical),
  LASTMOD     = format_lastmod_html(SOURCE_TS),
  MAIN        = html_body,
  
  SIDELINKS = lazy(function()
    return build_toc_html(toc_items, has_citations)
  end),
  
  REFERENCES = lazy(function()
    return build_bibliography_html(REFS_JSON, citations)
  end),

  -- Inject CSS variables captured in gather.lua
  STYLE = lazy(function()
    if custom_css and custom_css ~= "" then
      return ":root {\n" .. custom_css .. "\n}"
    else
      return ""
    end
  end),
}

-- Render and output
local final_html = render_template(template, document_content)
print(final_html)