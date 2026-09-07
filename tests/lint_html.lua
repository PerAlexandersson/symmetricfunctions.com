local function read_file(path)
  local f, err = io.open(path, "r")
  if not f then
    io.stderr:write(string.format("[ERROR] lint-html: cannot read %s: %s\n",
      path, err or "unknown error"))
    return nil
  end
  local text = f:read("*a")
  f:close()
  return text
end

local function shell_quote(s)
  return "'" .. tostring(s):gsub("'", "'\\''") .. "'"
end

local function html_files_from_dir(dir)
  local files = {}
  local cmd = "find " .. shell_quote(dir) .. " -type f -name '*.htm' | sort"
  local p = io.popen(cmd)
  if not p then return files end
  for path in p:lines() do
    files[#files + 1] = path
  end
  p:close()
  return files
end

local checks = {
  {
    label = "raw \\hyperref command leaked into HTML",
    pattern = "\\hyperref",
    plain = true,
  },
  {
    label = "raw \\toprule command leaked into HTML",
    pattern = "\\toprule",
    plain = true,
  },
  {
    label = "raw \\midrule command leaked into HTML",
    pattern = "\\midrule",
    plain = true,
  },
  {
    label = "raw \\bottomrule command leaked into HTML",
    pattern = "\\bottomrule",
    plain = true,
  },
  {
    label = "escaped generated <span> tag",
    pattern = "&lt;span",
    plain = true,
  },
  {
    label = "escaped generated </span> tag",
    pattern = "&lt;/span",
    plain = true,
  },
  {
    label = "escaped generated <a> tag",
    pattern = "&lt;a%s",
  },
  {
    label = "escaped generated </a> tag",
    pattern = "&lt;/a&gt;",
    plain = true,
  },
  {
    label = "escaped generated <strong> tag",
    pattern = "&lt;strong",
    plain = true,
  },
  {
    label = "escaped generated <em> tag",
    pattern = "&lt;em",
    plain = true,
  },
  {
    label = "escaped generated <code> tag",
    pattern = "&lt;code",
    plain = true,
  },
  {
    label = "TeX table conversion error marker",
    pattern = "tex%-error",
  },
  {
    label = "undefined label/citation marker",
    pattern = "UNDEF:",
    plain = true,
  },
  {
    label = "source-location annotation leaked into visible HTML",
    pattern = "@@[%w%._/%-]+%.tex:%d+",
  },
}

local files = {}
for i = 1, #arg do
  files[#files + 1] = arg[i]
end

if #files == 0 then
  files = html_files_from_dir(os.getenv("WWW_DIR") or "www")
end

local error_count = 0
local max_errors = tonumber(os.getenv("LINT_HTML_MAX_ERRORS") or "200") or 200
local www_dir = os.getenv("WWW_DIR") or "www"

local function report(path, lineno, label, line)
  error_count = error_count + 1
  if error_count <= max_errors then
    line = tostring(line or ""):gsub("^%s+", ""):gsub("%s+$", "")
    if #line > 180 then line = line:sub(1, 177) .. "..." end
    io.stderr:write(string.format(
      "[ERROR] lint-html: %s:%d: %s\n  %s\n",
      path, lineno, label, line))
  end
end

for _, path in ipairs(files) do
  local text = read_file(path)
  if text then
    local lineno = 0
    for line in (text .. "\n"):gmatch("([^\n]*)\n") do
      lineno = lineno + 1
      for _, check in ipairs(checks) do
        if line:find(check.pattern, 1, check.plain == true) then
          report(path, lineno, check.label, line)
        end
      end
    end
  else
    error_count = error_count + 1
  end
end

local sitemap_path = www_dir .. "/sitemap.xml"
local sitemap = read_file(sitemap_path)
if sitemap then
  local canonical_prefix = "https://www.symmetricfunctions.com/"
  local excluded_slugs = {
    ["403.htm"] = true,
    ["404.htm"] = true,
  }
  for url in sitemap:gmatch("<loc>(.-)</loc>") do
    local slug = url:match("^" .. canonical_prefix:gsub("([^%w])", "%%%1") .. "(.+)$")
    if not slug then
      report(sitemap_path, 1, "sitemap URL is outside the canonical site", url)
    elseif excluded_slugs[slug] then
      report(sitemap_path, 1, "error document included in sitemap", url)
    else
      local page_path = www_dir .. "/" .. slug
      local page = read_file(page_path)
      if not page then
        error_count = error_count + 1
      else
        local canonical = page:match('<link%s+rel="canonical"%s+href="([^"]+)"%s*/?>')
        if canonical ~= url then
          report(
            page_path,
            1,
            "canonical URL does not match sitemap URL",
            string.format("expected %s, found %s", url, canonical or "none")
          )
        end
        local og_url = page:match('<meta%s+property="og:url"%s+content="([^"]+)"%s*/?>')
        if og_url ~= url then
          report(
            page_path,
            1,
            "Open Graph URL does not match sitemap URL",
            string.format("expected %s, found %s", url, og_url or "none")
          )
        end
      end
    end
  end
else
  error_count = error_count + 1
end

if error_count > max_errors then
  io.stderr:write(string.format(
    "[ERROR] lint-html: suppressed %d additional error(s)\n",
    error_count - max_errors))
end

if error_count > 0 then
  os.exit(1)
end
