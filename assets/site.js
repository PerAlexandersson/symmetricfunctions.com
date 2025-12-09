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
        output: "html",
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


// Initialize Copy-to-Clipboard buttons on all <pre> blocks
  function initCopyButtons() {
    // 1. Find all <pre> tags
    var blocks = document.querySelectorAll('pre');
    
    blocks.forEach(function(pre) {
        // 2. Create the button
        var button = document.createElement('button');
        button.className = 'copy-btn';
        
        button.innerHTML = '<img src="icons/icon-clone.svg" class="copy icon" />'; 
        button.setAttribute('aria-label', 'Copy to clipboard');

        // 3. Add Click Logic
        button.addEventListener('click', function() {
            var code = pre.querySelector('code');
            var text = code ? code.innerText : pre.innerText;

            // The modern clipboard API
            navigator.clipboard.writeText(text).then(function() {
                // Success Feedback
                button.innerHTML = '<img src="icons/icon-heart.svg" class="heart icon" />';
                button.style.color = 'green';
                button.style.borderColor = 'green';
                
                // Reset after 2 seconds
                setTimeout(function() {
                    button.innerHTML = '<img src="icons/icon-clone.svg" class="heart icon" />';
                    button.style.color = '';
                    button.style.borderColor = '';
                }, 2000);
            }).catch(function(err) {
                console.error('Failed to copy!', err);
            });
        });

        // 4. Append button to the <pre> block
        pre.appendChild(button);
    });
  }

  // Family Index Table Sorting & Row Linking
  function initFamilyIndexTable() {
    var table = document.getElementById("family-index");
    if (!table) return;

    var headers = table.querySelectorAll('th');
    var tableBody = table.querySelector('tbody');
    
    // Map column index to data-attribute. 
    // We use null for index 0 because we will special-case it to use textContent.
    var columnDataMap = [null, 'space', 'category', 'year', 'rating'];
    var directions = [1, 1, 1, 1, 1];

    var rows = Array.prototype.slice.call(tableBody.querySelectorAll('tr'));

    // 1. Sorting Logic
    for (var i = 0; i < headers.length; i++) {
      (function(index) {
        headers[index].addEventListener('click', function() {
          var direction = directions[index];

          rows.sort(function(rowA, rowB) {
            var valA, valB;

            // If it's the first column (Name), sort by visible text
            if (index === 0) {
              valA = rowA.cells[0].textContent.replace(/\$/g, '').trim();
              valB = rowB.cells[0].textContent.replace(/\$/g, '').trim();
            } else {
              // Otherwise sort by the data attribute
              var attr = columnDataMap[index];
              valA = rowA.getAttribute('data-' + attr);
              valB = rowB.getAttribute('data-' + attr);
            }

            var numA = parseFloat(valA);
            var numB = parseFloat(valB);

            // Numeric Sort (if both are numbers)
            if (!isNaN(numA) && !isNaN(numB)) {
              return (numA - numB) * direction;
            }
            
            // Text Sort
            return valA.localeCompare(valB) * direction;
          });

            // Re-append sorted rows
          for (var j = 0; j < rows.length; j++) {
            tableBody.appendChild(rows[j]);
          }

          directions[index] = -direction;
        });
      })(i);
    }

    // Row Click Logic (Delegation)
    tableBody.addEventListener('click', function(e) {
      // Find the clicked row
      var row = e.target.closest('tr');
      if (!row) return;

      // If the user actually clicked a link directly, let the browser handle it
      // This prevents double-firing or breaking Middle-Click / Cmd-Click
      if (e.target.closest('a')) return;

      // Otherwise, find the primary link in this row and click it
      var link = row.querySelector('a');
      if (link) {
        link.click();
      }
    });

    // Sort table initially
    if (headers.length > 0) {
        headers[0].click();
    }
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
    initCopyButtons();
    initFamilyIndexTable();

    // Small accessibility improvement: keyboard to toggle sidebar
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