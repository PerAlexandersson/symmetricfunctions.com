/**
 * Utility functions for arXiv Combinatorics Frontend
 * Organized into sections: Core Utilities, BibTeX Functions, UI Features
 */

// ============================================================================
// CORE UTILITIES
// ============================================================================

/**
 * Copy text to clipboard with fallback for non-secure contexts
 * @param {string} text - The text to copy
 * @returns {Promise} - Resolves when copy succeeds, rejects on error
 */
function copyToClipboard(text) {
    // Try modern Clipboard API first (requires HTTPS or localhost)
    if (navigator.clipboard && navigator.clipboard.writeText) {
        return navigator.clipboard.writeText(text);
    }

    // Fallback for older browsers or non-secure contexts
    return new Promise((resolve, reject) => {
        const textarea = document.createElement('textarea');
        textarea.value = text;
        textarea.style.position = 'fixed';
        textarea.style.opacity = '0';
        document.body.appendChild(textarea);
        textarea.focus();
        textarea.select();

        try {
            const successful = document.execCommand('copy');
            document.body.removeChild(textarea);
            if (successful) {
                resolve();
            } else {
                reject(new Error('execCommand failed'));
            }
        } catch (err) {
            document.body.removeChild(textarea);
            reject(err);
        }
    });
}

/**
 * Generic fetch and copy utility
 * @param {string} url - API endpoint to fetch from
 * @param {string} successMessage - Message to show on success
 * @param {string} errorPrefix - Prefix for error messages
 * @returns {Promise}
 */
async function fetchAndCopy(url, successMessage, errorPrefix = 'Failed to copy') {
    try {
        const response = await fetch(url);
        if (!response.ok) {
            throw new Error(`HTTP ${response.status}`);
        }
        const text = await response.text();
        await copyToClipboard(text);
        alert(successMessage);
    } catch (err) {
        alert(`${errorPrefix}: ${err}`);
        throw err;
    }
}

// ============================================================================
// BIBTEX FUNCTIONS
// ============================================================================

/**
 * Fetch and copy arXiv BibTeX citation
 * @param {string} arxivId - The arXiv paper ID
 */
async function copyBibtex(arxivId) {
    await fetchAndCopy(
        `/api/bibtex/${arxivId}`,
        'arXiv BibTeX copied to clipboard!',
        'Failed to copy BibTeX'
    );
}

/**
 * Fetch and copy DOI BibTeX citation
 * @param {string} arxivId - The arXiv paper ID
 */
async function copyDoiBibtex(arxivId) {
    await fetchAndCopy(
        `/api/doi-bibtex/${arxivId}`,
        'DOI BibTeX copied to clipboard!',
        'Failed to copy DOI BibTeX'
    );
}

/**
 * Fetch BibTeX and display in element
 * @param {string} arxivId - The arXiv paper ID
 * @param {string} elementId - Target element ID for display
 */
async function fetchBibtex(arxivId, elementId) {
    try {
        const response = await fetch(`/api/bibtex/${arxivId}`);
        const bibtex = await response.text();
        document.getElementById(elementId).textContent = bibtex;
    } catch (error) {
        document.getElementById(elementId).textContent = 'Error loading BibTeX';
    }
}

// ============================================================================
// BULK BIBTEX FUNCTIONS
// ============================================================================

/**
 * Fetch and copy all BibTeX entries for an author
 * @param {string} authorName - The author's name
 */
async function copyAuthorBibtex(authorSlug) {
    await fetchAndCopy(
        `/api/author-bibtex/${authorSlug}`,
        'All BibTeX entries copied to clipboard!',
        'Failed to copy BibTeX'
    );
}

// ============================================================================
// SHARING FUNCTIONS
// ============================================================================

/**
 * Copy shareable link to clipboard
 * @param {string} arxivId - The arXiv paper ID
 */
async function copyShareLink(arxivId) {
    const url = `${window.location.origin}/paper/${arxivId}`;
    try {
        await copyToClipboard(url);
        alert('Link copied to clipboard!');
    } catch (err) {
        alert('Failed to copy link: ' + err);
    }
}

// ============================================================================
// UI FEATURES - Abstract Persistence
// ============================================================================

/**
 * Initialize persistent abstract state using localStorage
 * Remembers which abstracts are expanded across page loads
 */
function initAbstractPersistence() {
    const details = document.querySelectorAll('.abstract-details');

    // Restore state from localStorage
    details.forEach(detail => {
        const arxivId = detail.getAttribute('data-arxiv-id');
        if (arxivId) {
            const isOpen = localStorage.getItem(`abstract-${arxivId}`) === 'open';
            if (isOpen) {
                detail.open = true;
            }
        }
    });

    // Save state on toggle
    details.forEach(detail => {
        detail.addEventListener('toggle', function() {
            const arxivId = this.getAttribute('data-arxiv-id');
            if (arxivId) {
                localStorage.setItem(`abstract-${arxivId}`, this.open ? 'open' : 'closed');
            }
        });
    });
}

// ============================================================================
// UI FEATURES - Keyboard Shortcuts
// ============================================================================

/**
 * Initialize keyboard shortcuts for paper navigation
 * j/k - Navigate between papers
 * Enter - Toggle abstract
 */
function initKeyboardShortcuts() {
    document.addEventListener('keydown', function(e) {
        // Ignore if user is typing in an input/textarea
        if (e.target.tagName === 'INPUT' || e.target.tagName === 'TEXTAREA') {
            return;
        }

        const papers = Array.from(document.querySelectorAll('.paper'));
        if (papers.length === 0) return;

        let currentIndex = -1;
        const focused = document.activeElement;

        // Find current paper
        if (focused && focused.classList.contains('paper-title')) {
            const paper = focused.closest('.paper');
            currentIndex = papers.indexOf(paper);
        }

        if (e.key === 'j') {
            // Next paper
            e.preventDefault();
            const nextIndex = currentIndex + 1;
            if (nextIndex < papers.length) {
                const summary = papers[nextIndex].querySelector('.paper-title');
                if (summary) {
                    summary.focus();
                    summary.scrollIntoView({ behavior: 'smooth', block: 'center' });
                }
            }
        } else if (e.key === 'k') {
            // Previous paper
            e.preventDefault();
            const prevIndex = currentIndex - 1;
            if (prevIndex >= 0) {
                const summary = papers[prevIndex].querySelector('.paper-title');
                if (summary) {
                    summary.focus();
                    summary.scrollIntoView({ behavior: 'smooth', block: 'center' });
                }
            } else if (currentIndex === -1 && papers.length > 0) {
                // If nothing focused, focus first paper
                const summary = papers[0].querySelector('.paper-title');
                if (summary) {
                    summary.focus();
                    summary.scrollIntoView({ behavior: 'smooth', block: 'center' });
                }
            }
        } else if (e.key === 'Enter') {
            // Toggle current paper's abstract
            if (focused && focused.classList.contains('paper-title')) {
                e.preventDefault();
                focused.click();
            }
        }
    });
}

// ============================================================================
// UI FEATURES - Dark Mode
// ============================================================================

/**
 * Toggle dark mode and persist preference
 */
function toggleDarkMode() {
    const isDark = document.documentElement.classList.toggle('dark');
    localStorage.setItem('dark-mode', isDark ? 'on' : 'off');
    updateDarkModeLabel();
}

/**
 * Update the toggle link text
 */
function updateDarkModeLabel() {
    const toggle = document.getElementById('dark-mode-toggle');
    if (toggle) {
        const isDark = document.documentElement.classList.contains('dark');
        toggle.textContent = isDark ? 'Light mode' : 'Dark mode';
    }
}

/**
 * Initialize dark mode from saved preference
 */
function initDarkMode() {
    const saved = localStorage.getItem('dark-mode');
    if (saved === 'on') {
        document.documentElement.classList.add('dark');
    }
    updateDarkModeLabel();
}

// ============================================================================
// INITIALIZATION
// ============================================================================

/**
 * Initialize all UI features on page load
 */
document.addEventListener('DOMContentLoaded', function() {
    initDarkMode();
    initAbstractPersistence();
    initKeyboardShortcuts();
});
