// Search page (\specialblock{searchbox}): Pagefind UI with typeset math.
// The index keeps the TeX source, so macro names such as \schurP stay
// searchable; excerpts and section titles are typeset with KaTeX for display.
(function () {
  'use strict';

  var OPENERS = { '\\(': '\\)', '\\[': '\\]' };
  var DELIMITER = /\\[()[\]]|<\/?mark>/g;

  function decodeEntities(s) {
    return s.replace(/&lt;/g, '<').replace(/&gt;/g, '>').replace(/&quot;/g, '"')
      .replace(/&#39;/g, "'").replace(/&amp;/g, '&');
  }

  // True when the delimiter at index i is preceded by an odd run of backslashes.
  function escaped(s, i) {
    var n = 0;
    while (i - n - 1 >= 0 && s.charAt(i - n - 1) === '\\') n++;
    return n % 2 === 1;
  }

  function typeset(tex) {
    if (!window.katex) return null;
    try {
      return window.katex.renderToString(decodeEntities(tex), {
        throwOnError: false,
        displayMode: false,
        macros: Object.assign({}, window.KATEX_MACROS || {})
      });
    } catch (e) {
      return null;
    }
  }

  // Excerpts are HTML-escaped text with <mark> tags around matched words. Marks
  // may straddle formula boundaries, and the excerpt may start or end inside a
  // formula: such fragments are replaced by an ellipsis.
  function typesetExcerpt(html) {
    var out = '';
    var marked = false;     // a <mark> is open in the input
    var math = null;        // { close, tex, hit, start } while inside a formula
    var last = 0;
    var seenDelimiter = false;
    var m;
    DELIMITER.lastIndex = 0;
    while ((m = DELIMITER.exec(html))) {
      var token = m[0];
      var before = html.slice(last, m.index);
      last = DELIMITER.lastIndex;
      if (token === '<mark>' || token === '</mark>') {
        if (math) {
          math.tex += before;
          if (token === '<mark>') math.hit = true;
        } else {
          out += before + token;
        }
        marked = token === '<mark>';
        continue;
      }
      if (escaped(html, m.index)) {
        // \\[2pt] and similar: a TeX line break, not a delimiter.
        if (math) math.tex += before + token; else out += before + token;
        continue;
      }
      if (math) {
        math.tex += before;
        if (token !== math.close) { math.tex += token; continue; }
        var rendered = typeset(math.tex);
        var hit = math.hit || math.markedAtStart;
        out += rendered === null ? math.source + math.tex + token
          : (hit ? '<mark>' + rendered + '</mark>' : rendered);
        if (marked) out += '<mark>';
        math = null;
      } else if (OPENERS[token]) {
        out += before;
        if (marked) out += '</mark>';
        math = { close: OPENERS[token], source: token, tex: '', hit: false,
                 markedAtStart: marked };
      } else if (!seenDelimiter) {
        // A closing delimiter first: the excerpt began inside a formula.
        out = '… ';
        if (marked) out += '<mark>';
      } else {
        out += before + token;
      }
      seenDelimiter = true;
    }
    if (math) {
      // The excerpt ends inside a formula.
      out += ' …';
    } else {
      out += html.slice(last);
      if (marked) out += '</mark>';
    }
    return out;
  }

  function processResult(result) {
    if (result.excerpt) result.excerpt = typesetExcerpt(result.excerpt);
    (result.sub_results || []).forEach(function (sub) {
      if (sub.excerpt) sub.excerpt = typesetExcerpt(sub.excerpt);
    });
    return result;
  }

  // Titles are inserted as text, so they are typeset in place.
  function typesetTitles(root) {
    if (typeof renderMathInElement !== 'function') return;
    root.querySelectorAll('.pagefind-ui__result-title').forEach(function (el) {
      if (el.querySelector('.katex') || el.textContent.indexOf('\\') < 0) return;
      try {
        renderMathInElement(el, {
          delimiters: [
            { left: '\\(', right: '\\)', display: false },
            { left: '\\[', right: '\\]', display: false }
          ],
          output: 'html',
          throwOnError: false,
          macros: window.KATEX_MACROS || {}
        });
      } catch (e) {}
    });
  }

  window.addEventListener('DOMContentLoaded', function () {
    var root = document.getElementById('search');
    if (!root || typeof PagefindUI !== 'function') return;
    var pagefindUI = new PagefindUI({
      element: '#search',
      showImages: false,
      resetStyles: false,
      processResult: processResult
    });
    var pending = false;
    new MutationObserver(function () {
      if (pending) return;
      pending = true;
      requestAnimationFrame(function () { pending = false; typesetTitles(root); });
    }).observe(root, { childList: true, subtree: true });

    // JSON-LD SearchAction: search.htm?q=...
    var query = new URLSearchParams(window.location.search).get('q');
    if (query) pagefindUI.triggerSearch(query);
  });
})();
