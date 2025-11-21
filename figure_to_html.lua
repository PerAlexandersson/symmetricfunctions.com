-- Convert ytableau/youngtab/array/tabular to HTML tables.
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

local M = {}

-- ---------- Utilities ----------

local function pad_right(t, n, val)
  for i = #t + 1, n do t[i] = val end
  return t
end


-- split on top-level commas (ignore commas inside {...})
local function split_top_level_commas(s)
  local parts, buf, depth = {}, {}, 0
  for i = 1, #s do
    local ch = s:sub(i,i)
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
  -- trim all parts
  for i,p in ipairs(parts) do parts[i] = trim(p) end
  return parts
end

-- Extract background color specified as "*(...)" and strip it from the entry
local function extract_color(ent)
  local color = ent:match("%*%((.-)%)")
  local cleaned = ent:gsub("%*%((.-)%)", "")
  return color or "", cleaned
end

-- One UTF-8 codepoint at a time (for compact ytableaushort tokens)
local function utf8_next_len(b)
  if not b then return 1 end
  if b >= 0xF0 then return 4
  elseif b >= 0xE0 then return 3
  elseif b >= 0xC0 then return 2
  else return 1 end
end


-- ---------- Cell formatter (re-usable) ----------

-- opts = { delimiter="$" | "", align="l"|"c"|"r"|"" }
function M.format_cell(ent_in, opts)
  opts = opts or {}
  local delimiter = opts.delimiter or ""
  local align = opts.align or ""

  local ent = ent_in or ""
  local classes, styles = {}, {}

  -- background via *(...)
  local color; color, ent = extract_color(ent)
  if color ~= "" then table.insert(styles, "background-color: " .. color) end

  -- \none -> class "none" and remove from content
  if ent:find("\\none", 1, true) then
    ent = ent:gsub("\\none", "")
    table.insert(classes, "none")
  end

  -- alignment class
  if align == "l" or align == "c" or align == "r" then
    table.insert(classes, "entryAlign-" .. align)
  end

  -- empty -> nbsp and no delimiter
  if trim(ent) == "" then
    ent = "&nbsp;"
    delimiter = ""
  end

  local cls_attr = (#classes > 0) and (' class="' .. table.concat(classes, " ") .. '"') or ""
  local style_attr = (#styles > 0) and (' style="' .. table.concat(styles, "; ") .. '"') or ""

  return string.format("<td%s%s>%s%s%s</td>", cls_attr, style_attr, delimiter, ent, delimiter)
end

local format_cell = M.format_cell


local function split_cells_preserve_empties(s, sep)
  s   = tostring(s or "")
  sep = sep or "&"
  local out, i, n, m = {}, 1, #s, #sep
  if n == 0 then return {""} end
  while true do
    local j = string.find(s, sep, i, true)
    if j then
      out[#out+1] = string.sub(s, i, j - 1)
      i = j + m
      if i > n + 1 then out[#out+1] = "" ; break end
    else
      out[#out+1] = string.sub(s, i)
      break
    end
  end
  return out
end

-- export the local via the module table
M.split_cells_preserve_empties = split_cells_preserve_empties


-- ---------- TeX tabular/array ----------

-- type_ = "tabular" | "array" ; spec like "lcr|l" (only l/c/r kept)
function M.tex_tabular_to_html(s, type_, spec)
  local type__ = type_ or "tabular"

  -- parse alignment spec -> only l/c/r kept
  local specList = {}
  if spec and spec ~= "" then
    for ch in spec:gmatch(".") do
      if ch == "l" or ch == "c" or ch == "r" then
        table.insert(specList, ch)
      end
    end
  end

  -- 1) Robust row split (keep newlines; ensure trailing \\)
  local src = s or ""
  src = src:gsub("\r\n", "\n")
  src = src:gsub("\\toprule", "\\toprule\\\\")
           :gsub("\\midrule", "\\midrule\\\\")
           :gsub("\\bottomrule", "\\bottomrule\\\\")
  if not src:find("\\\\%s*$") then
    src = src .. "\\\\"
  end

  local rows = {}
  for line in src:gmatch("(.-)\\\\") do
    table.insert(rows, rtrim(line))
  end

  -- 2) Split rows into cells, preserving empties (including trailing)
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
      local cells = split_cells_preserve_empties(line,"&")
      table.insert(matrix, cells)
      if #cells > maxw then maxw = #cells end
    end
  end

  -- If spec length gives a stronger column count, use it
  local target_w = math.max(maxw, #specList)

  -- 3) Render
  local html_rows = {}
  for _, row in ipairs(matrix) do
    if row[1] == "__RULE__" then
      local cls = (row[2] == "top" and "toprule") or (row[2] == "mid" and "midrule") or "bottomrule"
      table.insert(html_rows, '<tr class="' .. cls .. '"><td colspan="100"></td></tr>\n')
    else
      -- pad rows to target width with empty cells (keeps rectangular shape)
      while #row < target_w do table.insert(row, "\\none") end
      local tds = {}
      for i, cell in ipairs(row) do
        local align = (specList[i] == "l" or specList[i] == "c" or specList[i] == "r") and specList[i] or ""
        local delim = (type__ == "array") and "$" or ""
        table.insert(tds, format_cell(cell, { delimiter = delim, align = align }))
      end
      table.insert(html_rows, "<tr>" .. table.concat(tds, "") .. "</tr>\n")
    end
  end

  return string.format('<table class="%s">%s</table>', type__, table.concat(html_rows, ""))
end

local tex_tabular_to_html = M.tex_tabular_to_html

-- ---------- ytableaushort{...} ----------
-- Split a ytableaushort row into tokens (cells)
-- Handles balanced {...} blocks and single-character cells
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
      local tok = row:sub(i, j - 1)  -- include closing }
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

 -- print_info("Split ytableaushort row '%s' into tokens: %s", row, table.concat(toks, "|"))

  return toks
end


-- opts = { delimiter = "$" | "" }
function M.ytableaushort_to_html(argstr, opts)
  opts = opts or {}
  local delim = (opts.delimiter ~= nil) and opts.delimiter or "$"

 -- print_info("Converting ytableaushort '%s' to HTML with delimiter '%s'", argstr, delim)

  local s = trim(argstr or "")

  -- rows separated by top-level commas
  local rows = split_top_level_commas(s)

  -- Turn each row into tokens (compact or spaced/& style)
  local row_tokens = {}
  local maxw = 0
  for _, row in ipairs(rows) do
    local toks = split_yshort_row(row)
    row_tokens[#row_tokens+1] = toks
    if #toks > maxw then maxw = #toks end
  end

  -- Pad with \none to rectangularize
  for i, toks in ipairs(row_tokens) do
    pad_right(toks, maxw, "\\none")
    row_tokens[i] = toks
  end


local html_rows = {}
  for _, toks in ipairs(row_tokens) do
    local tds = {}
    for _, tok in ipairs(toks) do
      -- Strip outer braces if present
      local cell_content = tok
      if cell_content:sub(1, 1) == "{" and cell_content:sub(-1) == "}" then
        cell_content = cell_content:sub(2, -2)
      end
      table.insert(tds, format_cell(cell_content, { delimiter = delim }))
    end
    table.insert(html_rows, "<tr>" .. table.concat(tds, "") .. "</tr>\n")
  end

  return '<table class="ytab">' .. table.concat(html_rows, "") .. "</table>\n"
end



local ytableaushort_to_html = M.ytableaushort_to_html


-- ---------- \begin{ytableau} ... \end{ytableau} / youngtab ----------

-- ytableau / youngtab body -> HTML
-- opts = { delimiter = "$" | "" }
function M.youngtab_to_html(body, opts)
  opts = opts or {}
  local delim = (opts.delimiter ~= nil) and opts.delimiter or "$"

  -- 1) Robust row split: DON'T strip newlines; just ensure a trailing '\\'
  local s = body or ""
  s = s:gsub("\r\n", "\n")
  if not s:find("\\\\%s*$") then
    s = s .. "\\\\"
  end

  local lines = {}
  for line in s:gmatch("(.-)\\\\") do
    -- keep whitespace significant inside cells, but drop row-end whitespace
    table.insert(lines, rtrim(line))
  end

  -- 2) Split rows into cells, preserving empties
  local rows, maxw = {}, 0
  for _, line in ipairs(lines) do
    if line ~= "" or true then  -- keep empty-only rows too
      local cells = split_cells_preserve_empties(line, "&")
      rows[#rows+1] = cells
      if #cells > maxw then maxw = #cells end
    end
  end

  -- 3) Pad to rectangle with \none (borderless)
  for i, cells in ipairs(rows) do
    while #cells < maxw do table.insert(cells, "\\none") end
    rows[i] = cells
  end

  -- 4) Render cells
  local html_rows = {}
  for _, cells in ipairs(rows) do
    local tds = {}
    for _, e in ipairs(cells) do
      table.insert(tds, format_cell(e, { delimiter = delim }))
    end
    table.insert(html_rows, "<tr>" .. table.concat(tds, "") .. "</tr>\n")
  end

  return '<table class="ytab">\n' .. table.concat(html_rows, "") .. "</table>\n"
end



local youngtab_to_html = M.youngtab_to_html

-- ---------- Convenience parser that detects and converts common TeX forms ----------

function M.transform_tex_snippet(s)
  if not s or s == "" then return nil end
  local src = trim(s)

  -- commands...
  local cmd, arg = src:match("^\\(%a+)%s*(%b{})%s*$")
  if cmd and arg then
    local inner = arg:sub(2, -2)
    if cmd == "ytableaushort" then
      return ytableaushort_to_html(inner, { delimiter = "$" })
    elseif cmd == "textytableaushort" then
      return ytableaushort_to_html(inner, { delimiter = "" })
    end
  end

--   -- environments...
--   local young_body = src:match("^%s*\\begin%s*%{youngtab%}%s*([%s%S]-)%s*\\end%s*%{youngtab%}%s*$")
--   if young_body then
--     return youngtab_to_html(young_body, { delimiter = "$" })
--   end

  local ytab_body = src:match("^%s*\\begin%s*%{ytableau%}%s*([%s%S]-)%s*\\end%s*%{ytableau%}%s*$")
  if ytab_body then
    return youngtab_to_html(ytab_body, { delimiter = "$" })
  end

  local youngtext_body = src:match("^%s*\\begin%s*%{youngtabtext%}%s*([%s%S]-)%s*\\end%s*%{youngtabtext%}%s*$")
  if youngtext_body then
    return youngtab_to_html(youngtext_body, { delimiter = "" })
  end

  --  \begin{array}{...}...\end{array}
  local a_cols, a_body = src:match("^%s*\\begin%s*%{array%}%s*(%b{})%s*([%s%S]-)%s*\\end%s*%{array%}%s*$")
  if a_cols and a_body then
    return tex_tabular_to_html(a_body, "array", trim(a_cols:sub(2,-2)))
  end

  -- \begin{rawtabular}{...}...\end{rawtabular}
  local t_cols, t_body = src:match("^%s*\\begin%s*%{rawtabular%}%s*(%b{})%s*([%s%S]-)%s*\\end%s*%{rawtabular%}%s*$")
  if t_cols and t_body then
    return tex_tabular_to_html(t_body, "tabular", trim(t_cols:sub(2,-2)))
  end

  return nil
end


-- ---------- Return module ----------
return M
