-- Convert ytableau/youngtab/array/tabular to HTML Spans (CSS Grid/Flex compatible).
-- This module converts TeX table formats into semantic <span> structures.
-- Exposes:
--   transform_tex_snippet, tex_tabular_to_span, ytableaushort_to_span, youngtab_to_span

local utils = dofile("utils.lua")
local trim = utils.trim
local rtrim = utils.rtrim
local print_warn = utils.print_warn

-- ========== UTILITY FUNCTIONS ==========

--- Pads a matrix (list of lists) to a rectangle using a specific value.
-- @return number max_w The calculated width (number of columns)
local function pad_matrix_to_rectangle(matrix, val)
  local max_w = 0
  for _, row in ipairs(matrix) do
    if #row > max_w then max_w = #row end
  end
  for _, row in ipairs(matrix) do
    for i = #row + 1, max_w do
      row[i] = val
    end
  end
  return max_w
end

--- Splits a string on top-level commas (ignoring commas inside {...}).
local function split_top_level_commas(s)
  local parts, buf, depth = {}, {}, 0
  for i = 1, #s do
    local ch = s:sub(i, i)
    if ch == "{" then
      depth = depth + 1
      table.insert(buf, ch)
    elseif ch == "}" then
      depth = math.max(0, depth - 1)
      table.insert(buf, ch)
    elseif ch == "," and depth == 0 then
      table.insert(parts, table.concat(buf))
      buf = {}
    else
      table.insert(buf, ch)
    end
  end
  table.insert(parts, table.concat(buf))
  for i, p in ipairs(parts) do parts[i] = trim(p) end
  return parts
end

--- Extracts background color specified as "*(color)" and removes it from the entry.
local function extract_color(ent)
  local color = ent:match("%*%((.-)%)")
  local cleaned = ent:gsub("%*%((.-)%)", "")
  return color or "", cleaned
end

--- Splits a string on a separator, preserving empty entries.
local function split_cells_preserve_empties(s, sep)
  s = tostring(s or "")
  sep = sep or "&"
  local out, i, n, m = {}, 1, #s, #sep
  if n == 0 then return { "" } end
  while true do
    local j = string.find(s, sep, i, true)
    if j then
      out[#out + 1] = string.sub(s, i, j - 1)
      i = j + m
      if i > n + 1 then out[#out + 1] = ""; break end
    else
      out[#out + 1] = string.sub(s, i); break
    end
  end
  return out
end

--- Splits a ytableaushort row into individual cell tokens.
local function split_yshort_row(row)
  row = trim(row or "")
  local toks = {}
  local i, n = 1, #row
  while i <= n do
    local ch = row:sub(i, i)
    if ch:match("%s") then
      i = i + 1
    elseif ch == "{" then
      local depth, j = 1, i + 1
      while j <= n and depth > 0 do
        local c = row:sub(j, j)
        if c == "{" then depth = depth + 1 elseif c == "}" then depth = depth - 1 end
        j = j + 1
      end
      local tok = row:sub(i, j - 1)
      if tok ~= "" then table.insert(toks, tok) end
      i = j
    else
      table.insert(toks, ch)
      i = i + 1
    end
  end
  return toks
end

--- Helper to check if a cell content counts as "empty/none"
local function is_cell_none(content)
  if not content or content == "" then return true end
  if content:find("\\none") then return true end
  return false
end


-- ========== CORE RENDERER ==========

--- Formats a single cell content into a span.
local function format_cell_content(ent_in, opts)
  opts = opts or {}
  local delimiter = opts.delimiter or ""
  local align = opts.align or ""
  local ent = ent_in or ""
  local classes, styles = { "ytab-cell" }, {}

  -- Extract Color
  local color
  color, ent = extract_color(ent)
  if color ~= "" then table.insert(styles, "background-color: " .. color) end

  -- Handle \none
  if ent:find("\\none", 1, true) then
    ent = ent:gsub("\\none", "")
    table.insert(classes, "none")
    table.insert(styles, "border: none; background: transparent") 
  end

  -- Alignment
  if align == "l" or align == "c" or align == "r" then
    table.insert(classes, "align-" .. align)
  end
  
  -- Extra classes (borders, etc)
  if opts.extra_classes then
    for _, c in ipairs(opts.extra_classes) do table.insert(classes, c) end
  end

  -- Empty handling
  if trim(ent) == "" then
    ent = "&nbsp;"
    delimiter = ""
  end

  local cls_attr = (' class="' .. table.concat(classes, " ") .. '"')
  local style_attr = (#styles > 0) and (' style="' .. table.concat(styles, "; ") .. '"') or ""

  return string.format("<span%s%s>%s%s%s</span>", cls_attr, style_attr, delimiter, ent, delimiter)
end

--- Renders a normalized matrix (list of lists) into HTML Spans.
-- @param matrix table The data matrix
-- @param specList table|nil List of alignment specs ['l', 'c', 'r'] matching columns
-- @param opts table Configuration: { type="name", delimiter="$", is_block=bool }
-- @param col_count number The number of columns (width of matrix)
local function render_matrix_to_span(matrix, specList, opts, col_count)
  specList = specList or {}
  opts = opts or {}
  local type_name = opts.type or "tabular"
  local delimiter = opts.delimiter or ""
  
  -- Base classes
  local classes = { "ytab-wrapper", type_name }
  if opts.is_block then table.insert(classes, "ytab-display") end

  -- Inject Column Variable for CSS Grid
  local style_attr = ""
  if col_count and col_count > 0 then
    style_attr = string.format(' style="--cols: %d;"', col_count)
  end

  local html_parts = {}
  table.insert(html_parts, '<span class="' .. table.concat(classes, " ") .. '"' .. style_attr .. '>')

  for r, row in ipairs(matrix) do
    if row[1] == "__RULE__" then
      -- Render structural rules as special rows
      local rule_cls = (row[2] == "top" and "rule-top") or (row[2] == "mid" and "rule-mid") or "rule-bottom"
      table.insert(html_parts, '<span class="ytab-row rule ' .. rule_cls .. '"></span>')
    else
      table.insert(html_parts, '<span class="ytab-row">')
      for c, cell in ipairs(row) do
        local align = specList[c] or ""
        
        -- Smart borders logic
        local border_classes = {}
        if c > 1 then 
           local left = matrix[r][c-1]
           if not is_cell_none(left) then table.insert(border_classes, "nbl") end
        end
        if r > 1 and matrix[r-1] then
           local top = matrix[r-1][c]
           if not is_cell_none(top) then table.insert(border_classes, "nbt") end
        end
        
        local cell_html = format_cell_content(cell, { 
            delimiter = delimiter, 
            align = align,
            extra_classes = border_classes
        })
        table.insert(html_parts, cell_html)
      end
      table.insert(html_parts, '</span>')
    end
  end

  table.insert(html_parts, '</span>')
  return table.concat(html_parts, "")
end


-- ========== PARSERS & CONVERTERS ==========

--- 1. Tabular / Array
local function tex_tabular_to_span(s, type_, spec)
  if not s or s == "" then return "", "Empty content" end
  
  -- Parse Specs
  local specList = {}
  if spec then
    for ch in spec:gmatch(".") do
      if ch == "l" or ch == "c" or ch == "r" then table.insert(specList, ch) end
    end
  end

  -- Normalize & Split Lines
  s = s:gsub("\r\n", "\n")
       :gsub("\\toprule", "\\toprule\\\\"):gsub("\\midrule", "\\midrule\\\\"):gsub("\\bottomrule", "\\bottomrule\\\\")
  if not s:find("\\\\%s*$") then s = s .. "\\\\" end

  local matrix = {}
  for line in s:gmatch("(.-)\\\\") do
    local tline = trim(line)
    if tline == "\\toprule" then table.insert(matrix, { "__RULE__", "top" })
    elseif tline == "\\midrule" then table.insert(matrix, { "__RULE__", "mid" })
    elseif tline == "\\bottomrule" then table.insert(matrix, { "__RULE__", "bottom" })
    elseif tline ~= "" then
      table.insert(matrix, split_cells_preserve_empties(line, "&"))
    end
  end

  -- Pad and get Width
  local width = pad_matrix_to_rectangle(matrix, "\\none")
  
  local delim = (type_ == "array") and "$" or ""
  local is_blk = (type_ == "tabular") -- Tabulars are blocks by default
  
  return render_matrix_to_span(matrix, specList, { type = type_, delimiter = delim, is_block = is_blk }, width)
end

--- 2. Ytableaushort
local function ytableaushort_to_span(argstr, opts)
  if not argstr or argstr == "" then return "", "Empty content" end
  opts = opts or {}
  
  local rows = split_top_level_commas(trim(argstr))
  local matrix = {}
  
  for _, row in ipairs(rows) do
    local tokens = split_yshort_row(row)
    -- Clean braces {x} -> x
    for k, v in ipairs(tokens) do
      if v:match("^{.*}$") then tokens[k] = v:sub(2, -2) end
    end
    table.insert(matrix, tokens)
  end

  local width = pad_matrix_to_rectangle(matrix, "\\none")

  local delim = opts.delimiter or "$"
  return render_matrix_to_span(matrix, nil, { type = "ytableau", delimiter = delim }, width)
end

--- 3. Youngtab / Ytableau Environment
local function youngtab_to_span(body, opts)
  if not body or body == "" then return "", "Empty content" end
  opts = opts or {}

  local s = body:gsub("\r\n", "\n")
  if not s:find("\\\\%s*$") then s = s .. "\\\\" end

  local matrix = {}
  for line in s:gmatch("(.-)\\\\") do
    table.insert(matrix, split_cells_preserve_empties(rtrim(line), "&"))
  end

  local width = pad_matrix_to_rectangle(matrix, "\\none")

  local delim = opts.delimiter or "$"
  return render_matrix_to_span(matrix, nil, { type = "ytableau", delimiter = delim }, width)
end


-- ========== MAIN ENTRY POINT ==========

--- Detects format and transforms to HTML Span structure.
local function transform_tex_snippet(s)
  if type(s) ~= "string" or s == "" then return nil, "Invalid input" end
  local src = trim(s)

  -- Command: \ytableaushort{...}
  local cmd, arg = src:match("^\\(%a+)%s*(%b{})%s*$")
  if cmd == "ytableaushort" then
    return ytableaushort_to_span(arg:sub(2, -2), { delimiter = "$" })
  elseif cmd == "textytableaushort" then
    return ytableaushort_to_span(arg:sub(2, -2), { delimiter = "" })
  end
  
  -- Environment: ytableau
  local ytab = src:match("^%s*\\begin%s*%{ytableau%}%s*([%s%S]-)%s*\\end%s*%{ytableau%}%s*$")
  if ytab then return youngtab_to_span(ytab, { delimiter = "$" }) end

  -- Environment: youngtabtext
  local ytext = src:match("^%s*\\begin%s*%{youngtabtext%}%s*([%s%S]-)%s*\\end%s*%{youngtabtext%}%s*$")
  if ytext then return youngtab_to_span(ytext, { delimiter = "" }) end

  -- Environment: array
  local acols, abody = src:match("^%s*\\begin%s*%{array%}%s*(%b{})%s*([%s%S]-)%s*\\end%s*%{array%}%s*$")
  if acols then return tex_tabular_to_span(abody, "array", acols:sub(2, -2)) end

  -- Environment: tabular
  local tcols, tbody = src:match("^%s*\\begin%s*%{tabular%}%s*(%b{})%s*([%s%S]-)%s*\\end%s*%{tabular%}%s*$")
  if tcols then return tex_tabular_to_span(tbody, "tabular", tcols:sub(2, -2)) end

  -- Environment: rawtabular
  local rcols, rbody = src:match("^%s*\\begin%s*%{rawtabular%}%s*(%b{})%s*([%s%S]-)%s*\\end%s*%{rawtabular%}%s*$")
  if rcols then return tex_tabular_to_span(rbody, "tabular", rcols:sub(2, -2)) end

  return nil, "Unknown format"
end

-- ========== EXPORTS ==========

local M = {
  tex_tabular_to_span = tex_tabular_to_span,
  ytableaushort_to_span = ytableaushort_to_span,
  youngtab_to_span = youngtab_to_span,
  transform_tex_snippet = transform_tex_snippet
}

return M