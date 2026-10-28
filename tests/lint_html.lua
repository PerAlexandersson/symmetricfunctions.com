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
    label = "build-time source location leaked into HTML",
    pattern = "data-source-loc",
    plain = true,
  },
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
  {
    label = "Unicode replacement character leaked into HTML",
    pattern = "�",
    plain = true,
  },
  {
    label = "numeric entity was double-escaped",
    pattern = "&amp;#",
    plain = true,
  },
  {
    label = "ampersand entity was double-escaped",
    pattern = "&amp;amp;",
    plain = true,
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
local src_dir = os.getenv("SRC_DIR") or "tex-source"
local assets_dir = os.getenv("ASSETS_DIR") or "assets"

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

    for class_value in text:gmatch('class="([^"]*)"') do
      local seen = {}
      for class_name in class_value:gmatch("%S+") do
        if seen[class_name] then
          report(path, 1, "duplicate token in class attribute", class_value)
          break
        end
        seen[class_name] = true
      end
    end

    for author_link in text:gmatch('<a[^>]-class="[^"]*author%-name[^"]*"[^>]*>.-</a>') do
      if author_link:find("\\", 1, true) or author_link:find("{", 1, true)
          or author_link:find("}", 1, true) then
        report(path, 1, "raw TeX leaked into author-name link", author_link)
      end
    end

    for math_body in text:gmatch("\\%((.-)\\%)") do
      if math_body:find("<", 1, true) or math_body:find(">", 1, true) then
        report(path, 1, "raw HTML angle bracket inside inline math", math_body)
      end
    end
    for math_body in text:gmatch("\\%[(.-)\\%]") do
      if math_body:find("<", 1, true) or math_body:find(">", 1, true) then
        report(path, 1, "raw HTML angle bracket inside display math", math_body)
      end
    end
  else
    error_count = error_count + 1
  end
end

local expected_html = {
  ["goto.htm"] = true,
  ["polynomial-relations.htm"] = true,
}

local function add_expected_from_dir(dir, extension, output_extension)
  local cmd = "find " .. shell_quote(dir) .. " -maxdepth 1 -type f -name '*" ..
      extension .. "' -printf '%f\\n' | sort"
  local p = io.popen(cmd)
  if not p then return end
  for filename in p:lines() do
    local stem = filename:sub(1, #filename - #extension)
    expected_html[stem .. output_extension] = true
  end
  p:close()
end

add_expected_from_dir(src_dir, ".tex", ".htm")
add_expected_from_dir(assets_dir, ".htm", ".htm")

for _, path in ipairs(html_files_from_dir(www_dir)) do
  local relative = path:sub(#www_dir + 2)
  if not expected_html[relative] then
    report(path, 1, "unexpected deployable HTML output", relative)
  end
end

local homepage_path = www_dir .. "/index.htm"
local homepage = read_file(homepage_path)
local search_action_target =
  '"target": "https://www.symmetricfunctions.com/search.htm?q={search_term_string}"'
if homepage then
  if not homepage:find(search_action_target, 1, true) then
    report(homepage_path, 1, "JSON-LD SearchAction target is missing", search_action_target)
  end
  if homepage:find("topicsindex.htm?q=", 1, true) then
    report(homepage_path, 1, "JSON-LD SearchAction targets a missing page", "topicsindex.htm")
  end
else
  error_count = error_count + 1
end

local search_path = www_dir .. "/search.htm"
local search_page = read_file(search_path)
if search_page then
  if not search_page:find('new URLSearchParams(window.location.search).get("q")',
      1, true) then
    report(search_path, 1, "search page does not read the SearchAction query", "q")
  end
  if not search_page:find("pagefindUI.triggerSearch(query)", 1, true) then
    report(search_path, 1, "search page does not submit the SearchAction query", "query")
  end
  if not search_page:find('content="noindex, follow"', 1, true)
      or search_page:find("data-pagefind-body", 1, true) then
    report(search_path, 1, "search page must be noindex and outside the Pagefind index", "robots")
  end
else
  error_count = error_count + 1
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

-- Every deployable page has unique element ids.
for _, path in ipairs(html_files_from_dir(www_dir)) do
  local page = read_file(path)
  if page then
    local seen, reported = {}, {}
    for id in page:gmatch('%sid="([^"]*)"') do
      if seen[id] and not reported[id] then
        report(path, 1, "duplicate element id", id)
        reported[id] = true
      end
      seen[id] = true
    end
  end
end

-- The public label and keyword feeds point at existing anchors and carry
-- plain text (no leftover TeX or source-location markers).
local file_reading = dofile("file_reading.lua")
local page_cache = {}
local function anchor_exists(href)
  local page_name, fragment = href:match("^([^#]+)#?(.*)$")
  if not page_name then return false end
  if page_cache[page_name] == nil then
    local f = io.open(www_dir .. "/" .. page_name, "r")
    page_cache[page_name] = f and f:read("*a") or false
    if f then f:close() end
  end
  local page = page_cache[page_name]
  if not page then return false end
  return fragment == "" or page:find('id="' .. fragment .. '"', 1, true) ~= nil
end
local function looks_like_tex(text)
  text = tostring(text or "")
  return text:find("[\\{}$]") ~= nil or text:find("@@", 1, true) ~= nil
      or text:find("--", 1, true) ~= nil
end

local labels_path = www_dir .. "/site-labels.json"
local labels = file_reading.load_json_file(labels_path, "public labels", false)
if type(labels) == "table" then
  for label, info in pairs(labels) do
    if not anchor_exists(info.href or "") then
      report(labels_path, 1, "label points to a missing anchor", label .. " -> " .. tostring(info.href))
    end
    if looks_like_tex(info.title) then
      report(labels_path, 1, "label title is not plain text", tostring(info.title))
    end
  end
else
  report(labels_path, 1, "public label feed is missing or unreadable", labels_path)
end

local keywords_path = www_dir .. "/site-keywords.json"
local catalogue = file_reading.load_json_file(keywords_path, "public keywords", false)
if type(catalogue) == "table" and catalogue.schema_version == 1
    and type(catalogue.keywords) == "table" then
  for _, keyword in ipairs(catalogue.keywords) do
    if not anchor_exists(keyword.href or "") then
      report(keywords_path, 1, "keyword points to a missing anchor",
        tostring(keyword.phrase) .. " -> " .. tostring(keyword.href))
    end
    if looks_like_tex(keyword.phrase) or looks_like_tex(keyword.title) then
      report(keywords_path, 1, "keyword is not plain text",
        tostring(keyword.phrase) .. " / " .. tostring(keyword.title))
    end
  end
else
  report(keywords_path, 1, "public keyword feed is missing or not schema version 1", keywords_path)
end

if error_count > max_errors then
  io.stderr:write(string.format(
    "[ERROR] lint-html: suppressed %d additional error(s)\n",
    error_count - max_errors))
end

if error_count > 0 then
  os.exit(1)
end
