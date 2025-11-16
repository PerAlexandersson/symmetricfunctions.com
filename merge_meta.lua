-- merge_meta.lua
-- Usage: lua merge_meta.lua temp/*.json
-- Outputs (in TEMP_DIR): site-labels.json, site-polydata.json, and (WWW_DIR) sitemap.xml


-- ----- deps / utils -------------------------------------------------
local utils = dofile("utils.lua")
local trim        = utils.trim
local print_info  = utils.print_info
local print_warn  = utils.print_warn
local print_error = utils.print_error
local print_todo  = utils.print_todo
local load_json   = utils.load_json_file
local json_lib    = utils.json_lib

-- FILE Paths (defined in the makefile)
local OUT_DIR         = os.getenv("TEMP_DIR") or "temp"
local LABELS_JSON     = os.getenv("LABELS_JSON")   or (OUT_DIR .. "/site-labels.json")
local POLYDATA_JSON   = os.getenv("POLYDATA_JSON") or (OUT_DIR .. "/site-polydata.json")
local TODOS_JSON      = os.getenv("TODOS_JSON") or (OUT_DIR .. "/site-todo.json")
local SITEMAP_XML     = os.getenv("SITEMAP_XML")   or (OUT_DIR .. "/sitemap.xml")

-- ----- tiny helpers -------------------------------------------------
local function basename(path) return path:match("([^/]+)$") end
local function stem(path)     return basename(path):gsub("%.json$", "") end


local function read_all(path)
  local f, err = io.open(path, "r"); if not f then error(err) end
  local s = f:read("*a"); f:close(); return s
end

local function write_all(path, s)
  local f, err = io.open(path, "w"); if not f then error(err) end
  f:write(s); f:close()
end

local function encode_pretty(tbl)
  if json_lib and json_lib.encode then
    local ok, out = pcall(json_lib.encode, tbl, { indent = true })
    if ok then return out end
  end
  error("No json encoder available")
end


-- Pandoc Meta helpers (unwrap MetaString/MetaList of strings/MetaMap)
local function meta_get(meta, key) return meta and meta[key] end

local function meta_list_strings(meta, key)
  local node = meta_get(meta, key)
  local out = {}
  if not node or node.t ~= "MetaList" then return out end
  for _, it in ipairs(node.c or {}) do
    if type(it) == "table" and it.t == "MetaString" then
      out[#out+1] = it.c
    elseif type(it) == "string" then
      out[#out+1] = it
    end
  end
  return out
end


local function meta_map(meta, key)
  local node = meta_get(meta, key)
  if not node or node.t ~= "MetaMap" then return {} end
  -- convert MetaMap -> plain Lua table (strings only for our needs)
  local out = {}
  for k, v in pairs(node.c or {}) do
    if type(v) == "table" and v.t == "MetaMap" then
      local inner = {}
      for kk, vv in pairs(v.c or {}) do
        if type(vv) == "table" and vv.t == "MetaString" then
          inner[kk] = vv.c
        end
      end
      out[k] = inner
    elseif type(v) == "table" and v.t == "MetaString" then
      out[k] = v.c
    end
  end
  return out
end

-- ----- collectors ---------------------------------------------------
local pages = {}            -- { {id=..., slug=..., title=...} ... }
local label_index = {}      -- label -> { page=..., href=..., title=... }
local polydata_index = {}   -- polyId -> { page=..., ...original fields... }
local todos_all = {}        -- { {page=..., text=...}, ... }

local label_dups  = {}       -- Track labels that are duplicates.

for i = 1, #arg do
  local path = arg[i]

  -- Use shared JSON loader; returns {} on error
  local doc = load_json(path, "page-json")
  if type(doc) ~= "table" or not doc.meta then
    print_error("Skipping unreadable or malformed JSON: %s", path)
  else
    local st   = stem(path)              -- e.g. "schurS"
    local slug = st .. ".htm"
    local meta = doc.meta or {}

    -- title (if present)
    local metatitle = meta_get(meta, "metatitle")
    local title = (metatitle and metatitle.t == "MetaString") and metatitle.c or st

    pages[#pages+1] = { id = st, slug = slug }

    -- labels + duplicates
    for _, lab in ipairs(meta_list_strings(meta, "labels")) do
      if label_index[lab] then
        -- already seen → record all pages where it appears
        label_dups[lab] = label_dups[lab] or { label_index[lab].page }
        table.insert(label_dups[lab], st)
      else
        label_index[lab] = { page = st, href = slug .. "#" .. lab, title = title }
      end
    end

    -- polydata: flatten and remember page
    local pd = meta_map(meta, "polydata")
    for pid, fields in pairs(pd) do
      local rec = {}
      for k, v in pairs(fields) do rec[k] = v end
      rec.page = st
      polydata_index[pid] = rec
    end

    -- todos
    for _, t in ipairs(meta_list_strings(meta, "todos")) do
      todos_all[#todos_all+1] = { page = st, text = t }
    end
  end
end


-- Warn about duplicate labels
for lab, pages_list in pairs(label_dups) do
  print_error("Label '%s' defined in multiple pages: %s", lab, table.concat(pages_list, ", "))
end





local function validate_polydata()
  local ok = true
  local required_fields = { "Name", "Space", "Year", "Rating" }

  for id, pdata in pairs(polydata_index) do
    -- Check that there is a matching label
    local lbl = label_index[id]
    if not lbl then
      print_error("polydata '%s' has no corresponding label_index entry", id)
      ok = false
    end

    -- (2) check required fields
    for _, field in ipairs(required_fields) do
      local v = pdata[field]
      local page = pdata["page"] or "?"
      if v == nil or trim(tostring(v)) == "" then
        print_error("polydata '%s' on %s is missing required field '%s'", id, page , field)
        ok = false
      end
    end
  end

  return ok
end


validate_polydata()

-- ----- outputs ------------------------------------------------------
-- 1) label -> file index
write_all(LABELS_JSON, encode_pretty(label_index))
print_info("Generated %s (%d labels)", LABELS_JSON, (function(n) local c=0 for _ in pairs(label_index) do c=c+1 end return c end)())

-- 2) polydata index
write_all(POLYDATA_JSON, encode_pretty(polydata_index))
print_info("Generated %s (%d poly items)", POLYDATA_JSON, (function(n) local c=0 for _ in pairs(polydata_index) do c=c+1 end return c end)())


-- 3) todos
write_all(TODOS_JSON, encode_pretty(todos_all))
print_info("Generated %s (%d todo notes)", TODOS_JSON, (function(n) local c=0 for _ in pairs(todos_all) do c=c+1 end return c end)())


-- 4) sitemap.xml (relative URLs)
local function iso_date(ts)
  local t = os.date("!*t", ts or os.time())
  return string.format("%04d-%02d-%02d", t.year, t.month, t.day)
end


do
  local lines = {}
  lines[#lines+1] = '<?xml version="1.0" encoding="UTF-8"?>'
  lines[#lines+1] = '<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">'
  local today = iso_date()
  table.sort(pages, function(a,b) return a.slug < b.slug end)
  for _, p in ipairs(pages) do
    lines[#lines+1] = "  <url>"
    lines[#lines+1] = "    <loc>" .. utils.html_escape(p.slug) .. "</loc>"
    lines[#lines+1] = "    <lastmod>" .. today .. "</lastmod>"
    lines[#lines+1] = "  </url>"
  end
  lines[#lines+1] = "</urlset>"
  write_all(SITEMAP_XML, table.concat(lines, "\n") .. "\n")
end
print_info("Generated %s (%d pages)", SITEMAP_XML, #pages)
