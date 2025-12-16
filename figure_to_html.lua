-- Convert ytableau/youngtab/array/tabular to HTML using CSS Grid with explicit positioning
-- Simplified approach: one container span + positioned cell spans

local utils = dofile("utils.lua")
local trim = utils.trim
local rtrim = utils.rtrim

-- ========== UTILITY FUNCTIONS ==========

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

local function extract_color(ent)
  local color = ent:match("%*%((.-)%)")
  local cleaned = ent:gsub("%*%((.-)%)", "")
  return color or "", cleaned
end

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

-- Helper to determine if a neighbor exists and is "solid" (not \none)
local function is_solid_cell(content)
  
  if content == nil then return false end

  -- If it's a rule row (table), it's not a solid cell
  if type(content) == "table" then return false end

  -- If it contains \none, it acts as empty space for border calculations
  if tostring(content):find("\\none") then return false end

  return true
end

-- ========== CORE RENDERER ==========

--- Formats a single cell with inline grid position
local function format_cell(content, row, col, opts)
  opts = opts or {}
  local delimiter = opts.delimiter or ""
  local align = opts.align or ""
  
  -- Neighbor flags for border logic
  local has_north = opts.has_north
  local has_south  = opts.has_south
  local has_east = opts.has_east
  local has_west  = opts.has_west
  
  local ent = content or ""
  local classes = {}
  local styles = {}
  
  -- Grid position
  table.insert(styles, string.format("grid-row: %d", row))
  table.insert(styles, string.format("grid-column: %d", col))

  -- Extract color
  local color
  color, ent = extract_color(ent)
  if color ~= "" then 
    table.insert(styles, "background-color: " .. color)
  end

  -- Handle \none
    local is_none = false
    if ent:find("\\none", 1, true) then
      ent = ent:gsub("\\none", "")
      is_none = true
      table.insert(classes, "cell-none")
    end

    -- The only cells with north/west borders are those in the first row/column that are not \none
    if not is_none and row == 1 then
      table.insert(classes, "border-n")
    end
    if not is_none and col == 1 then
      table.insert(classes, "border-w")
    end


    if not is_none or has_south then
      table.insert(classes, "border-s")
    end

    if not is_none or has_east then
      table.insert(classes, "border-e")
    end


  -- Alignment
  if align == "l" or align == "c" or align == "r" then
    table.insert(classes, "align-" .. align)
  end

  -- Empty handling
  if trim(ent) == "" then
    ent = "&nbsp;"
    delimiter = ""
  end
  
  local cls_attr = (#classes > 0) and (' class="' .. table.concat(classes, " ") .. '"') or ""
  local style_attr = ' style="' .. table.concat(styles, "; ") .. '"'
  
  return string.format("<span%s%s>%s%s%s</span>", cls_attr, style_attr, delimiter, ent, delimiter)
end

--- Renders matrix to HTML with CSS Grid
local function render_matrix(matrix, specList, opts, col_count)
  specList = specList or {}
  opts = opts or {}
  local type_name = opts.type or "ytableau"
  local delimiter = opts.delimiter or ""
  local is_inline = not opts.is_block
  
  -- Container classes
  local classes = { type_name }
  if is_inline then table.insert(classes, "inline") end
  
  -- Count actual rows (including rules)
  local total_rows = #matrix
  
  -- Grid dimensions
  local grid_style = string.format("grid-template-rows: repeat(%d, auto); grid-template-columns: repeat(%d, auto)", 
                                   total_rows, col_count)
  
  local html = {}
  table.insert(html, string.format('<span class="%s" style="%s">',
                                    table.concat(classes, " "), grid_style))
  
  -- Render cells with explicit positions
  local current_row = 0
  for r, row in ipairs(matrix) do
    if row[1] == "__RULE__" then
      current_row = current_row + 1
      -- Render horizontal rule spanning all columns
      local rule_type = row[2] or "mid"
      local rule_class = "rule rule-" .. rule_type
      local rule_style = string.format("grid-row: %d; grid-column: 1 / %d", 
                                       current_row, col_count + 1)
      table.insert(html, string.format('<span class="%s" style="%s"></span>',
                                       rule_class, rule_style))
    else
      current_row = current_row + 1
      for c, cell in ipairs(row) do
        -- We render ALL cells, even empty/\none ones, to maintain grid structure

        -- Determine neighbors for border logic
        -- Note: We check the raw matrix. matrix[r-1] might be a rule or nil.
        local neighbor_n = (r > 1) and matrix[r-1][c] or nil
        local neighbor_w = (c > 1) and matrix[r][c-1] or nil
        local neighbor_s = (matrix[r+1] and matrix[r+1][c]) or nil
        local neighbor_e = matrix[r][c+1] or nil
        
        local has_north = is_solid_cell(neighbor_n)
        local has_west  = is_solid_cell(neighbor_w)
        local has_south = is_solid_cell(neighbor_s)
        local has_east  = is_solid_cell(neighbor_e)
        
        local align = specList[c] or ""
        local cell_html = format_cell(cell, current_row, c, {
          delimiter = delimiter,
          align = align,
          has_north = has_north,
          has_west = has_west,
          has_south = has_south,
          has_east = has_east
        })
        table.insert(html, cell_html)
      end
    end
  end
  
  table.insert(html, '</span>')
  return table.concat(html, "\n")
end

-- ========== PARSERS ==========

local function tex_tabular_to_span(s, type_, spec)
  if not s or s == "" then return "", "Empty content" end
  
  -- Parse column specs
  local specList = {}
  if spec then
    for ch in spec:gmatch(".") do
      if ch == "l" or ch == "c" or ch == "r" then 
        table.insert(specList, ch) 
      end
    end
  end
  
  -- Normalize
  s = s:gsub("\r\n", "\n")
       :gsub("\\toprule", "\\toprule\\\\")
       :gsub("\\midrule", "\\midrule\\\\")
       :gsub("\\bottomrule", "\\bottomrule\\\\")
  if not s:find("\\\\%s*$") then s = s .. "\\\\" end
  
  local matrix = {}
  for line in s:gmatch("(.-)\\\\") do
    local tline = trim(line)
    if tline == "\\toprule" then
      table.insert(matrix, { "__RULE__", "top" })
    elseif tline == "\\midrule" then
      table.insert(matrix, { "__RULE__", "mid" })
    elseif tline == "\\bottomrule" then
      table.insert(matrix, { "__RULE__", "bottom" })
    elseif tline ~= "" then
      table.insert(matrix, split_cells_preserve_empties(line, "&"))
    end
  end
  
  -- Pad with \none
  -- is_solid_cell handles \none checks.
  local width = pad_matrix_to_rectangle(matrix, "\\none")
  
  local delim = (type_ == "array") and "$" or ""
  
  return render_matrix(matrix, specList, { 
    type = type_, 
    delimiter = delim, 
    is_block = true 
  }, width)
end

local function ytableaushort_to_span(argstr, opts)
  if not argstr or argstr == "" then return "", "Empty content" end
  opts = opts or {}
  
  local rows = split_top_level_commas(trim(argstr))
  local matrix = {}
  
  for _, row in ipairs(rows) do
    local tokens = split_yshort_row(row)
    for k, v in ipairs(tokens) do
      if v:match("^{.*}$") then tokens[k] = v:sub(2, -2) end
    end
    table.insert(matrix, tokens)
  end
  
  local width = pad_matrix_to_rectangle(matrix, "\\none")
  
  return render_matrix(matrix, nil, { 
    type = "ytableau", 
    delimiter = opts.delimiter or "$",
    is_block = false 
  }, width)
end

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
  
  return render_matrix(matrix, nil, { 
    type = "ytableau", 
    delimiter = opts.delimiter or "$",
    is_block = false 
  }, width)
end

-- ========== MAIN ENTRY ==========

local function transform_tex_snippet(s)
  if type(s) ~= "string" or s == "" then return nil, "Invalid input" end
  local src = trim(s)
  
  -- \ytableaushort{...}
  local cmd, arg = src:match("^\\(%a+)%s*(%b{})%s*$")
  if cmd == "ytableaushort" then
    return ytableaushort_to_span(arg:sub(2, -2), { delimiter = "$" })
  elseif cmd == "textytableaushort" then
    return ytableaushort_to_span(arg:sub(2, -2), { delimiter = "" })
  end
  
  -- \begin{ytableau}
  local ytab = src:match("^%s*\\begin%s*%{ytableau%}%s*([%s%S]-)%s*\\end%s*%{ytableau%}%s*$")
  if ytab then return youngtab_to_span(ytab, { delimiter = "$" }) end
  
  -- \begin{youngtabtext}
  local ytext = src:match("^%s*\\begin%s*%{youngtabtext%}%s*([%s%S]-)%s*\\end%s*%{youngtabtext%}%s*$")
  if ytext then return youngtab_to_span(ytext, { delimiter = "" }) end
  
  -- \begin{array}
  local acols, abody = src:match("^%s*\\begin%s*%{array%}%s*(%b{})%s*([%s%S]-)%s*\\end%s*%{array%}%s*$")
  if acols then return tex_tabular_to_span(abody, "array", acols:sub(2, -2)) end
  
  -- \begin{tabular}
  local tcols, tbody = src:match("^%s*\\begin%s*%{tabular%}%s*(%b{})%s*([%s%S]-)%s*\\end%s*%{tabular%}%s*$")
  if tcols then return tex_tabular_to_span(tbody, "tabular", tcols:sub(2, -2)) end
  
  -- \begin{rawtabular}
  local rcols, rbody = src:match("^%s*\\begin%s*%{rawtabular%}%s*(%b{})%s*([%s%S]-)%s*\\end%s*%{rawtabular%}%s*$")
  if rcols then return tex_tabular_to_span(rbody, "tabular", rcols:sub(2, -2)) end
  
  return nil, "Unknown format"
end

-- ========== EXPORTS ==========

return {
  tex_tabular_to_span = tex_tabular_to_span,
  ytableaushort_to_span = ytableaushort_to_span,
  youngtab_to_span = youngtab_to_span,
  transform_tex_snippet = transform_tex_snippet
}