-- Bibliography handler for CSL-JSON citations
--
-- This module converts CSL-JSON bibliography data into formatted HTML citations.
-- It handles various citation formats (journal articles, conference papers, books, etc.)
-- and generates consistent bibliography labels for cross-referencing.
--
-- Features:
-- - CSL-JSON parsing with flexible author field handling
-- - Automatic label generation (e.g., "Ale14", "ABC+24")
-- - DOI/URL/arXiv link resolution
-- - Cached bibliography loading for performance
-- - Support for multiple entry types (article, inproceedings, book, etc.)
--
-- Environment variables:
--   None (bibliography path passed as argument)

-- ========== DEPENDENCIES ==========

local file_reading      = dofile("file_reading.lua")
local utils             = dofile("utils.lua")
local ascii_fold_string = utils.ascii_fold_string
local html_escape       = utils.html_escape
local print_error       = utils.print_error


-- ========== CONSTANTS ==========

-- Month number to name mapping
local MONTH_NAMES = {
  "January", "February", "March", "April", "May", "June",
  "July", "August", "September", "October", "November", "December"
}

-- Maximum length for bibliography labels before truncation
local MAX_LABEL_LENGTH = 4

-- Default bibliography path
local DEFAULT_BIB_PATH = "./temp/bibliography.json"


-- ========== MODULE STATE ==========

-- Cached bibliography data (id -> CSL entry)
-- Memoized to avoid repeated file reads
local bib_cache = nil


-- ========== DATE UTILITIES ==========

--- Converts month number to month name.
-- @param month_num number|string Month number (1-12)
-- @return string|nil Month name or nil if invalid
local function month_number_to_name(month_num)
  local num = tonumber(month_num or 0)
  return MONTH_NAMES[num]
end


--- Extracts month from CSL-JSON issued date-parts.
-- @param item table CSL-JSON entry
-- @return string|nil Month name or nil if not present
local function extract_month(item)
  local date_parts = item.issued and item.issued["date-parts"]
  if date_parts and date_parts[1] and date_parts[1][2] then
    return month_number_to_name(date_parts[1][2])
  end
  return nil
end


--- Extracts year from CSL-JSON issued date-parts.
-- @param item table CSL-JSON entry
-- @return string Year as string, or empty string if not present
local function extract_year(item)
  local date_parts = item.issued and item.issued["date-parts"]
  if date_parts and date_parts[1] and date_parts[1][1] then
    return tostring(date_parts[1][1])
  end
  return ""
end


-- ========== AUTHOR NORMALIZATION ==========

--- Normalizes various author field formats to CSL-JSON author array.
-- Handles: nil, string, single object, array of strings/objects
-- @param author_field any Author field from CSL-JSON (various formats)
-- @return table Array of author objects with family/given/literal fields
local function normalize_authors(author_field)
  if author_field == nil then
    return {}
  end
  
  local field_type = type(author_field)
  
  -- Single string author
  if field_type == "string" then
    return { { literal = author_field } }
  end
  
  -- Table: could be single author object or array
  if field_type == "table" then
    -- Single author object with structured fields
    if author_field.family or author_field.given or author_field.literal then
      return { author_field }
    end
    
    -- Array of authors
    local normalized = {}
    for _, author in ipairs(author_field) do
      if type(author) == "string" then
        table.insert(normalized, { literal = author })
      elseif type(author) == "table" then
        if author.family or author.given or author.literal then
          table.insert(normalized, author)
        else
          -- Unknown structure, stringify as fallback
          table.insert(normalized, { literal = tostring(author) })
        end
      end
    end
    return normalized
  end
  
  return {}
end


--- Extracts display name from a single author object.
-- @param author table Author object with family/given/literal fields
-- @return string Formatted author name
local function format_author_name(author)
  if author.literal and author.literal ~= "" then
    return author.literal
  end
  
  local given = author.given or ""
  local family = author.family or ""
  
  if given ~= "" and family ~= "" then
    return given .. " " .. family
  end
  
  return given ~= "" and given or family
end


--- Joins author array into display string with proper punctuation.
-- Format: "First Author, Second Author, and Last Author"
-- @param authors table Array of author objects
-- @return string Formatted author list
local function join_author_names(authors)
  if not authors or #authors == 0 then
    return ""
  end
  
  local names = {}
  for _, author in ipairs(authors) do
    table.insert(names, format_author_name(author))
  end
  
  if #names == 1 then
    return names[1]
  end
  
  if #names == 2 then
    return names[1] .. " and " .. names[2]
  end
  
  -- Three or more: "A, B, and C"
  local last = table.remove(names)
  return table.concat(names, ", ") .. " and " .. last
end


--- Extracts last name from author for label generation.
-- @param author table Author object
-- @return string Last name or fallback identifier
local function extract_last_name(author)
  if author.family and author.family ~= "" then
    return author.family
  end
  
  if author.literal and author.literal ~= "" then
    -- Extract last word from literal as proxy for last name
    local last_word = author.literal:match("([^%s]+)%s*$")
    return last_word or author.literal
  end
  
  return author.given or ""
end


-- ========== STRING UTILITIES ==========

--- Returns the first UTF-8 codepoint of a string.
-- @param s string Input string
-- @return string First UTF-8 character
local function first_codepoint(s)
  return tostring(s):match("[%z\1-\127\194-\244][\128-\191]*") or ""
end


--- Returns UTF-8 aware string length.
-- @param s string Input string
-- @return number Length in characters (not bytes)
local function utf8_length(s)
  if utf8 and utf8.len then
    local len = utf8.len(s)
    if len then return len end
  end
  -- Fallback to byte length
  return #s
end


--- Extracts first letter of each word in a string.
-- @param s string Input string (e.g., "von Neumann")
-- @return string Concatenated first letters (e.g., "vN")
local function first_letters_of_words(s)
  local letters = {}
  for word in tostring(s):gmatch("%S+") do
    table.insert(letters, first_codepoint(word))
  end
  return table.concat(letters)
end


--- Strips HTML spans with "nocase" class (for title formatting).
-- @param s string HTML string
-- @return string String with nocase spans removed
local function strip_nocase_spans(s)
  s = tostring(s or "")
  return s:gsub('<span%s+[^>]*class=["\'][^"\']*nocase[^"\']*["\'][^>]*>(.-)</span>', '%1')
end


-- ========== LABEL GENERATION ==========

--- Generates bibliography label from authors and year.
-- Format examples:
--   Single author: "Ale14" (first 3 chars of last name + last 2 digits of year)
--   Multiple authors: "ABC14" (initials of last names + year)
--   Many authors: "ABCD+14" (truncated with + indicator)
-- @param authors table Array of author objects
-- @param year string|number Publication year
-- @return string Bibliography label (e.g., "Ale14", "ABC+24")
local function make_bibliography_label(authors, year)
  -- Extract last names
  local last_names = {}
  for _, author in ipairs(authors) do
    table.insert(last_names, extract_last_name(author))
  end
  
  -- Generate author key
  local author_key
  if #last_names == 1 then
    -- Single author: use first 3 characters of last name
    local name = tostring(last_names[1] or "")
    if utf8_length(name) >= 3 then
      author_key = name:sub(1, 3)
    else
      author_key = name
    end
  else
    -- Multiple authors: use first letter of each last name
    local initials = {}
    for _, name in ipairs(last_names) do
      table.insert(initials, first_letters_of_words(name or ""))
    end
    author_key = table.concat(initials)
  end
  
  -- Truncate if too long, add '+' indicator
  if utf8_length(author_key) >= 5 then
    author_key = author_key:sub(1, MAX_LABEL_LENGTH) .. "+"
  end
  
  -- Extract last 2 digits of year
  local year_suffix = ""
  if year ~= nil then
    local year_str = tostring(year)
    if #year_str >= 4 then
      year_suffix = year_str:sub(3, 4)
    end
  end
  
  -- ASCII-fold for URL safety and combine
  return ascii_fold_string(author_key) .. year_suffix
end


-- ========== HTML FORMATTING ==========

--- Formats page range with proper dash character.
-- @param pages string Page range (e.g., "123-456" or "123--456")
-- @return string HTML span with formatted pages
local function format_page_span(pages)
  if not pages or pages == "" then
    return ""
  end
  
  -- Replace hyphens with en-dash
  local formatted = pages:gsub("%-%-", "–"):gsub("%-", "–")
  return '<span class="citePages">:' .. html_escape(formatted) .. '</span>'
end


--- Creates linked title or plain title span.
-- Checks DOI, URL, and arXiv fields for linking.
-- @param item table CSL-JSON entry
-- @return string HTML anchor or span with title
local function format_title_with_link(item)
  local title = strip_nocase_spans(item.title or "")
  
  -- Determine link target (priority: DOI > URL > arXiv)
  local href = nil
  if item.DOI and item.DOI ~= "" then
    href = "http://dx.doi.org/" .. item.DOI
  elseif item.URL and item.URL ~= "" then
    href = item.URL
  elseif item.arXiv and item.arXiv ~= "" then
    href = "https://arxiv.org/abs/" .. item.arXiv
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


--- Formats venue information (journal/conference).
-- @param item table CSL-JSON entry
-- @return string HTML formatted venue information
local function format_venue_info(item)
  local parts = {}
  local container_title = item["container-title"] or ""
  local book_title = item["collection-title"] or item["event"] or item["event-title"] or item.booktitle or ""
  local volume = item.volume or ""
  local number = item.number or item.issue or ""
  local pages = item.page or ""
  local year = extract_year(item)
  local month = extract_month(item)
  
  if container_title ~= "" then
    -- Journal article format
    table.insert(parts, '<span class="citeJournal">' .. html_escape(container_title) .. '</span>')
    
    if volume ~= "" then
      table.insert(parts, ', <span class="citeVolume">' .. html_escape(volume) .. '</span>')
    end
    
    if number ~= "" then
      table.insert(parts, '<span class="citeNumber">(' .. html_escape(number) .. ')</span>')
    end
    
    if pages ~= "" then
      table.insert(parts, format_page_span(pages))
    end
    
    -- Date: prefer "Month Year" for journals
    if month then
      table.insert(parts, ', ' .. month .. ' ')
    else
      table.insert(parts, ',  ')
    end
    table.insert(parts, '<span class="citeYear">' .. html_escape(year) .. '. </span>')
    
  elseif book_title ~= "" then
    -- Conference/collection format
    table.insert(parts, '<span class="citeBooktitle">' .. html_escape(book_title) .. '</span>. ')
    
    local publisher = item.publisher or ""
    if publisher ~= "" then
      table.insert(parts, '<span class="citePublisher">' .. html_escape(publisher) .. '</span>,  ')
    end
    table.insert(parts, '<span class="citeYear">' .. html_escape(year) .. '. </span>')
    
  else
    -- Book/thesis/report format
    local series = item.series or ""
    local edition = item.edition or ""
    local publisher = item.publisher or ""
    
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
  
  return table.concat(parts)
end


--- Formats a single bibliography entry as HTML list item.
-- @param item table CSL-JSON entry
-- @param key string BibTeX key
-- @param label string|nil Optional custom label (generated if nil)
-- @return string HTML <li> element with formatted citation
local function format_bibliography_entry(item, key, label)
  local entry_id = item.id or (key or "")
  local authors = normalize_authors(item.author)
  local author_string = join_author_names(authors)
  local year = extract_year(item)
  local bib_label = label or make_bibliography_label(authors, year)
  
  local parts = {}
  
  -- Opening tag with ID
  table.insert(parts, '<li id="' .. html_escape(entry_id) .. '">')
  
  -- Label in brackets
  table.insert(parts, '<span class="citeKey">[' .. html_escape(bib_label) .. ']</span> ')
  
  -- Authors
  if author_string ~= "" then
    table.insert(parts, '<span class="citeAuthor">' .. html_escape(author_string) .. '</span>. ')
  end
  
  -- Title (with link if available)
  table.insert(parts, format_title_with_link(item) .. ". ")
  
  -- Venue information
  table.insert(parts, format_venue_info(item))
  
  -- Optional note
  if item.note and item.note ~= "" then
    table.insert(parts, '<span class="citeNote">' .. html_escape(item.note) .. '</span>')
  end
  
  table.insert(parts, "</li>")
  
  return table.concat(parts)
end


-- ========== BIBLIOGRAPHY LOADING ==========

--- Loads and caches bibliography JSON file.
-- Accepts either CSL-JSON array or object map format.
-- Results are memoized for performance.
-- @param path string|nil Path to bibliography JSON (uses default if nil)
-- @return table Map of citation ID to CSL-JSON entry
local function load_bibliography_json(path)
  if bib_cache then
    return bib_cache
  end
  
  path = path or DEFAULT_BIB_PATH
  local data = file_reading.load_json_file(path, "bibliography", true)
  local entry_map = {}
  
  if type(data) == "table" and #data > 0 then
    -- Array format: CSL-JSON array
    for _, entry in ipairs(data) do
      if entry and entry.id then
        entry_map[entry.id] = entry
      end
    end
  else
    -- Object format: map of ID to entry
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

--- Builds complete bibliography HTML section from citations list.
-- @param path string Path to bibliography JSON file
-- @param citations table Array of citation IDs or citation objects
-- @return string HTML <section> with bibliography, or empty string if no citations
local function build_bibliography_HTML(path, citations)
  local bibliography = load_bibliography_json(path)
  
  if type(citations) ~= "table" or #citations == 0 then
    return ""
  end
  
  local html_parts = {}
  table.insert(html_parts, '<section id="bibliography">\n<h2>Bibliography</h2>\n<ol>\n')
  
  for _, citation in ipairs(citations) do
    -- Handle both string IDs and wrapped objects
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


--- Gets the bibliography label for a citation ID.
-- @param id string Citation ID
-- @return string|nil Bibliography label (e.g., "Ale14") or nil if not found
local function get_bibliography_label(id)
  local bibliography = load_bibliography_json()
  local entry = bibliography and bibliography[id]
  
  if not entry then
    return nil
  end
  
  local authors = normalize_authors(entry.author)
  local year = extract_year(entry)
  
  return make_bibliography_label(authors, year)
end


-- ========== MODULE EXPORTS ==========

---@class BibliographyHandler
---@field build_bibliography_HTML fun(path: string, citations: table): string Builds HTML bibliography section
---@field get_bibliography_label fun(id: string): string? Gets label for a citation ID

---@type BibliographyHandler
local M = {
  build_bibliography_HTML = build_bibliography_HTML,
  get_bibliography_label = get_bibliography_label
}

return M