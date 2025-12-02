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
local print_info        = utils.print_info

-- ========== CONSTANTS ==========

local MONTH_NAMES = {
  "January", "February", "March", "April", "May", "June",
  "July", "August", "September", "October", "November", "December"
}

local MAX_LABEL_LENGTH = 4
local DEFAULT_BIB_PATH = "./temp/bibliography.json"

-- ========== MODULE STATE ==========

local bib_cache = nil

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

local function join_author_names(authors)
  if not authors or #authors == 0 then return "" end
  local names = {}
  for _, author in ipairs(authors) do table.insert(names, format_author_name(author)) end
  if #names == 1 then return names[1] end
  if #names == 2 then return names[1] .. " and " .. names[2] end
  local last = table.remove(names)
  return table.concat(names, ", ") .. " and " .. last
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

local function utf8_length(s)
  if utf8 and utf8.len then
    local len = utf8.len(s)
    if len then return len end
  end
  return #s
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
  return s:gsub('<span%s+[^>]*class=["\'][^"\']*nocase[^"\']*["\'][^>]*>(.-)</span>', '%1')
end

-- ========== LABEL GENERATION ==========

local function make_bibliography_label(authors, year)
  local last_names = {}
  for _, author in ipairs(authors) do
    table.insert(last_names, extract_last_name(author))
  end
  
  local author_key
  if #last_names == 1 then
    local name = tostring(last_names[1] or "")
    if utf8_length(name) >= 3 then author_key = name:sub(1, 3) else author_key = name end
  else
    local initials = {}
    for _, name in ipairs(last_names) do
      table.insert(initials, first_letters_of_words(name or ""))
    end
    author_key = table.concat(initials)
  end
  
  if utf8_length(author_key) >= 5 then
    author_key = author_key:sub(1, MAX_LABEL_LENGTH) .. "+"
  end
  
  local year_suffix = ""
  if year ~= nil then
    local year_str = tostring(year)
    if #year_str >= 4 then year_suffix = year_str:sub(3, 4) end
  end
  
  return ascii_fold_string(author_key) .. year_suffix
end


-- ========== HTML FORMATTING ==========

local function format_page_span(pages)
  if not pages or pages == "" then return "" end
  local formatted = pages:gsub("%-%-", "–"):gsub("%-", "–")
  return '<span class="citePages">:' .. html_escape(formatted) .. '</span>'
end

--- Scans item fields to find an arXiv ID.
-- Priority: item.eprint > item.arxivid > regex in URL > regex in note
local function find_arxiv_id(item)
  -- 1. Check explicit fields
  local explicit = item.eprint or item.arxivid or item.arXiv
  if explicit and explicit ~= "" then
    return tostring(explicit):gsub("^arXiv:", ""):gsub("^arxiv:", "")
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

--- Creates linked title. Priority: DOI > arXiv (via URL/eprint) > URL
local function format_title_with_link(item)
  local title = strip_nocase_spans(item.title or "")
  local href = nil
  
  local doi = item.DOI
  local arxivid = find_arxiv_id(item)
  local url = item.URL

  if doi and doi ~= "" then
    href = "https://doi.org/" .. doi
  elseif arxivid then
    href = "https://arxiv.org/abs/" .. arxivid
  elseif url and url ~= "" then
    href = url
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

  -- if it is arxiv preprint, then venue is arxiv. 
  if arxivid then
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

local function format_bibliography_entry(item, key, label)
  local entry_id = item.id or (key or "")

  local authors = normalize_authors(item.author)
  local author_string = join_author_names(authors)
  local year = extract_year(item)
  local bib_label = label or make_bibliography_label(authors, year)
  
  local parts = {}
  table.insert(parts, '<li id="' .. html_escape(entry_id) .. '">')
  table.insert(parts, '<span class="citeKey">[' .. html_escape(bib_label) .. ']</span> ')
  if author_string ~= "" then
    table.insert(parts, '<span class="citeAuthor">' .. html_escape(author_string) .. '</span>. ')
  end
  table.insert(parts, format_title_with_link(item) .. ". ")
  table.insert(parts, format_venue_info(item))
  
  -- Add the note
  if item.note and item.note ~= "" then
    table.insert(parts, ' <span class="citeNote">' .. html_escape(item.note) .. '</span>')
  end
  
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


-- ========== PUBLIC API ==========

local function build_bibliography_HTML(path, citations)
  local bibliography = load_bibliography_json(path)
  if type(citations) ~= "table" or #citations == 0 then return "" end
  
  local html_parts = {}
  table.insert(html_parts, '<section id="bibliography">\n<h2>Bibliography</h2>\n<ol>\n')
  
  for _, citation in ipairs(citations) do
    local cite_key = (type(citation) == "table" and citation.c) or citation
    local entry = bibliography[cite_key]
    if not entry then
      print_error("Missing citation key: %s", cite_key)
    else
      table.insert(html_parts, format_bibliography_entry(entry, cite_key) .. "\n")
    end
  end
  
  table.insert(html_parts, "</ol>\n</section>\n")
  return table.concat(html_parts)
end

local function get_bibliography_label(id)
  local bibliography = load_bibliography_json()
  local entry = bibliography and bibliography[id]
  if not entry then return nil end
  local authors = normalize_authors(entry.author)
  local year = extract_year(entry)
  return make_bibliography_label(authors, year)
end



local function get_bibliography_tooltop(id)
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

local M = {
  build_bibliography_HTML = build_bibliography_HTML,
  get_bibliography_label = get_bibliography_label,
  get_bibliography_tooltop = get_bibliography_tooltop
}

return M