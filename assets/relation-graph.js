(function () {
  'use strict';

  var SVG_NS = 'http://www.w3.org/2000/svg';
  var HTML_NS = 'http://www.w3.org/1999/xhtml';
  var NODE_W = 190;
  var NODE_H = 54;
  var X_STEP = 285;
  var Y_STEP = 76;
  var PAD_X = 64;
  var PAD_Y = 56;

  function $(selector, root) {
    return (root || document).querySelector(selector);
  }

  function $all(selector, root) {
    return Array.prototype.slice.call((root || document).querySelectorAll(selector));
  }

  function svgEl(name, attrs) {
    var el = document.createElementNS(SVG_NS, name);
    Object.keys(attrs || {}).forEach(function (key) {
      el.setAttribute(key, attrs[key]);
    });
    return el;
  }

  function htmlEl(name, attrs) {
    var el = document.createElementNS(HTML_NS, name);
    Object.keys(attrs || {}).forEach(function (key) {
      el.setAttribute(key, attrs[key]);
    });
    return el;
  }

  function escapeHtml(value) {
    return String(value == null ? '' : value)
      .replace(/&/g, '&amp;')
      .replace(/</g, '&lt;')
      .replace(/>/g, '&gt;')
      .replace(/"/g, '&quot;')
      .replace(/'/g, '&#39;');
  }

  function classPart(value) {
    return String(value || 'unknown').toLowerCase().replace(/[^a-z0-9_-]/g, '-');
  }

  function spaceClassPart(value) {
    return String(value || 'unknown')
      .toLowerCase()
      .replace(/\*/g, 'star')
      .replace(/[^a-z0-9]+/g, '-')
      .replace(/^-+|-+$/g, '') || 'unknown';
  }

  function nodeSortKey(node) {
    return [
      node.space || '',
      node.name || '',
      node.id || ''
    ].join('\t');
  }

  function makeNodeMap(nodes) {
    var map = Object.create(null);
    nodes.forEach(function (node) {
      map[node.id] = node;
    });
    return map;
  }

  function relationTypeMap(graph) {
    var map = Object.create(null);
    (graph.relation_types || []).forEach(function (type) {
      if (type.count > 0) map[type.type] = type;
    });
    return map;
  }

  function copyTypeSet(types) {
    var copied = Object.create(null);
    Object.keys(types || {}).forEach(function (key) {
      if (types[key]) copied[key] = true;
    });
    return copied;
  }

  function selectedTypeSet(root) {
    if (!root._relationGraphSelectedTypes) {
      root._relationGraphSelectedTypes = copyTypeSet(defaultTypes(root));
    }
    return root._relationGraphSelectedTypes;
  }

  function defaultTypes(root) {
    var value = root.getAttribute('data-default-types') || '';
    var selected = Object.create(null);
    value.split(/\s*,\s*/).forEach(function (type) {
      if (type) selected[type] = true;
    });
    return selected;
  }

  function hasSelectedTypes(types) {
    return Object.keys(types).length > 0;
  }

  function typeSetEquals(a, b) {
    var aKeys = Object.keys(a).sort();
    var bKeys = Object.keys(b).sort();
    if (aKeys.length !== bKeys.length) return false;
    for (var i = 0; i < aKeys.length; i += 1) {
      if (aKeys[i] !== bKeys[i]) return false;
    }
    return true;
  }

  function setTypeSelection(root, types) {
    root._relationGraphSelectedTypes = copyTypeSet(types);
  }

  function singletonTypeSet(typeName) {
    var types = Object.create(null);
    if (typeName) types[typeName] = true;
    return types;
  }

  var RELATION_LABELS = {
    positive_in: 'Positive expansion',
    specializes_to: 'Specialization',
    contains: 'Containment',
    k_theoretic_analogue_of: 'K-theoretic analogue',
    stable_limit: 'Stable limit',
    transforms_to: 'Transform',
    dual_to: 'Duality',
    signed_in: 'Signed expansion',
    refined_by: 'Refinement'
  };

  var MENU_RELATION_TYPES = [
    'positive_in',
    'specializes_to',
    'contains',
    'k_theoretic_analogue_of',
    'stable_limit'
  ];

  function relationLabel(type) {
    var key = typeof type === 'string' ? type : type.type;
    if (RELATION_LABELS[key]) return RELATION_LABELS[key];
    if (type && type.label) {
      return String(type.label).replace(/([a-z])([A-Z])/g, '$1 $2');
    }
    return String(key || 'Relation')
      .replace(/_/g, ' ')
      .replace(/\b\w/g, function (letter) { return letter.toUpperCase(); });
  }

  function edgeLabel(edge) {
    return relationLabel(edge.type) || edge.label || edge.type;
  }

  function typeSetForNames(typeMap, names) {
    var types = Object.create(null);
    names.forEach(function (name) {
      if (typeMap[name]) types[name] = true;
    });
    return types;
  }

  function presetDefinitions(graph) {
    var typeMap = relationTypeMap(graph);
    var seen = Object.create(null);
    var presets = [];

    function addPreset(id, label, types) {
      if (seen[id] || !hasSelectedTypes(types)) return;
      seen[id] = true;
      presets.push({ id: id, label: label, types: types });
    }

    function addSingle(typeName) {
      if (!typeMap[typeName]) return;
      addPreset(typeName, relationLabel(typeMap[typeName]), singletonTypeSet(typeName));
    }

    addPreset(
      'positive_in',
      'Positive expansion',
      typeSetForNames(typeMap, ['positive_in', 'refined_by'])
    );
    MENU_RELATION_TYPES.forEach(function (typeName) {
      if (typeName !== 'positive_in') addSingle(typeName);
    });
    return presets;
  }

  function initialTypeSet(graph, root) {
    var defaults = defaultTypes(root);
    if (hasSelectedTypes(defaults)) return defaults;
    var presets = presetDefinitions(graph);
    return presets.length > 0 ? presets[0].types : Object.create(null);
  }

  function textForNode(node) {
    return [
      node.id,
      node.name,
      node.space,
      node.symbol
    ].join(' ').toLowerCase();
  }

  function filteredGraph(graph, root) {
    var activeTypes = selectedTypeSet(root);
    var query = ($('#relationGraphSearch', root).value || '').trim().toLowerCase();
    var nodeMap = makeNodeMap(graph.nodes);
    var visibleNodes = Object.create(null);

    function nodeMatches(edge) {
      if (!query) return true;
      var source = nodeMap[edge.source];
      var target = nodeMap[edge.target];
      return (source && textForNode(source).indexOf(query) >= 0)
        || (target && textForNode(target).indexOf(query) >= 0)
        || String(edge.label || '').toLowerCase().indexOf(query) >= 0
        || edgeLabel(edge).toLowerCase().indexOf(query) >= 0;
    }

    var edges = graph.edges.filter(function (edge) {
      if (!activeTypes[edge.type]) return false;
      if (!nodeMatches(edge)) return false;
      visibleNodes[edge.source] = true;
      visibleNodes[edge.target] = true;
      return true;
    });

    var nodes = graph.nodes.filter(function (node) {
      return visibleNodes[node.id];
    });

    return { nodes: nodes, edges: edges };
  }

  function computeRanks(nodes, edges) {
    var adjacency = Object.create(null);
    var index = 0;
    var stack = [];
    var onStack = Object.create(null);
    var indexOf = Object.create(null);
    var lowlink = Object.create(null);
    var compOf = Object.create(null);
    var comps = [];

    nodes.forEach(function (node) {
      adjacency[node.id] = [];
    });

    edges.forEach(function (edge) {
      if (!adjacency[edge.source] || !adjacency[edge.target]) return;
      if (edge.source !== edge.target) adjacency[edge.source].push(edge.target);
    });

    function strongConnect(id) {
      indexOf[id] = index;
      lowlink[id] = index;
      index += 1;
      stack.push(id);
      onStack[id] = true;

      adjacency[id].forEach(function (target) {
        if (indexOf[target] == null) {
          strongConnect(target);
          lowlink[id] = Math.min(lowlink[id], lowlink[target]);
        } else if (onStack[target]) {
          lowlink[id] = Math.min(lowlink[id], indexOf[target]);
        }
      });

      if (lowlink[id] === indexOf[id]) {
        var comp = [];
        var current;
        do {
          current = stack.pop();
          onStack[current] = false;
          compOf[current] = comps.length;
          comp.push(current);
        } while (current !== id);
        comps.push(comp);
      }
    }

    nodes.forEach(function (node) {
      if (indexOf[node.id] == null) strongConnect(node.id);
    });

    var compOut = [];
    var compInDegree = [];
    var compRank = [];
    comps.forEach(function () {
      compOut.push(Object.create(null));
      compInDegree.push(0);
      compRank.push(0);
    });

    edges.forEach(function (edge) {
      var sourceComp = compOf[edge.source];
      var targetComp = compOf[edge.target];
      if (sourceComp == null || targetComp == null || sourceComp === targetComp) return;
      if (!compOut[sourceComp][targetComp]) {
        compOut[sourceComp][targetComp] = true;
        compInDegree[targetComp] += 1;
      }
    });

    var queue = comps
      .map(function (_, compId) { return compId; })
      .filter(function (compId) { return compInDegree[compId] === 0; });
    queue.sort(function (a, b) {
      return comps[a].join('\t').localeCompare(comps[b].join('\t'));
    });

    while (queue.length > 0) {
      var compId = queue.shift();
      Object.keys(compOut[compId]).forEach(function (targetKey) {
        var targetComp = Number(targetKey);
        compRank[targetComp] = Math.max(compRank[targetComp], compRank[compId] + 1);
        compInDegree[targetComp] -= 1;
        if (compInDegree[targetComp] === 0) queue.push(targetComp);
      });
      queue.sort(function (a, b) {
        return comps[a].join('\t').localeCompare(comps[b].join('\t'));
      });
    }

    var rank = Object.create(null);
    nodes.forEach(function (node) {
      rank[node.id] = compRank[compOf[node.id]] || 0;
    });
    return rank;
  }

  function rowIndexes(columns) {
    var rows = Object.create(null);
    Object.keys(columns).forEach(function (rankKey) {
      columns[rankKey].forEach(function (node, index) {
        rows[node.id] = index;
      });
    });
    return rows;
  }

  function orderLayers(columns, edges) {
    var rankKeys = Object.keys(columns)
      .map(Number)
      .sort(function (a, b) { return a - b; });
    var rankOf = Object.create(null);

    rankKeys.forEach(function (rankKey) {
      columns[rankKey].sort(function (a, b) {
        return nodeSortKey(a).localeCompare(nodeSortKey(b));
      });
      columns[rankKey].forEach(function (node) {
        rankOf[node.id] = rankKey;
      });
    });

    function reorder(rankKey, rows, forward) {
      columns[rankKey].sort(function (a, b) {
        var baryA = barycenter(a.id, rows, forward);
        var baryB = barycenter(b.id, rows, forward);
        if (baryA != null && baryB != null && baryA !== baryB) return baryA - baryB;
        if (baryA != null && baryB == null) return -1;
        if (baryA == null && baryB != null) return 1;
        return nodeSortKey(a).localeCompare(nodeSortKey(b));
      });
    }

    function barycenter(nodeId, rows, forward) {
      var sum = 0;
      var count = 0;
      edges.forEach(function (edge) {
        var neighbor = null;
        if (forward && edge.target === nodeId && rankOf[edge.source] < rankOf[nodeId]) {
          neighbor = edge.source;
        } else if (!forward && edge.source === nodeId && rankOf[edge.target] > rankOf[nodeId]) {
          neighbor = edge.target;
        }
        if (neighbor != null && rows[neighbor] != null) {
          sum += rows[neighbor];
          count += 1;
        }
      });
      return count > 0 ? sum / count : null;
    }

    for (var sweep = 0; sweep < 8; sweep += 1) {
      var rowsForward = rowIndexes(columns);
      rankKeys.forEach(function (rankKey) {
        if (rankKey !== rankKeys[0]) reorder(rankKey, rowsForward, true);
      });

      var rowsBackward = rowIndexes(columns);
      rankKeys.slice().reverse().forEach(function (rankKey) {
        if (rankKey !== rankKeys[rankKeys.length - 1]) {
          reorder(rankKey, rowsBackward, false);
        }
      });
    }

    return rankKeys;
  }

  function layoutGraph(nodes, edges) {
    var ranks = computeRanks(nodes, edges);
    var columns = Object.create(null);

    nodes.forEach(function (node) {
      var r = ranks[node.id] || 0;
      columns[r] = columns[r] || [];
      columns[r].push(node);
    });

    var rankKeys = orderLayers(columns, edges);
    var rankIndex = Object.create(null);
    rankKeys.forEach(function (rankKey, index) {
      rankIndex[rankKey] = index;
    });

    var positions = Object.create(null);
    var maxRows = 1;
    rankKeys.forEach(function (rankKey) {
      var column = columns[rankKey];
      maxRows = Math.max(maxRows, column.length);
    });

    rankKeys.forEach(function (rankKey) {
      var column = columns[rankKey];
      var yOffset = Math.max(0, (maxRows - column.length) * Y_STEP * 0.5);
      column.forEach(function (node, row) {
        positions[node.id] = {
          x: PAD_X + rankIndex[rankKey] * X_STEP,
          y: PAD_Y + yOffset + row * Y_STEP
        };
      });
    });

    return {
      positions: positions,
      width: Math.max(1120, PAD_X * 2 + NODE_W + (rankKeys.length - 1) * X_STEP),
      height: Math.max(520, PAD_Y * 2 + NODE_H + (maxRows - 1) * Y_STEP)
    };
  }

  function pathForEdge(source, target, index) {
    var sx = source.x + NODE_W;
    var sy = source.y + NODE_H / 2;
    var tx = target.x;
    var ty = target.y + NODE_H / 2;
    var bend = 64 + (index % 5) * 12;

    if (source.x === target.x && source.y === target.y) {
      var loopY = source.y - 20 - (index % 4) * 12;
      return [
        'M', source.x + NODE_W * 0.72, source.y,
        'C', source.x + NODE_W + 50, loopY,
        source.x - 50, loopY,
        source.x + NODE_W * 0.28, source.y
      ].join(' ');
    }

    if (source.x === target.x) {
      var side = source.x + NODE_W + bend;
      return ['M', sx, sy, 'C', side, sy, side, ty, target.x + NODE_W, ty].join(' ');
    }

    var dx = Math.max(80, Math.abs(tx - sx) * 0.45);
    return ['M', sx, sy, 'C', sx + dx, sy, tx - dx, ty, tx, ty].join(' ');
  }

  function renderNodeMath(root) {
    if (typeof renderMathInElement !== 'function') return;
    try {
      renderMathInElement(root, {
        delimiters: [
          {left: '$$', right: '$$', display: true},
          {left: '\\[', right: '\\]', display: true},
          {left: '$', right: '$', display: false},
          {left: '\\(', right: '\\)', display: false}
        ],
        output: 'html',
        throwOnError: false,
        macros: window.KATEX_MACROS || {}
      });
    } catch (error) {
      console.warn('KaTeX render failed for relation graph labels:', error);
    }
  }

  function appendNodeLabel(group, node) {
    var foreign = svgEl('foreignObject', {
      x: 0,
      y: 0,
      width: NODE_W,
      height: NODE_H,
      class: 'relation-node-label-object'
    });
    var label = htmlEl('div', { class: 'relation-node-label' });
    var title = htmlEl('div', { class: 'relation-node-title' });

    title.textContent = node.name || node.id;
    label.appendChild(title);

    var metaText = node.space || '';
    var meta = htmlEl('div', { class: 'relation-node-meta' });
    meta.textContent = metaText || node.id;
    label.appendChild(meta);

    foreign.appendChild(label);
    group.appendChild(foreign);
  }

  function edgeTitle(edge, nodeMap) {
    var source = nodeMap[edge.source] || { id: edge.source, name: edge.source };
    var target = nodeMap[edge.target] || { id: edge.target, name: edge.target };
    var conjecture = edge.status === 'conjecture' ? ' (Conjecture)' : '';
    return edgeLabel(edge) + conjecture + ': '
      + (source.name || source.id) + ' to ' + (target.name || target.id);
  }

  function drawEdges(svg, edges, positions, nodeMap, onPreview, onSelect) {
    var edgeLayer = svgEl('g', { class: 'relation-edge-layer' });
    svg.appendChild(edgeLayer);

    edges.forEach(function (edge, index) {
      var source = positions[edge.source];
      var target = positions[edge.target];
      if (!source || !target) return;

      var group = svgEl('g', {
        class: 'relation-edge relation-edge-' + classPart(edge.type)
          + ' relation-edge-status-' + classPart(edge.status)
      });
      var path = pathForEdge(source, target, index);
      var title = svgEl('title');
      title.textContent = edgeTitle(edge, nodeMap);
      var visible = svgEl('path', {
        d: path,
        class: 'relation-edge-path',
        'marker-end': 'url(#relationGraphArrow)'
      });
      var hit = svgEl('path', {
        d: path,
        class: 'relation-edge-hit',
        tabindex: '0',
        role: 'button',
        'aria-label': edgeTitle(edge, nodeMap)
      });
      hit.addEventListener('mouseenter', function () { onPreview(edge); });
      hit.addEventListener('focus', function () { onPreview(edge); });
      hit.addEventListener('click', function () { onSelect(edge, group); });
      hit.addEventListener('keydown', function (event) {
        if (event.key === 'Enter' || event.key === ' ') {
          event.preventDefault();
          onSelect(edge, group);
        }
      });
      group.appendChild(title);
      group.appendChild(visible);
      group.appendChild(hit);
      edgeLayer.appendChild(group);
    });
  }

  function drawNodes(svg, nodes, positions) {
    var nodeLayer = svgEl('g', { class: 'relation-node-layer' });
    svg.appendChild(nodeLayer);

    nodes.forEach(function (node) {
      var pos = positions[node.id];
      if (!pos) return;
      var link = svgEl('a', {
        href: node.href || '#',
        class: 'relation-node-link',
        'aria-label': node.name || node.id
      });
      var group = svgEl('g', {
        class: 'relation-node relation-node-space-' + spaceClassPart(node.space),
        transform: 'translate(' + pos.x + ',' + pos.y + ')'
      });
      var title = svgEl('title');
      title.textContent = (node.name || node.id) + ' (' + node.id + ')';
      var rect = svgEl('rect', {
        width: NODE_W,
        height: NODE_H,
        rx: 7,
        ry: 7
      });
      group.appendChild(title);
      group.appendChild(rect);
      appendNodeLabel(group, node);
      link.appendChild(group);
      nodeLayer.appendChild(link);
    });

    renderNodeMath(nodeLayer);
  }

  function renderSvg(svg, graph, view, nodeMap, onPreview, onSelect) {
    while (svg.firstChild) svg.removeChild(svg.firstChild);

    var layout = layoutGraph(view.nodes, view.edges);
    svg.setAttribute('viewBox', '0 0 ' + layout.width + ' ' + layout.height);
    svg.style.minWidth = Math.max(860, layout.width) + 'px';
    svg.style.minHeight = Math.max(480, layout.height) + 'px';

    var defs = svgEl('defs');
    defs.innerHTML = '<marker id="relationGraphArrow" viewBox="0 0 10 10" refX="9" refY="5" markerWidth="8" markerHeight="8" orient="auto-start-reverse"><path d="M 0 0 L 10 5 L 0 10 z"></path></marker>';
    svg.appendChild(defs);

    if (view.nodes.length === 0) {
      var empty = svgEl('text', { x: 40, y: 64, class: 'relation-graph-empty' });
      empty.textContent = 'No visible relations.';
      svg.appendChild(empty);
      return;
    }

    drawEdges(svg, view.edges, layout.positions, nodeMap, onPreview, onSelect);
    drawNodes(svg, view.nodes, layout.positions);
  }

  function renderRelationChoices(graph, root) {
    var container = $('#relationGraphRelationChoices', root);
    if (!container) return;
    container.innerHTML = '';
    presetDefinitions(graph).forEach(function (preset) {
      var button = document.createElement('button');
      button.type = 'button';
      button.className = 'relation-graph-preset';
      button.setAttribute('data-relation-choice', preset.id);
      button.textContent = preset.label;
      button.addEventListener('click', function () {
        setTypeSelection(root, preset.types);
        root.dispatchEvent(new Event('change', { bubbles: true }));
      });
      container.appendChild(button);
    });
  }

  function syncPresetButtons(graph, root) {
    var selected = selectedTypeSet(root);
    var presets = presetDefinitions(graph);
    $all('[data-relation-choice]', root).forEach(function (button) {
      var preset = presets.find(function (item) {
        return item.id === button.getAttribute('data-relation-choice');
      });
      var isActive = preset && typeSetEquals(selected, preset.types);
      button.classList.toggle('is-active', !!isActive);
      button.setAttribute('aria-pressed', isActive ? 'true' : 'false');
    });
  }

  function resetFilters(root) {
    $('#relationGraphSearch', root).value = '';
    setTypeSelection(root, defaultTypes(root));
  }

  function nodeLink(node) {
    return '<a href="' + escapeHtml(node.href || '#') + '">'
      + escapeHtml(node.name || node.id) + '</a>';
  }

  function renderRefs(refs) {
    if (!refs || refs.length === 0) return '<span class="relation-graph-muted">No reference recorded.</span>';
    return '<span class="relation-graph-ref-list">' + refs.map(function (ref) {
      var label = ref.label || ref.key;
      var title = ref.tooltip ? ' title="' + escapeHtml(ref.tooltip) + '"' : '';
      return '<a href="' + escapeHtml(ref.href || ('#' + ref.key)) + '"' + title + '>'
        + '[' + escapeHtml(label) + ']</a>';
    }).join(' ') + '</span>';
  }

  function renderAttrs(attrs) {
    var keys = Object.keys(attrs || {}).sort();
    if (keys.length === 0) return '';
    return '<span class="relation-graph-attr-list">' + keys.map(function (key) {
      return '<span><strong>' + escapeHtml(key.replace(/_/g, ' ')) + ':</strong> '
        + escapeHtml(attrs[key]) + '</span>';
    }).join(' ') + '</span>';
  }

  function renderDetails(panel, edge, nodeMap) {
    var source = nodeMap[edge.source] || { id: edge.source, name: edge.source };
    var target = nodeMap[edge.target] || { id: edge.target, name: edge.target };
    var conjecture = edge.status === 'conjecture'
      ? '<span class="relation-graph-conjecture">(Conjecture)</span>'
      : '';
    panel.innerHTML = [
      '<div class="relation-graph-details-row">',
      '<strong class="relation-graph-detail-label">',
      escapeHtml(edgeLabel(edge)),
      '</strong>', conjecture,
      '<span class="relation-graph-edge-summary">',
      nodeLink(source), ' <span>to</span> ', nodeLink(target), '</span>',
      '<span><strong>Refs:</strong> ', renderRefs(edge.refs), '</span>',
      renderAttrs(edge.attrs),
      '</div>'
    ].join('');
  }

  function loadGraph(root, src) {
    var embedded = $('#relationGraphData', root) || document.getElementById('relationGraphData');
    if (embedded && embedded.textContent.trim()) {
      try {
        return Promise.resolve(JSON.parse(embedded.textContent));
      } catch (error) {
        console.warn('Could not parse embedded relation graph data:', error);
      }
    }

    return fetch(src, { credentials: 'same-origin' })
      .then(function (response) {
        if (!response.ok) throw new Error('Could not load ' + src);
        return response.json();
      });
  }

  function initRelationGraph(root) {
    var src = root.getAttribute('data-graph-src') || 'polynomial-relations.json';
    var svg = $('#relationGraphSvg', root);
    var details = $('#relationGraphDetails', root);

    loadGraph(root, src)
      .then(function (graph) {
        var nodeMap = makeNodeMap(graph.nodes);
        setTypeSelection(root, initialTypeSet(graph, root));
        renderRelationChoices(graph, root);

        function update() {
          var view = filteredGraph(graph, root);
          syncPresetButtons(graph, root);
          renderSvg(svg, graph, view, nodeMap, function (edge) {
            renderDetails(details, edge, nodeMap);
          }, function (edge, edgeGroup) {
            $all('.relation-edge-selected', svg).forEach(function (item) {
              item.classList.remove('relation-edge-selected');
            });
            edgeGroup.classList.add('relation-edge-selected');
            renderDetails(details, edge, nodeMap);
          });
        }

        root.addEventListener('change', update);
        $('#relationGraphSearch', root).addEventListener('input', update);
        $('#relationGraphReset', root).addEventListener('click', function () {
          resetFilters(root);
          details.innerHTML = '<h3>Relation details</h3><p>No relation selected.</p>';
          update();
        });

        update();
      })
      .catch(function (error) {
        details.innerHTML = '<h3>Relation details</h3><p>'
          + escapeHtml(error.message) + '</p>';
      });
  }

  document.addEventListener('DOMContentLoaded', function () {
    $all('[data-relation-graph]').forEach(initRelationGraph);
  });
})();
