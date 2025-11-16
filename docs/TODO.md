

# TODO: Roadmap for Symmetricfunctions.com

*For symmetricfunctions.com and future open-source use*

This document outlines short-term, medium-term, and long-term improvements for the project.
The goal is: **clean, robust, maintainable, open-source-friendly, and an excellent user experience.**



# Build process

## Project Structure & Configuration

* [ ] Add a central `config.yaml` or `config.lua` with:

  * [ ] Paths (`src_dir`, `temp_dir`, `www_dir`, `data_dir`)
  * [ ] Default language, math engine, theme
  * [ ] Build options (minify, debug output, etc.)
* [ ] Refactor all Lua filters to read config instead of hardcoding
* [ ] Introduce consistent project layout:

  * `filters/`, `scripts/`, `assets/`, `tex-source/`, `build/`, `tests/`, `docs/`

## 1.2. Environment Variables & Defaults

* [ ] Decide on a single strategy: `.env` OR config file
* [ ] Add documented fallback order: CLI > env > config > default
* [ ] Verify Makefile correctly exports/propagates env vars

---

## 1.3. Lua Filter Cleanup & Robustness

* [ ] Consolidate helpers into `filters/utils.lua`:

  * [ ] `trim`, `split_top_level_commas`
  * [ ] `has_class`, `get_attr`
  * [ ] Logging helpers (`print_info`, etc.)
* [ ] Standardize error handling and logging
* [ ] Improve readability and structure of filters:

  * [ ] Split large filters into submodules where appropriate
  * [ ] Document API of each filter: what it transforms, expected output

## 1.4. Minimal Unit Testing

* [ ] Create a `tests/` directory
* [ ] Add small golden tests for each filter:

  * [ ] ytableau/youngtab parsing
  * [ ] theorem/proof environments
  * [ ] cite conversion
  * [ ] external link classification
* [ ] Add a Makefile target `make test` running the tests via Pandoc

---

## 1.5. Build System Improvements

* [ ] Add Makefile targets:

  * [ ] `make all` – full build
  * [ ] `make page NAME=...` – build single page
  * [ ] `make clean` – clean build artifacts
  * [ ] `make test` – unit tests
  * [ ] `make check-links` – check internal/external links
* [ ] Add version pinning for tools (Pandoc, Lua)
* [ ] Provide a Docker or Nix environment for reproducibility

---

## 1.6. Immediate UX Improvements

* [ ] Add TOC/sidebar nav to long pages
* [ ] Improve citations:

  * [ ] Hover previews for references
  * [ ] "Copy BibTeX" button in bibliography
* [ ] Ensure consistent math rendering (KaTeX/MathJax)
* [ ] Improve syntax highlighting for code blocks
* [ ] Consolidate icon classes for external links (Font Awesome)
* [ ] Auto-detect arXiv/OEIS/GitHub links and decorate them

---

# 2. Medium-Term Improvements

## 2.1. Documentation & Contributor Friendliness

* [ ] Write `README.md`:

  * [ ] What the project does
  * [ ] How to build
  * [ ] Requirements
* [ ] Write `CONTRIBUTING.md`:

  * [ ] How to add a new page
  * [ ] Lua coding standards
  * [ ] How to run tests
* [ ] Add architecture overview diagram:

  * LaTeX → preprocess → Pandoc → filters → render → HTML
* [ ] Add examples of input/output transformations for each filter

---

## 2.2. Navigation & Discoverability on Site

* [ ] Implement global search:

  * [ ] Prebuild JSON search index
  * [ ] Client-side JS search
* [ ] Add tag system + tag pages
* [ ] Add breadcrumbs: `Home > Macdonald > LLT`
* [ ] Improve automatic cross-linking:

  * [ ] Tooltip for definitions the first time they’re used
  * [ ] Auto-link “see also” between related topics
  * [ ] Automatically detect LaTeX `\ref` and generate helpful anchors

---

## 2.3. Accessibility & Responsiveness

* [ ] Ensure semantic HTML structure (`<nav>`, `<main>`, `<section>`)
* [ ] Add `alt` text for diagrams and SVGs
* [ ] Ensure high-contrast color theme
* [ ] Support responsive tables via `.table-wrapper`
* [ ] Auto-scale SVGs on mobile using `viewBox`
* [ ] Aria elements

---

## 2.4. Testing & Continuous Integration

* [ ] Add GitHub Actions:

  * [ ] Build pipeline
  * [ ] Run unit tests
  * [ ] Run link checker
* [ ] Add regression tests:

  * [ ] Golden HTML files for key pages
  * [ ] Diff on PRs to catch accidental HTML changes

---

# 3. Long-Term Tasks (Major Improvements)

## 3.1. Generalizing Beyond SymmetricFunctions.com

* [ ] Abstract config/theme to allow multiple “instances”
* [ ] Allow site-level configuration of:

  * [ ] Theorem names and styles
  * [ ] Supported combinatorial objects
  * [ ] Citation formats
* [ ] Package as an installable tool:

  * [ ] `pandoc-symmetric-functions` or similar
  * [ ] Clearly modular filters/plugins

---

## 3.2. Interactive Features

* [ ] Dynamic Dyck path / tableau viewers with JS:

  * [ ] Highlight area, bounce, major index, etc.
  * [ ] Click to toggle statistics
* [ ] Interactive Kostka matrices:

  * [ ] Search/filter by partition
  * [ ] Highlight rows, compare rows
* [ ] Add “Copy LaTeX / Copy Sage / Copy M2” buttons on examples
* [ ] Use data attributes to pass combinatorial statistics from filters to JS

---

## 3.3. Data Integration

* [ ] Serve JSON datasets for:

  * [ ] Symmetric functions
  * [ ] LLT data
  * [ ] Kostka-Foulkes tables
* [ ] Create a unified `data/registry.lua` for small combinatorial data bundles
* [ ] Build interactive browsers for OEIS-linked sequences

---

## 3.4. Versioning & Releases

* [ ] Start versioning:

  * [ ] `v0.1.0` = “usable internally”
  * [ ] `v0.2.0` = “public alpha”
* [ ] Maintain `CHANGELOG.md`
* [ ] Publish documentation as a separate mini-site

---

## 3.5. Templates, Samples, and Dev Experience

* [ ] Create `examples/minimal-site/`:

  * [ ] A small LaTeX file
  * [ ] Simple theorem + ytableau
  * [ ] One-command build
* [ ] Add `make watch` with `entr` or `fswatch` for auto rebuild
* [ ] `make serve` to start a small static server
* [ ] Add metadata dashboard:

  * [ ] Missing labels
  * [ ] Missing references
  * [ ] Broken links
  * [ ] Pages missing tags

---

# Appendix: Possible Future Extensions

* [ ] Inline diagram generator for:

  * [ ] Ferrers diagrams
  * [ ] Young tableaux
  * [ ] Dyck paths
  * [ ] Flow diagrams (Macdonald recursion, etc.)

* [ ] Tooling for automatically generating SVGs from TikZ code. LaTeX repo with scripts for combinatorial diagrams.

---
