-- Extract raw BibTeX entries from bibliography.bib into a JSON object.
--
-- The regular bibliography pipeline converts BibTeX to CSL JSON for display.
-- This companion extractor preserves source BibTeX entries for copy/download
-- controls in the rendered bibliography.

local file_reading = dofile("file_reading.lua")
local utils = dofile("utils.lua")

local trim = utils.trim
local print_error = utils.print_error
local has_errors = utils.has_errors

local input_path = arg[1] or "bibliography.bib"
local source = file_reading.read_file(input_path, "BibTeX source", true)

local function skip_space(s, pos)
  while pos <= #s and s:sub(pos, pos):match("%s") do
    pos = pos + 1
  end
  return pos
end

local function find_entry_end(s, open_pos, open_char)
  local close_char = (open_char == "{") and "}" or ")"
  local depth = 1
  local escaped = false
  local pos = open_pos + 1

  while pos <= #s do
    local ch = s:sub(pos, pos)
    if escaped then
      escaped = false
    elseif ch == "\\" then
      escaped = true
    elseif ch == open_char then
      depth = depth + 1
    elseif ch == close_char then
      depth = depth - 1
      if depth == 0 then
        return pos
      end
    end
    pos = pos + 1
  end

  return nil
end

local function extract_key(entry, open_pos, close_pos)
  local body = entry:sub(open_pos + 1, close_pos - 1)
  return body:match("^%s*([^,%s]+)%s*,")
end

local entries = {}
local pos = 1

while true do
  local at = source:find("@", pos, true)
  if not at then break end

  local type_start = skip_space(source, at + 1)
  local entry_type = source:match("^([%a]+)", type_start)
  if not entry_type then
    pos = at + 1
  else
    local after_type = skip_space(source, type_start + #entry_type)
    local open_char = source:sub(after_type, after_type)
    if open_char ~= "{" and open_char ~= "(" then
      pos = at + 1
    else
      local close_pos = find_entry_end(source, after_type, open_char)
      if not close_pos then
        print_error("Unclosed BibTeX entry beginning near byte %d", at)
        break
      end

      local raw = trim(source:sub(at, close_pos)) .. "\n"
      local lower_type = entry_type:lower()
      if lower_type ~= "comment" and lower_type ~= "preamble"
          and lower_type ~= "string" then
        local key = extract_key(raw, after_type - at + 1, close_pos - at + 1)
        if not key or key == "" then
          print_error("BibTeX entry beginning near byte %d has no citation key", at)
        elseif entries[key] then
          print_error("Duplicate BibTeX key: %s", key)
        else
          entries[key] = raw
        end
      end

      pos = close_pos + 1
    end
  end
end

if has_errors() then
  os.exit(1)
end

io.write(file_reading.json_encode(entries, true, true))
io.write("\n")
