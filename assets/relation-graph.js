(function () {
  'use strict';

  var SVG_NS = 'http://www.w3.org/2000/svg';
  var NODE_W = 178;
  var NODE_H = 54;
  var X_STEP = 260;
  var Y_STEP = 84;
  var PAD_X = 54;
  var PAD_Y = 48;

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

  function escapeHtml(value) {
    return String(value == null ? '' : value)
      .replace(/&/g, '&amp;')
      .replace(/</g, '&lt;')
      .replace(/>/g, '&gt;')
      .replace(/"/g, '&quot;')
      .replace(/'/g, '&#39;');
  }

  function classPart(value) {
    return String(value || 'unknown').replace(/[^a-zA-Z0-9_-]/g, '-');
  }

  function truncate(value, limit) {
    value = String(value || '');
    if (value.length <= limit) return value;
    return value.slice(0, Math.max(0, limit - 3)) + '...';
  }

  function sortByName(a, b) {
    return (a.name || a.id).localeCompare(b.name || b.id) || a.id.localeCompare(b.id);
  }

  function makeNodeMap(nodes) {
    var map = Object.create(null);
    nodes.forEach(function (node) {
      map[node.id] = node;
    });
    return map;
  }

  function activeValues(selector, root) {
    var values = Object.create(null);
    $all(selector, root).forEach(function (input) {
      var value = input.getAttribute('data-status-filter') || input.value;
      if (input.checked) values[value] = true;
    });
    return values;
  }

  function textForNode(node) {
    return [
      node.id,
      node.name,
      node.space,
      node.category,
      node.symbol
    ].join(' ').toLowerCase();
  }

  function filteredGraph(graph, root) {
    var activeTypes = activeValues('[data-relation-type-filter]', root);
    var activeStatuses = activeValues('[data-status-filter]', root);
    var posetOnly = $('#relationGraphPosetOnly', root).checked;
    var query = ($('#relationGraphSearch', root).value || '').trim().toLowerCase();
    var nodeMap = makeNodeMap(graph.nodes);
    var visibleNodes = Object.create(null);

    function nodeMatches(edge) {
      if (!query) return true;
      var source = nodeMap[edge.source];
      var target = nodeMap[edge.target];
      return (source && textForNode(source).indexOf(query) >= 0)
        || (target && textForNode(target).indexOf(query) >= 0)
        || String(edge.label || '').toLowerCase().indexOf(query) >= 0;
    }

    var edges = graph.edges.filter(function (edge) {
      if (!activeTypes[edge.type]) return false;
      if (!activeStatuses[edge.status]) return false;
      if (posetOnly && !edge.poset) return false;
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
    var ids = Object.create(null);
    var rank = Object.create(null);
    var indeg = Object.create(null);
    var outgoing = Object.create(null);

    nodes.forEach(function (node) {
      ids[node.id] = true;
      rank[node.id] = 0;
      indeg[node.id] = 0;
      outgoing[node.id] = [];
    });

    edges.forEach(function (edge) {
      if (!ids[edge.source] || !ids[edge.target]) return;
      outgoing[edge.source].push(edge.target);
      if (edge.source !== edge.target) indeg[edge.target] += 1;
    });

    var queue = nodes
      .filter(function (node) { return indeg[node.id] === 0; })
      .sort(sortByName)
      .map(function (node) { return node.id; });
    var seen = Object.create(null);

    while (queue.length > 0) {
      var id = queue.shift();
      seen[id] = true;
      outgoing[id].forEach(function (target) {
        if (target !== id) rank[target] = Math.max(rank[target], rank[id] + 1);
        indeg[target] -= 1;
        if (indeg[target] === 0) queue.push(target);
      });
      queue.sort(function (a, b) { return a.localeCompare(b); });
    }

    nodes.forEach(function (node) {
      if (!seen[node.id]) {
        var incident = edges.some(function (edge) {
          return edge.source === node.id || edge.target === node.id;
        });
        if (incident) rank[node.id] = Math.max(rank[node.id], 0);
      }
    });

    return rank;
  }

  function layoutGraph(nodes, edges) {
    var ranks = computeRanks(nodes, edges);
    var columns = Object.create(null);
    var maxRank = 0;

    nodes.forEach(function (node) {
      var r = ranks[node.id] || 0;
      maxRank = Math.max(maxRank, r);
      columns[r] = columns[r] || [];
      columns[r].push(node);
    });

    var positions = Object.create(null);
    var maxRows = 1;
    Object.keys(columns).forEach(function (rankKey) {
      var column = columns[rankKey].sort(function (a, b) {
        var ak = [a.space || '', a.category || '', a.name || '', a.id].join('\t');
        var bk = [b.space || '', b.category || '', b.name || '', b.id].join('\t');
        return ak.localeCompare(bk);
      });
      maxRows = Math.max(maxRows, column.length);
      column.forEach(function (node, row) {
        positions[node.id] = {
          x: PAD_X + Number(rankKey) * X_STEP,
          y: PAD_Y + row * Y_STEP
        };
      });
    });

    return {
      positions: positions,
      width: Math.max(920, PAD_X * 2 + NODE_W + maxRank * X_STEP),
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

  function appendNodeText(group, node) {
    var title = svgEl('text', {
      x: 14,
      y: 23,
      class: 'relation-node-title'
    });
    title.textContent = truncate(node.name || node.id, 28);
    group.appendChild(title);

    var meta = svgEl('text', {
      x: 14,
      y: 41,
      class: 'relation-node-meta'
    });
    var metaText = [node.space, node.category].filter(Boolean).join(' - ');
    meta.textContent = truncate(metaText || node.id, 30);
    group.appendChild(meta);
  }

  function drawEdges(svg, edges, positions, onSelect) {
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
        'aria-label': edge.label + ': ' + edge.source + ' to ' + edge.target
      });
      hit.addEventListener('click', function () { onSelect(edge, group); });
      hit.addEventListener('keydown', function (event) {
        if (event.key === 'Enter' || event.key === ' ') {
          event.preventDefault();
          onSelect(edge, group);
        }
      });
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
        class: 'relation-node',
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
      appendNodeText(group, node);
      link.appendChild(group);
      nodeLayer.appendChild(link);
    });
  }

  function renderSvg(svg, graph, view, onSelect) {
    while (svg.firstChild) svg.removeChild(svg.firstChild);

    var layout = layoutGraph(view.nodes, view.edges);
    svg.setAttribute('viewBox', '0 0 ' + layout.width + ' ' + layout.height);
    svg.style.minWidth = Math.max(860, layout.width) + 'px';
    svg.style.minHeight = Math.max(480, layout.height) + 'px';

    var defs = svgEl('defs');
    defs.innerHTML = '<marker id="relationGraphArrow" viewBox="0 0 10 10" refX="9" refY="5" markerWidth="7" markerHeight="7" orient="auto-start-reverse"><path d="M 0 0 L 10 5 L 0 10 z"></path></marker>';
    svg.appendChild(defs);

    if (view.nodes.length === 0) {
      var empty = svgEl('text', { x: 40, y: 64, class: 'relation-graph-empty' });
      empty.textContent = 'No visible relations.';
      svg.appendChild(empty);
      return;
    }

    drawEdges(svg, view.edges, layout.positions, onSelect);
    drawNodes(svg, view.nodes, layout.positions);
  }

  function renderFilters(graph, root) {
    var container = $('#relationGraphTypeFilters', root);
    container.innerHTML = '';
    graph.relation_types
      .filter(function (type) { return type.count > 0; })
      .forEach(function (type) {
        var label = document.createElement('label');
        label.className = 'relation-graph-filter';
        label.innerHTML = '<input type="checkbox" data-relation-type-filter value="'
          + escapeHtml(type.type) + '" checked> '
          + '<span>' + escapeHtml(type.label) + '</span>'
          + '<small>' + String(type.count) + '</small>';
        container.appendChild(label);
      });
  }

  function nodeLink(node) {
    return '<a href="' + escapeHtml(node.href || '#') + '">'
      + escapeHtml(node.name || node.id) + '</a>';
  }

  function renderRefs(refs) {
    if (!refs || refs.length === 0) return '<p class="relation-graph-muted">No reference recorded.</p>';
    return '<ul>' + refs.map(function (ref) {
      var label = ref.label || ref.key;
      var title = ref.tooltip ? ' title="' + escapeHtml(ref.tooltip) + '"' : '';
      return '<li><a href="' + escapeHtml(ref.href || ('#' + ref.key)) + '"' + title + '>'
        + '[' + escapeHtml(label) + ']</a> '
        + '<code>' + escapeHtml(ref.key) + '</code></li>';
    }).join('') + '</ul>';
  }

  function renderAttrs(attrs) {
    var keys = Object.keys(attrs || {}).sort();
    if (keys.length === 0) return '';
    return '<dl>' + keys.map(function (key) {
      return '<dt>' + escapeHtml(key.replace(/_/g, ' ')) + '</dt>'
        + '<dd>' + escapeHtml(attrs[key]) + '</dd>';
    }).join('') + '</dl>';
  }

  function renderDetails(panel, edge, nodeMap) {
    var source = nodeMap[edge.source] || { id: edge.source, name: edge.source };
    var target = nodeMap[edge.target] || { id: edge.target, name: edge.target };
    panel.innerHTML = [
      '<h3>' + escapeHtml(edge.label || edge.type) + '</h3>',
      '<p class="relation-graph-edge-summary">',
      nodeLink(source), ' <span>to</span> ', nodeLink(target),
      '</p>',
      '<p><strong>Status:</strong> ', escapeHtml(edge.status || 'theorem'), '</p>',
      edge.poset ? '<p><strong>Poset edge:</strong> yes</p>' : '',
      '<h4>References</h4>',
      renderRefs(edge.refs),
      renderAttrs(edge.attrs)
    ].join('');
  }

  function initRelationGraph(root) {
    var src = root.getAttribute('data-graph-src') || 'polynomial-relations.json';
    var svg = $('#relationGraphSvg', root);
    var details = $('#relationGraphDetails', root);

    fetch(src, { credentials: 'same-origin' })
      .then(function (response) {
        if (!response.ok) throw new Error('Could not load ' + src);
        return response.json();
      })
      .then(function (graph) {
        var nodeMap = makeNodeMap(graph.nodes);
        renderFilters(graph, root);

        function update() {
          var view = filteredGraph(graph, root);
          renderSvg(svg, graph, view, function (edge, edgeGroup) {
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
          $('#relationGraphSearch', root).value = '';
          $('#relationGraphPosetOnly', root).checked = false;
          $all('[data-relation-type-filter], [data-status-filter]', root).forEach(function (input) {
            input.checked = true;
          });
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
