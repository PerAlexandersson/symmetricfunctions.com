-- Pure Lua renderer for Pandoc JSON → template HTML
--
-- This module converts Pandoc's JSON AST into HTML, handling:
-- - Internal link resolution via site-wide label map
-- - Bibliography insertion from .bib data
-- - LaTeX table environments (ytableau, tabular, etc.) → HTML tables
-- - File existence validation for images
-- - Table of contents generation from headers
--
-- Environment variables:
--   TEMP_DIR    - Directory for intermediate files (default: "temp")
--   REFS_JSON   - Path to bibliography JSON (default: temp/bibliography.json)
--   LABELS_JSON - Path to site labels JSON (default: temp/site-labels.json)
--   TEMPLATE    - HTML template file (default: "template.htm")
--   WWW_DIR     - Output directory (default: "www")
--   SOURCE_TS   - Source timestamp in seconds (default: current time)

-- ========== DEPENDENCIES ==========

local bibhandler   = dofile("bibhandler.lua")
local file_reading = dofile("file_reading.lua")
local fig_to_html  = dofile("figure_to_html.lua")

local utils        = dofile("utils.lua")
local html_escape  = utils.html_escape
local slugify      = utils.slugify
local print_warn   = utils.print_warn
local print_info   = utils.print_info
local print_error  = utils.print_error

local transform_tex_snippet = fig_to_html.transform_tex_snippet


-- ========== CONFIGURATION ==========

local TEMP_DIR    = os.getenv("TEMP_DIR") or "temp"
local REFS_JSON   = os.getenv("REFS_JSON") or (TEMP_DIR .. "/bibliography.json")
local LABELS_JSON = os.getenv("LABELS_JSON") or (TEMP_DIR .. "/site-labels.json")
local TEMPLATE    = os.getenv("TEMPLATE") or "template.htm"
local WWW_DIR     = os.getenv("WWW_DIR") or "www"
local SOURCE_TS   = os.getenv("SOURCE_TS") or tostring(os.time())

-- Site-wide label mapping for cross-page references
-- Example entry: SITE_LABELS_MAP["schurS"] = { 
--   page = "schur", 
--   href = "schur.htm#schurS", 
--   title = "Schur polynomials"
-- }
local SITE_LABELS_MAP = file_reading.load_json_file(LABELS_JSON, "site-labels")


-- ========== CONSTANTS ==========

-- Unicode characters for typography
local EM_DASH = utf8.char(0x2014)  -- —
local EN_DASH = utf8.char(0x2013)  -- –

-- Font Awesome style mappings
local ICON_STYLES = {
  solid = "fas",
  light = "fal",
  duotone = "fad",
  regular = "far"
}


-- ========== UTILITY FUNCTIONS ==========

--- Converts double/triple hyphens to proper dash characters.
-- Note: This may be redundant as Pandoc often handles this.
-- @param s string The string to process
-- @return string String with dashes replaced
local function typodash(s)
  return (s or ""):gsub("%-%-%-", "—"):gsub("%-%-", "–")
end


--- Renders Pandoc attributes as HTML attribute string.
-- @param attr table Pandoc attribute triplet: {id, classes, keyvals}
-- @return string HTML attributes string (e.g., ' id="foo" class="bar baz"')
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
-- @param kvs table Array of {key, value} pairs
-- @return table Map of key to value
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
-- @param arr table Array to search
-- @param val any Value to find
-- @return boolean True if value is found
local function array_contains(arr, val)
  for _, v in ipairs(arr) do
    if v == val then
      return true
    end
  end
  return false
end


-- ========== INLINE ELEMENT RENDERERS ==========

-- TODO: Remove fa-dependency
--- Renders an icon span as Font Awesome element.
-- @param kvs table Key-value pairs from attributes
-- @return string HTML <i> element or empty string
local function render_icon(kvs)
  local kv_map = extract_keyvals(kvs)
  local icon_name = kv_map["data-icon"]
  local icon_style = kv_map["data-style"] or "solid"
  
  if not icon_name then
    return nil  -- Not an icon, render as normal span
  end
  
  local fa_style = ICON_STYLES[icon_style] or "fas"
  return string.format('<i class="%s fa-%s" aria-hidden="true"></i>', fa_style, icon_name)
end


--- Renders a link element, handling internal cross-references.
-- @param attr table Pandoc attributes
-- @param inlines table Array of inline elements (link text)
-- @param target string|table Link target (URL or {url, title})
-- @return string HTML <a> element
local function render_link(attr, inlines, target)
  local url, title = "#", ""
  
  -- Decode target (Pandoc 2.x/3.x compatibility)
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
      print_error("Internal link to unknown label '%s' (text: %s)", label, link_inner_html)
      url = "#" .. label  -- Graceful degradation
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
-- @param attr table Pandoc attributes
-- @param caption table Array of inline elements (caption)
-- @param target string|table Image source
-- @return string HTML <img> element
local function render_image(attr, caption, target)
  local src, title = "", ""
  
  -- Decode target
  if type(target) == "table" then
    src   = target[1] or target.src or ""
    title = target[2] or target.title or ""
  elseif type(target) == "string" then
    src = target
  end
  
  local captionHTML = render_inlines_html(caption)
  
  -- Validate image file exists
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
-- @param body string LaTeX table code
-- @return string HTML table or error markup
local function render_latex_table_inline(body)
  local html, err = transform_tex_snippet(body)
  if err then
    print_error("Failed to convert LaTeX table (inline): %s", err)
    return "<code class='tex-error'>" .. html_escape(body) .. "</code>"
  end
  return html
end


--- Renders Pandoc inline elements to HTML.
-- @param inlines table Array of Pandoc inline elements
-- @return string Concatenated HTML string
function render_inlines_html(inlines)
  if type(inlines) ~= "table" then 
    return "" 
  end

  local buffer = {}

  for _, el in ipairs(inlines) do
    local t, c = el.t, el.c
    
    if t == "Str" then
      -- Replace dashes: --- → —, -- → –
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
      
      -- Check if this is an icon span
      if array_contains(classes, "icon") then
        local icon_html = render_icon(kvs)
        if icon_html then
          table.insert(buffer, icon_html)
        else
          -- No icon data, render as normal span
          table.insert(buffer, "<span" .. render_attr(attr) .. ">" .. render_inlines_html(inl) .. "</span>")
        end
      else
        -- Normal span
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
-- @param attr table Pandoc attributes
-- @param blocks table Array of block elements
-- @return string HTML <details> element
local function render_collapsible(attr, blocks)
  local head = blocks[1]
  local rest = {}
  for i = 2, #blocks do 
    rest[#rest + 1] = blocks[i] 
  end
  
  -- Render heading without <p> wrapper (invalid inside <summary>)
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
-- @param body string LaTeX table code
-- @return string HTML table or error markup
local function render_latex_table_block(body)
  local html, err = transform_tex_snippet(body)
  if err then
    print_error("Failed to convert LaTeX table (block): %s", err)
    return "<pre class='tex-error'>" .. html_escape(body) .. "</pre>\n"
  end
  return html
end


--- Extracts plain text from inline elements (for TOC).
-- @param inlines table Array of inline elements
-- @return string Plain text representation
local function extract_text_from_inlines(inlines)
  local parts = {}
  for _, x in ipairs(inlines) do
    if x.t == "Str" then
      table.insert(parts, x.c)
    elseif x.t == "Space" then
      table.insert(parts, " ")
    elseif x.t == "Math" then
      table.insert(parts, x.c[2] or "")
    end
  end
  return table.concat(parts)
end


--- Renders a header element.
-- @param level number Header level (1-6)
-- @param attr table Pandoc attributes
-- @param inlines table Array of inline elements (header text)
-- @param header_collector function|nil Optional callback for TOC generation
-- @return string HTML header element
local function render_header(level, attr, inlines, header_collector)
  -- Ensure we have an ID
  local id = attr[1]
  if (not id) or id == "" then
    print_error("Header missing ID")
    local text_parts = {}
    for _, x in ipairs(inlines) do
      if x.t == "Str" then
        table.insert(text_parts, x.c)
      end
    end
    id = slugify(table.concat(text_parts, ""))
    attr[1] = id
  end
  
  -- Collect for TOC if callback provided
  if header_collector then
    local text = extract_text_from_inlines(inlines)
    header_collector(level, id, text)
  end
  
  local tag = "h" .. tostring(level)
  return "<" .. tag .. render_attr(attr) .. ">" .. render_inlines_html(inlines) .. "</" .. tag .. ">\n"
end


--- Renders Pandoc block elements to HTML.
-- @param blocks table Array of Pandoc block elements
-- @param header_collector function|nil Optional callback(level, id, text) for TOC
-- @return string Concatenated HTML string
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
      
      -- Check for special div types
      local is_env = array_contains(classes, "env")
      local is_collapsible = array_contains(classes, "collapsible")
      
      if is_env and is_collapsible then
        table.insert(buffer, render_collapsible(attr, c[2] or {}))
      else
        -- Default div rendering
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

--- Safely extracts metadata value, handling MetaString wrappers.
-- @param meta table Pandoc metadata object
-- @param key string Metadata key
-- @param fallback any Default value if key not found
-- @return any Metadata value or fallback
local function get_meta(meta, key, fallback)
  local v = meta[key]
  if type(v) == "table" and v.t == "MetaString" then 
    return v.c 
  end
  return v or fallback
end



-- ========== TABLE OF CONTENTS ==========

--- Creates a TOC collector function.
-- @return function Collector function(level, id, text)
-- @return table Array to collect TOC items
local function create_toc_collector()
  local toc_items = {}
  
  local function collector(level, id, text)
    if not id or id == "" then
      return
    end
    
    local css_class = ""
    if level == 2 then
      css_class = "section"
    elseif level == 3 then
      css_class = "subsection"
    end
    
    table.insert(
      toc_items,
      string.format('<li><a href="#%s" class="%s">%s</a></li>\n', id, css_class, text or "")
    )
  end
  
  return collector, toc_items
end


-- ========== TEMPLATE RENDERING ==========

--- Renders the final HTML document from template.
-- @param template string Template HTML with <!--PLACEHOLDER--> markers
-- @param content table Map of placeholder names to values
-- @return string Final HTML document
local function render_template(template, content)
  local used = {}
  
  local result = template:gsub("<!%-%-([A-Z_]+)%-%->", function(name)
    local val = content[name]
    if not val then
      print_error("Unknown placeholder in template: <!--%s-->", name)
      return ""
    end
    used[name] = true
    return val
  end)
  
  return result
end


-- ========== MAIN EXECUTION ==========

-- Load Pandoc document
local pandoc_doc = file_reading.load_json_file(arg[1], "json pandoc document")

-- Extract metadata
local meta = pandoc_doc.meta or {}
local title     = get_meta(meta, "metatitle", "Untitled")
local desc      = get_meta(meta, "metadescription", title)
local canonical = get_meta(meta, "canonical", "index.htm")
local citations = meta.citations and (meta.citations.c or meta.citations) or {}
local labels    = meta.labels and (meta.labels.c or meta.labels) or {}
local families  = meta.families or {}


-- Render body with TOC collection
local collect_header, toc_items = create_toc_collector()
local html_body = render_blocks_html(pandoc_doc.blocks or {}, collect_header)

-- Add bibliography to TOC
if #toc_items > 0 then
  table.insert(toc_items, '<li><a href="#bibliography" class="section">Bibliography</a></li>\n')
end

-- Build bibliography
local cite_html = bibhandler.build_bibliography_HTML(REFS_JSON, citations)

-- Format last modified date
local lastmod = os.date("%Y-%m-%d", tonumber(SOURCE_TS))
local lastmod_html = string.format(
  '<time class="dateMod" datetime="%s">%s</time>',
  lastmod, lastmod
)

-- Load template
local template = file_reading.read_file(TEMPLATE, "html template")

-- Assemble document
local document_content = {
  TITLE       = html_escape(title),
  DESCRIPTION = html_escape(desc),
  CANONICAL   = html_escape(canonical),
  SIDELINKS   = table.concat(toc_items, "\n"),
  LASTMOD     = lastmod_html,
  MAIN        = html_body,
  REFERENCES  = cite_html,
}

-- Render and output
local final_html = render_template(template, document_content)
print(final_html)