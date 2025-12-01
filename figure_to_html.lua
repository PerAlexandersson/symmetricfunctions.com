-- Convert ytableau/youngtab/array/tabular to HTML tables.
-- This module provides functions to convert various TeX table formats into HTML tables.
-- Exposes:
--   format_cell, tex_tabular_to_html, ytableaushort_to_html, youngtab_to_html, transform_tex_snippet

local utils = dofile("utils.lua")
local trim = utils.trim
local ltrim = utils.ltrim
local rtrim = utils.rtrim
local CONSOLE = utils.CONSOLE
local print_warn = utils.print_warn
local print_info = utils.print_info
local print_error = utils.print_error


-- ========== UTILITY FUNCTIONS ==========

--- Pads a table to a specified length with a given value.
-- @param t table The table to pad
-- @param n number The target length
-- @param val any The value to pad with
-- @return table The padded table
local function pad_right(t, n, val)
  for i = #t + 1, n do 
    t[i] = val 
  end
  return t
end


--- Splits a string on top-level commas (ignoring commas inside {...}).
-- @param s string The string to split
-- @return table Array of split strings, trimmed
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
  
  -- Trim all parts
  for i, p in ipairs(parts) do 
    parts[i] = trim(p) 
  end
  return parts
end


--- Extracts background color specified as "*(color)" and removes it from the entry.
-- @param ent string The entry text to process
-- @return string color The extracted color (empty string if none)
-- @return string cleaned The entry text with color specification removed
local function extract_color(ent)
  local color = ent:match("%*%((.-)%)")
  local cleaned = ent:gsub("%*%((.-)%)", "")
  return color or "", cleaned
end


--- Splits a string on a separator, preserving empty entries (including trailing empties).
-- @param s string The string to split
-- @param sep string The separator (default: "&")
-- @return table Array of split strings
local function split_cells_preserve_empties(s, sep)
  s = tostring(s or "")
  sep = sep or "&"
  local out, i, n, m = {}, 1, #s, #sep
  
  if n == 0 then 
    return { "" } 
  end
  
  while true do
    local j = string.find(s, sep, i, true)
    if j then
      out[#out + 1] = string.sub(s, i, j - 1)
      i = j + m
      if i > n + 1 then
        out[#out + 1] = ""
        break
      end
    else
      out[#out + 1] = string.sub(s, i)
      break
    end
  end
  return out
end


--- Splits a ytableaushort row into individual cell tokens.
-- Handles balanced {...} blocks and single-character cells.
-- @param row string The row string to split
-- @return table Array of cell tokens
local function split_yshort_row(row)
  row = trim(row or "")
  local toks = {}
  local i, n = 1, #row

  while i <= n do
    local ch = row:sub(i, i)

    -- Skip whitespace
    if ch:match("%s") then
      i = i + 1

    -- Cell is a balanced {...} block
    elseif ch == "{" then
      local depth = 1
      local j = i + 1
      while j <= n and depth > 0 do
        local c = row:sub(j, j)
        if c == "{" then
          depth = depth + 1
        elseif c == "}" then
          depth = depth - 1
        end
        j = j + 1
      end
      local tok = row:sub(i, j - 1) -- includes closing }
      if tok ~= "" then
        table.insert(toks, tok)
      end
      i = j

    -- Cell is a single non-space character
    else
      table.insert(toks, ch)
      i = i + 1
    end
  end

  return toks
end


-- ========== CELL FORMATTING ==========

--- Formats a single table cell as HTML with optional styling and delimiters.
-- @param ent_in string The cell content
-- @param opts table Options table with fields:
--   - delimiter (string): Delimiter to wrap content with (e.g., "$" for math mode). Default: ""
--   - align (string): Alignment - "l", "c", or "r". Default: ""
-- @return string HTML <td> element
-- @return string|nil error Error message if formatting fails
local function format_cell(ent_in, opts)
  -- Input validation
  if ent_in ~= nil and type(ent_in) ~= "string" then
    return "", "Cell content must be a string or nil"
  end
  
  opts = opts or {}
  
  -- Validate opts.delimiter
  if opts.delimiter ~= nil and type(opts.delimiter) ~= "string" then
    return "", "opts.delimiter must be a string or nil"
  end
  
  -- Validate opts.align
  if opts.align ~= nil and type(opts.align) ~= "string" then
    return "", "opts.align must be a string or nil"
  end
  
  if opts.align and opts.align ~= "" and opts.align ~= "l" and opts.align ~= "c" and opts.align ~= "r" then
    print_warn("Invalid alignment '%s', ignoring. Valid values: 'l', 'c', 'r'", opts.align)
    opts.align = ""
  end
  
  local delimiter = opts.delimiter or ""
  local align = opts.align or ""

  local ent = ent_in or ""
  local classes, styles = {}, {}

  -- Extract background color via *(...)
  local color
  color, ent = extract_color(ent)
  if color ~= "" then 
    table.insert(styles, "background-color: " .. color) 
  end

  -- Handle \none -> add "none" class and remove from content
  if ent:find("\\none", 1, true) then
    ent = ent:gsub("\\none", "")
    table.insert(classes, "none")
  end

  -- Add alignment class
  if align == "l" or align == "c" or align == "r" then
    table.insert(classes, "entryAlign-" .. align)
  end

  -- Handle empty cells -> nbsp and no delimiter
  if trim(ent) == "" then
    ent = "&nbsp;"
    delimiter = ""
  end

  local cls_attr = (#classes > 0) and (' class="' .. table.concat(classes, " ") .. '"') or ""
  local style_attr = (#styles > 0) and (' style="' .. table.concat(styles, "; ") .. '"') or ""

  return string.format("<td%s%s>%s%s%s</td>", cls_attr, style_attr, delimiter, ent, delimiter)
end


-- ========== TEX TABULAR/ARRAY CONVERSION ==========

--- Converts TeX tabular or array environment to HTML table.
-- @param s string The table content (rows separated by \\)
-- @param type_ string Table type: "tabular" or "array". Default: "tabular"
-- @param spec string Column specification (e.g., "lcr|l"). Only l/c/r are kept for alignment
-- @return string HTML <table> element
-- @return string|nil error Error message if conversion fails
local function tex_tabular_to_html(s, type_, spec)
  -- Input validation
  if not s or s == "" then
    return "", "Table content cannot be empty"
  end
  
  if type(s) ~= "string" then
    return "", "Table content must be a string"
  end
  
  if type_ ~= nil and type(type_) ~= "string" then
    return "", "Table type must be a string or nil"
  end
  
  if spec ~= nil and type(spec) ~= "string" then
    return "", "Column specification must be a string or nil"
  end
  
  local type__ = type_ or "tabular"
  
  if type__ ~= "tabular" and type__ ~= "array" then
    print_warn("Unknown table type '%s', defaulting to 'tabular'", type__)
    type__ = "tabular"
  end

  -- Parse alignment spec -> only keep l/c/r
  local specList = {}
  if spec and spec ~= "" then
    for ch in spec:gmatch(".") do
      if ch == "l" or ch == "c" or ch == "r" then
        table.insert(specList, ch)
      end
    end
  end

  -- Normalize line endings and ensure rules end with \\
  local src = s or ""
  src = src:gsub("\r\n", "\n")
  src = src:gsub("\\toprule", "\\toprule\\\\")
           :gsub("\\midrule", "\\midrule\\\\")
           :gsub("\\bottomrule", "\\bottomrule\\\\")
  
  -- Ensure trailing \\
  if not src:find("\\\\%s*$") then
    src = src .. "\\\\"
  end

  -- Split into rows
  local rows = {}
  for line in src:gmatch("(.-)\\\\") do
    table.insert(rows, rtrim(line))
  end

  -- Parse rows into cells
  local matrix, maxw = {}, 0
  for _, line in ipairs(rows) do
    local tline = trim(line)
    if tline == "\\toprule" then
      table.insert(matrix, { "__RULE__", "top" })
    elseif tline == "\\midrule" then
      table.insert(matrix, { "__RULE__", "mid" })
    elseif tline == "\\bottomrule" then
      table.insert(matrix, { "__RULE__", "bottom" })
    elseif tline ~= "" then
      local cells = split_cells_preserve_empties(line, "&")
      table.insert(matrix, cells)
      if #cells > maxw then 
        maxw = #cells 
      end
    end
  end

  -- Use column spec length if it's larger
  local target_w = math.max(maxw, #specList)

  -- Render HTML
  local html_rows = {}
  for _, row in ipairs(matrix) do
    if row[1] == "__RULE__" then
      local cls = (row[2] == "top" and "toprule") 
                  or (row[2] == "mid" and "midrule") 
                  or "bottomrule"
      table.insert(html_rows, '<tr class="' .. cls .. '"><td colspan="' .. target_w .. '"></td></tr>\n')
    else
      -- Pad rows to target width (maintains rectangular shape)
      while #row < target_w do 
        table.insert(row, "\\none") 
      end
      
      local tds = {}
      for i, cell in ipairs(row) do
        local align = (specList[i] == "l" or specList[i] == "c" or specList[i] == "r") 
                      and specList[i] or ""
        local delim = (type__ == "array") and "$" or ""
        local formatted_cell, err = format_cell(cell, { delimiter = delim, align = align })
        if err then
          print_warn("Error formatting cell: %s", err)
        end
        table.insert(tds, formatted_cell)
      end
      table.insert(html_rows, "<tr>" .. table.concat(tds, "") .. "</tr>\n")
    end
  end

  return string.format('<table class="%s">%s</table>', type__, table.concat(html_rows, ""))
end


-- ========== YTABLEAUSHORT CONVERSION ==========

--- Converts ytableaushort command content to HTML table.
-- @param argstr string The ytableaushort argument (rows separated by commas)
-- @param opts table Options table with fields:
--   - delimiter (string): Delimiter for cell content (e.g., "$" for math). Default: "$"
-- @return string HTML <table> element with class "ytab"
-- @return string|nil error Error message if conversion fails
local function ytableaushort_to_html(argstr, opts)
  -- Input validation
  if not argstr or argstr == "" then
    return "", "ytableaushort content cannot be empty"
  end
  
  if type(argstr) ~= "string" then
    return "", "ytableaushort content must be a string"
  end
  
  opts = opts or {}
  
  if opts.delimiter ~= nil and type(opts.delimiter) ~= "string" then
    return "", "opts.delimiter must be a string or nil"
  end
  
  local delim = (opts.delimiter ~= nil) and opts.delimiter or "$"

  local s = trim(argstr or "")

  -- Split rows by top-level commas
  local rows = split_top_level_commas(s)

  -- Parse each row into tokens
  local row_tokens = {}
  local maxw = 0
  for _, row in ipairs(rows) do
    local toks = split_yshort_row(row)
    row_tokens[#row_tokens + 1] = toks
    if #toks > maxw then 
      maxw = #toks 
    end
  end

  -- Pad with \none to create rectangular table
  for i, toks in ipairs(row_tokens) do
    pad_right(toks, maxw, "\\none")
    row_tokens[i] = toks
  end

  -- Render HTML
  local html_rows = {}
  for _, toks in ipairs(row_tokens) do
    local tds = {}
    for _, tok in ipairs(toks) do
      -- Strip outer braces if present
      local cell_content = tok
      if cell_content:sub(1, 1) == "{" and cell_content:sub(-1) == "}" then
        cell_content = cell_content:sub(2, -2)
      end
      local formatted_cell, err = format_cell(cell_content, { delimiter = delim })
      if err then
        print_warn("Error formatting cell: %s", err)
      end
      table.insert(tds, formatted_cell)
    end
    table.insert(html_rows, "<tr>" .. table.concat(tds, "") .. "</tr>\n")
  end

  return '<table class="ytab">' .. table.concat(html_rows, "") .. "</table>\n"
end


-- ========== YTABLEAU/YOUNGTAB CONVERSION ==========

--- Converts ytableau or youngtab environment body to HTML table.
-- @param body string The table body (rows separated by \\, cells by &)
-- @param opts table Options table with fields:
--   - delimiter (string): Delimiter for cell content (e.g., "$" for math). Default: "$"
-- @return string HTML <table> element with class "ytab"
-- @return string|nil error Error message if conversion fails
local function youngtab_to_html(body, opts)
  -- Input validation
  if not body or body == "" then
    return "", "Table body cannot be empty"
  end
  
  if type(body) ~= "string" then
    return "", "Table body must be a string"
  end
  
  opts = opts or {}
  
  if opts.delimiter ~= nil and type(opts.delimiter) ~= "string" then
    return "", "opts.delimiter must be a string or nil"
  end
  
  local delim = (opts.delimiter ~= nil) and opts.delimiter or "$"

  -- Normalize line endings and ensure trailing \\
  local s = body or ""
  s = s:gsub("\r\n", "\n")
  if not s:find("\\\\%s*$") then
    s = s .. "\\\\"
  end

  -- Split into rows
  local lines = {}
  for line in s:gmatch("(.-)\\\\") do
    table.insert(lines, rtrim(line))
  end

  -- Parse rows into cells
  -- Note: In LaTeX, a row with just \\ creates a single empty cell
  local rows, maxw = {}, 0
  for _, line in ipairs(lines) do
    local cells = split_cells_preserve_empties(line, "&")
    rows[#rows + 1] = cells
    if #cells > maxw then 
      maxw = #cells 
    end
  end

  -- Pad to rectangle with \none (creates borderless cells)
  for i, cells in ipairs(rows) do
    while #cells < maxw do 
      table.insert(cells, "\\none") 
    end
    rows[i] = cells
  end

  -- Render HTML
  local html_rows = {}
  for _, cells in ipairs(rows) do
    local tds = {}
    for _, e in ipairs(cells) do
      local formatted_cell, err = format_cell(e, { delimiter = delim })
      if err then
        print_warn("Error formatting cell: %s", err)
      end
      table.insert(tds, formatted_cell)
    end
    table.insert(html_rows, "<tr>" .. table.concat(tds, "") .. "</tr>\n")
  end

  return '<table class="ytab">\n' .. table.concat(html_rows, "") .. "</table>\n"
end


-- ========== CONVENIENCE PARSER ==========

--- Detects and converts common TeX table formats to HTML.
-- Supports: \ytableaushort{}, \textytableaushort{}, 
--           \begin{ytableau}...\end{ytableau}, \begin{youngtabtext}...\end{youngtabtext},
--           \begin{array}...\end{array}, \begin{rawtabular}...\end{rawtabular}
-- @param s string The TeX snippet to convert
-- @return string|nil HTML table string, or nil if no recognized format found
-- @return string|nil error Error message with details if conversion fails
local function transform_tex_snippet(s)
  if not s or s == "" then 
    return nil, "Input is empty or nil"
  end
  
  if type(s) ~= "string" then
    return nil, "Input must be a string"
  end
  
  local src = trim(s)

  -- Check for commands
  local cmd, arg = src:match("^\\(%a+)%s*(%b{})%s*$")
  if cmd and arg then
    local inner = arg:sub(2, -2)
    if cmd == "ytableaushort" then
      local result, err = ytableaushort_to_html(inner, { delimiter = "$" })
      if err then
        return nil, "Failed to convert \\ytableaushort: " .. err
      end
      return result
    elseif cmd == "textytableaushort" then
      local result, err = ytableaushort_to_html(inner, { delimiter = "" })
      if err then
        return nil, "Failed to convert \\textytableaushort: " .. err
      end
      return result
    end
  end
  
  -- Check for ytableau environment
  local ytab_body = src:match("^%s*\\begin%s*%{ytableau%}%s*([%s%S]-)%s*\\end%s*%{ytableau%}%s*$")
  if ytab_body then
    local result, err = youngtab_to_html(ytab_body, { delimiter = "$" })
    if err then
      return nil, "Failed to convert ytableau environment: " .. err
    end
    return result
  end

  -- Check for youngtabtext environment
  local youngtext_body = src:match("^%s*\\begin%s*%{youngtabtext%}%s*([%s%S]-)%s*\\end%s*%{youngtabtext%}%s*$")
  if youngtext_body then
    local result, err = youngtab_to_html(youngtext_body, { delimiter = "" })
    if err then
      return nil, "Failed to convert youngtabtext environment: " .. err
    end
    return result
  end

  -- Check for array environment
  local a_cols, a_body = src:match("^%s*\\begin%s*%{array%}%s*(%b{})%s*([%s%S]-)%s*\\end%s*%{array%}%s*$")
  if a_cols and a_body then
    local result, err = tex_tabular_to_html(a_body, "array", trim(a_cols:sub(2, -2)))
    if err then
      return nil, "Failed to convert array environment: " .. err
    end
    return result
  end

  -- Check for rawtabular environment
  local t_cols, t_body = src:match("^%s*\\begin%s*%{rawtabular%}%s*(%b{})%s*([%s%S]-)%s*\\end%s*%{rawtabular%}%s*$")
  if t_cols and t_body then
    local result, err = tex_tabular_to_html(t_body, "tabular", trim(t_cols:sub(2, -2)))
    if err then
      return nil, "Failed to convert rawtabular environment: " .. err
    end
    return result
  end

  return nil, "No recognized TeX table format found in input"
end



-- ========== SPAN-BASED IMPLEMENTATION ==========

--- Parses a TeX tabular source string into a structured matrix of cells.
-- @param s string The raw TeX body
-- @param spec string The column specification (e.g. "lcr")
-- @return table matrix A list of rows, where each row is a list of cell strings (or { "__RULE__", type })
-- @return table specList A list of alignment characters ("l", "c", "r")
-- @return number target_w The calculated width (max columns) of the table
local function parse_tabular_source(s, spec)
  -- Parse alignment spec -> only keep l/c/r
  local specList = {}
  if spec and spec ~= "" then
    for ch in spec:gmatch(".") do
      if ch == "l" or ch == "c" or ch == "r" then
        table.insert(specList, ch)
      end
    end
  end

  -- Normalize line endings and ensure rules end with \\
  local src = s or ""
  src = src:gsub("\r\n", "\n")
  src = src:gsub("\\toprule", "\\toprule\\\\")
           :gsub("\\midrule", "\\midrule\\\\")
           :gsub("\\bottomrule", "\\bottomrule\\\\")
  
  -- Ensure trailing \\
  if not src:find("\\\\%s*$") then
    src = src .. "\\\\"
  end

  -- Split into rows
  local rows_raw = {}
  for line in src:gmatch("(.-)\\\\") do
    table.insert(rows_raw, rtrim(line))
  end

  -- Parse rows into cells
  local matrix, maxw = {}, 0
  for _, line in ipairs(rows_raw) do
    local tline = trim(line)
    if tline == "\\toprule" then
      table.insert(matrix, { "__RULE__", "top" })
    elseif tline == "\\midrule" then
      table.insert(matrix, { "__RULE__", "mid" })
    elseif tline == "\\bottomrule" then
      table.insert(matrix, { "__RULE__", "bottom" })
    elseif tline ~= "" then
      local cells = split_cells_preserve_empties(line, "&")
      table.insert(matrix, cells)
      if #cells > maxw then 
        maxw = #cells 
      end
    end
  end

  local target_w = math.max(maxw, #specList)
  return matrix, specList, target_w
end


--- Formats a single table cell as an HTML SPAN (for inline validity).
-- @param ent_in string The cell content
-- @param opts table Options (delimiter, align)
-- @return string HTML <span> element
-- @return string|nil error Error message
local function format_cell_span(ent_in, opts)
  -- Input validation
  if ent_in ~= nil and type(ent_in) ~= "string" then
    return "", "Cell content must be a string or nil"
  end
  
  opts = opts or {}
  local delimiter = opts.delimiter or ""
  local align = opts.align or ""

  local ent = ent_in or ""
  local classes, styles = { "ytab-cell" }, {} -- Base class for CSS Grid/Flex styling

  -- Extract background color
  local color
  color, ent = extract_color(ent)
  if color ~= "" then 
    table.insert(styles, "background-color: " .. color) 
  end

  -- Handle \none
  if ent:find("\\none", 1, true) then
    ent = ent:gsub("\\none", "")
    table.insert(classes, "none")
    table.insert(styles, "border: none") -- Explicit style helper
  end

  -- Add alignment class
  if align == "l" or align == "c" or align == "r" then
    table.insert(classes, "align-" .. align)
  end

  -- Handle empty cells
  if trim(ent) == "" then
    ent = "&nbsp;"
    delimiter = ""
  end

  local cls_attr = (' class="' .. table.concat(classes, " ") .. '"')
  local style_attr = (#styles > 0) and (' style="' .. table.concat(styles, "; ") .. '"') or ""

  return string.format("<span%s%s>%s%s%s</span>", cls_attr, style_attr, delimiter, ent, delimiter)
end


--- Converts TeX tabular/array to an HTML SPAN-based structure.
-- This creates a structure safe for use inside <p> tags.
-- @param s string The table content
-- @param type_ string "tabular" or "array"
-- @param spec string Column specification
-- @return string HTML <span> structure
-- @return string|nil error
local function tex_tabular_to_span(s, type_, spec)
  if not s or s == "" then return "", "Table content cannot be empty" end

  -- 1. Parse Data
  local matrix, specList, target_w = parse_tabular_source(s, spec)
  
  local type__ = type_ or "tabular"
  local wrapper_class = "ytab-wrapper " .. type__

  -- 2. Generate HTML
  local html_parts = {}
  table.insert(html_parts, '<span class="' .. wrapper_class .. '">')

  for _, row in ipairs(matrix) do
    if row[1] == "__RULE__" then
      -- Render rules as a row with a specific class, or ignore if using borders via CSS
      local cls = (row[2] == "top" and "rule-top") 
                  or (row[2] == "mid" and "rule-mid") 
                  or "rule-bottom"
      -- We add a divider span
      table.insert(html_parts, '<span class="ytab-row rule ' .. cls .. '"></span>')
    else
      -- Pad row
      while #row < target_w do 
        table.insert(row, "\\none") 
      end
      
      table.insert(html_parts, '<span class="ytab-row">')
      
      for i, cell in ipairs(row) do
        local align = (specList[i] == "l" or specList[i] == "c" or specList[i] == "r") 
                      and specList[i] or ""
        local delim = (type__ == "array") and "$" or ""
        
        local formatted_cell, err = format_cell_span(cell, { delimiter = delim, align = align })
        if err then print_warn("Error formatting span cell: %s", err) end
        
        table.insert(html_parts, formatted_cell)
      end
      
      table.insert(html_parts, '</span>') -- End row
    end
  end

  table.insert(html_parts, '</span>') -- End wrapper
  return table.concat(html_parts, "")
end



-- ========== MODULE EXPORTS ==========

---@class TexTableConverter
---@field format_cell fun(ent_in: string, opts: table?): string, string? Formats a single table cell as HTML
---@field tex_tabular_to_html fun(s: string, type_: string?, spec: string?): string, string? Converts TeX tabular/array to HTML
---@field ytableaushort_to_html fun(argstr: string, opts: table?): string, string? Converts ytableaushort to HTML
---@field youngtab_to_html fun(body: string, opts: table?): string, string? Converts ytableau/youngtab to HTML
---@field transform_tex_snippet fun(s: string): string?, string? Detects and converts common TeX table formats

---@type TexTableConverter
local M = {
  format_cell = format_cell,
  tex_tabular_to_html = tex_tabular_to_html,
  ytableaushort_to_html = ytableaushort_to_html,
  youngtab_to_html = youngtab_to_html,
  transform_tex_snippet = transform_tex_snippet,
  format_cell_span = format_cell_span,
  tex_tabular_to_span = tex_tabular_to_span
}

return M