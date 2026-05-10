-- Read family JSON and emit an HTML table for symmetric function families.

local utils          = dofile("utils.lua")
local file_reading   = dofile("file_reading.lua")
local bibhandler     = dofile("bibhandler.lua")

local trim         = utils.trim
local html_escape  = utils.html_escape
local print_error  = utils.print_error
local load_json    = file_reading.load_json_file
local get_bib_label = bibhandler.get_bibliography_label
local get_bib_tooltip = bibhandler.get_bibliography_tooltip

----------------------------------------------------------------------
-- Helpers
----------------------------------------------------------------------

local function space_with_basis(entry)
  local space = entry.Space or ""
  local is_basis = entry.Basis

  if space == "" then
    return "", "", ""
  end
  
  return html_escape(space), (is_basis and "true" or "false")
end

local function make_family_list(families)
  local list = {}
  for key, data in pairs(families) do
    data._key = key
    list[#list+1] = data
  end
  table.sort(list, function(a, b)
    local na = (a.Name or a._key or ""):lower()
    local nb = (b.Name or b._key or ""):lower()
    if na == nb then
      return (a.Year or "") < (b.Year or "")
    end
    return na < nb
  end)
  return list
end

local function family_href(key, entry)
  entry = entry or {}
  local page = entry.page or ""
  if page ~= "" then
    return string.format("%s.htm#%s", page, key)
  end
  return string.format("#%s", key)
end

local function relation_text(relations)
  if type(relations) ~= "table" then return "" end

  local parts = {}
  for _, relation in ipairs(relations) do
    if type(relation) == "table" then
      parts[#parts + 1] = table.concat({
        relation.label or relation.type or "",
        relation.target or "",
        relation.ref or ""
      }, " ")
    end
  end

  return table.concat(parts, " ")
end

local function render_relation_ref(ref)
  ref = trim(ref or "")
  if ref == "" then return "" end

  local parts = {}
  for bib_key in (ref .. ","):gmatch("(.-)%s*,") do
    bib_key = trim(bib_key)
    if bib_key ~= "" then
      local label = get_bib_label(bib_key) or bib_key
      local tooltip = get_bib_tooltip(bib_key)
      local title_attr = tooltip and string.format(' title="%s"', html_escape(tooltip)) or ""
      parts[#parts + 1] = string.format(
        '<span class="fam-relation-ref"%s>[%s]</span>',
        title_attr,
        html_escape(label)
      )
    end
  end

  if #parts == 0 then return "" end
  return " " .. table.concat(parts, " ")
end

local function render_relation_cell(entry, families)
  local relations = entry.Relations
  if type(relations) ~= "table" or #relations == 0 then
    return '<td class="fam-relations">&nbsp;</td>'
  end

  local parts = {}
  for _, relation in ipairs(relations) do
    if type(relation) == "table" then
      local label = relation.label or relation.type or "Relation"
      local target = relation.target or ""
      local target_entry = families[target]
      local target_name = (target_entry and target_entry.Name) or target
      local target_html

      if target ~= "" then
        target_html = string.format(
          '<a href="%s">%s</a>',
          html_escape(family_href(target, target_entry)),
          html_escape(target_name)
        )
      else
        target_html = '<span class="fam-relation-missing">?</span>'
      end

      parts[#parts + 1] = string.format(
        '<span class="fam-relation"><span class="fam-relation-label">%s</span> %s%s</span>',
        html_escape(label),
        target_html,
        render_relation_ref(relation.ref)
      )
    end
  end

  if #parts == 0 then
    return '<td class="fam-relations">&nbsp;</td>'
  end

  return string.format(
    '<td class="fam-relations"><div class="fam-relations-list">%s</div></td>',
    table.concat(parts, " ")
  )
end

----------------------------------------------------------------------
-- Render one table row
----------------------------------------------------------------------

local function render_row(entry, families)
  local key      = entry._key or ""
  local name     = entry.Name or key
  local space    = entry.Space or ""
  local is_basis = entry.Basis or ""
  local category = entry.Category or ""
  local year     = entry.Year or ""
  local rating   = entry.Rating or ""
  local bib      = entry.Bib or ""
  local symbol   = entry.Symbol or ""
  local keywords = entry.Keywords or ""
  local page     = entry.page or ""

  local space_html, basis_attr = space_with_basis(entry)

  local href = family_href(key, entry)

  local pct = (tonumber(rating) or 0) * 10

  local data_attrs = string.format(
    'data-key="%s" data-space="%s" data-category="%s" data-year="%s" data-rating="%s" data-basis="%s" data-relations="%s" style="--percent: %d%%;"',
    html_escape(key),
    html_escape(space),
    html_escape(category),
    html_escape(tostring(year)),
    rating,
    is_basis,
    html_escape(relation_text(entry.Relations)),
    pct
  )

  local name_cell = string.format(
    '<td class="fam-name"><a href="%s">%s</a></td>',
    html_escape(href),
    html_escape(name)
  )

  local space_cell = string.format(
    '<td class="fam-space">%s</td>',
    space_html ~= "" and space_html or "&nbsp;"
  )

  local cat_cell = string.format(
    '<td class="fam-category">%s</td>',
    category ~= "" and html_escape(category) or "&nbsp;"
  )

  local year_cell = string.format(
    '<td class="fam-year">%s</td>',
    year ~= "" and html_escape(tostring(year)) or "&nbsp;"
  )

  local rating_cell = string.format(
    '<td class="fam-rating" data-rating="%s">★★★★★</td>',
    rating
  )

  local relations_cell = render_relation_cell(entry, families)

  -- Details cell (Symbol, Bib, Keywords, Basis, Space)
  -- local has_details = (symbol ~= "" or bib ~= "" or keywords ~= "")

  -- local details_html = ""
  -- if has_details then
  --   local parts = {}

  --   if symbol ~= "" then
  --     parts[#parts+1] = string.format(
  --       '<div><strong>Symbol:</strong> %s</div>',
  --       symbol
  --     )
  --   end
  --   if bib ~= "" then
  --     parts[#parts+1] = string.format(
  --       '<div><strong>Ref:</strong> %s</div>',
  --       html_escape(bib)
  --     )
  --   end
  --   if keywords ~= "" then
  --     parts[#parts+1] = string.format(
  --       '<div><strong>Keywords:</strong> %s</div>',
  --       html_escape(keywords)
  --     )
  --   end

  --   details_html = string.format(
  --     '<details><summary>Details</summary><div class="fam-details">%s</div></details>',
  --     table.concat(parts, "")
  --   )
  -- else
  --   details_html = "&nbsp;"
  -- end

  --local details_cell = string.format('<td class="fam-extra">%s</td>', details_html)

  return string.format(
    '<tr %s> %s %s %s %s %s %s </tr>',
    data_attrs,
    name_cell,
    space_cell,
    cat_cell,
    year_cell,
    rating_cell,
    relations_cell
  )
end

----------------------------------------------------------------------
-- Render full table
----------------------------------------------------------------------

local function render_polynomial_table(polydata)
  local list = make_family_list(polydata)

  local out = {}
  out[#out+1] = '<table id="family-index" class="family-index">'
  out[#out+1] = '<thead><tr>'
  out[#out+1] = '<th class="fi-name">Name</th>'
  out[#out+1] = '<th class="fi-space">Space</th>'
  out[#out+1] = '<th class="fi-category">Category</th>'
  out[#out+1] = '<th class="fi-year">Year</th>'
  out[#out+1] = '<th class="fi-rating">Rating</th>'
  out[#out+1] = '<th class="fi-relations">Relations</th>'
  out[#out+1] = '</tr></thead>'
  out[#out+1] = '<tbody>'

  for _, entry in ipairs(list) do
    out[#out+1] = render_row(entry, polydata)
  end

  out[#out+1] = '</tbody></table>'

  return table.concat(out, "\n")
end

local M = {
  render_polynomial_table = render_polynomial_table,
}
return M
