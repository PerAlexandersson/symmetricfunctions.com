// Main site JS: cookie dialog, sidebar, TOC click handlers, scroll behavior, KaTeX init.
(function () {
  'use strict';

  // Utility
  function setCookieAccepted() {
    document.cookie = "cookieaccepted=1; expires=Thu, 18 Dec 2030 12:00:00 UTC; path=/";
  }

  // KaTeX initialization (macros expected from katex-macros.js in window.KATEX_MACROS)
  function initKatex() {
    if (typeof renderMathInElement !== 'function') return;
    var macros = window.KATEX_MACROS || {};
    try {
      renderMathInElement(document.body, {
        delimiters: [
          {left: "$$", right: "$$", display: true},
          {left: "\\[", right: "\\]", display: true},
          {left: "$",  right: "$",  display: false},
          {left: "\\(", right: "\\)", display: false}
        ],
        throwOnError: false,
        macros: macros
      });
    } catch (e) {
      // Fail gracefully in older browsers
      console.warn('KaTeX render failed:', e);
    }
  }

  // Cookie dialog
  function initCookieDialog() {
    if (document.cookie.indexOf("cookieaccepted=") >= 0) return;
    var dlg = document.getElementById("cookie-dialog");
    if (!dlg || !dlg.showModal) return;
    dlg.showModal();
    dlg.addEventListener('close', function () {
      if (dlg.returnValue === "accept") setCookieAccepted();
    });
  }

  // Sidebar toggle + aria sync
  function toggleSideBar() {
    var toc = document.getElementById("tocContainer");
    var btn = document.getElementById("tocButton");
    if (!toc || !btn) return;
    var expanded = btn.getAttribute("aria-expanded") === "true";
    toc.classList.toggle("sideBarShowHide");
    btn.setAttribute("aria-expanded", String(!expanded));
    toc.setAttribute("aria-hidden", String(expanded));
  }

  // Wire up TOC list items to close sidebar on click (delegation safe)
  function initTOCListeners() {
    var tocList = document.getElementById("tocLinkList");
    if (!tocList) return;
    tocList.addEventListener('click', function (ev) {
      // only close on link clicks (keeps behaviour conservative)
      var target = ev.target;
      while (target && target !== tocList) {
        if (target.tagName === 'A' || target.tagName === 'BUTTON') {
          toggleSideBar();
          return;
        }
        target = target.parentElement;
      }
    });
  }

  // Hide/show floating tocButton on scroll
  function initScrollBehavior() {
    var prev = window.pageYOffset;
    var tocButton = document.getElementById("tocButton");
    if (!tocButton) return;
    window.addEventListener('scroll', function () {
      var cur = window.pageYOffset;
      tocButton.style.bottom = (prev > cur) ? '0' : '-50px';
      prev = cur;
    }, { passive: true });
  }

  // Index sorting: keep the same API as before
  window.sortByVariable = function (newClass) {
    var elem = document.getElementById("index-container");
    if (!elem) return;
    if (elem.className === newClass) {
      elem.style.flexDirection = (elem.style.flexDirection === 'column') ? 'column-reverse' : 'column';
    } else {
      elem.className = newClass;
    }
  };

  // Expose toggle for template inline onclick compatibility
  window.toggleSideBar = toggleSideBar;

  // Init on DOM ready
  document.addEventListener('DOMContentLoaded', function () {
    initKatex();
    initCookieDialog();
    initTOCListeners();
    initScrollBehavior();

    // small accessibility improvement: keyboard to toggle sidebar
    var tocButton = document.getElementById("tocButton");
    if (tocButton) {
      tocButton.addEventListener('keydown', function (e) {
        if (e.key === 'Enter' || e.key === ' ') {
          e.preventDefault();
          toggleSideBar();
        }
      });
    }
  });

})();