-- ============================================================================
-- JSON Library Detection and Decoding
-- ============================================================================

-- luacheck: globals pandoc
-- luacheck: ignore 113/json (checking for global json library)

---@diagnostic disable-next-line: undefined-global
local pandoc      = pandoc
---@diagnostic disable-next-line: undefined-field
local g_json      = _G.json

local utils       = dofile("utils.lua")
local print_warn  = utils.print_warn
local print_error = utils.print_error

-- Try multiple JSON libraries in order of preference
local JSON_LIB    = (function()
  -- 1) Pandoc's decoder (when running inside pandoc)
  if type(pandoc) == "table" and pandoc.json and pandoc.json.decode then
    return { lib = pandoc.json, name = "pandoc.json" }
  end

  -- 2) dkjson (pure Lua)
  local ok, dkjson = pcall(require, "dkjson")
  if ok and dkjson and dkjson.decode then
    return { lib = dkjson, name = "dkjson" }
  end

  -- 3) lunajson (pure Lua, fast)
  local ok, lunajson = pcall(require, "lunajson")
  if ok and lunajson and lunajson.decode then
    return { lib = lunajson, name = "lunajson" }
  end

  -- 4) cjson (C module)
  local ok, cjson = pcall(require, "cjson")
  if ok and cjson and cjson.decode then
    return { lib = cjson, name = "cjson" }
  end

  -- 5) Global json fallback
  if g_json and g_json.decode then
    return { lib = g_json, name = "_G.json" }
  end

  return nil
end)()


-- Decode JSON string with error handling
-- @param s: JSON string
-- @param what: description for error messages (optional)
-- @param strict: if true, error on failure; if false, return empty table (default: false)
-- @return decoded table or empty table on error
local function json_decode(s, what, strict)
  if not JSON_LIB or not JSON_LIB.lib or not JSON_LIB.lib.decode then
    local msg = "No JSON library available (tried pandoc.json, dkjson, lunajson, cjson, _G.json)"
    if strict then
      error(msg)
    else
      print_warn(msg)
    end
    return {}
  end

  local ok, data, err

  -- dkjson returns (obj, pos, err) format
  if JSON_LIB.name == "dkjson" then
    data, _, err = JSON_LIB.lib.decode(s, 1, nil)
    ok = (data ~= nil)
  else
    ok, data = pcall(JSON_LIB.lib.decode, s)
  end

  if not ok or type(data) ~= "table" then
    local msg = string.format("Could not decode %s: %s", what or "JSON", tostring(err or data or "unknown error"))
    if strict then
      error(msg)
    else
      print_warn(msg)
      return {}
    end
  end

  return data
end

-- ============================================================================
-- File Reading
-- ============================================================================

-- Check if a file exists and is readable
-- @param path: file path
-- @return true if file exists and is readable, false otherwise
local function file_exists(path)
  local f = io.open(path, "r")
  if f then
    f:close()
    return true
  end
  return false
end

-- Read file contents
-- @param path: file path
-- @param what: description for error messages (optional)
-- @param strict: if true, error/exit on failure; if false, return nil (default: true)
-- @return file contents or nil on error
local function read_file(path, what, strict)
  if strict == nil then strict = true end

  local f, err = io.open(path, "r")
  if not f then
    local msg = string.format("Could not open %s '%s': %s", what or "file", path, err or "")
    if strict then
      print_error(msg)
      os.exit(1)
    else
      print_warn(msg)
    end
    return nil
  end

  local s = f:read("*a")
  f:close()
  return s
end

-- Load and decode JSON file
-- @param path: file path
-- @param what: description for error messages (optional)
-- @param strict: if true, error/exit on failure; if false, return empty table (default: false)
-- @return decoded table or empty table on error
local function load_json_file(path, what, strict)
  local contents = read_file(path, what, strict)
  if not contents then
    return {}
  end
  return json_decode(contents, what or path, strict)
end

-- ============================================================================
-- JSON Input Reading (for CLI tools)
-- ============================================================================

-- Read JSON from file argument or stdin
-- @param args: argument table (optional, defaults to global arg)
-- @param strict: if true, exit on error; if false, return nil (default: true)
-- @return decoded JSON table
local function read_json_input(args, strict)
  args = args or arg
  if strict == nil then strict = true end

  -- Try to read from file argument
  if args and args[1] and args[1] ~= "-" then
    local doc = load_json_file(args[1], "JSON data", false)
    if not doc or next(doc) == nil then
      if strict then
        print_error("JSON decode error reading %s", args[1])
        os.exit(1)
      else
        return nil
      end
    end
    return doc
  end

  -- Read from stdin
  local contents = io.read("*a")
  local doc = json_decode(contents, "stdin JSON", false)
  if not doc or type(doc) ~= "table" then
    if strict then
      print_error("JSON decode error reading from stdin")
      os.exit(1)
    else
      return nil
    end
  end

  return doc
end


-- Encode table as JSON string
-- @param tbl: table to encode
-- @param indent: if true, produce indented/pretty JSON (default: true)
-- @param strict: if true, error on failure; if false, return nil (default: true)
-- @return JSON string or nil on error
local function json_encode(tbl, indent, strict)
  if indent == nil then indent = true end
  if strict == nil then strict = true end

  if not JSON_LIB or not JSON_LIB.lib or not JSON_LIB.lib.encode then
    local msg = "No JSON encoder available (tried pandoc.json, dkjson, lunajson, cjson, _G.json)"
    if strict then
      error(msg)
    else
      print_warn(msg)
    end
    return nil
  end

  local ok, result

  -- Try encoding with indentation if supported
  if indent and JSON_LIB.name == "dkjson" then
    ok, result = pcall(JSON_LIB.lib.encode, tbl, { indent = true })
  else
    ok, result = pcall(JSON_LIB.lib.encode, tbl)
  end

  if not ok then
    local msg = string.format("Could not encode table to JSON: %s", tostring(result))
    if strict then
      error(msg)
    else
      print_warn(msg)
      return nil
    end
  end

  return result
end

-- ============================================================================
-- Exports
-- ============================================================================

return {
  json_decode = json_decode,
  file_exists = file_exists,
  read_file = read_file,
  load_json_file = load_json_file,
  read_json_input = read_json_input,
  json_encode = json_encode,
}
