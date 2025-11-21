

-- ===== Small utils =========================================================


-- --- add once near your helpers ---
local ACCENT_MAP = {
  ["á"]="a",["à"]="a",["ä"]="a",["â"]="a",["ã"]="a",["å"]="a",["ā"]="a",
  ["Á"]="A",["À"]="A",["Ä"]="A",["Â"]="A",["Ã"]="A",["Å"]="A",["Ā"]="A",
  ["č"]="c",["ć"]="c",["ç"]="c",["Č"]="C",["Ć"]="C",["Ç"]="C",
  ["ď"]="d",["Đ"]="D",["đ"]="d",
  ["é"]="e",["è"]="e",["ë"]="e",["ê"]="e",["ē"]="e",["É"]="E",["È"]="E",["Ë"]="E",["Ê"]="E",["Ē"]="E",
  ["í"]="i",["ì"]="i",["ï"]="i",["î"]="i",["ī"]="i",["Í"]="I",["Ì"]="I",["Ï"]="I",["Î"]="I",["Ī"]="I",
  ["ł"]="l",["Ł"]="L",
  ["ñ"]="n",["Ń"]="N",["ń"]="n",
  ["ó"]="o",["ò"]="o",["ö"]="o",["ô"]="o",["õ"]="o",["ō"]="o",["ø"]="o",["Ó"]="O",["Ò"]="O",["Ö"]="O",["Ô"]="O",["Õ"]="O",["Ō"]="O",["Ø"]="O",
  ["œ"]="oe",["Œ"]="OE",
  ["ś"]="s",["š"]="s",["ş"]="s",["Ś"]="S",["Š"]="S",["Ş"]="S",
  ["ß"]="ss",
  ["ť"]="t",["ț"]="t",["Ţ"]="T",["ț"]="t",
  ["ú"]="u",["ù"]="u",["ü"]="u",["û"]="u",["ū"]="u",["Ú"]="U",["Ù"]="U",["Ü"]="U",["Û"]="U",["Ū"]="U",
  ["ý"]="y",["ÿ"]="y",["Ý"]="Y",
  ["ž"]="z",["ż"]="z",["ź"]="z",["Ž"]="Z",["Ż"]="Z",["Ź"]="Z",
  ["ğ"]="g",["Ğ"]="G"
}


local UTF8_CP = "[%z\1-\127\194-\244][\128-\191]*"

local function ascii_fold_string(s)
  -- replace known accented codepoints
  s = s:gsub(UTF8_CP, function(cp) return ACCENT_MAP[cp] or cp end)

  -- keep only ASCII alnum, brackets, and +-
  s = s:gsub("[^%[%]A-Za-z0-9+-]", "")
  return s
end


local function set_add(set, k)
    if k and k~="" then set[k]=true end
end

local function set_to_sorted_list(set)
    local t={}
    for k in pairs(set) do t[#t+1]=k end table.sort(t)
    return t
end

local function ltrim(s)
  s = s or ""
  local t = s:match("^%s*(.*)$")
  return t
end

local function rtrim(s)
  s = s or ""
  local t = s:match("^(.-)%s*$")
  return t
end

local function trim(s)
  return rtrim(ltrim(s))
end

local function html_escape(s)
  return (s:gsub("&","&amp;"):gsub("<","&lt;"):gsub(">","&gt;"))
end


function capitalize_first(s)
  if type(s) ~= "string" then return s end
  return (s:gsub("^(%s*)(%a)", function(sp, a) return sp .. a:upper() end, 1))
end

local function normalize_url(u)
  u = u:gsub("^%s+",""):gsub("%s+$","")
  local scheme = u:match("^([%a][%w+.-]*):")
  local href = u
  if not scheme then
    href = u:match("^//") and ("https:"..u) or ("https://"..u)
    scheme = "https"
  end
  local display = u
  if scheme == "http" or scheme == "https" then
    display = u:gsub("^https?://",""):gsub("^//","")
  end
  return href, display
end


-- Slugify (for ids/anchors): ASCII fold + lowercase + dash collapse
local function slugify(s)
  s = ascii_fold_string(s or "", "_%-")  -- allow - and _
  s = s:lower():gsub("%s+", "-"):gsub("%-+", "-"):gsub("^%-",""):gsub("%-$","")
  return s
end

-- ===== Console helpers  =======================================
local function _color_enabled()
  if os.getenv("NO_COLOR") then return false end
  local is_windows = package.config:sub(1,1) == "\\"
  if is_windows then
    return os.getenv("ANSICON") or os.getenv("WT_SESSION") or os.getenv("ConEmuANSI") == "ON"
  else
    local term = os.getenv("TERM") or ""
    return term ~= "" and term ~= "dumb"
  end
end

local CONSOLE = {
  -- reset
  reset      = "\27[0m",

  -- text styles
  bold       = "\27[1m",
  dim        = "\27[2m",
  italic     = "\27[3m",
  underline  = "\27[4m",
  blink      = "\27[5m",
  inverse    = "\27[7m",
  hidden     = "\27[8m",
  strike     = "\27[9m",

  -- 8 standard foreground colors
  black      = "\27[30m",
  red        = "\27[31m",
  green      = "\27[32m",
  yellow     = "\27[33m",
  blue       = "\27[34m",
  magenta    = "\27[35m",
  cyan       = "\27[36m",
  white      = "\27[37m",

  -- 8 bright foreground colors
  bright_black   = "\27[90m",
  bright_red     = "\27[91m",
  bright_green   = "\27[92m",
  bright_yellow  = "\27[93m",
  bright_blue    = "\27[94m",
  bright_magenta = "\27[95m",
  bright_cyan    = "\27[96m",
  bright_white   = "\27[97m",

  -- standard backgrounds
  bg_black    = "\27[40m",
  bg_red      = "\27[41m",
  bg_green    = "\27[42m",
  bg_yellow   = "\27[43m",
  bg_blue     = "\27[44m",
  bg_magenta  = "\27[45m",
  bg_cyan     = "\27[46m",
  bg_white    = "\27[47m",

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

local function _fmt(fmt, ...) return (select("#", ...) > 0) and string.format(fmt, ...) or tostring(fmt) end

local function print_todo(fmt, ...)
  local m=_fmt(fmt,...);
  if #m>60 then m=m:sub(1,57).."..." end
  if _use_color then io.stderr:write(CONSOLE.yellow," 📝  todo: ",CONSOLE.cyan,m,CONSOLE.reset,"\n")
  else io.stderr:write("[TODO] ", m ,"\n") end
end

local function print_warn(fmt, ...)
  local m=_fmt(fmt,...);
  if _use_color then io.stderr:write(CONSOLE.yellow," ⚠ warn: ",CONSOLE.yellow,m,CONSOLE.reset,"\n")
  else io.stderr:write("[WARN] ",m,"\n") end
end

local function print_info(fmt, ...)
  local m=_fmt(fmt,...); if _use_color then io.stderr:write(CONSOLE.bold," ℹ️ ",CONSOLE.reset," ",m,"\n")
  else io.stderr:write("[INFO] ",m,"\n") end
end

local function print_color(col, fmt, ...)
  local m=_fmt(fmt,...); if _use_color then io.stderr:write(col,m,CONSOLE.reset,"\n")
  else io.stderr:write("[INFO] ",m,"\n") end
end

local function print_error(fmt, ...)
  local m=_fmt(fmt,...);
  if _use_color then io.stderr:write(CONSOLE.bg_red,CONSOLE.black," ✖ ",CONSOLE.reset," ",CONSOLE.red,m,CONSOLE.reset,"\n")
    else io.stderr:write("[ERROR] ",m,"\n")
  end
end





-- ===== JSON helpers =====================================================

-- Prefer dkjson; fall back to pandoc.json or _G.json
local JSON_LIB = (function()
  local ok, m = pcall(require, "dkjson")
  if ok and m then return m end
  if type(pandoc) == "table" and pandoc.json and pandoc.json.decode then
    return pandoc.json
  end
  if _G.json and _G.json.decode then
    return _G.json
  end
  return nil
end)()

local function json_decode_safe(s, what)
  if not JSON_LIB or not JSON_LIB.decode then
    error("No JSON library available (dkjson/pandoc.json). Install lua-dkjson.")
  end
  local ok, data = pcall(JSON_LIB.decode, s)
  if not ok or type(data) ~= "table" then
    print_warn("Could not decode %s JSON", what or "JSON")
    return {}
  end
  return data
end

local function load_json_file(path, what)
  local f, err = io.open(path, "r")
  if not f then
    print_warn("Could not read %s JSON at %s", what or "JSON", path)
    return {}
  end
  local s = f:read("*a")
  f:close()
  return json_decode_safe(s, what)
end

local function file_exists(path)
  local f = io.open(path, "r")
  if f ~= nil then
    f:close()
    return true
  end
  return false
end

return {
  ascii_fold_string = ascii_fold_string,
  trim = trim,
  ltrim = ltrim,
  rtrim = rtrim,
  slugify = slugify,
  html_escape = html_escape,
  capitalize_first = capitalize_first,
  set_add = set_add,
  set_to_sorted_list = set_to_sorted_list,
  normalize_url = normalize_url,
  CONSOLE = CONSOLE,
  print_error = print_error,
  print_todo = print_todo,
  print_warn = print_warn,
  print_info = print_info,
  print_color = print_color,
  json_lib = JSON_LIB,
  json_decode_safe = json_decode_safe,
  load_json_file = load_json_file,
  file_exists = file_exists,
}
