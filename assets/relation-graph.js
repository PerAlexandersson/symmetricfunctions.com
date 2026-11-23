// Polynomial relation explorer (polynomial-relations.htm).
//
// Two views over the graph data that relation_graph.lua embeds in the page:
//   * Family:   one family in the middle, the families pointing to it on the
//               left and those it points to on the right, grouped by relation
//               type, followed by every relation with references and notes.
//   * Overview: one kind of relation at a time, drawn as layered diagrams
//               (one per connected component), with relations implied by
//               transitivity hidden unless asked for.
// State lives in the URL hash (#family=<id>, #overview=<group>), so cards are
// plain links and the back button works.
//
// Text that KaTeX typesets is always inserted with textContent into its own
// element (family name, symbol, space, category, year, attribute values);
// tests/lint_katex.py checks exactly these fields.
(function () {
  'use strict';

  var SVG_NS = 'http://www.w3.org/2000/svg';

  // Relation groups shown in the overview, in the fixed order of the
  // categorical palette (slot 0 is the neutral "other" colour).
  var GROUPS = [
    { id: 'positive', label: 'Positive expansion', types: ['positive_in', 'refined_by'], slot: 1,
      desc: 'An arrow A → B means that A expands positively in B; refinements are included.' },
    { id: 'specialization', label: 'Specialization', types: ['specializes_to'], slot: 2,
      desc: 'An arrow A → B means that a parameter value, limit or substitution turns A into B.' },
    { id: 'containment', label: 'Containment', types: ['contains'], slot: 3,
      desc: 'An arrow A → B means that B is a subfamily or special case of A.' },
    { id: 'generalization', label: 'Generalization', types: ['generalizes'], slot: 4,
      desc: 'An arrow A → B means that A generalizes B.' },
    { id: 'transform', label: 'Transform', types: ['transforms_to'], slot: 5,
      desc: 'An arrow A → B means that a named transform takes A to B.' },
    { id: 'stable-limit', label: 'Stable limit', types: ['stable_limit'], slot: 6,
      desc: 'An arrow A → B means that B is the stable limit of A.' },
    { id: 'k-theory', label: 'K-theoretic analogue', types: ['k_theoretic_analogue_of'], slot: 7,
      desc: 'An arrow A → B means that A is a K-theoretic analogue of B.' },
    { id: 'signed', label: 'Signed expansion', types: ['signed_in'], slot: 8,
      desc: 'An arrow A → B means that A expands in B with a predictable sign rule.' },
    { id: 'duality', label: 'Duality', types: ['dual_to', 'nsym_qsym_dual'], slot: 0,
      desc: 'An arrow A → B means that A and B are dual under a pairing or involution.' },
    { id: 'degeneration', label: 'Degeneration', types: ['degenerates_to'], slot: 0,
      desc: 'An arrow A → B means that A degenerates or limits to B.' }
  ];

  // How each relation reads from the focused family: "out" heads the list of
  // targets (focus -> target), "in" the list of sources (source -> focus),
  // and "verb" joins two names in the relation list.
  var PHRASES = {
    positive_in: { verb: 'expands positively in', out: 'Expands positively in', in: 'Expand positively in this family' },
    refined_by: { verb: 'is refined by', out: 'Refined by', in: 'Refined by this family' },
    specializes_to: { verb: 'specializes to', out: 'Specializes to', in: 'Specialize to this family' },
    contains: { verb: 'contains', out: 'Contains', in: 'Contain this family' },
    generalizes: { verb: 'generalizes', out: 'Generalizes', in: 'Generalize this family' },
    degenerates_to: { verb: 'degenerates to', out: 'Degenerates to', in: 'Degenerate to this family' },
    stable_limit: { verb: 'has stable limit', out: 'Has stable limit', in: 'Have this family as stable limit' },
    k_theoretic_analogue_of: { verb: 'is a K-theoretic analogue of', out: 'K-theoretic analogue of', in: 'K-theoretic analogues of this family' },
    transforms_to: { verb: 'transforms to', out: 'Transforms to', in: 'Transform to this family' },
    signed_in: { verb: 'expands with signs in', out: 'Expands with signs in', in: 'Expand with signs in this family' },
    dual_to: { verb: 'is dual to', out: 'Dual to', in: 'Dual to this family' },
    nsym_qsym_dual: { verb: 'is NSym/QSym dual to', out: 'NSym/QSym dual to', in: 'NSym/QSym dual to this family' }
  };

  var ATTR_LABELS = {
    scope: 'Scope', map: 'Map', proof: 'Proof', semiring: 'Coefficients',
    sign_rule: 'Sign rule', parameter: 'Parameter', pairing: 'Pairing',
    note: 'Note', combinatorial_rule: 'Combinatorial rule'
  };

  var COLLAPSE_AFTER = 8;            // cards shown per group before "Show more"
  var NODE_W = 184, NODE_H = 46;     // overview node box
  var LAYER_GAP = 72, ROW_GAP = 12;  // overview spacing
  var PAD = 14;                      // padding around an overview diagram
  var SMALL_W = 520, SMALL_H = 360;  // diagrams at most this size go in the grid

  // ---------------------------------------------------------------- helpers

  function $(selector, root) { return (root || document).querySelector(selector); }
  function $all(selector, root) {
    return Array.prototype.slice.call((root || document).querySelectorAll(selector));
  }

  // el('a.cls', {href: ...}, child, ...): children are nodes or plain text.
  function el(spec, attrs) {
    var parts = spec.split('.');
    var node = document.createElement(parts[0] || 'div');
    if (parts.length > 1) node.className = parts.slice(1).join(' ');
    Object.keys(attrs || {}).forEach(function (key) {
      if (attrs[key] != null && attrs[key] !== false) node.setAttribute(key, attrs[key]);
    });
    for (var i = 2; i < arguments.length; i += 1) append(node, arguments[i]);
    return node;
  }

  function append(node, child) {
    if (child == null || child === false) return;
    if (Array.isArray(child)) { child.forEach(function (c) { append(node, c); }); return; }
    node.appendChild(typeof child === 'string' ? document.createTextNode(child) : child);
  }

  // An element whose whole text is one field that KaTeX may typeset.
  function field(spec, text) {
    var node = el(spec);
    node.textContent = text;
    return node;
  }

  function svg(name, attrs) {
    var node = document.createElementNS(SVG_NS, name);
    Object.keys(attrs || {}).forEach(function (key) { node.setAttribute(key, attrs[key]); });
    return node;
  }

  function typeset(node) {
    if (typeof renderMathInElement !== 'function') return;
    try {
      renderMathInElement(node, {
        delimiters: [
          { left: '$$', right: '$$', display: true },
          { left: '\\[', right: '\\]', display: true },
          { left: '$', right: '$', display: false },
          { left: '\\(', right: '\\)', display: false }
        ],
        output: 'html',
        throwOnError: false,
        macros: window.KATEX_MACROS || {}
      });
    } catch (error) {
      console.warn('KaTeX render failed for relation graph labels:', error);
    }
  }

  // Plain text for searching: drop TeX commands, braces and dollars.
  function plain(text) {
    return String(text || '')
      .replace(/\\[A-Za-z]+/g, ' ')
      .replace(/[{}$\\^_]/g, ' ')
      .replace(/\s+/g, ' ')
      .trim()
      .toLowerCase();
  }

  // TeX dashes in text (not inside $...$): --- and -- become em and en dashes.
  function texDashes(text) {
    return String(text).split('$').map(function (part, i) {
      return i % 2 ? part : part.replace(/---/g, '\u2014').replace(/--/g, '\u2013');
    }).join('$');
  }

  // A name for tooltips (not typeset): math delimiters and commands removed.
  function readable(text) {
    return String(text || '').replace(/\$/g, '').replace(/\\([A-Za-z]+)/g, '$1').replace(/[{}]/g, '');
  }

  function familyHash(id) { return '#family=' + encodeURIComponent(id); }
  function overviewHash(id) { return '#overview=' + encodeURIComponent(id); }

  // ------------------------------------------------------------------ model

  function buildModel(graph) {
    var nodes = Object.create(null);
    (graph.nodes || []).forEach(function (node) {
      node.name = texDashes(node.name || node.id);
      nodes[node.id] = node;
      node.searchText = plain([node.name, node.id, node.space, node.category].join(' '));
      node.out = [];
      node.in = [];
    });

    var groupOfType = Object.create(null);
    var groups = GROUPS.map(function (group) {
      var copy = Object.assign({}, group, { types: group.types.slice(), count: 0 });
      copy.types.forEach(function (type) { groupOfType[type] = copy; });
      return copy;
    });

    var edges = (graph.edges || []).filter(function (edge) {
      return nodes[edge.source] && nodes[edge.target];
    });
    edges.forEach(function (edge) {
      var group = groupOfType[edge.type];
      if (!group) {
        // A relation type this page does not know yet: its own neutral group.
        group = { id: 'type-' + edge.type, label: edge.label || edge.type, types: [edge.type],
          slot: 0, count: 0, desc: 'An arrow A → B means: A ' + (edge.label || edge.type) + ' B.' };
        groupOfType[edge.type] = group;
        groups.push(group);
      }
      edge.group = group;
      group.count += 1;
      nodes[edge.source].out.push(edge);
      nodes[edge.target].in.push(edge);
    });

    return {
      graph: graph,
      nodes: nodes,
      edges: edges,
      groups: groups.filter(function (group) { return group.count > 0; }),
      groupById: function (id) {
        return groups.filter(function (group) { return group.id === id && group.count > 0; })[0];
      }
    };
  }

  function phrase(type) {
    return PHRASES[type] || {
      verb: String(type).replace(/_/g, ' '),
      out: String(type).replace(/_/g, ' '),
      in: String(type).replace(/_/g, ' ') + ' (to this family)'
    };
  }

  function typeOrder(type) {
    for (var i = 0; i < GROUPS.length; i += 1) {
      var j = GROUPS[i].types.indexOf(type);
      if (j >= 0) return i * 10 + j;
    }
    return 1000;
  }

  function byName(a, b) {
    return plain(a.name).localeCompare(plain(b.name)) || a.id.localeCompare(b.id);
  }

  // -------------------------------------------------------------- the app

  function RelationExplorer(root, graph) {
    this.root = root;
    this.model = buildModel(graph);
    this.defaultFamily = root.getAttribute('data-default-family') || '';
    this.defaultGroup = root.getAttribute('data-default-overview') || 'positive';
    this.showImplied = false;
    this.zoom = Object.create(null);
    this.view = $('#relationGraphView', root);
    this.tabs = $all('[data-view]', root);
    this.setupSearch();
    this.tabs.forEach(function (tab) {
      tab.addEventListener('click', function () {
        var view = tab.getAttribute('data-view');
        if (view === 'family') {
          location.hash = familyHash(this.lastFamily || this.defaultFamily || this.firstFamily());
        } else {
          location.hash = overviewHash(this.lastGroup || this.defaultGroup);
        }
      }.bind(this));
    }, this);
    window.addEventListener('hashchange', this.route.bind(this, true));
    // The focus card is sticky, so its connectors follow it while scrolling.
    var pending = false;
    window.addEventListener('scroll', function () {
      if (pending || !this.flow) return;
      pending = true;
      requestAnimationFrame(function () { pending = false; this.drawWires(); }.bind(this));
    }.bind(this), { passive: true });
    if (typeof ResizeObserver === 'function') {
      this.resizer = new ResizeObserver(function () { this.drawWires(); }.bind(this));
    } else {
      window.addEventListener('resize', function () { this.drawWires(); }.bind(this));
    }
    this.route(false);
  }

  RelationExplorer.prototype.firstFamily = function () {
    return Object.keys(this.model.nodes).sort()[0];
  };

  RelationExplorer.prototype.parseHash = function () {
    var match = /^#(family|overview)=(.+)$/.exec(location.hash || '');
    if (!match) return null;
    var value;
    try { value = decodeURIComponent(match[2]); } catch (e) { return null; }
    return { view: match[1], value: value };
  };

  // Show the state named by the hash.  Hashes that are not ours (section
  // links such as #bibliography) keep the current view.
  RelationExplorer.prototype.route = function (fromHashChange) {
    var state = this.parseHash();
    if (!state) {
      if (fromHashChange && this.current) return;
      state = { view: 'overview', value: this.defaultGroup };
    }
    if (state.view === 'family') {
      this.showFamily(state.value);
    } else {
      this.showOverview(state.value);
    }
    if (fromHashChange) {
      var top = this.root.getBoundingClientRect().top;
      if (top < 0) this.root.scrollIntoView({ block: 'start' });
    }
  };

  RelationExplorer.prototype.setTab = function (view) {
    this.tabs.forEach(function (tab) {
      var active = tab.getAttribute('data-view') === view;
      tab.setAttribute('aria-pressed', active ? 'true' : 'false');
      tab.classList.toggle('is-active', active);
    });
    this.root.setAttribute('data-current-view', view);
  };

  RelationExplorer.prototype.replaceView = function (content) {
    if (this.resizer) this.resizer.disconnect();
    this.view.innerHTML = '';
    this.view.appendChild(content);
    typeset(content);
  };

  // ------------------------------------------------------------- search

  RelationExplorer.prototype.setupSearch = function () {
    var input = $('#relationGraphSearch', this.root);
    var list = $('#relationGraphResults', this.root);
    if (!input || !list) return;
    var self = this;
    var matches = [];
    var active = -1;

    function close() {
      list.hidden = true;
      list.innerHTML = '';
      input.setAttribute('aria-expanded', 'false');
      input.removeAttribute('aria-activedescendant');
      active = -1;
    }

    function highlight(index) {
      var options = $all('[role="option"]', list);
      options.forEach(function (option, i) {
        option.setAttribute('aria-selected', i === index ? 'true' : 'false');
      });
      active = index;
      if (options[index]) {
        input.setAttribute('aria-activedescendant', options[index].id);
        options[index].scrollIntoView({ block: 'nearest' });
      }
    }

    function choose(node) {
      close();
      input.value = '';
      input.blur();
      location.hash = familyHash(node.id);
    }

    function update() {
      var query = plain(input.value);
      if (!query) { close(); return; }
      var words = query.split(' ');
      matches = Object.keys(self.model.nodes).map(function (id) { return self.model.nodes[id]; })
        .filter(function (node) {
          return words.every(function (word) { return node.searchText.indexOf(word) >= 0; });
        })
        .sort(function (a, b) {
          var as = plain(a.name).indexOf(query) === 0 ? 0 : 1;
          var bs = plain(b.name).indexOf(query) === 0 ? 0 : 1;
          return as - bs || (b.in.length + b.out.length) - (a.in.length + a.out.length) || byName(a, b);
        })
        .slice(0, 12);
      list.innerHTML = '';
      if (matches.length === 0) {
        list.appendChild(el('li.rg-search-empty', { role: 'presentation' }, 'No family matches.'));
      }
      matches.forEach(function (node, index) {
        var option = el('li.rg-search-option', { role: 'option', id: 'relationGraphOption' + index,
          'aria-selected': 'false' },
          field('span.rg-search-name', node.name),
          field('span.rg-search-space', node.space || ''));
        option.addEventListener('mousedown', function (event) { event.preventDefault(); });
        option.addEventListener('click', function () { choose(node); });
        list.appendChild(option);
      });
      list.hidden = false;
      input.setAttribute('aria-expanded', 'true');
      typeset(list);
      highlight(matches.length ? 0 : -1);
    }

    input.addEventListener('input', update);
    input.addEventListener('focus', function () { if (input.value) update(); });
    input.addEventListener('blur', close);
    input.addEventListener('keydown', function (event) {
      if (event.key === 'ArrowDown' && matches.length) {
        event.preventDefault();
        if (list.hidden) update();
        highlight(Math.min(matches.length - 1, active + 1));
      } else if (event.key === 'ArrowUp' && matches.length) {
        event.preventDefault();
        highlight(Math.max(0, active - 1));
      } else if (event.key === 'Enter') {
        if (!list.hidden && matches[active]) {
          event.preventDefault();
          choose(matches[active]);
        }
      } else if (event.key === 'Escape') {
        if (!list.hidden) { event.preventDefault(); close(); } else { input.value = ''; }
      }
    });
  };

  // ------------------------------------------------------------- family view

  // Neighbours of the focused family, grouped by relation type and collapsed
  // so that several edges between the same pair share one card.
  function neighbourGroups(edges, side) {
    var byType = Object.create(null);
    edges.forEach(function (edge) {
      var other = side === 'in' ? edge.source : edge.target;
      var bucket = byType[edge.type] = byType[edge.type] || { type: edge.type, group: edge.group, items: Object.create(null) };
      var item = bucket.items[other] = bucket.items[other] || { id: other, edges: [] };
      item.edges.push(edge);
    });
    return Object.keys(byType)
      .sort(function (a, b) { return typeOrder(a) - typeOrder(b) || a.localeCompare(b); })
      .map(function (type) {
        var bucket = byType[type];
        bucket.items = Object.keys(bucket.items).map(function (id) { return bucket.items[id]; });
        return bucket;
      });
  }

  RelationExplorer.prototype.showFamily = function (id) {
    var model = this.model;
    var focus = model.nodes[id];
    this.setTab('family');
    this.current = 'family:' + id;
    if (!focus) {
      this.replaceView(el('div.rg-message', {},
        el('p', {}, 'There is no family with the id “' + id + '” in the relation data. '),
        el('p', {}, el('a', { href: overviewHash(this.defaultGroup) }, 'Back to the overview'))));
      return;
    }
    this.lastFamily = id;

    var view = el('div.rg-family');
    var flow = el('div.rg-flow');
    var inGroups = neighbourGroups(focus.in.filter(function (e) { return e.source !== id; }), 'in');
    var outGroups = neighbourGroups(focus.out.filter(function (e) { return e.target !== id; }), 'out');

    flow.appendChild(this.familyColumn(inGroups, 'in'));
    flow.appendChild(this.focusCard(focus));
    flow.appendChild(this.familyColumn(outGroups, 'out'));
    this.wires = svg('svg', { class: 'rg-wires', 'aria-hidden': 'true', focusable: 'false' });
    flow.appendChild(this.wires);
    view.appendChild(flow);
    view.appendChild(this.relationList(focus));

    this.flow = flow;
    this.focusId = id;
    this.replaceView(view);
    this.drawWires();
    if (this.resizer) this.resizer.observe(flow);
    this.linkHighlights(view);
  };

  RelationExplorer.prototype.focusCard = function (node) {
    var count = node.in.length + node.out.length;
    var facts = el('p.rg-focus-facts');
    [node.space, node.category, node.year].forEach(function (value) {
      if (value) facts.appendChild(field('span', value));
    });
    return el('div.rg-focus', {},
      el('div.rg-focus-card', { 'data-node': node.id },
        facts,
        field('h3.rg-focus-name', node.name),
        node.symbol ? field('p.rg-focus-symbol', node.symbol) : null,
        el('p.rg-focus-count', {}, count + (count === 1 ? ' relation' : ' relations')),
        node.href ? el('a.rg-focus-link', { href: node.href }, 'Open the family page') : null));
  };

  RelationExplorer.prototype.familyColumn = function (groups, side) {
    var model = this.model;
    var column = el('div.rg-col.rg-col-' + side);
    column.appendChild(el('p.rg-col-title', {}, side === 'in' ? 'Pointing to this family' : 'This family points to'));
    if (groups.length === 0) {
      column.appendChild(el('p.rg-col-empty', {}, side === 'in'
        ? 'No recorded relation points to this family.'
        : 'This family has no recorded outgoing relation.'));
      return column;
    }
    groups.forEach(function (bucket) {
      var items = bucket.items.map(function (item) {
        item.node = model.nodes[item.id];
        return item;
      }).sort(function (a, b) { return byName(a.node, b.node); });
      var section = el('section.rg-group.rg-c' + bucket.group.slot, { 'data-side': side });
      section.appendChild(el('h4.rg-group-head', {},
        el('span.rg-swatch', { 'aria-hidden': 'true' }),
        el('span.rg-group-label', {}, phrase(bucket.type)[side]),
        el('span.rg-group-count', {}, String(items.length))));
      var list = el('ul.rg-cards');
      items.forEach(function (item, index) {
        var conjecture = item.edges.every(function (e) { return e.status === 'conjecture'; });
        var card = el('a.rg-card', {
          href: familyHash(item.id),
          'data-node': item.id,
          'data-edges': item.edges.map(function (e) { return e.id; }).join(' '),
          'data-slot': String(bucket.group.slot),
          'data-conjecture': conjecture ? 'true' : null
        },
          field('span.rg-card-name', item.node.name),
          item.node.symbol ? field('span.rg-card-symbol', item.node.symbol) : null,
          conjecture ? el('span.rg-badge', {}, 'conjecture') : null);
        var li = el('li', {}, card);
        if (index >= COLLAPSE_AFTER) li.hidden = true;
        list.appendChild(li);
      });
      section.appendChild(list);
      if (items.length > COLLAPSE_AFTER) {
        var more = el('button.rg-more', { type: 'button', 'aria-expanded': 'false' },
          'Show ' + (items.length - COLLAPSE_AFTER) + ' more');
        more.addEventListener('click', function () {
          var open = more.getAttribute('aria-expanded') !== 'true';
          $all('li', list).forEach(function (li, index) {
            if (index >= COLLAPSE_AFTER) li.hidden = !open;
          });
          more.setAttribute('aria-expanded', open ? 'true' : 'false');
          more.textContent = open ? 'Show fewer' : 'Show ' + (items.length - COLLAPSE_AFTER) + ' more';
          this.drawWires();
        }.bind(this));
        section.appendChild(more);
      }
      column.appendChild(section);
    }, this);
    return column;
  };

  // Connectors from the cards to the focused family.  Each relation group
  // meets the focus card at its own port; arrows always point to the right,
  // from the source family to the target family.
  RelationExplorer.prototype.drawWires = function () {
    var wires = this.wires;
    var flow = this.flow;
    if (!wires || !flow || !flow.isConnected) return;
    while (wires.firstChild) wires.removeChild(wires.firstChild);
    if (getComputedStyle(wires).display === 'none') return;
    var box = flow.getBoundingClientRect();
    wires.setAttribute('width', box.width);
    wires.setAttribute('height', box.height);
    wires.setAttribute('viewBox', '0 0 ' + box.width + ' ' + box.height);
    var focus = $('.rg-focus-card', flow).getBoundingClientRect();

    ['in', 'out'].forEach(function (side) {
      var groups = $all('.rg-group[data-side="' + side + '"]', flow);
      groups.forEach(function (group, gi) {
        var portY = focus.top - box.top + focus.height * (gi + 1) / (groups.length + 1);
        var portX = (side === 'in' ? focus.left : focus.right) - box.left;
        $all('.rg-card', group).forEach(function (card) {
          if (card.parentNode.hidden) return;
          var r = card.getBoundingClientRect();
          var cy = r.top - box.top + r.height / 2;
          var start, end;
          if (side === 'in') {
            start = { x: r.right - box.left, y: cy };
            end = { x: portX, y: portY };
          } else {
            start = { x: portX, y: portY };
            end = { x: r.left - box.left, y: cy };
          }
          var bend = Math.max(24, (end.x - start.x) * 0.5);
          var path = svg('path', {
            class: 'rg-wire rg-c' + card.getAttribute('data-slot')
              + (card.hasAttribute('data-conjecture') ? ' is-conjecture' : ''),
            'data-node': card.getAttribute('data-node'),
            d: 'M' + start.x + ' ' + start.y + ' C' + (start.x + bend) + ' ' + start.y + ' '
              + (end.x - bend) + ' ' + end.y + ' ' + (end.x - 7) + ' ' + end.y + ' L' + end.x + ' ' + end.y
          });
          wires.appendChild(path);
          wires.appendChild(arrowHead(end.x, end.y, 'rg-c' + card.getAttribute('data-slot'),
            card.getAttribute('data-node')));
        });
      });
    });
  };

  function arrowHead(x, y, cls, node) {
    return svg('path', {
      class: 'rg-arrow ' + cls,
      'data-node': node || '',
      d: 'M' + (x - 8) + ' ' + (y - 4.5) + ' L' + x + ' ' + y + ' L' + (x - 8) + ' ' + (y + 4.5) + ' Z'
    });
  }

  RelationExplorer.prototype.relationList = function (focus) {
    var model = this.model;
    var edges = focus.out.concat(focus.in.filter(function (e) { return e.source !== e.target; }));
    edges.sort(function (a, b) {
      var aOut = a.source === focus.id ? 0 : 1;
      var bOut = b.source === focus.id ? 0 : 1;
      return aOut - bOut || typeOrder(a.type) - typeOrder(b.type)
        || byName(model.nodes[aOut ? a.source : a.target], model.nodes[bOut ? b.source : b.target]);
    });
    var section = el('section.rg-rels', { 'aria-label': 'Relations of this family' });
    section.appendChild(el('h3.rg-rels-title', {}, 'All relations of this family'));
    var list = el('ol.rg-rel-list');
    edges.forEach(function (edge) {
      var source = model.nodes[edge.source];
      var target = model.nodes[edge.target];
      var other = edge.source === focus.id ? target : source;
      function name(node) {
        if (node.id === focus.id) return field('strong.rg-rel-name.is-focus', node.name);
        var link = el('a.rg-rel-name', { href: familyHash(node.id) });
        link.appendChild(field('span', node.name));
        return link;
      }
      var row = el('li.rg-rel.rg-c' + edge.group.slot, { 'data-node': other.id, 'data-edge': edge.id },
        el('span.rg-swatch', { 'aria-hidden': 'true' }),
        el('div.rg-rel-body', {},
          el('p.rg-rel-sentence', {},
            name(source), ' ', el('span.rg-rel-verb', {}, phrase(edge.type).verb), ' ', name(target),
            edge.status === 'conjecture' ? el('span.rg-badge', {}, 'conjecture') : null),
          attributeList(edge.attrs),
          referenceList(edge.refs)));
      list.appendChild(row);
    });
    section.appendChild(list);
    return section;
  };

  function attributeList(attrs) {
    var keys = Object.keys(attrs || {}).sort(function (a, b) {
      var order = Object.keys(ATTR_LABELS);
      var ai = order.indexOf(a), bi = order.indexOf(b);
      return (ai < 0 ? 99 : ai) - (bi < 0 ? 99 : bi) || a.localeCompare(b);
    });
    if (keys.length === 0) return null;
    var list = el('dl.rg-attrs');
    keys.forEach(function (key) {
      var value = attrs[key];
      if (key === 'combinatorial_rule' && value === 'none_known') value = 'none known';
      list.appendChild(el('div', {},
        el('dt', {}, ATTR_LABELS[key] || key.replace(/_/g, ' ')),
        field('dd', value)));
    });
    return list;
  }

  function referenceList(refs) {
    if (!refs || refs.length === 0) return null;
    var span = el('p.rg-refs');
    refs.forEach(function (ref, index) {
      if (index > 0) span.appendChild(document.createTextNode(' '));
      span.appendChild(el('a', { href: ref.href || ('#' + ref.key), title: ref.tooltip || null },
        '[' + (ref.label || ref.key) + ']'));
    });
    return span;
  }

  // Hovering a card or a relation row lights up everything about that
  // neighbour: its card, its connector and its relation rows.
  RelationExplorer.prototype.linkHighlights = function (view) {
    function set(nodeId, on) {
      view.classList.toggle('is-tracing', on);
      $all('[data-node="' + (window.CSS && CSS.escape ? CSS.escape(nodeId) : nodeId) + '"]', view)
        .forEach(function (item) { item.classList.toggle('is-hot', on); });
    }
    $all('.rg-card, .rg-rel', view).forEach(function (item) {
      var id = item.getAttribute('data-node');
      ['mouseenter', 'focusin'].forEach(function (name) {
        item.addEventListener(name, function () { set(id, true); });
      });
      ['mouseleave', 'focusout'].forEach(function (name) {
        item.addEventListener(name, function () { set(id, false); });
      });
    });
  };

  // ------------------------------------------------------------- overview

  RelationExplorer.prototype.showOverview = function (groupId) {
    var model = this.model;
    var group = model.groupById(groupId) || model.groupById(this.defaultGroup) || model.groups[0];
    this.setTab('overview');
    this.current = 'overview:' + group.id;
    this.lastGroup = group.id;
    this.flow = null;
    this.wires = null;

    var drawn = overviewEdges(model, group, this.showImplied);
    var nodeIds = Object.create(null);
    drawn.edges.forEach(function (edge) { nodeIds[edge.source] = true; nodeIds[edge.target] = true; });
    var components = connectedComponents(Object.keys(nodeIds), drawn.edges);

    var view = el('div.rg-overview');

    var chips = el('nav.rg-chips', { 'aria-label': 'Relation type' });
    model.groups.forEach(function (g) {
      chips.appendChild(el('a.rg-chip.rg-c' + g.slot, {
        href: overviewHash(g.id), 'aria-current': g === group ? 'true' : null
      },
        el('span.rg-swatch', { 'aria-hidden': 'true' }),
        el('span', {}, g.label),
        el('span.rg-chip-count', {}, String(g.count))));
    });
    view.appendChild(chips);

    var familyCount = Object.keys(nodeIds).length;
    var summary = el('div.rg-summary', {},
      el('p.rg-summary-desc', {}, group.desc + ' Select a family to see all of its relations.'),
      el('p.rg-summary-stats', {},
        familyCount + ' families, ' + drawn.edges.length + ' relations, '
        + components.length + (components.length === 1 ? ' connected piece' : ' connected pieces')));
    if (drawn.implied > 0 || this.showImplied) {
      var toggle = el('input', { type: 'checkbox' });
      toggle.checked = this.showImplied;
      toggle.addEventListener('change', function () {
        this.showImplied = toggle.checked;
        this.showOverview(group.id);
      }.bind(this));
      summary.appendChild(el('label.rg-toggle', {}, toggle,
        ' Show the ' + drawn.implied + (drawn.implied === 1 ? ' relation' : ' relations')
        + ' implied by transitivity'));
    }
    view.appendChild(summary);

    var large = el('div.rg-diagrams');
    var small = el('div.rg-diagram-grid');
    var pairs = components.filter(function (component) { return component.nodes.length === 2; });
    components = components.filter(function (component) { return component.nodes.length !== 2; });
    components.forEach(function (component) {
      var layout = layoutComponent(component.nodes, component.edges, model);
      var figure = this.diagram(layout, group, component);
      if (layout.width <= SMALL_W && layout.height <= SMALL_H) {
        small.appendChild(figure);
      } else {
        large.appendChild(figure);
      }
    }, this);
    if (large.childNodes.length) view.appendChild(large);
    if (small.childNodes.length) view.appendChild(small);
    if (pairs.length) view.appendChild(this.pairList(pairs, group, components.length > 0));
    this.replaceView(view);
    $all('.rg-frame', view).forEach(function (frame) { this.fitFrame(frame); }, this);
  };

  // The edges of a group, one per ordered pair, minus those implied by a
  // path of the same transitive relation type (unless showImplied).
  function overviewEdges(model, group, showImplied) {
    var implied = 0;
    var seen = Object.create(null);
    var edges = [];
    group.types.forEach(function (type) {
      var typeEdges = model.edges.filter(function (edge) {
        return edge.type === type && edge.source !== edge.target;
      });
      var reducible = typeEdges.length > 0 && typeEdges.every(function (edge) { return edge.transitive; });
      var drop = reducible ? impliedPairs(typeEdges) : Object.create(null);
      typeEdges.forEach(function (edge) {
        var key = edge.source + '\t' + edge.target;
        if (drop[key]) {
          if (!seen['implied\t' + key]) { implied += 1; seen['implied\t' + key] = true; }
          if (!showImplied) return;
        }
        if (seen[key]) {
          seen[key].conjecture = seen[key].conjecture && edge.status === 'conjecture';
          return;
        }
        var drawnEdge = {
          source: edge.source, target: edge.target, type: edge.type, slot: group.slot,
          conjecture: edge.status === 'conjecture', implied: !!drop[key]
        };
        seen[key] = drawnEdge;
        edges.push(drawnEdge);
      });
    });
    return { edges: edges, implied: implied };
  }

  // Pairs (s, t) with a path s -> x -> ... -> t of length at least two.
  // Edges inside a strongly connected component are never dropped.
  function impliedPairs(edges) {
    var succ = Object.create(null);
    edges.forEach(function (edge) {
      (succ[edge.source] = succ[edge.source] || Object.create(null))[edge.target] = true;
    });
    var reach = Object.create(null);
    function reachable(start) {
      if (reach[start]) return reach[start];
      var seen = Object.create(null);
      var stack = Object.keys(succ[start] || {});
      while (stack.length) {
        var id = stack.pop();
        if (seen[id]) continue;
        seen[id] = true;
        Object.keys(succ[id] || {}).forEach(function (next) { stack.push(next); });
      }
      reach[start] = seen;
      return seen;
    }
    var drop = Object.create(null);
    edges.forEach(function (edge) {
      var s = edge.source, t = edge.target;
      if (reachable(t)[s]) return;   // same strongly connected component
      var others = Object.keys(succ[s] || {});
      for (var i = 0; i < others.length; i += 1) {
        var x = others[i];
        if (x !== t && x !== s && reachable(x)[t]) { drop[s + '\t' + t] = true; return; }
      }
    });
    return drop;
  }

  function connectedComponents(ids, edges) {
    var parent = Object.create(null);
    ids.forEach(function (id) { parent[id] = id; });
    function find(id) {
      while (parent[id] !== id) { parent[id] = parent[parent[id]]; id = parent[id]; }
      return id;
    }
    edges.forEach(function (edge) { parent[find(edge.source)] = find(edge.target); });
    var byRoot = Object.create(null);
    ids.forEach(function (id) {
      var root = find(id);
      (byRoot[root] = byRoot[root] || { nodes: [], edges: [] }).nodes.push(id);
    });
    edges.forEach(function (edge) { byRoot[find(edge.source)].edges.push(edge); });
    return Object.keys(byRoot).map(function (root) { return byRoot[root]; })
      .sort(function (a, b) {
        return b.nodes.length - a.nodes.length || a.nodes.slice().sort()[0].localeCompare(b.nodes.slice().sort()[0]);
      });
  }

  // Layered layout: strongly connected components share a layer; layers come
  // from longest paths, measured from the sources or to the sinks, whichever
  // gives the narrower drawing; barycentre sweeps order each layer; vertical
  // positions minimize the squared distance to the neighbours' mean subject
  // to the row spacing (isotonic regression).
  function layoutComponent(ids, edges, model) {
    var succ = Object.create(null), pred = Object.create(null);
    ids.forEach(function (id) { succ[id] = []; pred[id] = []; });
    edges.forEach(function (edge) {
      succ[edge.source].push(edge.target);
      pred[edge.target].push(edge.source);
    });

    // Tarjan's strongly connected components.
    var index = 0, stack = [], onStack = Object.create(null);
    var order = Object.create(null), low = Object.create(null), comp = Object.create(null);
    var comps = [];
    function connect(id) {
      order[id] = low[id] = index++;
      stack.push(id); onStack[id] = true;
      succ[id].forEach(function (next) {
        if (order[next] == null) { connect(next); low[id] = Math.min(low[id], low[next]); }
        else if (onStack[next]) { low[id] = Math.min(low[id], order[next]); }
      });
      if (low[id] === order[id]) {
        var members = [], member;
        do { member = stack.pop(); onStack[member] = false; comp[member] = comps.length; members.push(member); }
        while (member !== id);
        comps.push(members);
      }
    }
    ids.slice().sort().forEach(function (id) { if (order[id] == null) connect(id); });

    var cSucc = comps.map(function () { return Object.create(null); });
    var cPred = comps.map(function () { return Object.create(null); });
    edges.forEach(function (edge) {
      var a = comp[edge.source], b = comp[edge.target];
      if (a !== b) { cSucc[a][b] = true; cPred[b][a] = true; }
    });
    function longest(neighbours) {
      var memo = [];
      function depth(c) {
        if (memo[c] != null) return memo[c];
        var best = 0;
        Object.keys(neighbours[c]).forEach(function (n) { best = Math.max(best, depth(Number(n)) + 1); });
        memo[c] = best;
        return best;
      }
      return comps.map(function (_, c) { return depth(c); });
    }
    var fromSources = longest(cPred);
    var toSinks = longest(cSucc);
    var maxToSinks = Math.max.apply(null, toSinks);
    var fromSinks = toSinks.map(function (h) { return maxToSinks - h; });
    function widest(layering) {
      var counts = Object.create(null), widestLayer = 0;
      comps.forEach(function (members, c) {
        counts[layering[c]] = (counts[layering[c]] || 0) + members.length;
        widestLayer = Math.max(widestLayer, counts[layering[c]]);
      });
      return widestLayer;
    }
    var compLayer = (widest(fromSinks) < widest(fromSources) ? fromSinks : fromSources).slice();
    // Either layering leaves the sinks (or the sources) at the far edge even
    // when their neighbours are near the other end; move them next to their
    // neighbours instead.
    comps.forEach(function (_, c) {
      var preds = Object.keys(cPred[c]), succs = Object.keys(cSucc[c]);
      if (succs.length === 0 && preds.length > 0) {
        compLayer[c] = 1 + Math.max.apply(null, preds.map(function (p) { return compLayer[Number(p)]; }));
      }
    });
    comps.forEach(function (_, c) {
      var preds = Object.keys(cPred[c]), succs = Object.keys(cSucc[c]);
      if (preds.length === 0 && succs.length > 0) {
        compLayer[c] = Math.min.apply(null, succs.map(function (s) { return compLayer[Number(s)]; })) - 1;
      }
    });
    var lowest = Math.min.apply(null, compLayer);
    compLayer = compLayer.map(function (l) { return l - lowest; });

    var layer = Object.create(null);
    var layers = [];
    ids.forEach(function (id) {
      var l = compLayer[comp[id]];
      layer[id] = l;
      (layers[l] = layers[l] || []).push(id);
    });
    layers = layers.filter(Boolean);
    layers.forEach(function (members, l) { members.forEach(function (id) { layer[id] = l; }); });

    function sortKey(id) {
      var node = model.nodes[id];
      return plain(node.name) + '\t' + id;
    }
    layers.forEach(function (members) {
      members.sort(function (a, b) { return sortKey(a).localeCompare(sortKey(b)); });
    });

    function positions() {
      var pos = Object.create(null);
      layers.forEach(function (members) { members.forEach(function (id, i) { pos[id] = i; }); });
      return pos;
    }
    function sweep(downward) {
      var pos = positions();
      var range = downward
        ? layers.map(function (_, l) { return l; })
        : layers.map(function (_, l) { return layers.length - 1 - l; });
      range.forEach(function (l) {
        var bary = Object.create(null);
        layers[l].forEach(function (id) {
          var neighbours = (downward ? pred[id] : succ[id]).filter(function (n) {
            return downward ? layer[n] < l : layer[n] > l;
          });
          if (neighbours.length) {
            bary[id] = neighbours.reduce(function (sum, n) { return sum + pos[n]; }, 0) / neighbours.length;
          }
        });
        layers[l].sort(function (a, b) {
          var ba = bary[a], bb = bary[b];
          if (ba != null && bb != null && ba !== bb) return ba - bb;
          if (ba != null && bb == null) return -1;
          if (ba == null && bb != null) return 1;
          return pos[a] - pos[b];
        });
        layers[l].forEach(function (id, i) { pos[id] = i; });
      });
    }
    for (var s = 0; s < 6; s += 1) { sweep(true); sweep(false); }

    var STEP = NODE_H + ROW_GAP;
    var y = Object.create(null);
    var tallest = Math.max.apply(null, layers.map(function (m) { return m.length; }));
    layers.forEach(function (members) {
      var offset = (tallest - members.length) * STEP / 2;
      members.forEach(function (id, i) { y[id] = offset + i * STEP; });
    });
    for (var it = 0; it < 8; it += 1) {
      layers.forEach(function (members) {
        var desired = members.map(function (id) {
          var neighbours = pred[id].concat(succ[id]).filter(function (n) { return n !== id; });
          if (!neighbours.length) return y[id];
          return neighbours.reduce(function (sum, n) { return sum + y[n]; }, 0) / neighbours.length;
        });
        var placed = isotonic(desired.map(function (d, i) { return d - i * STEP; }));
        members.forEach(function (id, i) { y[id] = placed[i] + i * STEP; });
      });
    }
    var minY = Math.min.apply(null, ids.map(function (id) { return y[id]; }));
    var maxY = Math.max.apply(null, ids.map(function (id) { return y[id]; }));

    var placed = Object.create(null);
    ids.forEach(function (id) {
      placed[id] = { x: PAD + layer[id] * (NODE_W + LAYER_GAP), y: PAD + y[id] - minY };
    });
    return {
      nodes: ids, edges: edges, pos: placed, layer: layer,
      width: PAD * 2 + layers.length * NODE_W + (layers.length - 1) * LAYER_GAP,
      height: PAD * 2 + (maxY - minY) + NODE_H
    };
  }

  // Least-squares non-decreasing fit (pool adjacent violators).
  function isotonic(values) {
    var blocks = [];
    values.forEach(function (v) {
      blocks.push({ sum: v, n: 1 });
      while (blocks.length > 1) {
        var a = blocks[blocks.length - 2], b = blocks[blocks.length - 1];
        if (a.sum / a.n <= b.sum / b.n) break;
        blocks.pop();
        a.sum += b.sum; a.n += b.n;
      }
    });
    var out = [];
    blocks.forEach(function (block) {
      for (var i = 0; i < block.n; i += 1) out.push(block.sum / block.n);
    });
    return out;
  }

  RelationExplorer.prototype.diagram = function (layout, group, component) {
    var model = this.model;
    var canvas = el('div.rg-canvas', { style: 'width:' + layout.width + 'px;height:' + layout.height + 'px' });
    var edgeLayer = svg('svg', {
      class: 'rg-edges', width: layout.width, height: layout.height,
      viewBox: '0 0 ' + layout.width + ' ' + layout.height, 'aria-hidden': 'true', focusable: 'false'
    });
    layout.edges.forEach(function (edge) {
      var a = layout.pos[edge.source], b = layout.pos[edge.target];
      var d, endX, endY, x1, y1;
      if (layout.layer[edge.source] === layout.layer[edge.target]) {
        x1 = a.x + NODE_W; y1 = a.y + NODE_H / 2;
        endX = b.x + NODE_W; endY = b.y + NODE_H / 2;
        d = 'M' + x1 + ' ' + y1 + ' C' + (x1 + 36) + ' ' + y1 + ' ' + (endX + 36) + ' ' + endY + ' '
          + endX + ' ' + endY;
        var head = svg('path', {
          class: 'rg-arrow rg-c' + edge.slot,
          d: 'M' + (endX + 8) + ' ' + (endY - 4.5) + ' L' + endX + ' ' + endY + ' L' + (endX + 8) + ' ' + (endY + 4.5) + ' Z'
        });
        head.setAttribute('data-edge', edge.source + '\t' + edge.target);
        edgeLayer.appendChild(svg('path', {
          class: 'rg-wire rg-c' + edge.slot + (edge.conjecture ? ' is-conjecture' : '') + (edge.implied ? ' is-implied' : ''),
          d: d, 'data-edge': edge.source + '\t' + edge.target
        }));
        edgeLayer.appendChild(head);
        return;
      }
      x1 = a.x + NODE_W; y1 = a.y + NODE_H / 2;
      endX = b.x; endY = b.y + NODE_H / 2;
      var bend = Math.max(28, (endX - x1) * 0.45);
      d = 'M' + x1 + ' ' + y1 + ' C' + (x1 + bend) + ' ' + y1 + ' ' + (endX - bend) + ' ' + endY + ' '
        + (endX - 7) + ' ' + endY + ' L' + endX + ' ' + endY;
      edgeLayer.appendChild(svg('path', {
        class: 'rg-wire rg-c' + edge.slot + (edge.conjecture ? ' is-conjecture' : '') + (edge.implied ? ' is-implied' : ''),
        d: d, 'data-edge': edge.source + '\t' + edge.target
      }));
      var arrow = arrowHead(endX, endY, 'rg-c' + edge.slot);
      arrow.setAttribute('data-edge', edge.source + '\t' + edge.target);
      edgeLayer.appendChild(arrow);
    });
    canvas.appendChild(edgeLayer);

    layout.nodes.forEach(function (id) {
      var node = model.nodes[id];
      var p = layout.pos[id];
      canvas.appendChild(el('a.rg-node', {
        href: familyHash(id), 'data-node': id, title: readable(node.name),
        style: 'left:' + p.x + 'px;top:' + p.y + 'px;width:' + NODE_W + 'px;height:' + NODE_H + 'px'
      },
        field('span.rg-node-name', node.name)));
    });

    var sizer = el('div.rg-sizer', {}, canvas);
    var frame = el('div.rg-frame', { tabindex: '-1' }, sizer);
    frame._layout = layout;
    var caption = el('figcaption.rg-caption', {},
      el('span', {}, component.nodes.length + ' families, ' + component.edges.length
        + (component.edges.length === 1 ? ' relation' : ' relations')));
    var figure = el('figure.rg-diagram', {}, frame, caption);
    figure.setAttribute('aria-label', 'Diagram of ' + component.nodes.length + ' families');
    if (layout.width > SMALL_W || layout.height > SMALL_H) {
      var key = group.id + ':' + component.nodes.slice().sort()[0];
      var self = this;
      var zoomBar = el('div.rg-zoom', { role: 'group', 'aria-label': 'Zoom' });
      [['\u2212', 'Zoom out', -1], ['Fit', 'Fit to width', 0], ['+', 'Zoom in', 1]].forEach(function (spec) {
        var button = el('button', { type: 'button', 'aria-label': spec[1], title: spec[1] }, spec[0]);
        button.addEventListener('click', function () {
          var z = self.zoom[key] || frame._zoom || 1;
          if (spec[2] === 0) z = Math.min(1, frame.clientWidth / layout.width);
          else z = Math.max(0.3, Math.min(1.6, z * (spec[2] > 0 ? 1.25 : 0.8)));
          self.zoom[key] = z;
          setZoom(frame, z);
        });
        zoomBar.appendChild(button);
      });
      frame._zoomKey = key;
      caption.appendChild(zoomBar);
      figure.classList.add('is-large');
    }
    this.traceHover(canvas, layout);
    return figure;
  };

  // Components of exactly two families: one compact list of "A -> B" rows.
  RelationExplorer.prototype.pairList = function (pairs, group, afterDiagrams) {
    var model = this.model;
    var rows = [];
    pairs.forEach(function (component) {
      component.edges.forEach(function (edge) { rows.push(edge); });
    });
    rows.sort(function (a, b) { return byName(model.nodes[a.source], model.nodes[b.source]); });
    function node(id) {
      var link = el('a.rg-pair-node', { href: familyHash(id) });
      link.appendChild(field('span', model.nodes[id].name));
      return link;
    }
    var list = el('ul.rg-pairs.rg-c' + group.slot);
    rows.forEach(function (edge) {
      list.appendChild(el('li.rg-pair', {},
        node(edge.source),
        el('span.rg-pair-arrow' + (edge.conjecture ? '.is-conjecture' : ''), { 'aria-label': edge.conjecture ? 'to (conjecture)' : 'to' }),
        node(edge.target)));
    });
    return el('section.rg-pair-section', {},
      el('h3.rg-pairs-title', {}, afterDiagrams
        ? 'Separate pairs (' + rows.length + ')'
        : rows.length + (rows.length === 1 ? ' pair' : ' pairs')),
      list);
  };

  // Large diagrams start at a legible fit-to-width (never below 70%).
  RelationExplorer.prototype.fitFrame = function (frame) {
    var layout = frame._layout;
    if (!frame._zoomKey) {
      setZoom(frame, Math.max(0.6, Math.min(1, frame.clientWidth / layout.width)));
      return;
    }
    var z = this.zoom[frame._zoomKey];
    if (z == null) z = Math.max(0.7, Math.min(1, frame.clientWidth / layout.width));
    setZoom(frame, z);
  };

  function setZoom(frame, z) {
    var layout = frame._layout;
    var sizer = frame.firstChild;
    var canvas = sizer.firstChild;
    frame._zoom = z;
    sizer.style.width = Math.ceil(layout.width * z) + 'px';
    sizer.style.height = Math.ceil(layout.height * z) + 'px';
    canvas.style.transform = z === 1 ? '' : 'scale(' + z + ')';
  }

  // Hovering or focusing a family dims everything but its own relations.
  RelationExplorer.prototype.traceHover = function (canvas, layout) {
    var neighbours = Object.create(null);
    layout.nodes.forEach(function (id) { neighbours[id] = Object.create(null); });
    layout.edges.forEach(function (edge) {
      neighbours[edge.source][edge.target] = true;
      neighbours[edge.target][edge.source] = true;
    });
    function set(id, on) {
      canvas.classList.toggle('is-tracing', on);
      $all('.rg-node', canvas).forEach(function (node) {
        var other = node.getAttribute('data-node');
        node.classList.toggle('is-hot', on && (other === id || !!neighbours[id][other]));
      });
      $all('[data-edge]', canvas).forEach(function (path) {
        var ends = path.getAttribute('data-edge').split('\t');
        path.classList.toggle('is-hot', on && (ends[0] === id || ends[1] === id));
      });
    }
    $all('.rg-node', canvas).forEach(function (node) {
      var id = node.getAttribute('data-node');
      node.addEventListener('mouseenter', function () { set(id, true); });
      node.addEventListener('mouseleave', function () { set(id, false); });
      node.addEventListener('focus', function () { set(id, true); });
      node.addEventListener('blur', function () { set(id, false); });
    });
  };

  // ------------------------------------------------------------- loading

  function loadGraph(root) {
    var embedded = $('#relationGraphData', root) || document.getElementById('relationGraphData');
    if (embedded && embedded.textContent.trim()) {
      try {
        return Promise.resolve(JSON.parse(embedded.textContent));
      } catch (error) {
        console.warn('Could not parse embedded relation graph data:', error);
      }
    }
    var src = root.getAttribute('data-graph-src') || 'polynomial-relations.json';
    return fetch(src, { credentials: 'same-origin' }).then(function (response) {
      if (!response.ok) throw new Error('Could not load ' + src);
      return response.json();
    });
  }

  function init(root) {
    loadGraph(root)
      .then(function (graph) { root._relationExplorer = new RelationExplorer(root, graph); })
      .catch(function (error) {
        var view = $('#relationGraphView', root);
        if (view) view.textContent = 'The relation data could not be loaded: ' + error.message;
      });
  }

  document.addEventListener('DOMContentLoaded', function () {
    $all('[data-relation-graph]').forEach(init);
  });
})();
