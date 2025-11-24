-- families_to_html.lua
-- Read family JSON and emit an HTML table for symmetric function families.

local utils        = dofile("utils.lua")
local json_utils   = dofile("file_reading.lua")

local trim         = utils.trim
local html_escape  = utils.html_escape
local slugify      = utils.slugify
local print_error  = utils.print_error
local load_json    = json_utils.load_json_file

----------------------------------------------------------------------
-- Helpers
----------------------------------------------------------------------

--TODO: Use CSS and data-rating attribute instead.
local function rating_to_stars(r)
  local n = tonumber(r or 0) or 0
  if n < 0 then n = 0 end
  if n > 5 then n = 5 end
  return string.rep("★", n) .. string.rep("☆", 5 - n)
end

local function basis_flag(entry)
  -- Normalize a bit: treat "True", "Yes", "Basis" as positive
  local b = tostring(entry.Basis or ""):lower()
  if b == "true" or b == "yes" or b == "basis" then
    return true
  end
  return false
end

local function space_with_basis(entry)
  local space = entry.Space or ""
  local is_basis = basis_flag(entry)

  if space == "" then
    return "", "", ""
  end

  local space_html = html_escape(space)
  local basis_html = ""
  local basis_title = ""

  if is_basis then
    basis_html  = '<span class="family-badge family-basis">basis</span>'
    basis_title = "basis"
  else
    basis_html  = '<span class="family-badge family-nonbasis">not basis</span>'
    basis_title = "not basis"
  end

  -- e.g. "Sym  [basis]"
  local combined = string.format(
    '%s %s',
    space_html,
    basis_html
  )

  return combined, (is_basis and "true" or "false"), basis_title
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

----------------------------------------------------------------------
-- Render one table row
----------------------------------------------------------------------

local function render_row(entry)
  local key      = entry._key or ""
  local name     = entry.Name or key
  local space    = entry.Space or ""
  local category = entry.Category or ""
  local year     = entry.Year or ""
  local rating   = entry.Rating or ""
  local bib      = entry.Bib or ""
  local symbol   = entry.Symbol or ""
  local keywords = entry.Keywords or ""
  local page     = entry.page or ""

  local rating_num   = rating_to_number(rating)
  local rating_stars = rating_to_stars(rating)
  local space_html, basis_attr, _basis_title = space_with_basis(entry)

  local slug  = slugify(key)
  local href  = ""
  if page ~= "" then
    href = string.format("%s.htm#%s", page, key)
  else
    href = string.format("#%s", key)
  end

  local data_attrs = string.format(
    'data-key="%s" data-space="%s" data-category="%s" data-year="%s" data-rating="%d" data-basis="%s"',
    html_escape(key),
    html_escape(space),
    html_escape(category),
    html_escape(tostring(year)),
    rating_num,
    basis_attr
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
    '<td class="fam-rating" data-rating="%d">%s</td>',
    rating_num,
    html_escape(rating_stars)
  )

  -- Details cell (Symbol, Bib, Keywords, Basis, Space)
  local has_details = (symbol ~= "" or bib ~= "" or keywords ~= "")

  local details_html = ""
  if has_details then
    local parts = {}

    if symbol ~= "" then
      parts[#parts+1] = string.format(
        '<div><strong>Symbol:</strong> %s</div>',
        symbol  -- keep TeX, KaTeX will handle it later
      )
    end
    if bib ~= "" then
      parts[#parts+1] = string.format(
        '<div><strong>Ref:</strong> %s</div>',
        html_escape(bib)
      )
    end
    if keywords ~= "" then
      parts[#parts+1] = string.format(
        '<div><strong>Keywords:</strong> %s</div>',
        html_escape(keywords)
      )
    end

    details_html = string.format(
      '<details><summary>Details</summary><div class="fam-details">%s</div></details>',
      table.concat(parts, "")
    )
  else
    details_html = "&nbsp;"
  end

  local details_cell = string.format('<td class="fam-extra">%s</td>', details_html)

  return string.format(
    '<tr %s>%s%s%s%s%s%s</tr>',
    data_attrs,
    name_cell,
    space_cell,
    cat_cell,
    year_cell,
    rating_cell,
    details_cell
  )
end

----------------------------------------------------------------------
-- Render full table
----------------------------------------------------------------------

local function render_table(families)
  local list = make_family_list(families)

  local out = {}
  out[#out+1] = '<table id="family-index" class="family-index">'
  out[#out+1] = '<thead><tr>'
  out[#out+1] = '<th class="fi-name">Name</th>'
  out[#out+1] = '<th class="fi-space">Space</th>'
  out[#out+1] = '<th class="fi-category">Category</th>'
  out[#out+1] = '<th class="fi-year">Year</th>'
  out[#out+1] = '<th class="fi-rating">Rating</th>'
  out[#out+1] = '<th class="fi-extra">Details</th>'
  out[#out+1] = '</tr></thead>'
  out[#out+1] = '<tbody>'

  for _, entry in ipairs(list) do
    out[#out+1] = render_row(entry)
  end

  out[#out+1] = '</tbody></table>'

  return table.concat(out, "\n")
end

----------------------------------------------------------------------
-- Main (CLI)
----------------------------------------------------------------------

local function main()
  local json_path = arg[1]
  if not json_path then
    print_error("Usage: lua families_to_html.lua families.json > family-index.htmlfrag")
    os.exit(1)
  end

  local families = load_json(json_path, "family metadata", true)
  local html = render_table(families)
  io.write(html, "\n")
end

if pcall(debug.getlocal, 4, 1) == false then
  -- run only when executed as a script, not when required() as a module
  main()
end

return {
  render_table = render_table,
}
