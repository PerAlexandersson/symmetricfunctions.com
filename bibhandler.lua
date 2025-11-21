-- Script for turning cite data into html


local file_reading      = dofile("file_reading.lua")
local utils             = dofile("utils.lua")
local ascii_fold_string = utils.ascii_fold_string
local html_escape       = utils.html_escape
local print_error       = utils.print_error

-- Where we get the bib from
-- TODO: Make as flag/argument
local bibliographyPath  = "./temp/bibliography.json"


-- helpers
local function month_name(m)
  local names = { "January", "February", "March", "April", "May", "June",
    "July", "August", "September", "October", "November", "December" }
  return names[tonumber(m or 0)] or nil
end

local function get_month(item)
  local dp = item.issued and item.issued["date-parts"]
  if dp and dp[1] and dp[1][2] then return month_name(dp[1][2]) end
  return nil
end

local function get_year(item)
  local dp = item.issued and item.issued["date-parts"]
  if dp and dp[1] and dp[1][1] then return tostring(dp[1][1]) end
  return ""
end


-- Normalize various author shapes -> array of CSL-style entries
-- Accepts: nil | string | object | array of strings/objects
local function normalize_authors(a)
  if a == nil then return {} end
  local t = type(a)
  if t == "string" then
    return { { literal = a } }
  elseif t == "table" then
    -- single object? (has family/given/literal)
    if a.family or a.given or a.literal then
      return { a }
    end
    -- array case: ensure each element is object
    local out = {}
    for _, v in ipairs(a) do
      if type(v) == "string" then
        out[#out + 1] = { literal = v }
      elseif type(v) == "table" then
        if v.family or v.given or v.literal then
          out[#out + 1] = v
        else
          -- unknown shape -> stringify best-effort
          out[#out + 1] = { literal = tostring(v) }
        end
      end
    end
    return out
  else
    return {}
  end
end

-- Join authors for display: "A. B. Family, ..., and Last Family"
local function join_authors(auth_arr)
  local function name_of(a)
    if a.literal and a.literal ~= "" then return a.literal end
    local g = a.given or ""
    local f = a.family or ""
    if g ~= "" and f ~= "" then return g .. " " .. f end
    return g ~= "" and g or f
  end
  local parts = {}
  for _, a in ipairs(auth_arr or {}) do parts[#parts + 1] = name_of(a) end
  if #parts == 0 then return "" end
  if #parts == 1 then return parts[1] end
  if #parts == 2 then return parts[1] .. " and " .. parts[2] end
  local last = table.remove(parts)
  return table.concat(parts, ", ") .. " and " .. last
end

-- Extract last-name-ish token for label generation
local function last_name_of(a)
  if a.family and a.family ~= "" then return a.family end
  if a.literal and a.literal ~= "" then
    -- take last word of literal as a proxy
    local last = a.literal:match("([^%s]+)%s*$")
    return last or a.literal
  end
  return a.given or ""
end

local function strip_nocase_spans(s)
  s = tostring(s or "")
  -- match any <span ... class="... nocase ...">...</span>
  return s:gsub('<span%s+[^>]*class=["\'][^"\']*nocase[^"\']*["\'][^>]*>(.-)</span>', '%1')
end

local function page_span(p)
  if not p or p == "" then return "" end
  p = p:gsub("%-%-", "–"):gsub("%-", "–")
  return '<span class="citePages">:' .. html_escape(p) .. '</span>'
end

local function title_link(item)
  local title = item.title or ""

  title       = strip_nocase_spans(title)

  local href  = nil
  if item.DOI and item.DOI ~= "" then
    href = "http://dx.doi.org/" .. item.DOI
  elseif item.URL and item.URL ~= "" then
    href = item.URL
  elseif item.arXiv and item.arXiv ~= "" then
    href = "https://arxiv.org/abs/" .. item.arXiv
  end
  if href then
    return string.format('<a class="citeLinkTitle" href="%s">%s</a>',
      html_escape(href), html_escape(title))
  else
    -- no link available; keep styling but no anchor
    return string.format('<span class="citeTitle">%s</span>', html_escape(title))
  end
end


-- AuthorBibKey(authors, year) -> string
-- authors: array of last-name strings (multi-word last names allowed)
-- year   : string or number (optional). If 4 chars, append chars 3-4.
local function make_bib_label(authors_arr, year)
  -- Extract last names
  local authors = {}
  for _, a in ipairs(authors_arr) do authors[#authors + 1] = last_name_of(a) end

  -- utf8-safe: first codepoint of a word
  local function first_codepoint(s)
    -- matches one UTF-8 codepoint
    return tostring(s):match("[%z\1-\127\194-\244][\128-\191]*") or ""
  end

  local function strlen_u(s)
    if utf8 and utf8.len then
      local n = utf8.len(s)
      if n then return n end
    end
    return #s
  end

  local function first_letters_of_words(s)
    local letters = {}
    for w in tostring(s):gmatch("%S+") do
      letters[#letters + 1] = first_codepoint(w)
    end
    return table.concat(letters)
  end


  local authKey
  if #authors == 1 then
    local a = tostring(authors[1] or "")
    if strlen_u(a) >= 3 then
      authKey = a:sub(1, 3)
    else
      authKey = a
    end
  else
    local parts = {}
    for _, a in ipairs(authors) do
      parts[#parts + 1] = first_letters_of_words(a or "")
    end
    authKey = table.concat(parts)
  end

  -- If too many initials, keep first 4 and add '+'
  if strlen_u(authKey) >= 5 then
    authKey = authKey:sub(1, 4) .. "+"
  end

  -- Append chars 3-4 of a 4-char year (e.g., "2017" -> "17")
  local yy = ""
  if year ~= nil then
    local y = tostring(year)
    if #y >= 4 then
      yy = y:sub(3, 4)
    end
  end

  return ascii_fold_string(authKey) .. yy
end


-- Main formatter to match your sample HTML
-- Pass: item (CSL-JSON), key (BibTeX key), label (e.g. "[Ale14]") optional
local function format_bib_as_HTML(item, key, label)
  local li_id     = item.id or (key or "")
  local authArr   = normalize_authors(item.author)
  local authors   = join_authors(authArr)
  local year      = get_year(item)
  local lab       = label or make_bib_label(authArr, year)
  local month     = get_month(item)
  local ctitle    = item["container-title"] or ""
  local booktit   = item["collection-title"] or item["event"] or item["event-title"] or item.booktitle or ""
  local series    = item.series or ""
  local edition   = item.edition or ""
  local publisher = item.publisher or ""
  local volume    = item.volume or ""
  local number    = item.number or item.issue or ""
  local pages     = item.page or ""
  local is_arxiv  = (ctitle == "arXiv e-prints") or (item.URL and item.URL:match("arxiv%.org"))

  -- Start assembling
  local parts     = {}
  table.insert(parts, '<li id="' .. html_escape(li_id) .. '">')
  table.insert(parts, '<span class="citeKey">[' .. html_escape(lab) .. ']</span> ')
  if authors ~= "" then
    table.insert(parts, '<span class="citeAuthor">' .. html_escape(authors) .. '</span>. ')
  end

  table.insert(parts, title_link(item) .. ". ")

  -- Venue / container
  if ctitle ~= "" then
    table.insert(parts, '<span class="citeJournal">' .. html_escape(ctitle) .. '</span>')
    if volume ~= "" then
      table.insert(parts, ', <span class="citeVolume">' .. html_escape(volume) .. '</span>')
    end
    if number ~= "" then
      table.insert(parts, '<span class="citeNumber">(' .. html_escape(number) .. ')</span>')
    end
    if pages ~= "" then
      table.insert(parts, page_span(pages))
    end

    -- date bit: prefer Month Year for journals if month exists
    if month then
      table.insert(parts, ', ' .. month .. ' ')
    else
      table.insert(parts, ',  ')
    end
    table.insert(parts, '<span class="citeYear">' .. html_escape(year) .. '. </span>')
  elseif booktit ~= "" then
    -- conference/collection
    table.insert(parts, '<span class="citeBooktitle">' .. html_escape(booktit) .. '</span>. ')
    if publisher ~= "" then
      table.insert(parts, '<span class="citePublisher">' .. html_escape(publisher) .. '</span>,  ')
    end
    table.insert(parts, '<span class="citeYear">' .. html_escape(year) .. '. </span>')
  else
    -- books, theses, reports, etc.
    if series ~= "" then
      table.insert(parts, '<span class="citeSeries">' .. html_escape(series) .. ', </span>')
    end
    if publisher ~= "" then
      table.insert(parts, '<span class="citePublisher">' .. html_escape(publisher) .. '</span>, ')
    end
    if edition ~= "" then
      table.insert(parts, '<span class="citeEdition">' .. html_escape(edition) .. ',</span> ')
    end
    table.insert(parts, ' <span class="citeYear">' .. html_escape(year) .. '. </span>')
  end

  -- Optional extra note
  if item.note and item.note ~= "" then
    table.insert(parts, '<span class="citeNote">' .. html_escape(item.note) .. '</span>')
  end

  table.insert(parts, "</li>")
  return table.concat(parts)
end



-- Cached bib map (id -> CSL entry)
local bib_by_id = nil

-- Load and cache bibliography JSON, returning a map id -> entry.
-- Accepts either CSL-JSON array or an object map; memoized across calls.
local function load_bibliography_json(path)
  if bib_by_id then return bib_by_id end
  path = path or bibliographyPath

  local data = file_reading.load_json_file(path, "bibliography", true)
  local map = {}

  if type(data) == "table" and #data > 0 then
    -- array of CSL entries
    for _, entry in ipairs(data) do
      if entry and entry.id then
        map[entry.id] = entry
      end
    end
  else
    -- object map: id -> entry
    for id, entry in pairs(data) do
      if type(entry) == "table" then
        entry.id = entry.id or id
        map[entry.id] = entry
      end
    end
  end

  bib_by_id = map
  return bib_by_id
end

-- Creates the entire bibliography section using the cached loader
local function build_bibliography_HTML(path, citations)
  local bib = load_bibliography_json(path)

  if type(citations) ~= "table" or #citations == 0 then
    return ""
  end

  local out = {}
  out[#out + 1] = '<section id="bibliography">\n<h2>Bibliography</h2>\n<ol>\n'

  for _, c in ipairs(citations) do
    local key = (type(c) == "table" and c.c) or c
    local item = bib[key]
    if not item then
      print_error("Missing citation key: %s ", key)
    else
      out[#out + 1] = format_bib_as_HTML(item, key) .. "\n"
    end
  end

  out[#out + 1] = "</ol>\n</section>\n"
  return table.concat(out)
end


-- Returns the short label for an internal bib id, e.g. "AJ24".
local function get_bib_entry_label(id)
  local bib = load_bibliography_json()
  local item = bib and bib[id]
  if not item then return nil end

  local authArr = normalize_authors(item.author)
  local year    = get_year(item)
  local label   = make_bib_label(authArr, year) -- e.g. "[AJ24]"

  return label
end

return {
  build_bibliography_HTML = build_bibliography_HTML,
  get_bib_entry_label = get_bib_entry_label
}
