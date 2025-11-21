-- ============================================================================
-- String Utilities
-- ============================================================================

-- Map of accented characters to their ASCII equivalents
local ACCENT_MAP = {
  ["á"] = "a", ["à"] = "a", ["ä"] = "a", ["â"] = "a", ["ã"] = "a", ["å"] = "a", ["ā"] = "a",
  ["Á"] = "A", ["À"] = "A", ["Ä"] = "A", ["Â"] = "A", ["Ã"] = "A", ["Å"] = "A", ["Ā"] = "A",
  ["č"] = "c", ["ć"] = "c", ["ç"] = "c",
  ["Č"] = "C", ["Ć"] = "C", ["Ç"] = "C",
  ["ď"] = "d", ["Đ"] = "D", ["đ"] = "d",
  ["é"] = "e", ["è"] = "e", ["ë"] = "e", ["ê"] = "e", ["ē"] = "e",
  ["É"] = "E", ["È"] = "E", ["Ë"] = "E", ["Ê"] = "E", ["Ē"] = "E",
  ["í"] = "i", ["ì"] = "i", ["ï"] = "i", ["î"] = "i", ["ī"] = "i",
  ["Í"] = "I", ["Ì"] = "I", ["Ï"] = "I", ["Î"] = "I", ["Ī"] = "I",
  ["ł"] = "l", ["Ł"] = "L",
  ["ñ"] = "n", ["Ń"] = "N", ["ń"] = "n",
  ["ó"] = "o", ["ò"] = "o", ["ö"] = "o", ["ô"] = "o", ["õ"] = "o", ["ō"] = "o", ["ø"] = "o",
  ["Ó"] = "O", ["Ò"] = "O", ["Ö"] = "O", ["Ô"] = "O", ["Õ"] = "O", ["Ō"] = "O", ["Ø"] = "O",
  ["œ"] = "oe", ["Œ"] = "OE",
  ["ś"] = "s", ["š"] = "s", ["ş"] = "s",
  ["Ś"] = "S", ["Š"] = "S", ["Ş"] = "S",
  ["ß"] = "ss",
  ["ť"] = "t", ["Ţ"] = "T", ["ț"] = "t",
  ["ú"] = "u", ["ù"] = "u", ["ü"] = "u", ["û"] = "u", ["ū"] = "u",
  ["Ú"] = "U", ["Ù"] = "U", ["Ü"] = "U", ["Û"] = "U", ["Ū"] = "U",
  ["ý"] = "y", ["ÿ"] = "y", ["Ý"] = "Y",
  ["ž"] = "z", ["ż"] = "z", ["ź"] = "z",
  ["Ž"] = "Z", ["Ż"] = "Z", ["Ź"] = "Z",
  ["ğ"] = "g", ["Ğ"] = "G"
}

--- Convert accented characters to ASCII equivalents and remove non-alphanumeric characters.
--- Keeps ASCII alphanumeric characters, brackets [], and +- symbols.
--- @param s string Input string with potential accented characters
--- @return string ASCII-folded string with only allowed characters
local function ascii_fold_string(s)
  -- Replace known accented UTF-8 codepoints
  local UTF8_CP = "[%z\1-\127\194-\244][\128-\191]*"
  s = s:gsub(UTF8_CP, function(cp) return ACCENT_MAP[cp] or cp end)

  -- Keep only ASCII alphanumeric, brackets, and +-
  s = s:gsub("[^%[%]A-Za-z0-9+-]", "")
  return s
end

--- Remove leading whitespace from a string.
--- @param s string|nil Input string (nil-safe)
--- @return string String with leading whitespace removed
local function ltrim(s)
  s = s or ""
  local t = s:match("^%s*(.*)$")
  return t
end

--- Remove trailing whitespace from a string.
--- @param s string|nil Input string (nil-safe)
--- @return string String with trailing whitespace removed
local function rtrim(s)
  s = s or ""
  local t = s:match("^(.-)%s*$")
  return t
end

--- Remove leading and trailing whitespace from a string.
--- @param s string|nil Input string (nil-safe)
--- @return string Trimmed string
local function trim(s)
  return rtrim(ltrim(s))
end

--- Escape HTML special characters (&, <, >).
--- @param s string Input string
--- @return string HTML-escaped string
local function html_escape(s)
  return (s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"))
end

--- Capitalize the first letter of a string, preserving leading whitespace.
--- @param s string|any Input string (returns unchanged if not a string)
--- @return string|any String with first letter capitalized, or original value if not a string
local function capitalize_first(s)
  if type(s) ~= "string" then return s end
  return (s:gsub("^(%s*)(%a)", function(sp, a) return sp .. a:upper() end, 1))
end

--- Normalize a URL by adding scheme if missing and extracting display text.
--- Assumes https:// if no scheme is present.
--- @param u string Input URL (may be partial)
--- @return string href Full URL with scheme
--- @return string display URL without scheme (for display purposes)
local function normalize_url(u)
  u = u:gsub("^%s+", ""):gsub("%s+$", "")
  local scheme = u:match("^([%a][%w+.-]*):")
  local href = u
  if not scheme then
    href = u:match("^//") and ("https:" .. u) or ("https://" .. u)
    scheme = "https"
  end
  local display = u
  if scheme == "http" or scheme == "https" then
    display = u:gsub("^https?://", ""):gsub("^//", "")
  end
  return href, display
end

--- Convert a string to a URL-safe slug.
--- ASCII-folds, lowercases, converts spaces to dashes, and removes leading/trailing dashes.
--- @param s string|nil Input string
--- @return string URL-safe slug
local function slugify(s)
  s = ascii_fold_string(s or "")
  s = s:lower():gsub("%s+", "-"):gsub("%-+", "-"):gsub("^%-", ""):gsub("%-$", "")
  return s
end

-- ============================================================================
-- Table Utilities
-- ============================================================================

--- Add a key to a set (table used as a set with keys as true values).
--- Only adds non-nil, non-empty string keys.
--- @param set table The set to add to
--- @param k any Key to add (only added if truthy and non-empty)
local function set_add(set, k)
  if k and k ~= "" then set[k] = true end
end

--- Convert a set (table with keys) to a sorted list of keys.
--- @param set table Set to convert (keys will become list elements)
--- @return table Sorted array of keys
local function set_to_sorted_list(set)
  local t = {}
  for k in pairs(set) do t[#t + 1] = k end
  table.sort(t)
  return t
end

--- Count the number of key-value pairs in a table.
--- Works for both array and hash tables.
--- @param t table Table to count
--- @return number Number of entries in the table
local function table_size(t)
  local count = 0
  for _ in pairs(t) do count = count + 1 end
  return count
end

-- ============================================================================
-- Console Output (with ANSI color support)
-- ============================================================================

--- Check if color output is enabled based on environment variables.
--- Respects NO_COLOR, and checks for terminal support on Unix/Windows.
--- @return boolean true if color should be used, false otherwise
local function _color_enabled()
  if os.getenv("NO_COLOR") then return false end
  local is_windows = package.config:sub(1, 1) == "\\"
  if is_windows then
    return (os.getenv("ANSICON") ~= nil) or 
           (os.getenv("WT_SESSION") ~= nil) or 
           (os.getenv("ConEmuANSI") == "ON")
  else
    local term = os.getenv("TERM") or ""
    return term ~= "" and term ~= "dumb"
  end
end

--- ANSI color and style codes
local CONSOLE = {
  -- reset
  reset             = "\27[0m",

  -- text styles
  bold              = "\27[1m",
  dim               = "\27[2m",
  italic            = "\27[3m",
  underline         = "\27[4m",
  blink             = "\27[5m",
  inverse           = "\27[7m",
  hidden            = "\27[8m",
  strike            = "\27[9m",

  -- 8 standard foreground colors
  black             = "\27[30m",
  red               = "\27[31m",
  green             = "\27[32m",
  yellow            = "\27[33m",
  blue              = "\27[34m",
  magenta           = "\27[35m",
  cyan              = "\27[36m",
  white             = "\27[37m",

  -- 8 bright foreground colors
  bright_black      = "\27[90m",
  bright_red        = "\27[91m",
  bright_green      = "\27[92m",
  bright_yellow     = "\27[93m",
  bright_blue       = "\27[94m",
  bright_magenta    = "\27[95m",
  bright_cyan       = "\27[96m",
  bright_white      = "\27[97m",

  -- standard backgrounds
  bg_black          = "\27[40m",
  bg_red            = "\27[41m",
  bg_green          = "\27[42m",
  bg_yellow         = "\27[43m",
  bg_blue           = "\27[44m",
  bg_magenta        = "\27[45m",
  bg_cyan           = "\27[46m",
  bg_white          = "\27[47m",

  -- bright backgrounds
  bg_bright_black   = "\27[100m",
  bg_bright_red     = "\27[101m",
  bg_bright_green   = "\27[102m",
  bg_bright_yellow  = "\27[103m",
  bg_bright_blue    = "\27[104m",
  bg_bright_magenta = "\27[105m",
  bg_bright_cyan    = "\27[106m",
  bg_bright_white   = "\27[107m",
}

local _use_color = _color_enabled()

--- Format a string using printf-style formatting, or convert to string if no args.
--- @param fmt string Format string
--- @param ... any Values to format
--- @return string Formatted string
local function _fmt(fmt, ...)
  return (select("#", ...) > 0) and string.format(fmt, ...) or tostring(fmt)
end

--- Print a TODO message to stderr with optional location highlighting.
--- Automatically truncates long messages and highlights file:line locations.
--- @param fmt string Format string or message
--- @param ... any Format arguments
local function print_todo(fmt, ...)
  local m = _fmt(fmt, ...)
  -- Keep a reasonably short line in the log
  m = m:gsub("%s+", " "):gsub("^%s+", ""):gsub("%s+$", "")
  if #m > 160 then m = m:sub(1, 150) .. "..." end

  if not _use_color then
    io.stderr:write("[TODO] ", m, "\n")
    return
  end

  -- Try to split into "location" + "message"
  -- Expect something like "path/to/file.tex:123 rest of message"
  local loc, msg = m:match("^(%S+:%d+)%s*(.*)$")
  if not loc then
    -- Fallback: no recognizable "file:line" prefix
    io.stderr:write(
      CONSOLE.cyan, "todo: ",
      CONSOLE.yellow, m,
      CONSOLE.reset, "\n"
    )
    return
  end

  -- If msg is empty (just "file.tex:123"), keep it non-empty for cosmetics
  if msg == "" then msg = "(no message)" end

  io.stderr:write(
    CONSOLE.cyan, "todo: ",
    CONSOLE.underline, CONSOLE.bright_blue, loc, CONSOLE.reset,
    " ",
    CONSOLE.bright_yellow, msg,
    CONSOLE.reset,
    "\n"
  )
end

--- Print a warning message to stderr.
--- @param fmt string Format string or message
--- @param ... any Format arguments
local function print_warn(fmt, ...)
  local m = _fmt(fmt, ...)
  if _use_color then
    io.stderr:write(CONSOLE.yellow, " ⚠ warn: ", CONSOLE.yellow, m, CONSOLE.reset, "\n")
  else
    io.stderr:write("[WARN] ", m, "\n")
  end
end

--- Print an informational message to stderr.
--- @param fmt string Format string or message
--- @param ... any Format arguments
local function print_info(fmt, ...)
  local m = _fmt(fmt, ...)
  if _use_color then
    io.stderr:write(CONSOLE.bold, " ℹ️ ", CONSOLE.reset, " ", m, "\n")
  else
    io.stderr:write("[INFO] ", m, "\n")
  end
end

--- Print a colored message to stderr.
--- @param col string ANSI color code from CONSOLE table
--- @param fmt string Format string or message
--- @param ... any Format arguments
local function print_color(col, fmt, ...)
  local m = _fmt(fmt, ...)
  if _use_color then
    io.stderr:write(col, m, CONSOLE.reset, "\n")
  else
    io.stderr:write("[INFO] ", m, "\n")
  end
end

--- Print an error message to stderr with red highlighting.
--- @param fmt string Format string or message
--- @param ... any Format arguments
local function print_error(fmt, ...)
  local m = _fmt(fmt, ...)
  if _use_color then
    io.stderr:write(CONSOLE.bg_red, CONSOLE.black, " ✖ ", CONSOLE.reset, " ", CONSOLE.red, m, CONSOLE.reset, "\n")
  else
    io.stderr:write("[ERROR] ", m, "\n")
  end
end

-- ============================================================================
-- Exports
-- ============================================================================

return {
  -- String utilities
  ascii_fold_string = ascii_fold_string,
  trim = trim,
  ltrim = ltrim,
  rtrim = rtrim,
  slugify = slugify,
  html_escape = html_escape,
  capitalize_first = capitalize_first,
  normalize_url = normalize_url,
  
  -- Table utilities
  table_size = table_size,
  set_add = set_add,
  set_to_sorted_list = set_to_sorted_list,
  
  -- Console output
  CONSOLE = CONSOLE,
  print_error = print_error,
  print_todo = print_todo,
  print_warn = print_warn,
  print_info = print_info,
  print_color = print_color,
}