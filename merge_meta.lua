-- Metadata merger for static site generation
--
-- This script processes multiple Pandoc JSON files and extracts metadata to build:
-- - Site-wide label index (for cross-page references)
-- - Polydata index (for structured data about mathematical objects)
-- - TODO list (for tracking unfinished work)
-- - Sitemap XML (for search engines)
--
-- Usage:
--   lua merge_meta.lua temp/*.json
--
-- Outputs:
--   TEMP_DIR/site-labels.json   - Label to page/href mapping
--   TEMP_DIR/site-polydata.json - Polydata entries with validation
--   TEMP_DIR/site-todo.json     - Collected TODO items
--   TEMP_DIR/sitemap.xml        - XML sitemap for SEO
--
-- Environment variables:
--   TEMP_DIR      - Output directory for JSON files (default: "temp")
--   LABELS_JSON   - Path for labels output (default: temp/site-labels.json)
--   POLYDATA_JSON - Path for polydata output (default: temp/site-polydata.json)
--   TODOS_JSON    - Path for todos output (default: temp/site-todo.json)
--   SITEMAP_XML   - Path for sitemap output (default: temp/sitemap.xml)

-- ========== DEPENDENCIES ==========

local utils          = dofile("utils.lua")
local trim           = utils.trim
local print_info     = utils.print_info
local print_warn     = utils.print_warn
local print_error    = utils.print_error
local has_errors     = utils.has_errors
local table_size     = utils.table_size
local html_escape    = utils.html_escape

local file_reading   = dofile("file_reading.lua")
local json_encode    = file_reading.json_encode
local load_json_file = file_reading.load_json_file
local bibhandler     = dofile("bibhandler.lua")
local relation_registry = dofile("relation_registry.lua")
local relation_graph = dofile("relation_graph.lua")


-- ========== CONFIGURATION ==========

local OUT_DIR        = os.getenv("TEMP_DIR") or "temp"
local LABELS_JSON    = os.getenv("LABELS_JSON") or (OUT_DIR .. "/site-labels.json")
local POLYDATA_JSON  = os.getenv("POLYDATA_JSON") or (OUT_DIR .. "/site-polydata.json")
local TODOS_JSON     = os.getenv("TODOS_JSON") or (OUT_DIR .. "/site-todo.json")
local SITEMAP_XML    = os.getenv("SITEMAP_XML") or (OUT_DIR .. "/sitemap.xml")
local RELATION_GRAPH_HTML = os.getenv("RELATION_GRAPH_HTML") or "www/polynomial-relations.htm"
local RELATION_GRAPH_JSON = os.getenv("RELATION_GRAPH_JSON") or "www/polynomial-relations.json"


-- ========== CONSTANTS ==========

-- Required fields for polydata entries
local REQUIRED_POLYDATA_FIELDS = { "Name", "Space", "Year", "Rating" }

-- ========== FILE UTILITIES ==========

--- Extracts filename from path.
-- @param path string File path
-- @return string Filename without directory
local function get_basename(path)
  return path:match("([^/]+)$") or path
end


--- Extracts filename stem (without extension).
-- @param path string File path
-- @return string Filename without directory or .json extension
local function get_stem(path)
  return get_basename(path):gsub("%.json$", "")
end


--- Writes string to file atomically.
-- @param path string Output file path
-- @param content string Content to write
-- @return boolean, string|nil Success status and error message if failed
local function write_file(path, content)
  local file, err = io.open(path, "w")
  if not file then
    return false, err
  end
  
  local success, write_err = file:write(content)
  file:close()
  
  if not success then
    return false, write_err
  end
  
  return true
end


-- ========== PANDOC METADATA EXTRACTION ==========

--- Safely gets a metadata field.
-- @param meta table Pandoc metadata object
-- @param key string Field key
-- @return any|nil Field value or nil
local function get_meta_field(meta, key)
  return meta and meta[key]
end


--- Extracts a list of strings from Pandoc MetaList.
-- @param meta table Pandoc metadata object
-- @param key string Field key
-- @return table Array of strings
local function extract_meta_string_list(meta, key)
  local node = get_meta_field(meta, key)
  local result = {}
  
  if not node or node.t ~= "MetaList" then
    return result
  end
  
  for _, item in ipairs(node.c or {}) do
    if type(item) == "table" and item.t == "MetaString" then
      table.insert(result, item.c)
    elseif type(item) == "string" then
      table.insert(result, item)
    end
  end
  
  return result
end


--- Converts Pandoc metadata nodes to plain Lua values.
-- Handles nested MetaMaps, MetaLists, and scalar metadata nodes.
-- @param node any Pandoc metadata node
-- @return any Plain Lua value
local function meta_to_plain(node)
  if type(node) ~= "table" then
    return node
  end

  local node_type = node.t
  if node_type == "MetaString" then
    return node.c
  elseif node_type == "MetaBool" then
    return node.c and true or false
  elseif node_type == "MetaList" then
    local result = {}
    for _, item in ipairs(node.c or {}) do
      local value = meta_to_plain(item)
      if value ~= nil then
        result[#result + 1] = value
      end
    end
    return result
  elseif node_type == "MetaMap" then
    local result = {}
    for k, v in pairs(node.c or {}) do
      local value = meta_to_plain(v)
      if value ~= nil then
        result[k] = value
      end
    end
    return result
  end

  return nil
end


--- Extracts a map from Pandoc MetaMap, converting to plain Lua table.
-- @param meta table Pandoc metadata object
-- @param key string Field key
-- @return table Map of strings to strings or nested maps
local function extract_meta_map(meta, key)
  local node = get_meta_field(meta, key)
  
  if not node or node.t ~= "MetaMap" then
    return {}
  end

  local result = meta_to_plain(node)
  if type(result) ~= "table" then
    return {}
  end

  return result
end


--- Extracts page title from metadata.
-- @param meta table Pandoc metadata object
-- @param fallback string Fallback title if not found
-- @return string Page title
local function extract_page_title(meta, fallback)
  local metatitle = get_meta_field(meta, "metatitle")
  
  if metatitle and metatitle.t == "MetaString" then
    return metatitle.c
  end
  
  return fallback
end


-- ========== DATA COLLECTION ==========

--- Represents collected site data during processing.
-- @class SiteData
-- @field pages table Array of page info: {id, slug}
-- @field labels table Map of label to {page, href, title}
-- @field polydata table Map of polydata ID to fields
-- @field todos table Array of {page, text}
-- @field label_duplicates table Map of duplicate labels to pages array
-- @field polydata_duplicates table Map of duplicate polydata ids to pages array


--- Creates a new site data collector.
-- @return SiteData Empty data structure
local function create_site_data()
  return {
    pages = {},
    labels = {},
    polydata = {},
    todos = {},
    label_duplicates = {},
    polydata_duplicates = {}
  }
end


--- Processes a single label, detecting duplicates.
-- @param data SiteData Site data collector
-- @param label string Label identifier
-- @param page_id string Page identifier
-- @param slug string Page slug (filename)
-- @param title string Page title
local function process_label(data, label, page_id, slug, title)
  if data.labels[label] then
    -- Duplicate detected
    data.label_duplicates[label] = data.label_duplicates[label] or { data.labels[label].page }
    table.insert(data.label_duplicates[label], page_id)
  else
    data.labels[label] = {
      page = page_id,
      href = slug .. "#" .. label,
      title = title
    }
  end
end


--- Processes polydata entries for a page.
-- @param data SiteData Site data collector
-- @param polydata_map table Map of polydata ID to fields
-- @param page_id string Page identifier
local function process_polydata(data, polydata_map, page_id)
  for poly_id, fields in pairs(polydata_map) do
    if data.polydata[poly_id] then
      data.polydata_duplicates[poly_id] =
        data.polydata_duplicates[poly_id] or { data.polydata[poly_id].page }
      table.insert(data.polydata_duplicates[poly_id], page_id)
      goto continue
    end

    local record = { page = page_id }
    
    -- Copy all fields
    for k, v in pairs(fields) do
      record[k] = v
    end
    
    data.polydata[poly_id] = record

    ::continue::
  end
end


--- Processes TODOs for a page.
-- @param data SiteData Site data collector
-- @param todos table Array of TODO strings
-- @param page_id string Page identifier
local function process_todos(data, todos, page_id)
  for _, todo_text in ipairs(todos) do
    table.insert(data.todos, {
      page = page_id,
      text = todo_text
    })
  end
end


--- Processes a single JSON file and extracts metadata.
-- @param data SiteData Site data collector
-- @param file_path string Path to JSON file
local function process_json_file(data, file_path)
  local doc = load_json_file(file_path, "page-json")
  
  if type(doc) ~= "table" or not doc.meta then
    print_error("Skipping unreadable or malformed JSON: %s", file_path)
    return
  end
  
  local page_id = get_stem(file_path)
  local slug = page_id .. ".htm"
  local meta = doc.meta or {}
  local title = extract_page_title(meta, page_id)
  
  -- Register page
  table.insert(data.pages, {
    id = page_id,
    slug = slug
  })
  
  -- Process labels
  local labels = extract_meta_string_list(meta, "labels")
  for _, label in ipairs(labels) do
    process_label(data, label, page_id, slug, title)
  end
  
  -- Process polydata
  local polydata_map = extract_meta_map(meta, "polydata")
  process_polydata(data, polydata_map, page_id)
  
  -- Process TODOs
  local todos = extract_meta_string_list(meta, "todos")
  process_todos(data, todos, page_id)
end


-- ========== VALIDATION ==========

local function split_refs(ref)
  local refs = {}
  for item in (tostring(ref or "") .. ","):gmatch("(.-)%s*,") do
    item = trim(item)
    if item ~= "" then
      refs[#refs + 1] = item
    end
  end
  return refs
end

local function normalize_relation_refs(relation)
  local refs = {}
  local seen = {}

  local function add_ref(ref)
    ref = trim(ref or "")
    if ref ~= "" and not seen[ref] then
      refs[#refs + 1] = ref
      seen[ref] = true
    end
  end

  if type(relation.refs) == "table" then
    for _, ref in ipairs(relation.refs) do
      add_ref(ref)
    end
  elseif relation.refs ~= nil then
    add_ref(tostring(relation.refs))
  end

  for _, ref in ipairs(split_refs(relation.ref)) do
    add_ref(ref)
  end

  relation.refs = refs
  if #refs > 0 then
    relation.ref = table.concat(refs, ",")
  else
    relation.ref = nil
  end

  return refs
end

local function validate_relation_refs(poly_id, page_id, relation, index)
  local refs = normalize_relation_refs(relation)
  if #refs == 0 then
    print_warn("Polydata '%s' on page '%s' relation #%d has no bibliography key",
               poly_id, page_id, index)
    return
  end

  for _, ref in ipairs(refs) do
    if not bibhandler.get_bibliography_label(ref) then
      print_error("Polydata '%s' on page '%s' relation #%d has unknown bibliography key '%s'",
                  poly_id, page_id, index, ref)
    end
  end
end

local function validate_relation_status(poly_id, page_id, relation, index)
  local status = relation_registry.normalize_status(relation.status)
  relation.status = status

  if not relation_registry.is_valid_status(status) then
    print_error("Polydata '%s' on page '%s' relation #%d has invalid status '%s'",
                poly_id, page_id, index, tostring(relation.status))
    return false
  end

  return true
end

local function validate_relation_attrs(poly_id, page_id, relation, index)
  if relation.attrs == nil then
    return true
  end

  if type(relation.attrs) ~= "table" then
    print_error("Polydata '%s' on page '%s' relation #%d has malformed attrs",
                poly_id, page_id, index)
    return false
  end

  local relation_type = relation.type or ""
  local is_valid = true
  local normalized_attrs = {}

  for key, value in pairs(relation.attrs) do
    local normalized_key = relation_registry.normalize_attr_key(key)
    normalized_attrs[normalized_key] = value

    if not relation_registry.is_allowed_attr(relation_type, normalized_key) then
      print_error("Polydata '%s' on page '%s' relation #%d has unexpected attribute '%s'",
                  poly_id, page_id, index, normalized_key)
      is_valid = false
    end
  end

  relation.attrs = normalized_attrs

  return is_valid
end

local function validate_rating(poly_id, page_id, value)
  local rating = tonumber(value)
  if not rating then
    print_error("Polydata '%s' on page '%s' has non-numeric Rating '%s'",
                poly_id, page_id, tostring(value))
    return false
  end
  if rating < 0 or rating > 10 then
    print_error("Polydata '%s' on page '%s' has Rating outside 0..10: %s",
                poly_id, page_id, tostring(value))
    return false
  end
  return true
end

local function validate_basis(poly_id, page_id, value)
  if value == nil or value == "" then
    return true
  end
  local text = trim(tostring(value)):lower()
  if text == "yes" or text == "no"
      or text == "true" or text == "false"
      or text == "1" or text == "0"
      or text == "?" or text == "unknown" then
    return true
  end
  print_error("Polydata '%s' on page '%s' has invalid Basis value '%s'",
              poly_id, page_id, tostring(value))
  return false
end

--- Validates that polydata entries have required fields and matching labels.
-- @param data SiteData Site data to validate
-- @return boolean True if all validation passes
local function validate_polydata(data)
  local is_valid = true
  
  for poly_id, poly_entry in pairs(data.polydata) do
    local page_id = poly_entry.page or "?"
    
    -- Check for corresponding label
    if not data.labels[poly_id] then
      print_error("Polydata '%s' has no corresponding label entry", poly_id)
      is_valid = false
    end
    
    -- Check required fields
    for _, field in ipairs(REQUIRED_POLYDATA_FIELDS) do
      local value = poly_entry[field]
      if value == nil or trim(tostring(value)) == "" then
        print_error("Polydata '%s' on page '%s' is missing required field '%s'", 
                    poly_id, page_id, field)
        is_valid = false
      end
    end

    if poly_entry.Rating ~= nil
        and not validate_rating(poly_id, page_id, poly_entry.Rating) then
      is_valid = false
    end

    if poly_entry.Basis ~= nil
        and not validate_basis(poly_id, page_id, poly_entry.Basis) then
      is_valid = false
    end

    -- Check relation metadata, if present.
    local relations = poly_entry.Relations
    if relations ~= nil then
      if type(relations) ~= "table" then
        print_error("Polydata '%s' on page '%s' has malformed Relations data", 
                    poly_id, page_id)
        is_valid = false
      else
        for index, relation in ipairs(relations) do
          if type(relation) ~= "table" then
            print_error("Polydata '%s' on page '%s' has malformed relation #%d",
                        poly_id, page_id, index)
            is_valid = false
          else
            local relation_type = relation.type or ""
            local target = trim(tostring(relation.target or ""))

            if not relation_registry.is_valid_type(relation_type) then
              print_error("Polydata '%s' on page '%s' has unknown relation type '%s'",
                          poly_id, page_id, tostring(relation_type))
              is_valid = false
            end

            if not validate_relation_status(poly_id, page_id, relation, index) then
              is_valid = false
            end

            if not validate_relation_attrs(poly_id, page_id, relation, index) then
              is_valid = false
            end

            validate_relation_refs(poly_id, page_id, relation, index)

            if target == "" then
              print_error("Polydata '%s' on page '%s' has relation #%d with no target",
                          poly_id, page_id, index)
              is_valid = false
            elseif not data.polydata[target] then
              print_error("Polydata '%s' on page '%s' relation '%s' points to unknown polydata '%s'",
                          poly_id, page_id, relation_type, target)
              is_valid = false
            end
          end
        end
      end
    end
  end
  
  return is_valid
end


--- Reports duplicate labels found during processing.
-- @param duplicates table Map of label to pages array
local function report_duplicate_labels(duplicates)
  local is_valid = true
  for label, pages in pairs(duplicates) do
    print_error("Label '%s' defined in multiple pages: %s", 
                label, table.concat(pages, ", "))
    is_valid = false
  end
  return is_valid
end

--- Reports duplicate polydata ids found during processing.
-- @param duplicates table Map of polydata id to pages array
local function report_duplicate_polydata(duplicates)
  local is_valid = true
  for poly_id, pages in pairs(duplicates) do
    print_error("Polydata '%s' defined in multiple pages: %s",
                poly_id, table.concat(pages, ", "))
    is_valid = false
  end
  return is_valid
end


-- ========== OUTPUT GENERATION ==========

--- Formats a date as ISO 8601 (YYYY-MM-DD).
-- @param timestamp number|nil Unix timestamp (defaults to current time)
-- @return string Formatted date
local function format_iso_date(timestamp)
  local time_table = os.date("!*t", timestamp or os.time())
  return string.format("%04d-%02d-%02d", time_table.year, time_table.month, time_table.day)
end


--- Generates sitemap XML content.
-- @param pages table Array of page info: {id, slug}
-- @return string XML sitemap content
local function generate_sitemap_xml(pages)
  local lines = {}
  
  table.insert(lines, '<?xml version="1.0" encoding="UTF-8"?>')
  table.insert(lines, '<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">')
  
  local today = format_iso_date()
  
  -- Sort pages by slug for consistent output
  local sorted_pages = {}
  for _, page in ipairs(pages) do
    table.insert(sorted_pages, page)
  end
  table.sort(sorted_pages, function(a, b) return a.slug < b.slug end)
  
  for _, page in ipairs(sorted_pages) do
    table.insert(lines, "  <url>")
    table.insert(lines, "    <loc>https://www.symmetricfunctions.com/" .. html_escape(page.slug) .. "</loc>")
    table.insert(lines, "    <lastmod>" .. today .. "</lastmod>")
    table.insert(lines, "  </url>")
  end
  
  table.insert(lines, "</urlset>")
  
  return table.concat(lines, "\n") .. "\n"
end


--- Writes JSON data to file with error handling.
-- @param path string Output file path
-- @param data table Data to encode as JSON
-- @param description string Human-readable description for logging
-- @return boolean Success status
local function write_json_file(path, data, description)
  local json_content = json_encode(data)
  local success, err = write_file(path, json_content)
  
  if not success then
    print_error("Failed to write %s: %s", path, err)
    return false
  end
  
  print_info("Generated %s (%d %s)", path, table_size(data), description)
  return true
end

--- Writes XML data to file with error handling.
-- @param path string Output file path
-- @param content string XML content
-- @param count number Count of items for logging
-- @param description string Human-readable description for logging
-- @return boolean Success status
local function write_xml_file(path, content, count, description)
  local success, err = write_file(path, content)
  
  if not success then
    print_error("Failed to write %s: %s", path, err)
    return false
  end
  
  print_info("Generated %s (%d %s)", path, count, description)
  return true
end


--- Generates a goto.htm redirect page from label data.
-- URLs of the form goto.htm#label redirect to the correct page#anchor.
-- @param labels table Label map from site data
-- @return string HTML content
local function generate_goto_html(labels)
  -- Build sorted JS object literal
  local entries = {}
  for label, info in pairs(labels) do
    table.insert(entries, string.format('"%s":"%s"', label, info.href))
  end
  table.sort(entries)

  return [[<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<title>Redirecting… | SymCat</title>
</head>
<body>
<p>Redirecting…</p>
<script>
var defined_labels = {]] .. table.concat(entries, ",") .. [[};
var id = location.hash.slice(1);
var target = defined_labels[id];
if (target) { location.replace(target); }
else { document.body.textContent = "Unknown label: " + id; }
</script>
<noscript><p>JavaScript is required for redirection.</p></noscript>
</body>
</html>
]]
end


--- Generates all output files from collected site data.
-- @param data SiteData Collected and validated site data
-- @return boolean True if all outputs written successfully
local function generate_outputs(data)
  local all_success = true
  local graph = relation_graph.build_graph(data.polydata)

  -- Write labels index
  if not write_json_file(LABELS_JSON, data.labels, "labels") then
    all_success = false
  end

  -- Write polydata index
  if not write_json_file(POLYDATA_JSON, data.polydata, "poly items") then
    all_success = false
  end

  -- Write TODOs
  if not write_json_file(TODOS_JSON, data.todos, "todo notes") then
    all_success = false
  end

  -- Write sitemap XML
  local sitemap_pages = {}
  local has_relation_page = false
  for _, page in ipairs(data.pages) do
    sitemap_pages[#sitemap_pages + 1] = page
    if page.slug == "polynomial-relations.htm" then
      has_relation_page = true
    end
  end
  if not has_relation_page then
    sitemap_pages[#sitemap_pages + 1] = {
      id = "polynomial-relations",
      slug = "polynomial-relations.htm"
    }
  end

  local sitemap_content = generate_sitemap_xml(sitemap_pages)
  if not write_xml_file(SITEMAP_XML, sitemap_content, #sitemap_pages, "pages") then
    all_success = false
  end

  -- Write goto.htm redirect page and public site-labels.json
  local www_dir = os.getenv("WWW_DIR") or "www"
  local goto_path = www_dir .. "/goto.htm"
  local goto_content = generate_goto_html(data.labels)
  local ok, err = write_file(goto_path, goto_content)
  if ok then
    print_info("Generated %s (%d labels)", goto_path, table_size(data.labels))
  else
    print_error("Failed to write %s: %s", goto_path, err)
    all_success = false
  end

  -- Public copy of labels for cross-site use (e.g. arxiv.symmetricfunctions.com)
  if not write_json_file(www_dir .. "/site-labels.json", data.labels, "labels (public)") then
    all_success = false
  end

  if not write_json_file(RELATION_GRAPH_JSON, graph, "relation graph items") then
    all_success = false
  end

  local graph_html = relation_graph.render_page(graph)
  local graph_ok, graph_err = write_file(RELATION_GRAPH_HTML, graph_html)
  if graph_ok then
    print_info("Generated %s (%d relations)",
               RELATION_GRAPH_HTML, graph.stats.edge_count)
  else
    print_error("Failed to write %s: %s", RELATION_GRAPH_HTML, graph_err)
    all_success = false
  end

  return all_success
end


-- ========== MAIN EXECUTION ==========

--- Main entry point for metadata merging.
-- @return number Exit code (0 for success, 1 for failure)
local function main()
  -- Validate command line arguments
  if #arg == 0 then
    print_error("Usage: lua merge_meta.lua temp/*.json")
    return 1
  end
  
  -- Initialize data collection
  local site_data = create_site_data()
  
  -- Process all input files
  for i = 1, #arg do
    process_json_file(site_data, arg[i])
  end
  
  -- Report issues
  local labels_unique = report_duplicate_labels(site_data.label_duplicates)
  local polydata_unique = report_duplicate_polydata(site_data.polydata_duplicates)
  
  -- Validate collected data
  local validation_passed = validate_polydata(site_data)

  if not (labels_unique and polydata_unique and validation_passed)
      or has_errors() then
    print_error("Metadata merge completed with errors")
    return 1
  end
  
  -- Generate outputs
  local outputs_written = generate_outputs(site_data)
  
  -- Determine exit code
  if outputs_written and not has_errors() then
    return 0
  else
    print_error("Metadata merge completed with errors")
    return 1
  end
end


-- Execute main function
local exit_code = main()
os.exit(exit_code)
