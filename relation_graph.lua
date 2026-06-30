-- Generate an interactive relation graph from polydata relation rows.

local utils             = dofile("utils.lua")
local file_reading      = dofile("file_reading.lua")
local bibhandler        = dofile("bibhandler.lua")
local relation_registry = dofile("relation_registry.lua")

local trim        = utils.trim

local M = {}

local GRAPH_HTML = "polynomial-relations.htm"
local GRAPH_JSON = "polynomial-relations.json"
local GRAPH_JS = "relation-graph.js?v=2"

local function attr_is_false(value)
  if value == false then return true end
  if value == nil then return false end
  local text = trim(tostring(value)):lower()
  return text == "false" or text == "no" or text == "0"
end

local function relation_is_visible(relation)
  if type(relation) ~= "table" then return false end
  if relation.status == "question" then return false end
  if type(relation.attrs) == "table" and attr_is_false(relation.attrs.include) then
    return false
  end
  return true
end

local function family_href(poly_id, entry)
  entry = entry or {}
  local page = entry.page or ""
  if page ~= "" then
    return string.format("%s.htm#%s", page, poly_id)
  end
  return string.format("#%s", poly_id)
end

local function copy_attrs(attrs)
  if type(attrs) ~= "table" then return {} end
  local copied = {}
  for key, value in pairs(attrs) do
    copied[key] = value
  end
  return copied
end

local function relation_refs(relation)
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
  end

  for ref in (tostring(relation.ref or "") .. ","):gmatch("(.-)%s*,") do
    add_ref(ref)
  end

  return refs
end

local function reference_items(refs)
  local items = {}
  for _, key in ipairs(refs) do
    items[#items + 1] = {
      key = key,
      label = bibhandler.get_bibliography_label(key) or key,
      tooltip = bibhandler.get_bibliography_tooltip(key) or "",
      href = "#" .. key
    }
  end
  return items
end

local function make_node(poly_id, entry)
  return {
    id = poly_id,
    name = entry.Name or poly_id,
    symbol = entry.Symbol or "",
    space = entry.Space or "",
    category = entry.Category or "",
    year = entry.Year or "",
    page = entry.page or "",
    href = family_href(poly_id, entry)
  }
end

local function sorted_relation_types(counts)
  local list = {}
  for type_name, spec in pairs(relation_registry.types()) do
    list[#list + 1] = {
      type = type_name,
      label = spec.label,
      poset = spec.poset and true or false,
      transitive = spec.transitive and true or false,
      count = counts[type_name] or 0
    }
  end
  table.sort(list, function(a, b)
    if a.poset ~= b.poset then return a.poset end
    return a.label < b.label
  end)
  return list
end

local function sorted_nodes(nodes_by_id)
  local nodes = {}
  for _, node in pairs(nodes_by_id) do
    nodes[#nodes + 1] = node
  end
  table.sort(nodes, function(a, b)
    local ak = table.concat({ a.space or "", a.category or "", a.name or "", a.id or "" }, "\t")
    local bk = table.concat({ b.space or "", b.category or "", b.name or "", b.id or "" }, "\t")
    return ak < bk
  end)
  return nodes
end

local function sorted_edges(edges)
  table.sort(edges, function(a, b)
    local ak = table.concat({
      a.source,
      a.type,
      a.target,
      tostring(a.source_index or 0),
      a.label
    }, "\t")
    local bk = table.concat({
      b.source,
      b.type,
      b.target,
      tostring(b.source_index or 0),
      b.label
    }, "\t")
    return ak < bk
  end)
  for index, edge in ipairs(edges) do
    edge.id = string.format("e%d", index)
  end
  return edges
end

function M.build_graph(polydata)
  local nodes_by_id = {}
  local edges = {}
  local relation_type_counts = {}
  local status_counts = {}
  local ref_seen = {}
  local ref_keys = {}

  for source_id, entry in pairs(polydata or {}) do
    local relations = entry.Relations
    if type(relations) == "table" then
      for index, relation in ipairs(relations) do
        if relation_is_visible(relation) then
          local target_id = trim(relation.target or "")
          local target_entry = polydata[target_id]
          if target_entry then
            nodes_by_id[source_id] = nodes_by_id[source_id] or make_node(source_id, entry)
            nodes_by_id[target_id] = nodes_by_id[target_id] or make_node(target_id, target_entry)

            local type_name = relation.type or ""
            local spec = relation_registry.get_type(type_name) or {}
            local status = relation.status or "theorem"
            local refs = relation_refs(relation)
            for _, ref in ipairs(refs) do
              if not ref_seen[ref] then
                ref_keys[#ref_keys + 1] = ref
                ref_seen[ref] = true
              end
            end

            relation_type_counts[type_name] = (relation_type_counts[type_name] or 0) + 1
            status_counts[status] = (status_counts[status] or 0) + 1
            local attrs = copy_attrs(relation.attrs)

            edges[#edges + 1] = {
              source = source_id,
              target = target_id,
              type = type_name,
              label = relation.label or spec.label or type_name,
              status = status,
              poset = spec.poset and true or false,
              transitive = spec.transitive and true or false,
              refs = reference_items(refs),
              attrs = next(attrs) and attrs or nil,
              source_index = index
            }
          end
        end
      end
    end
  end

  table.sort(ref_keys)

  local graph = {
    version = 1,
    generated_from = "polydata",
    graph_page = GRAPH_HTML,
    nodes = sorted_nodes(nodes_by_id),
    edges = sorted_edges(edges),
    relation_types = sorted_relation_types(relation_type_counts),
    status_counts = status_counts,
    references = ref_keys,
    stats = {
      node_count = 0,
      edge_count = #edges,
      reference_count = #ref_keys
    }
  }
  graph.stats.node_count = #graph.nodes
  return graph
end

local function format_iso_date(timestamp)
  local time_table = os.date("!*t", timestamp or os.time())
  return string.format("%04d-%02d-%02d", time_table.year, time_table.month, time_table.day)
end

local function format_lastmod_html(timestamp)
  local date = format_iso_date(timestamp)
  return string.format('<time class="dateMod" datetime="%s">%s</time>', date, date)
end

local function render_template(template, content)
  return template:gsub("<!%-%-([A-Z_%-]+)%-%->", function(name)
    return content[name] or ""
  end)
end

local function render_side_links(has_references)
  local links = {
    '<li><a href="#relationGraph" class="section">Relation graph</a></li>',
    '<li><a href="#relationData" class="section">Data</a></li>'
  }
  if has_references then
    links[#links + 1] = '<li><a href="#bibliography" class="section">Bibliography</a></li>'
  end
  return table.concat(links, "\n")
end

local function escape_json_for_script(json)
  return tostring(json or "")
    :gsub("<", "\\u003c")
    :gsub(">", "\\u003e")
    :gsub("&", "\\u0026")
end

local function render_main(graph)
  local graph_json = escape_json_for_script(file_reading.json_encode(graph))
  return string.format([[
<h2 id="relationGraph">Polynomial relation graph</h2>
<p>
This graph is generated from the structured relation rows in the polynomial
metadata. Direct formal relations are shown as directed edges.
</p>
<section class="relation-graph-page"
    data-relation-graph
    data-graph-src="%s"
    aria-labelledby="relationGraph">
  <div class="relation-graph-toolbar" aria-label="Relation graph controls">
    <label class="relation-graph-search">
      <span>Search</span>
      <input id="relationGraphSearch" type="search"
          placeholder="Schur, Macdonald, key..."
          autocomplete="off">
    </label>
    <fieldset class="relation-graph-fieldset">
      <legend>Types</legend>
      <div id="relationGraphTypeFilters" class="relation-graph-filter-list"></div>
    </fieldset>
    <fieldset class="relation-graph-fieldset">
      <legend>Status</legend>
      <label><input type="checkbox" data-status-filter="theorem" checked> Theorem</label>
      <label><input type="checkbox" data-status-filter="conjecture" checked> Conjecture</label>
    </fieldset>
    <label class="relation-graph-toggle">
      <input id="relationGraphPosetOnly" type="checkbox">
      Poset edges only
    </label>
    <button id="relationGraphReset" type="button">Reset</button>
  </div>

  <div class="relation-graph-shell">
    <div class="relation-graph-stage" tabindex="0">
      <svg id="relationGraphSvg"
          class="relation-graph-svg"
          role="img"
          aria-label="Polynomial relation graph"></svg>
    </div>
    <aside id="relationGraphDetails"
        class="relation-graph-details"
        aria-live="polite">
      <h3>Relation details</h3>
      <p>No relation selected.</p>
    </aside>
  </div>
</section>

<h2 id="relationData">Data</h2>
<p>
The browser view above is backed by
<a href="%s">the generated relation JSON</a>.
</p>
<script id="relationGraphData" type="application/json">
%s
</script>
<script src="./%s"></script>
]], GRAPH_JSON, GRAPH_JSON, graph_json, GRAPH_JS)
end

function M.render_page(graph, options)
  options = options or {}
  local template_path = options.template_path or os.getenv("TEMPLATE") or "template.htm"
  local refs_json = options.refs_json or os.getenv("REFS_JSON") or "temp/bibliography.json"
  local template = file_reading.read_file(template_path, "html template")
  local references_html = ""
  if #graph.references > 0 then
    references_html = bibhandler.build_bibliography_HTML(refs_json, graph.references)
  end

  return render_template(template, {
    TITLE = "Polynomial relation graph",
    DESCRIPTION = "Interactive graph of structured relations between polynomial families.",
    CANONICAL = GRAPH_HTML,
    STYLE = "",
    LASTMOD = format_lastmod_html(),
    EDITLINK = '<a class="editLink" href="https://github.com/PerAlexandersson/symmetricfunctions.com/blob/master/relation_graph.lua" target="_blank" rel="noopener">Improve this page</a>',
    MAIN = render_main(graph),
    SIDELINKS = render_side_links(#graph.references > 0),
    REFERENCES = references_html
  })
end

return M
