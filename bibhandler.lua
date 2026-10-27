-- Bibliography handler for CSL-JSON citations
--
-- This module converts CSL-JSON bibliography data into formatted HTML citations.
-- It handles various citation formats (journal articles, conference papers, books, etc.)
-- and generates consistent bibliography labels for cross-referencing.

-- ========== DEPENDENCIES ==========

local file_reading      = dofile("file_reading.lua")
local utils             = dofile("utils.lua")
local ascii_fold_string = utils.ascii_fold_string
local html_escape       = utils.html_escape
local print_error       = utils.print_error

-- ========== CONSTANTS ==========

local MONTH_NAMES = {
  "January", "February", "March", "April", "May", "June",
  "July", "August", "September", "October", "November", "December"
}

local MAX_LABEL_LENGTH = 4
local TEMP_DIR = os.getenv("TEMP_DIR") or "temp"
local DEFAULT_BIB_PATH = os.getenv("REFS_JSON") or (TEMP_DIR .. "/bibliography.json")
local DEFAULT_BIBTEX_PATH = os.getenv("BIBTEX_JSON") or (TEMP_DIR .. "/bibtex-entries.json")

-- ========== MODULE STATE ==========

local bib_cache = nil
local bibtex_cache = nil
local label_cache = nil

local get_bibliography_label -- defined after the bibliography loaders

-- ========== DATE UTILITIES ==========

local function month_number_to_name(month_num)
  local num = tonumber(month_num or 0)
  return MONTH_NAMES[num]
end

local function extract_month(item)
  local date_parts = item.issued and item.issued["date-parts"]
  if date_parts and date_parts[1] and date_parts[1][2] then
    return month_number_to_name(date_parts[1][2])
  end
  return nil
end

local function extract_year(item)
  local date_parts = item.issued and item.issued["date-parts"]
  if date_parts and date_parts[1] and date_parts[1][1] then
    local y = tonumber(date_parts[1][1])
    if y then return string.format("%.0f", y) end
  end
  return ""
end


-- ========== AUTHOR NORMALIZATION ==========

local function normalize_authors(author_field)
  if author_field == nil then return {} end

  local field_type = type(author_field)
  if field_type == "string" then
    return { { literal = author_field } }
  end

  if field_type == "table" then
    if author_field.family or author_field.given or author_field.literal then
      return { author_field }
    end
    local normalized = {}
    for _, author in ipairs(author_field) do
      if type(author) == "string" then
        table.insert(normalized, { literal = author })
      elseif type(author) == "table" then
        if author.family or author.given or author.literal then
          table.insert(normalized, author)
        else
          table.insert(normalized, { literal = tostring(author) })
        end
      end
    end
    return normalized
  end
  return {}
end

local function format_author_name(author)
  if author.literal and author.literal ~= "" then return author.literal end
  local given = author.given or ""
  local family = author.family or ""
  if given ~= "" and family ~= "" then return given .. " " .. family end
  return given ~= "" and given or family
end

local function extract_last_name(author)
  if author.family and author.family ~= "" then return author.family end
  if author.literal and author.literal ~= "" then
    local last_word = author.literal:match("([^%s]+)%s*$")
    return last_word or author.literal
  end
  return author.given or ""
end


-- ========== STRING UTILITIES ==========

local function first_codepoint(s)
  return tostring(s):match("[%z\1-\127\194-\244][\128-\191]*") or ""
end

local function first_letters_of_words(s)
  local letters = {}
  for word in tostring(s):gmatch("%S+") do
    table.insert(letters, first_codepoint(word))
  end
  return table.concat(letters)
end

local function strip_nocase_spans(s)
  s = tostring(s or "")
  return (s:gsub('<span%s+[^>]*class=["\'][^"\']*nocase[^"\']*["\'][^>]*>(.-)</span>', '%1'))
end

-- ========== LABEL GENERATION ==========

-- Labels follow BibTeX alpha style: the first three letters of a single
-- author's surname, or the surname initials of several authors (at most four,
-- then "+"), followed by the two-digit year.  Names are ASCII-folded before
-- truncation so that multibyte letters are never split.
local function make_base_label(authors, year)
  local author_key
  if #authors == 1 then
    author_key = ascii_fold_string(extract_last_name(authors[1])):sub(1, 3)
  else
    local initials = {}
    for _, author in ipairs(authors) do
      initials[#initials + 1] = ascii_fold_string(
        first_letters_of_words(extract_last_name(author)))
    end
    author_key = table.concat(initials)
    if #author_key > MAX_LABEL_LENGTH then
      author_key = author_key:sub(1, MAX_LABEL_LENGTH) .. "+"
    end
  end

  local year_str = tostring(year or "")
  local year_suffix = #year_str >= 4 and year_str:sub(3, 4) or ""
  return author_key .. year_suffix
end


-- ========== HTML FORMATTING ==========

local function format_page_span(pages)
  if not pages or pages == "" then return "" end
  local formatted = pages:gsub("%-%-", "–"):gsub("%-", "–")
  return '<span class="citePages">:' .. html_escape(formatted) .. '</span>'
end

local function is_safe_bibliography_url(url)
  url = tostring(url or ""):match("^%s*(.-)%s*$")
  if url == "" then return false end
  local scheme = url:match("^([A-Za-z][A-Za-z0-9+.-]*):")
  if not scheme then return false end
  scheme = scheme:lower()
  return scheme == "http" or scheme == "https"
end

local function is_arxiv_container_title(container_title)
  return tostring(container_title or ""):lower():match("arxiv") ~= nil
end

--- Scans item fields to find an arXiv ID.
-- Priority: item.eprint > item.arxivid > regex in URL > regex in note
local function find_arxiv_id(item)
  -- 1. Check explicit fields
  local explicit = item.eprint or item.arxivid or item.arXiv
  if explicit and explicit ~= "" then
    return (tostring(explicit):gsub("^[Aa][Rr][Xx][Ii][Vv]:", ""))
  end

  -- 2. Check URL field for "arxiv.org/abs/ID" pattern
  if item.URL and item.URL ~= "" then
    local match = item.URL:match("arxiv%.org/abs/([%w%.%-%/]+)")
    if match then return match end
  end

  -- 3. Check Note field
  if item.note and item.note ~= "" then
    local match = item.note:match("arXiv:([%w%.%-%/]+)")
    if match then return match end
  end

  return nil
end

--- Strips resolver prefixes, so "https://dx.doi.org/10.1/x" and
--- "doi:10.1/x" both become "10.1/x".
local function normalize_doi(doi)
  doi = tostring(doi or ""):match("^%s*(.-)%s*$")
  doi = doi:gsub("^[Hh][Tt][Tt][Pp][Ss]?://[%w%.]*[Dd][Oo][Ii]%.[Oo][Rr][Gg]/", "")
  doi = doi:gsub("^[Dd][Oo][Ii]:%s*", "")
  return doi
end

--- Creates linked title. Priority: DOI > arXiv (via URL/eprint) > URL
local function format_title_with_link(item)
  local title = strip_nocase_spans(item.title or "")
  local href = nil
  
  local doi = item.DOI
  local arxivid = find_arxiv_id(item)
  local url = item.URL

  doi = normalize_doi(doi)
  if doi ~= "" then
    href = "https://doi.org/" .. doi
  elseif arxivid then
    href = "https://arxiv.org/abs/" .. arxivid
  elseif url and url ~= "" then
    if is_safe_bibliography_url(url) then
      href = url
    else
      print_error("Unsafe bibliography URL rejected for '%s': %s", title, url)
    end
  end

  if href then
    return string.format(
      '<a class="citeLinkTitle" href="%s">%s</a>',
      html_escape(href),
      html_escape(title)
    )
  else
    return string.format('<span class="citeTitle">%s</span>', html_escape(title))
  end
end

local function format_venue_info(item)
  local parts = {}
  local container_title = item["container-title"] or ""
  local book_title = item["collection-title"] or item["event"] or item["event-title"] or item.booktitle or ""
  local volume = item.volume or ""
  local number = item.number or item.issue or ""
  local pages = item.page or ""
  local year = extract_year(item)
  local month = extract_month(item)
  local arxivid = find_arxiv_id(item)

  -- Use arXiv as the venue only for actual preprints.  Published articles may
  -- still carry an arXiv URL/eprint, but their journal data should be shown.
  if arxivid and (container_title == "" or is_arxiv_container_title(container_title)) then
    container_title = "arXiv:" .. arxivid
  end
  
  if container_title ~= "" then
    -- Journal
    table.insert(parts, '<span class="citeJournal">' .. html_escape(container_title) .. '</span>')
    if volume ~= "" then table.insert(parts, ', <span class="citeVolume">' .. html_escape(volume) .. '</span>') end
    if number ~= "" then table.insert(parts, '<span class="citeNumber">(' .. html_escape(number) .. ')</span>') end
    if pages ~= "" then table.insert(parts, format_page_span(pages)) end
    if month then table.insert(parts, ', ' .. month .. ' ') else table.insert(parts, ',  ') end
    table.insert(parts, '<span class="citeYear">' .. html_escape(year) .. '. </span>')
    
  elseif book_title ~= "" then
    -- Conference/Book
    table.insert(parts, '<span class="citeBooktitle">' .. html_escape(book_title) .. '</span>. ')
    local publisher = item.publisher or ""
    if publisher ~= "" then table.insert(parts, '<span class="citePublisher">' .. html_escape(publisher) .. '</span>,  ') end
    table.insert(parts, '<span class="citeYear">' .. html_escape(year) .. '. </span>')
    
  else
    -- Report/Thesis/Preprint
    local series = item.series or ""
    local edition = item.edition or ""
    local publisher = item.publisher or ""
    if series ~= "" then table.insert(parts, '<span class="citeSeries">' .. html_escape(series) .. ', </span>') end
    if publisher ~= "" then table.insert(parts, '<span class="citePublisher">' .. html_escape(publisher) .. '</span>, ') end
    if edition ~= "" then table.insert(parts, '<span class="citeEdition">' .. html_escape(edition) .. ',</span> ') end
    table.insert(parts, ' <span class="citeYear">' .. html_escape(year) .. '. </span>')
  end

  return table.concat(parts)
end

local function download_filename_for_key(key)
  local filename = tostring(key or ""):gsub("[^%w%._%-]+", "_")
  if filename == "" then filename = "citation" end
  return filename .. ".bib"
end

local function format_bibtex_controls(key, bibtex_entry)
  if not bibtex_entry or bibtex_entry == "" then
    print_error("Missing raw BibTeX entry for citation key: %s", key or "")
    return ""
  end

  return table.concat({
    '<details class="bibtex-details" data-pagefind-ignore>',
    '<summary>.bib</summary>',
    '<div class="bibtex-actions">',
    '<button type="button" class="bibtex-copy">',
    '<img src="icons/icon-clone.svg" class="icon" alt="" aria-hidden="true"/> Copy',
    '</button>',
    '<button type="button" class="bibtex-download" data-filename="',
    html_escape(download_filename_for_key(key)),
    '">',
    '<img src="icons/icon-download.svg" class="icon" alt="" aria-hidden="true"/> Download',
    '</button>',
    '</div>',
    '<pre class="bibtex-code" data-no-auto-copy="true"><code>',
    html_escape(bibtex_entry),
    '</code></pre>',
    '</details>'
  })
end

local function format_bibliography_entry(item, key, label, bibtex_entry)
  local entry_id = item.id or (key or "")

  local authors = normalize_authors(item.author)
  local bib_label = label or get_bibliography_label(entry_id) or entry_id
  
  local parts = {}
  table.insert(parts, '<li id="' .. html_escape(entry_id) .. '">')
  table.insert(parts, '<span class="citeMeta"><span class="citeKey">[')
  table.insert(parts, html_escape(bib_label))
  table.insert(parts, ']</span></span><span class="citeText">')
  if #authors > 0 then
    local linked_names = {}
    for _, author in ipairs(authors) do
      local name = format_author_name(author)
      local scholar_url = "https://scholar.google.com/scholar?q=" .. name:gsub(" ", "+")
      table.insert(linked_names, '<a class="citeAuthorLink" href="' .. html_escape(scholar_url) .. '" target="_blank" rel="noopener">' .. html_escape(name) .. '</a>')
    end
    local author_html
    if #linked_names == 1 then
      author_html = linked_names[1]
    elseif #linked_names == 2 then
      author_html = linked_names[1] .. " and " .. linked_names[2]
    else
      local last = table.remove(linked_names)
      author_html = table.concat(linked_names, ", ") .. " and " .. last
    end
    table.insert(parts, '<span class="citeAuthor">' .. author_html .. '</span>. ')
  end
  table.insert(parts, format_title_with_link(item) .. ". ")
  table.insert(parts, format_venue_info(item))
  
  -- Add the note
  if item.note and item.note ~= "" then
    table.insert(parts, ' <span class="citeNote">' .. html_escape(item.note) .. '</span>')
  end

  table.insert(parts, '</span>')
  table.insert(parts, format_bibtex_controls(key, bibtex_entry))
  
  table.insert(parts, "</li>")
  
  return table.concat(parts)
end


-- ========== BIBLIOGRAPHY LOADING ==========

local function load_bibliography_json(path)
  if bib_cache then return bib_cache end
  path = path or DEFAULT_BIB_PATH
  local data = file_reading.load_json_file(path, "bibliography", true)
  local entry_map = {}
  
  if type(data) == "table" and #data > 0 then
    for _, entry in ipairs(data) do
      if entry and entry.id then entry_map[entry.id] = entry end
    end
  else
    for id, entry in pairs(data) do
      if type(entry) == "table" then
        entry.id = entry.id or id
        entry_map[entry.id] = entry
      end
    end
  end
  bib_cache = entry_map
  return bib_cache
end

--- Assigns every entry its site-wide label.  Entries whose base labels
--- coincide get suffixes a, b, ... in order of year, title and key, so a label
--- identifies one reference on every page and in the public bibliography.
local function bibliography_labels()
  if label_cache then return label_cache end
  local groups = {}
  for id, entry in pairs(load_bibliography_json()) do
    local base = make_base_label(normalize_authors(entry.author), extract_year(entry))
    groups[base] = groups[base] or {}
    table.insert(groups[base], { id = id, entry = entry })
  end

  label_cache = {}
  for base, members in pairs(groups) do
    if #members == 1 then
      label_cache[members[1].id] = base
    else
      table.sort(members, function(a, b)
        local ya, yb = extract_year(a.entry), extract_year(b.entry)
        if ya ~= yb then return ya < yb end
        local ta = ascii_fold_string(tostring(a.entry.title or "")):lower()
        local tb = ascii_fold_string(tostring(b.entry.title or "")):lower()
        if ta ~= tb then return ta < tb end
        return a.id < b.id
      end)
      for index, member in ipairs(members) do
        local suffix = index <= 26 and string.char(96 + index) or ("_" .. index)
        label_cache[member.id] = base .. suffix
      end
    end
  end
  return label_cache
end

local function load_bibtex_json(path)
  if bibtex_cache then return bibtex_cache end
  path = path or DEFAULT_BIBTEX_PATH
  bibtex_cache = file_reading.load_json_file(path, "raw BibTeX entries", true)
  return bibtex_cache
end

-- ========== PUBLIC API ==========

local function build_bibliography_HTML(path, citations, bibtex_path)
  local bibliography = load_bibliography_json(path)
  local bibtex_entries = load_bibtex_json(bibtex_path)
  if type(citations) ~= "table" or #citations == 0 then return "" end
  
  local html_parts = {}
  table.insert(html_parts, '<section id="bibliography">\n<h2>Bibliography</h2>\n<ol>\n')
  
  for _, citation in ipairs(citations) do
    local cite_key = (type(citation) == "table" and citation.c) or citation
    local entry = bibliography[cite_key]
    if not entry then
      print_error("Missing citation key: %s", cite_key)
    else
      table.insert(html_parts, format_bibliography_entry(
        entry,
        cite_key,
        nil,
        bibtex_entries[cite_key]
      ) .. "\n")
    end
  end
  
  table.insert(html_parts, "</ol>\n</section>\n")
  return table.concat(html_parts)
end

get_bibliography_label = function(id)
  return bibliography_labels()[id]
end


local function get_bibliography_tooltip(id)
  local bibliography = load_bibliography_json()
  local entry = bibliography and bibliography[id]
  if not entry then return nil end
  local authors = normalize_authors(entry.author)
  
  if not authors or #authors == 0 then return "" end
  local names = {}
  for _, author in ipairs(authors) do
    table.insert(names, extract_last_name(author))
  end

  local author_str = ""
  if #names == 1 then
    author_str = names[1]
  elseif #names == 2 then
    author_str = names[1] .. " and " .. names[2]
  elseif #names > 2 then
    local last = table.remove(names)
    author_str = table.concat(names, ", ") .. " and " .. last
  end
  
  local title = strip_nocase_spans(entry.title or "")
  local year = extract_year(entry)
  return string.format("%s, %s (%s)", author_str, title, year)
end

--- Public, machine-readable bibliography for cross-site use (for example the
--- RealRooted Lean catalog): citation key -> { label, csl, bibtex }, where
--- `label` is the same short label the site renders, e.g. "Bre95".
local function public_bibliography()
  local bibliography = load_bibliography_json() or {}
  local bibtex_entries = load_bibtex_json() or {}
  local entries = {}
  for key, entry in pairs(bibliography) do
    entries[key] = {
      label = get_bibliography_label(key),
      csl = entry,
      bibtex = bibtex_entries[key],
    }
  end
  return entries
end

local M = {
  build_bibliography_HTML = build_bibliography_HTML,
  public_bibliography = public_bibliography,
  get_bibliography_label = get_bibliography_label,
  get_bibliography_tooltip = get_bibliography_tooltip
}

return M
