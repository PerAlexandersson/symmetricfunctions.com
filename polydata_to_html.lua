-- Read family JSON and emit an HTML table for symmetric function families.

local utils             = dofile("utils.lua")
local bibhandler        = dofile("bibhandler.lua")
local relation_registry = dofile("relation_registry.lua")

local trim         = utils.trim
local html_escape  = utils.html_escape
local get_bib_label = bibhandler.get_bibliography_label
local get_bib_tooltip = bibhandler.get_bibliography_tooltip
local relation_is_visible = relation_registry.is_visible
local family_href = relation_registry.family_href

----------------------------------------------------------------------
-- Helpers
----------------------------------------------------------------------

local function normalize_boolean(value)
  if value == true then return true end
  if value == false or value == nil then return false end
  local text = trim(tostring(value)):lower()
  return text == "yes" or text == "true" or text == "1"
end

local function normalize_rating(value)
  local rating = tonumber(value)
  if not rating then return 0 end
  if rating < 0 then return 0 end
  if rating > 10 then return 10 end
  return rating
end

--- Sorted list of { key = id, data = entry } by name, then year, then id.
local function make_family_list(families)
  local list = {}
  for key, data in pairs(families) do
    list[#list+1] = { key = key, data = data }
  end
  table.sort(list, function(a, b)
    local na = (a.data.Name or a.key):lower()
    local nb = (b.data.Name or b.key):lower()
    if na ~= nb then return na < nb end
    local ya, yb = tostring(a.data.Year or ""), tostring(b.data.Year or "")
    if ya ~= yb then return ya < yb end
    return a.key < b.key
  end)
  return list
end

local function relation_text(relations)
  if type(relations) ~= "table" then return "" end

  local parts = {}
  for _, relation in ipairs(relations) do
    if relation_is_visible(relation) then
      local refs = relation.ref or ""
      if refs == "" and type(relation.refs) == "table" then
        refs = table.concat(relation.refs, " ")
      end
      parts[#parts + 1] = table.concat({
        relation.label or relation.type or "",
        relation.target or "",
        refs,
        relation.status or ""
      }, " ")
    end
  end

  return table.concat(parts, " ")
end

local function render_relation_refs(relation, labels)
  local refs = relation_registry.refs(relation or {})
  if #refs == 0 then return "" end
  local parts = {}

  for _, bib_key in ipairs(refs) do
    local label = labels[bib_key] or get_bib_label(bib_key) or bib_key
    local tooltip = get_bib_tooltip(bib_key)
    local title_attr = tooltip and string.format(' title="%s"', html_escape(tooltip)) or ""
    parts[#parts + 1] = string.format(
      '<span class="fam-relation-ref"%s>[%s]</span>',
      title_attr,
      html_escape(label)
    )
  end

  return " " .. table.concat(parts, " ")
end

local function render_relation_cell(entry, families, labels)
  local relations = entry.Relations
  if type(relations) ~= "table" or #relations == 0 then
    return '<td class="fam-relations">&nbsp;</td>'
  end

  local parts = {}
  for _, relation in ipairs(relations) do
    if relation_is_visible(relation) then
      local label = relation.label or relation.type or "Relation"
      local target = relation.target or ""
      local target_entry = families[target]
      local target_name = (target_entry and target_entry.Name) or target
      local target_html
      local status = relation.status or "theorem"

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
        '<span class="fam-relation fam-relation-%s"><span class="fam-relation-label">%s</span> %s%s</span>',
        html_escape(status),
        html_escape(label),
        target_html,
        render_relation_refs(relation, labels)
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

local function render_row(key, entry, families, labels)
  local name     = entry.Name or key
  local space    = entry.Space or ""
  local is_basis = normalize_boolean(entry.Basis)
  local category = entry.Category or ""
  local year     = entry.Year or ""
  local rating   = normalize_rating(entry.Rating)

  local href = family_href(key, entry)

  local pct = (tonumber(rating) or 0) * 10

  local data_attrs = string.format(
    'data-key="%s" data-space="%s" data-category="%s" data-year="%s" data-rating="%s" data-basis="%s" data-relations="%s" style="--percent: %g%%;"',
    html_escape(key),
    html_escape(space),
    html_escape(category),
    html_escape(tostring(year)),
    html_escape(tostring(rating)),
    is_basis and "true" or "false",
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
    space ~= "" and html_escape(space) or "&nbsp;"
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
    html_escape(tostring(rating))
  )

  local relations_cell = render_relation_cell(entry, families, labels)

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

  -- Every reference shown in the table counts as cited on this page.
  local keys = {}
  for _, item in ipairs(list) do
    for _, relation in ipairs(item.data.Relations or {}) do
      if relation_is_visible(relation) then
        for _, key in ipairs(relation_registry.refs(relation)) do keys[#keys + 1] = key end
      end
    end
  end
  local labels = bibhandler.page_labels(keys)

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

  for _, item in ipairs(list) do
    out[#out+1] = render_row(item.key, item.data, polydata, labels)
  end

  out[#out+1] = '</tbody></table>'

  return table.concat(out, "\n")
end

local M = {
  render_polynomial_table = render_polynomial_table,
}
return M
