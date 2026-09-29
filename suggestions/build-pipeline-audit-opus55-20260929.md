# Build-pipeline audit — symmetricfunctions.com

Auditor: Claude Opus 5.5 (sole audit owner), with host-supervisor verification,
2026-09-29.
Baseline: `master` at `02f8941`, clean worktree, no other worker recorded as
owner in `HANDOFF.md`.

## Scope and method

In scope: `Makefile`, `config.mk`, `config_test.mk`, every `*.lua` module and
filter, `template.htm`, `tests/check_unittest.lua`, `tests/lint_html.lua`,
`tests/unittest.tex`, the pagefind and SVG generation interfaces, caching and
incremental behaviour, and the deploy staging logic, including a read-only look
at the constrained deploy bridge
(`tools/supervisor-scripts/supervisor_tool/symmetricfunctions_deploy.py`).
Out of scope: the mathematical `.tex` corpus.  Corpus files were only grepped,
to measure how many real pages a pipeline defect affects.

Environment: GNU Make 4.3, pandoc 3.1.3, Lua 5.4.6 with system `dkjson`, jq,
node/npx (resolves pagefind 1.5.2), UTC timezone in Docker.

What was run:

* I read every in-scope file in full.
* Reproductions ran the real `preprocess.lua` → `pandoc --lua-filter=gather.lua`
  → `render.lua` chain on small probe files in the session scratchpad.  They
  read the existing `temp/*.json` metadata; nothing in `temp/` or `www/` was
  written.  The probe harness is `scratchpad/audit/run.sh`.
* `merge_meta.lua` and `bibtex_extract.lua` were run twice, with every output
  path redirected to the scratchpad, to test determinism.
* Make was inspected only with dry runs (`make -n`, `make -n -W <file>`).
  I ran no build, check, or deploy, and changed no pipeline source or
  generated output.
* Six read-only HTTP GETs to production: the status of `unittest.htm`,
  `topicsindex.htm` and `goto.htm`, the title of `unittest.htm`, `robots.txt`,
  and `gammaPositivity.htm` to confirm D2.

Classification used below:

* **Confirmed defect**: reproduced, or directly observable in current output.
  "Live" means it is visible in the current `www/` and/or on production.
  "Latent" means it is reproduced on a probe but no current page triggers it.
* **Hardening**: a real risk or fragility with no observed wrong output yet.
* **QoL**: optional improvements to speed, ergonomics, or maintainability.

## Ranked summary

| #   | Class      | Sev    | Conf | Title |
|-----|------------|--------|------|-------|
| D1  | Defect (live)   | High   | High | `make check` puts `unittest.htm` into the deploy tree; it is public and in the search index |
| D2  | Defect (live)   | High   | High | `\name` initials slice bytes and keep raw TeX: 22 visibly broken names (5 U+FFFD, 17 raw TeX), 38 TeX tooltips |
| D3  | Defect (live)   | Medium | High | Math-punctuation rewrite moves `:` into math (51 sites), which gives relation spacing |
| D4  | Defect (latent) | Medium | High | `\url` → `\href` rewrite crashes on `%` and mangles `~ # _ &` |
| D5  | Defect (latent) | Medium | High | `\cite` inside ``…'' fails the build as "hyperref to unknown label" (Quoted double walk) |
| D6  | Defect (latent) | Medium | High | `\&` in a tabular cell splits the column and drops the ampersand |
| D7  | Defect (latent) | Medium | High | TOC text drops `\emph`/`\name`/link words and is not HTML-escaped |
| D8  | Defect (latent) | Medium | High | Image `alt`/`title` are HTML-escaped twice |
| D9  | Defect          | Medium | High | `make svg` exits 0 when TeX compilation or SVG conversion fails |
| D10 | Defect          | Medium | High | SVG staleness ignores `svg-tex/lib` and shared macros; `make` cannot pass `--force` |
| D11 | Defect (live)   | Medium | High | Stale pagefind index files accumulate locally, in Dropbox, and on production |
| D12 | Defect (live)   | Medium | High | The eprint→url `sed` duplicates `url` in 1,035 entries; which URL wins depends on field order |
| D13 | Defect (live)   | Low–Med| High | Citation labels: byte-sliced prefixes (29 entries) and no a/b disambiguation (47 collisions on 32 pages) |
| D14 | Defect (latent) | Low–Med| High | Multi-key `\cite[loc]{A,B}` loses the locator; the prefix and `\citeauthor` semantics are lost silently |
| D15 | Defect (latent) | Low    | High | `preprocess.lua` rewrites inside verbatim and renames any `{proof}` group |
| D16 | Defect          | Low    | High | Missing and wrong Make prerequisites (`file_reading.lua`; merge depends on BibTeX JSON instead of CSL JSON) |
| D17 | Defect (latent) | Low    | High | Output-directory configuration is only partly honoured (`config_test.mk` overrides, hard-coded `temp/`) |
| D18 | Defect (live)   | Low    | High | JSON outputs are byte-nondeterministic (key order), and the relation page is re-dated daily |
| D19 | Defect (live)   | Low    | High | JSON-LD `SearchAction` points to a 404 (`topicsindex.htm`) |
| D20 | Defect (latent) | Low    | High | Bare `\none` in `\ytableaushort` is split into letters |
| D21 | Defect          | Low    | High | Small error-path bugs (placeholder name dropped; polydata load failure swallowed) |
| D22 | Defect (latent) | Medium | High | Corrupt required JSON can render an `Untitled` page and exit successfully |
| D23 | Defect          | Medium | High | Deleted sources/assets survive locally, in search, and remotely; `.created` is deployed |
| H1  | Hardening | High   | —    | Deploy is not tied to a verified build of HEAD; no file allowlist or pruning |
| H2  | Hardening | Medium | —    | Unpinned tools (`npx pagefind`, pandoc, dkjson); `Q=1` hides pagefind errors |
| H3  | Hardening | Medium | —    | No build lock for a multi-agent checkout; merge outputs written non-atomically |
| H4  | Hardening | Medium | —    | 148 MB of generated output is synced by Dropbox |
| H5  | Hardening | Medium | —    | Math emitted unescaped, relying on an incomplete `\lt{}` preprocessor rewrite |
| H6  | Hardening | Low–Med| —    | Silent content loss in fragment parsing and `\cite*` suppression; pandoc API drift |
| H7  | Hardening | Low–Med| —    | Label, filename and JS-literal assumptions are not validated |
| H8  | Hardening | Low    | —    | Lint and unittest coverage gaps (the live D2 would have been caught) |
| H9  | Hardening | Low    | —    | `tex_to_svg.lua` shell quoting, absolute host path, environment-dependent SVG bytes |
| Q1–Q9 | QoL     | Low    | —    | Incremental rebuilds, dates, cache busting, dead code, docs (see the end of this file) |

---

## A. Confirmed defects

### D1 — The unit-test page is written into the deploy tree, published, and indexed

* **Severity:** High (a public artefact, and it persists).  **Confidence:** High.
* **Where:** `config_test.mk:6` sets `WWW_DIR = www`.  `config_test.mk:23` then
  builds `TEST_HTML := www/unittest.htm`.  `Makefile:141-146` renders it
  there, and `Makefile:162,180` make `check` depend on it.  Deploy copies all
  of `www/` with no exclusion (`Makefile:197-200`; bridge
  `symmetricfunctions_deploy.py:130-139`).  Pagefind indexes `www/**/*.htm`
  (`Makefile:191,193`).
* **Evidence:**
  * `www/unittest.htm` exists, dated 2026-09-25.
  * `curl https://www.symmetricfunctions.com/unittest.htm` returns HTTP 200
    with title `Unittest | SymCat`.
  * The pagefind entry reports `page_count: 146`, which is the 144 sources plus
    `unittest.htm` plus `polynomial-relations.htm`, so the fixture is
    searchable.
  * `robots.txt` allows all crawlers.
  * rsync has no `--delete`, so the page stays live even after the local
    output directory is fixed.
* **Impact:** Every `make check` that precedes a deploy re-publishes a
  synthetic fixture page.  Its fake polynomial family, fake relations and test
  prose show up in site search and to crawlers.
* **Fix:**
  1. Render test HTML into `$(TEST_WWW_DIR)` (`temp/test-www/unittest.htm`).
     Set `TEST_HTML := $(patsubst $(TEST_DIR)/%.tex,$(TEST_WWW_DIR)/%.htm,…)`,
     make the test render rule write there, and update the default path at
     `tests/check_unittest.lua:21`.
  2. Add a guard to `lint-html` (and to the bridge, see H1) that fails when
     `www/` holds an `.htm` file outside the expected set: the sources plus
     `goto`, `search`, and `polynomial-relations`.
  3. Removing the live `unittest.htm` needs an explicitly authorized remote
     deletion.  This is a user decision; I did not do it.
* **Regression test:** After `make check`, assert `test ! -e www/unittest.htm`.
  Add a lint check that compares `www/*.htm` with the expected basename set.

### D2 — `\name{…}` renders broken initials and raw TeX (live)

* **Severity:** High (visible on production pages).  **Confidence:** High.
* **Where:** `gather.lua:502-571`.
  * The argument is used as a raw string with no TeX parsing (`:516`).
  * Initials come from `name_part:sub(1, 1)` (`:547`, `:552`), which slices
    bytes, not codepoints.
  * The Scholar query is not URL-encoded (`:562`).
* **Evidence:**
  * Probe: `\name{Élie Cartan}` renders as `�. Cartan`.
  * Live: `curl …/gammaPositivity.htm` contains `>�. Gal<` for
    `\name{Świętosław Gal}`.
  * In the current `www/`, 5 author links contain U+FFFD, from
    `gammaPositivity`, `plethysm` (×3) and `tableauOperators`.
  * 38 author links carry TeX source in their tooltip, and 17 of them also in
    the visible text, for example `N. Gonz{\'a}lez` (crystals),
    `O. A. Agust{\'i}n-Aquino` (cspMisc) and `{. T{\'e}treault` (plethysm).
    These 17 are disjoint from the 5 U+FFFD cases.
* **Impact:** Visible mojibake and TeX on public pages.  Scholar search links
  contain undecoded TeX.  The lint and unit test do not catch it (H8).
* **Fix:**
  1. Convert the argument to Unicode text first:
     `pandoc.utils.stringify(pandoc.read(arg, "latex"))`.  This turns
     `{\'a}` into `á` and `{\l}` into `ł`.
  2. Take initials by codepoint, e.g. `part:match("^[%z\1-\127\194-\244][\128-\191]*")`,
     after skipping leading braces and punctuation.
  3. Apply the same conversion to the optional short form and to the tooltip.
  4. Percent-encode the query.
* **Regression test:** Add to `tests/unittest.tex`:
  `\name{Świętosław Gal}`, `\name{Nicolle Gonz{\'a}lez}`,
  `\name{{\'E}tienne T{\'e}treault}`, `\name{Marcel-Paul Schützenberger}`.
  Assert the rendered texts `Ś. Gal`, `N. González`, `É. Tétreault`,
  `M.-P. Schützenberger`.  Add lint checks for U+FFFD and for `{\` in text
  outside math.

### D3 — `$x$:` is rewritten to `$x:$` (live typographic defect)

* **Severity:** Medium.  **Confidence:** High.
* **Where:** `preprocess.lua:671-684`.  The punctuation class is `[%.,:]`.
* **Evidence:**
  * The corpus has 50 inline-math occurrences followed by `:`, plus 1 `\):`.
  * `www/cspMatch.htm` contains `Y_{n,k}:\)`.
  * In TeX and KaTeX, `:` is a relation, so an ord–rel pair gets a thick
    space: the output reads "Y_{n,k} :".  Moving `.` and `,` is harmless
    (ord and punct atoms).
  * The same rewrite also runs inside verbatim blocks (D15).
* **Impact:** Spurious space before colons in 50+ places.  This is the
  well-known reason `\colon` exists.
* **Fix:** Drop `:` from both patterns (keep `.` and `,`).  Apply the rewrite
  only outside verbatim and code.
* **Regression test:** A preprocess golden test (see H8): `$f$: x` must stay
  byte-identical; `$f$.` becomes `$f.$`.

### D4 — `\url{…}` rewrite crashes on `%` and mangles `~ # _ &`

* **Severity:** Medium (latent, but percent-encoded URLs are common and the
  error is misleading).  **Confidence:** High.
* **Where:** `preprocess.lua:645-653`.  The display text is emitted as the
  *LaTeX-parsed* second argument of `\href`.
* **Evidence:**
  * `\url{https://example.com/a%20b}` makes gather fail with pandoc exit 64,
    `unexpected {`, at a line/column in `.pre.tex` that does not correspond to
    the source.
  * `\url{https://example.com/~user/a_b#frag}` renders the visible text
    `example.com/ user/a_b#frag`, because `~` became a no-break space.
  * The same URL passed through `\href{…}{x}` works, because pandoc treats the
    URL argument verbatim.
  * There are currently 0 corpus occurrences.
* **Fix:** Stop rewriting `\url` in the preprocessor.  Pandoc already parses
  `\url` verbatim into a `Link` whose text equals its target.  Normalize the
  scheme and trim the display text in `gather.Link()` when the link text
  equals the URL (an autolink).  If the rewrite stays, emit the display text as
  `\nolinkurl{…}` or escape `% # _ & ~ $ ^ { }`.
* **Regression test:** Add `\url{https://example.com/~u/a_b%20c#f}` to the
  unit test.  Assert `href="https://example.com/~u/a_b%20c#f"` and visible
  text `example.com/~u/a_b%20c#f`.

### D5 — `\cite` inside ``…'' breaks the build (Quoted double walk)

* **Severity:** Medium.  **Confidence:** High.
* **Where:** `gather.lua:783-787`.  In pandoc's default typewise traversal,
  children are filtered before parents (bottom-up).  `Quoted()` then re-walks
  the already-filtered children with the full filter.  `Link()`
  (`gather.lua:817-823`) therefore runs a second time on the cite links built
  by `Cite()` and adds class `hyperref`.  `render.lua:190-199` then treats
  them as cross-page references.
* **Evidence:**
  * Probe ``see \cite{Ferroni2026Unimodality}''.  Render exits 1 with
    `[ERROR] hyperref to unknown label 'Ferroni2026Unimodality' (text: Fer26)`
    and no source location.
  * Probe ``\href{https://example.com}{ex}'' renders `class="href href"`.
* **Fix:** Delete the `Quoted` handler; the children are already processed.
  Also make `Link()` idempotent: skip links that already carry
  `cite`/`hyperref`/`href`/`oeis`, and never add a class twice.
* **Regression test:** Put ``see \cite{Cauchy1815}'' in the unit test.
  Assert that the render succeeds, the link has `class="cite"` without
  `hyperref`, and no `class` attribute contains a repeated token.

### D6 — `\&` inside a tabular cell splits the column

* **Severity:** Medium.  **Confidence:** High.
* **Where:** `gather.lua:279-294` splits on every `&` at brace depth 0.  The
  later splitter in `figure_to_html.lua:103` does check the preceding
  backslash, but by then the cell has already been split and re-rendered.
* **Evidence:** A two-column probe tabular with the row `A \& B & C` renders a
  3-column grid with cells `A`, `B`, `C`; the ampersand is gone and every row
  is shifted.
* **Fix:** Skip `&` when it is preceded by an odd number of backslashes, and
  when it is inside `$…$`, `\(...\)`, or a nested environment.  Better, reuse
  one tokenizer for both passes.
* **Regression test:** A unit-test tabular with `A \& B & C`.  Assert
  `grid-template-columns: repeat(2, auto)` and a visible `A &amp; B`.

### D7 — TOC entries lose inline markup and are not escaped

* **Severity:** Medium (latent: no current heading uses markup).
  **Confidence:** High.
* **Where:** `render.lua:456-465` keeps only `Str`, `Space` and `Math`.
  `render.lua:608` inserts the text and `id` without `html_escape`.
* **Evidence:** The probe heading
  `\subsection{The \emph{key} and \name{Alain Lascoux} \& co polynomials}`
  produces the TOC entry `The  and  & co polynomials`: two words are missing
  and the `&` is raw.
* **Fix:** Build TOC text recursively: `Emph`, `Strong`, `Span`, `Link`
  (text only), `Quoted`, `Code`, `SoftBreak` → space.  Escape it and the
  `id`.  Or reuse `render_inlines_html` with links unwrapped.
* **Regression test:** A unit-test subsection with `\emph`, `\name` and `\&`.
  Assert the exact TOC `<li>`.

### D8 — Image `alt` and `title` are double-escaped

* **Severity:** Medium (latent).  **Confidence:** High.
* **Where:** `render.lua:227` renders the caption to *HTML*.
  `render.lua:249-254` then `html_escape`s that HTML again.
* **Evidence:** `\svgimg{svg-images/logo.svg}{Young's lattice}` produces
  `alt="Young&amp;#39;s lattice"`.  Screen readers read "Young ampersand
  hash 39 s".  No current alt text contains `' & < > "`.
* **Fix:** Use `pandoc.utils.stringify`-equivalent plain text for `alt` and
  `title`, and escape it once.
* **Regression test:** Assert `alt="Young&#39;s lattice"` in the unit HTML.
  Lint for `&amp;#` and `&amp;amp;`.

### D9 — `make svg` never fails

* **Severity:** Medium.  **Confidence:** High.
* **Where:**
  * `tex_to_svg.lua:325-328` and `:334-337` call `print_error` and then
    `return`.
  * `:347-351` and `:367-371` report conversion failures only as warnings.
  * The script ends with `print_info("Done.")` (`:404`) and exits 0.
* **Impact:**
  * `make svg Q=1` reports success when a figure failed to compile.  The
    stale tracked SVG is kept and can be committed as "regenerated".
    HANDOFF entries repeatedly list `make svg Q=1` as a passing check.
  * The pdflatex log is discarded (`> /dev/null 2>&1`) and the failed
    `temp/svg-tex/*.log` is not mentioned.
* **Fix:** Track failures.  End with `os.exit(utils.has_errors() and 1 or 0)`.
  Treat conversion failures as errors.  On compile failure, print the path of
  the pdflatex log and its last ~20 lines.
* **Regression test:** Allow `SVG_SRC_DIR` and `SVG_TEMP_DIR` environment
  overrides.  Run the script on a scratch directory with a deliberately broken
  `.tex` file and expect a nonzero exit.

### D10 — SVG incremental rebuild ignores shared libraries

* **Severity:** Medium.  **Confidence:** High.
* **Where:**
  * `tex_to_svg.lua:126-143` compares only the source `.tex` mtime with the
    SVG mtime.
  * `TEXINPUTS` includes `svg-tex/lib` and
    `/home/paxinum/Dropbox/latex/tikz-macros` (`:61-63`), which are not
    dependencies.
  * `--force` exists (`:44-49`), but `make svg` cannot pass it
    (`Makefile:155-158`).
* **Evidence:** `svg-tex/lib/growth-diagrams.tex` holds reusable primitives
  (HANDOFF 2026-09-17).  Editing it and running `make svg` leaves every
  dependent figure stale and prints "Skipping (up to date)".
* **Fix:**
  * Compare against max(mtime(source), mtime(every file in `svg-tex/lib`),
    optionally the shared macros directory).  Better, record the pdflatex
    `-recorder` `.fls` inputs per figure and use those.
  * Add `make svg FORCE=1` → `lua tex_to_svg.lua --force`.
* **Regression test:** In a scratch copy, touch a lib file and assert that the
  dry-run/plan output lists the dependent source.

### D11 — Stale pagefind files accumulate (local, Dropbox, production)

* **Severity:** Medium.  **Confidence:** High.
* **Where:** `Makefile:188-194` never cleans `www/_pagefind`.  Deploy and the
  bridge never delete remote files.
* **Evidence:**
  * `www/_pagefind` is 98 MB.
  * It holds 119 `pagefind.en_*.pf_meta` files, but `pagefind-entry.json`
    references only `en_407528ea6b`.
  * All 2,639 `index/` chunks predate the current entry file.
  * There are 317 fragments for 146 pages, dated 2026-09-09 through
    2026-09-28.
* **Impact:** Unbounded growth.  Each deploy uploads new hashed files and
  never removes old ones.  Dropbox syncs all of it (H4).
* **Fix:** `rm -rf $(WWW_DIR)/_pagefind` before indexing, or index into
  `$(TEMP_DIR)/_pagefind.new` and swap it in atomically.  For production, add
  a scoped prune (for example a second rsync of `_pagefind/` with
  `--delete-after`).  Leave the top-level no-delete policy unchanged.
* **Regression test:** After two consecutive builds, assert that exactly one
  `pf_meta` file exists and that every chunk is referenced by, or newer than,
  the entry file.

### D12 — eprint→url `sed` creates duplicate `url` fields

* **Severity:** Medium.  **Confidence:** High.
* **Where:** `Makefile:52`.
* **Evidence:**
  * 1,035 BibTeX entries have both `eprint` and `url`; in 208 the values
    differ.
  * After the `sed`, each such entry has two `url` fields, and which one wins
    depends on field order, with no warning:
    * `ChapuyDolega2022`: the DOI URL is replaced by the arXiv URL.
    * `FeiginMakedonskyi2015`: the `http://arxiv.org/pdf/….pdf` URL is kept,
      so `find_arxiv_id` (`bibhandler.lua:215-218`, which matches `/abs/`
      only) cannot recover the id.
  * The regex also matches any field name *ending* in `eprint` (a future
    `preprint = {…}` would become `prurl`).  It ignores `eprinttype` and
    `archivePrefix` (33 entries set `archiveprefix={arXiv}`).
* **Impact:** Order-dependent link targets.  It is masked when a DOI exists
  (DOI wins, `bibhandler.lua:238-241`) and wrong otherwise.  The venue shows
  `arXiv e-prints` instead of `arXiv:<id>` for `/pdf/` URLs.
* **Fix:**
  * Do not rewrite the `.bib` text.  After CSL conversion, post-process in
    Lua using the already-parsed raw entries (`bibtex_extract.lua`):
    * if an entry has `eprint` and no `url`, set `URL`;
    * if it has both, keep `URL` and store `arxiv = <id>` for
      `find_arxiv_id`.
  * Anchor any remaining regex to the start of a field (`^\s*eprint\s*=`).
  * Accept `/pdf/<id>(\.pdf)?` in `find_arxiv_id`.
* **Regression test:** Two fixture entries, `url+eprint` and `eprint` only.
  Assert `URL` and the displayed `arXiv:<id>` for both.

### D13 — Citation labels: byte slicing and no disambiguation

* **Severity:** Low–Medium.  **Confidence:** High.
* **Where:** `bibhandler.lua:152-160` (`name:sub(1, 3)` is byte-based) and
  `:145-181`, which has no collision handling.
* **Evidence** (computed with the real `bibhandler.lua` on
  `temp/bibliography.json`):
  * 29 single-author entries get two-letter labels: `Bóna→Bo03`,
    `Brändén→Br04/Br06/Br08/Br15`, `Sjöstrand→Sj07`.
  * 32 pages contain 47 pairs of *different* works with the *same* visible
    label, for example:
    * `cspTableau`: `Rho10` = `Rhoades2010` and `Rhoades2010b`;
    * `chromaticEexpansion`: `CH19` = `ChoHong2019` and `ChoHuh2019`;
    * `crystals`: `MT25` = `MarbergTong2025Primed` and
      `MarbergTong2025SetValued`.
* **Fix:**
  * Fold to ASCII first, then take three codepoints.
  * Assign deterministic `a/b/c` suffixes to colliding labels, either
    site-wide in `bibhandler` at load time (sort colliding keys by year,
    title, key) or per page in `gather.Pandoc()`.  Site-wide is simpler and
    stable across pages.
* **Regression test:** Assert `get_bibliography_label("Bona2003") == "Bon03"`
  and `get_bibliography_label("Branden2006") == "Bra06"`, and that
  `Rhoades2010` and `Rhoades2010b` get distinct labels.

### D14 — Citation variants silently lose information

* **Severity:** Low–Medium (latent; 0 current uses).  **Confidence:** High.
* **Where:** `gather.lua:735-738` reads only `citations[1].suffix`, but pandoc
  attaches the locator to the *last* citation.  Prefixes and `mode` are
  ignored.
* **Evidence:**
  * `\cite[Thm.~3.1]{A,B}` renders as `[Fer26, Fer26]`; the locator is lost.
  * `\cite[see][p.~4]{A}` renders as `[p. 4, Fer26]`; "see" is lost.
  * `\citeauthor{A}` renders as `[Fer26]`.
* **Fix:** Use the prefix of the first citation and the suffix of the last.
  Raise an error (with location) for `AuthorInText` or `SuppressAuthor` modes
  until they are supported.
* **Regression test:** The three forms above in the unit test, with exact
  expected output or an expected build error.

### D15 — Preprocessor rewrites leak into verbatim and unrelated braces

* **Severity:** Low (latent; 7 pages use verbatim/lstlisting, none currently
  affected).  **Confidence:** High.
* **Where:**
  * All annotation passes (`preprocess.lua:59-333`) and global rewrites
    (`:629-684`) ignore verbatim and comments.  Only the angle-bracket pass
    (`:358-362`, `:470-479`) skips verbatim.
  * `:634-636` renames *every* `{proof}` brace group.
* **Evidence:** In the probe, `\hyperref[x]{proof}` becomes link text
  `symproof`.  Inside `\begin{verbatim}`, `\cite{Foo}` gained `@@path:line`,
  `$x$.` became `$x.$`, and `{proof}` became `{symproof}`.
* **Fix:** Mask verbatim, lstlisting, `\verb` and comment spans once, run all
  rewrites on the masked text, then restore.  Restrict renames to
  `\begin{…}` and `\end{…}`.
* **Regression test:** Golden-file preprocess tests (H8) with verbatim
  content and `\hyperref[…]{proof}`.

### D16 — Missing or wrong Make prerequisites

* **Severity:** Low.  **Confidence:** High.
* **Where:**
  * `config.mk:38`: `GATHER_DEPS` omits `file_reading.lua`, which gather loads
    through `bibhandler.lua:9`.
  * `Makefile:100`: the metadata rule depends on `$(BIBTEX_JSON)`, which
    `merge_meta.lua` never reads, and not on `$(REFS_JSON)`, which it reads
    via `bibhandler` (`merge_meta.lua:389`).  It is only covered indirectly
    through the JSON files.
  * `Makefile:165` (the unittest check) omits `file_reading.lua` and
    `utils.lua`.
* **Evidence:** `make -n -W file_reading.lua` plans 0 gathers and 144 renders.
  `-W utils.lua` plans 144 gathers.
* **Fix:** Add the missing files, and replace `BIBTEX_JSON` with `REFS_JSON`
  in the merge rule.  Long term, generate the Lua dependency lists from
  `dofile` calls (a 10-line script that emits `temp/lua-deps.mk`).
* **Regression test:** A `make deps-check` that greps `dofile("…")` edges and
  diffs them against `*_DEPS`.

### D17 — Output-directory configuration is only partly honoured

* **Severity:** Low (latent; it blocks H4).  **Confidence:** High.
* **Where:**
  * `config_test.mk:5-10,18` re-assign `TEMP_DIR`, `WWW_DIR`, `PANDOC`, `LUA`
    and `TEMPLATE` *after* `config.mk`.  The `:=` lists in `config.mk:44-58`
    keep the old values, while recursive recipe variables take the new ones.
  * `bibhandler.lua:24` hard-codes `./temp/bibliography.json`.
    `load_bibliography_json(path)` returns the cache regardless of `path`
    (`:390-393`).  `get_bibliography_label` passes no path (`:449`, `:459`).
  * `tex_to_svg.lua:34-41` hard-codes `temp/svg-tex`.
  * `relation_graph.lua:322` and `tests/check_unittest.lua:19-21` default to
    `temp/`.
* **Impact:** Setting `TEMP_DIR` or `WWW_DIR` in `config.mk` leaves a
  half-moved build.  Gather and merge keep reading `./temp/bibliography.json`
  (stale or missing).
* **Fix:**
  * Keep one definition of each directory and tool (delete the duplicates
    from `config_test.mk`).
  * Read `REFS_JSON` in `bibhandler`, and key the cache by path.
  * Derive every default from `TEMP_DIR` and `WWW_DIR`.
* **Regression test:** Run `make -pn | grep -E '^(TEMP_DIR|WWW_DIR) '`, and a
  scratch build with `TEMP_DIR=$(mktemp -d)` that must not touch `./temp`.

### D18 — Nondeterministic generated bytes

* **Severity:** Low.  **Confidence:** High.
* **Where:**
  * `file_reading.lua:205-209`: dkjson encodes in `pairs()` order.
  * `relation_graph.lua:334`: `LASTMOD` is the current day.
* **Evidence:**
  * Two identical `merge_meta.lua` runs to scratch produce `site-labels.json`
    (public), `site-polydata.json` and `polynomial-relations.json/.htm` that
    differ byte-for-byte but are equal under `jq -S`.
  * Two `bibtex_extract.lua` runs give different MD5 sums.
  * `goto.htm` and `sitemap.xml` are stable, because they are sorted.
* **Impact:** Noisy diffs, churn in rsync, Dropbox and caches, and no
  reproducible-build check is possible.
* **Fix:** Encode with sorted keys (dkjson accepts
  `{ keyorder = sorted_keys }`, or add a small recursive sorted encoder).
  Date the relation page from its inputs (max source mtime or git time).
* **Regression test:** Run merge twice into scratch and `cmp` all outputs.

### D19 — JSON-LD SearchAction targets a 404

* **Severity:** Low.  **Confidence:** High.
* **Where:** `template.htm:51` (`topicsindex.htm?q=`).  Production returns
  HTTP 404.  `assets/search.htm` and `site.js` do not read a `q` parameter.
* **Fix:** Point it at `search.htm?q={search_term_string}` and teach
  `search.htm` to pre-fill from `?q=`, or remove the `potentialAction`.
* **Regression test:** A lint check that every same-site URL in JSON-LD
  resolves to a file in `www/`.

### D20 — Bare `\none` in `\ytableaushort`

* **Severity:** Low (latent; the corpus uses the braced `{\none}` form).
  **Confidence:** High.
* **Where:** `figure_to_html.lua:135-159` tokenizes per character outside
  braces.
* **Evidence:** `\ytableaushort{\none 12, 3}` renders cells `$\$ $n$ $o$ $n$ $e$ $1$ $2$`.
* **Fix:** Read `\[A-Za-z]+` control words as a single token.
* **Regression test:** A unit case asserting 3 cells in row 1 with the first
  marked `cell-none`.

### D21 — Small error-path bugs

* **Severity:** Low.  **Confidence:** High.
* `render.lua:666`:
  `print_error("Unknown placeholder in template: ", name)` has no `%s`, so the
  name is never printed.
* `render.lua:546-551`: `load_json_file` is non-strict and returns `{}` on
  failure, so `if polydata` is always true.  A missing or corrupt
  `site-polydata.json` renders an empty "Symmetric functions" table after
  only a `[WARN]`.  Use `strict=true`.
* `bibhandler.lua:138-141`: `strip_nocase_spans` has no effect.  Pandoc 3.1.3
  csljson emits no `nocase` spans (0 of 2,527 items), though 141 titles use
  `{{…}}` protection.  If a future pandoc emits them again, nested spans would
  be half-stripped and then escaped into visible text.  Pin the behaviour with
  a test, or remove the function.
* **Regression test:** Unit checks for each function.

### D22 — Required JSON inputs fail open

* **Severity:** Medium (latent, but especially relevant after an interrupted
  build).  **Confidence:** High.
* **Where:** `render.lua:44` loads the site-label map without strict mode, and
  `render.lua:686` does the same for the primary Pandoc document.
  `file_reading.lua:133-140` therefore turns a missing or malformed required
  input into `{}` after only a warning.
* **Evidence:** The host supervisor invoked `render.lua` with the repository
  `Makefile` as its input JSON while retaining the normal metadata and
  template paths.  It printed
  `Could not decode json pandoc document: no valid JSON value ...`, rendered
  an `Untitled` document to stdout, and exited 0.  D21 records the analogous
  fail-open polydata load.
* **Impact:** A truncated or corrupt intermediate can be converted into a
  successful-looking blank page.  This defeats `.DELETE_ON_ERROR` and any
  deploy gate that trusts only command exit status.
* **Fix:** Load the Pandoc document, site labels, and polydata with
  `strict=true`; treat every required-input warning as fatal.  Keep
  non-strict mode only for genuinely optional inputs.
* **Regression test:** Feed `render.lua` malformed JSON and a malformed
  labels file in separate cases.  Both must exit nonzero and must not emit
  an HTML document.

### D23 — Deletions are not propagated, and a Make sentinel is deployable

* **Severity:** Medium.  **Confidence:** High.
* **Where:** Source/output lists are positive wildcards computed at parse time
  (`config.mk:43-46`); there is no rule that removes outputs whose source has
  disappeared.  `copy-assets` only overlays files (`Makefile:149-151`),
  Pagefind scans every remaining `www/**/*.htm` (`Makefile:188-194`), and
  deploy rsync has no `--delete` (`Makefile:197-200`).  The directory stamp is
  itself `www/.created` (`Makefile:42-44`), inside that deploy tree.
* **Evidence:** By Make semantics, deleting or renaming a source removes it
  from `TEX_FILES`/`JSON_FILES`/`HTML_FILES` but creates no newer prerequisite
  and no removal recipe, so its old JSON and HTML survive.  Deleted assets
  likewise survive the overlay copy.  A dry-run of the exact rsync source
  includes `>f+++++++++ .created`; the remote no-delete policy also preserves
  every previously published orphan.
* **Impact:** Removed pages and assets can remain public and searchable, and
  stale metadata can retain labels from deleted pages until a clean build.
  The empty build sentinel is also eligible for publication.
* **Fix:** Generate an expected-output manifest and prune only files not in
  that manifest before Pagefind.  Move the directory stamp under `temp/` (or
  explicitly exclude it).  Keep top-level remote deletion gated, but add a
  constrained manifest-based prune or release-directory swap to the deploy
  bridge.
* **Regression test:** In a scratch checkout, build a temporary page and
  asset, then delete their sources and rebuild.  Their JSON, HTML, copied
  asset, search record, and manifest entries must disappear; the deploy dry
  run must not contain `.created`.

---

## B. Hardening

### H1 — Tie deploys to a verified build (High)

* **Observed:**
  * `deploy` depends only on `copy-assets` (`Makefile:198`).
  * `ship` runs `clean → all → deploy` without `check` (`Makefile:204-207`).
  * The bridge verifies a clean checkout and the expected HEAD
    (`symmetricfunctions_deploy.py:215-230`), but `www/` is gitignored.
    Nothing proves that `www/` was built from that HEAD, passed `make check`,
    or contains only expected files (D1, D11).
* **Proposal:**
  * Make `all` or `check` write `temp/build-manifest.json` containing the
    commit, a dirty flag, tool versions, the time, a `check: passed` flag, and
    a sorted list of `www/` files with SHA-256 hashes.
  * The Makefile `deploy` and the bridge (a separate project, so this is a
    suggestion there) refuse to run when the manifest commit ≠ HEAD, the
    check has not passed, or `www/` does not match the manifest.
  * Make `ship` run `check`.
* **Test:** Build, change HEAD (an empty commit), and assert that deploy
  refuses.

### H2 — Pin and surface external tools (Medium)

* `npx pagefind` (`Makefile:191,193`) fetches whatever version is current at
  build time; 1.5.2 today.  `search.htm` depends on its UI API.  Pin it with
  `npx --yes pagefind@1.5.2`, or a `package.json` and lockfile outside
  Dropbox.
* Add `make doctor`, which checks:
  * the `pandoc --version` major.minor that has been validated (3.1);
  * `lua -e 'require"dkjson"'` (an undocumented hard dependency of every
    non-pandoc Lua step);
  * `jq`, and `pdflatex`/`pdfinfo`/`dvisvgm|pdftocairo` for the SVG step.
* List all of these in `README.md:68`.
* `Makefile:191` sends pagefind stdout *and stderr* to `/dev/null` under
  `Q=1`, so a failure shows only `Error 1`.  Capture the output to
  `temp/pagefind.log` and print its tail on failure.

### H3 — Concurrency and atomicity (Medium)

* Several agents share this checkout (HANDOFF history).  There is no lock, so
  two `make` runs race on `temp/*.json`, the grouped metadata outputs, and
  `www/`.  Wrap the top-level targets in `flock temp/.build.lock`.  An
  `.NOTPARALLEL`-safe re-exec pattern is enough.
* `merge_meta.lua:78-96` says "atomically" but opens the final path directly.
  An interrupted merge leaves truncated JSON, which `render.lua:44` loads
  non-strictly.  Write `path .. ".tmp"`, then `os.rename`.
* `tex_to_svg.lua:317-318` shares one `temp/svg-tex` directory across runs.
  Use a per-run directory.

### H4 — Generated output is synced by Dropbox (Medium)

* `www/` (112 MB) and `temp/` (36 MB) sit in the Dropbox-synced checkout, and
  neither carries the `com.dropbox.ignored` attribute.  The only xattr is
  `user.com.dropbox.attrs`.  Every build (and D11's growth) is re-uploaded.
* The workspace guide asks for generated artefacts to live outside Dropbox.
* Once D17 is fixed, default `TEMP_DIR` and `WWW_DIR` to a Docker volume or
  cache path.  Whether to mark the existing directories as ignored is a user
  decision.

### H5 — Escape math bodies instead of preprocessing `<` (Medium)

* `render.lua:371-380` emits `Math` bodies unescaped.
* Safety depends on `preprocess.lua:339-356`, which rewrites `<`/`>` only in a
  fixed list of environments.  The probe shows `\begin{alignat*}{2} a &< b`
  is *not* rewritten; `eqnarray`, `split`, `Bmatrix`, `CD` and macro-expanded
  `<` are likewise missed.
* The current output has 0 raw-`<` math spans, so this is latent.
* KaTeX auto-render reads decoded text nodes, so `html_escape(body)` is safe
  (`&amp;` → `&`) and would make the rewrite unnecessary.  Update
  `tests/check_unittest.lua:83` to match.

### H6 — Silent content loss and pandoc API drift (Low–Medium)

* `gather.lua:108-115` (`parse_inlines_walk`) returns `{}` when the fragment
  does not start with a `Para`, and drops every block after the first.  This
  affects `\defin`, `\enquote`, `\filelink`, theorem titles and cells.  Warn
  (with location) when `#blocks ~= 1`.
* `gather.lua:922-926` turns any raw `\cite…` into `Str("")`.  Returning
  `nil` is enough: `Cite()` discards its children, and an unrecognized
  standalone variant would then surface as `TEX still present` in render.
* `gather.lua:672-678` reads topic-card titles and descriptions with plain
  `latex` and no filter, so `\name`, `\cite` and custom macros vanish.
* `pandoc.walk_block`/`walk_inline` (`gather.lua:103,113,784`) have been
  deprecated since pandoc 2.17; use `:walk(filter)`.
* `render.lua` supports a fixed set of AST types.  `Figure`, `Table`, `Note`,
  `SmallCaps`, `Underline`, `Superscript`, `Subscript` and `DefinitionList`
  produce generic "Unhandled … type" errors with no location.  At least name
  the construct and page.
* Empty Lua tables round-trip as `MetaMap {}` (for example
  `"citations":{"t":"MetaMap","c":{}}`) and as JSON `[]`.  Consumers tolerate
  this by accident.  Use `pandoc.MetaList{}` explicitly.

### H7 — Unvalidated labels, filenames and JS literals (Low–Medium)

* `merge_meta.lua:670` interpolates labels and hrefs into a JS object literal
  in `goto.htm` without escaping.
* `gather.lua:70-72` and every `@@` pattern accept only filenames matching
  `[%w._/-]`.  Any other character leaks `@@…` into citation keys and anchors.
* All 2,207 current labels match `^[A-Za-z0-9_:.-]+$`.  Enforce that in
  `merge_meta` (error on violation), enforce the source-filename charset in
  the Makefile, and emit goto data with `json_encode`.

### H8 — Test and lint gaps (Low; high leverage)

* `lint-html` scans only `$(HTML_FILES)`.  It misses `goto.htm`,
  `polynomial-relations.htm`, `search.htm` and stray files (D1).
* Missing checks, each of which would have caught a defect above:
  * U+FFFD (D2);
  * `{\` or `\&#39;` in visible text (D2);
  * `&amp;#` or `&amp;amp;` (D8);
  * duplicate class tokens (D5);
  * raw `<` inside `\(…\)` (H5);
  * more than one `pf_meta` file (D11).
* No preprocess-level tests exist.  Add
  `tests/preprocess/*.tex` + `*.expected` golden pairs, run with
  `lua preprocess.lua x.tex < x.tex | diff - x.expected`.  Cover verbatim,
  `{proof}`, `$x$:`, `\url`, and `\cite` annotation.
* `make check` always prints two expected `[WARN]` lines from the fixtures,
  which trains readers to ignore warnings.  Assert the expected warnings in
  `check_unittest.lua` instead (capture stderr).
* A determinism test is missing (D18).

### H9 — `tex_to_svg.lua` robustness (Low)

* Paths go unquoted into `cp`, `mv`, `pdfinfo` and `dvisvgm`
  (`tex_to_svg.lua:149,199-216,317-318`).
* It relies on `$PWD` (`:55-59`), and `/home/paxinum/Dropbox/latex/tikz-macros`
  is hard-coded (`:62`).
* The `pdftocairo` fallback produces bytes that depend on the environment, so
  tracked SVGs change depending on where they were built.
* Named figures map to PDF pages by order (`:343-347`); an unnamed or extra
  page shifts every later name.  Verify that the page count equals
  `#figure_names` and fail otherwise.
* SVGs whose `\tikzsetnextfilename` was removed are never pruned.

---

## C. Optional quality-of-life

* **Q1 — Incremental work.**
  * `merge_meta.lua` rewrites all eight outputs on every run.  Every page
    depends on `site-labels.json` and `site-polydata.json` (`Makefile:121`),
    so one edit re-renders all 144 pages: 146 `www/*.htm` files share the
    same minute as `site-labels.json`.
  * Writing only when content changes is enough; GNU Make re-stats targets.
    Render is cheap (about 0.02–0.16 s per page), so the bigger saving is that
    `search` and `copy-assets` are phony and run pagefind on every `make`.
  * Any `bibliography.bib` edit re-runs all 144 pandoc gathers
    (`Makefile:84`).
* **Q2 — `make FILE=…` semantics.** AGENTS.md says it "uses stale metadata",
  but `meta` depends on every JSON file and `all` still runs the site-wide
  merge and pagefind.  Add a true fast path, `make page FILE=x.tex`
  (preprocess, gather and render against the existing metadata, no pagefind),
  or correct the docs.
* **Q3 — Dates.**
  * Page dates come from filesystem mtime (`Makefile:118-119`) formatted in
    *local* time (`render.lua:635`); the sitemap and relation page use UTC.
  * A git checkout or Dropbox restore resets mtimes, and every sitemap
    `<lastmod>` is the build day (`merge_meta.lua:603-616`).
  * Use `git log -1 --format=%ct -- file`, cached per commit, with UTC `!%Y-%m-%d`.
* **Q4 — Cache busting.**
  * `tex-init.js` has no version query (`template.htm:102`), although KaTeX
    macros change often (HANDOFF 2026-09-17), so visitors can run stale
    macros against new pages.
  * `style.css`, `site.js` and `relation-graph.js` use hand-maintained `?v=`
    strings.  Generate content hashes in `copy-assets`.
* **Q5 — Published debug attributes.** 2,412 `data-source-loc="tex-source/…:N"`
  attributes are published.  Every inserted line changes all later
  attributes, which churns diffs and uploads.  Strip them in production
  builds, or keep them behind `DEBUG=1`.
* **Q6 — Search hygiene.** `403.htm`, `404.htm` (and today `unittest.htm`)
  carry `data-pagefind-body` through the template and are indexed.  Exclude
  them.
* **Q7 — Dead code and duplication.**
  * Dead: `families` is never populated, so `synthesize_meta` is dead
    (`gather.lua:52,1166-1220`); `has_north`/`has_west` are unused
    (`figure_to_html.lua:191-194`); the legacy table-target branches are
    unused; `test.htm` at the repo root is unreferenced (last touched in
    `fc47438`); `parse_name` is a global.
  * Duplicated: `relation_refs`, `attr_is_false`, `relation_is_visible`,
    `format_iso_date`, `render_template` and `family_href`, each in two or
    three modules.
  * Each `dofile` of `bibhandler` has its own cache, so the bibliography can
    be decoded more than once per process.
* **Q8 — Preprocess diagnostics.** `preprocess.lua:604-611` prints
  `WARNING:` without a filename, in a non-standard format, and the line
  numbers are counted *after* the `\specialblock`/`\ytableaushort` newline
  insertion (`:509-527`).  Use `utils.print_warn("%s:%d …")` with original
  line numbers.
* **Q9 — Docs drift.**
  * AGENTS.md documents `\svgimg[width=0.8]{…}`, but the parser requires
    `width=<num>\textwidth` (`gather.lua:598`).  The documented form is
    silently ignored (`width:auto`); all corpus uses include `\textwidth`.
    Accept bare numbers, or fail on unparsed options.
  * "Pandoc runs with `--fail-if-warnings` — any warning stops the build" is
    true only for pandoc's own warnings.  Lua `[WARN]` messages never fail the
    build.

---

## Suggested order of work

1. **D1 + H1 guard:** move test output out of `www/` and add the stray-file
   lint.  The live-file removal needs an explicit authorized deploy decision.
2. **D2 + the H8 lint rules:** fixes the 22 visibly broken author names and
   38 TeX tooltips on production.
3. **D3, D5, D6, D4:** small, localized fixes, each with a unit case.
4. **D9, D10, D11, D16:** build-system correctness.
5. **D12, D13:** bibliography correctness; check the resulting diff of labels
   and URLs site-wide before shipping.
6. H2–H5, then QoL items as time permits.

## Reproduction appendix

All commands were run from the repository root and write only to the session
scratchpad (`$S`).  The probe helper `run NAME <<'EOF' … EOF` wraps a body in
`\metatitle`, `\metadescription` and a labelled `\section`, then runs:

```
lua preprocess.lua $S/NAME.tex < $S/NAME.tex > $S/NAME.pre.tex
pandoc $S/NAME.pre.tex --from=latex+raw_tex --to=json --lua-filter=gather.lua --fail-if-warnings -o $S/NAME.json
SOURCE_TS=0 lua render.lua $S/NAME.json > $S/NAME.htm
```

Other checks:

* Determinism: run `merge_meta.lua` twice with `LABELS_JSON`, `POLYDATA_JSON`,
  `TODOS_JSON`, `SITEMAP_XML`, `WWW_DIR` and `RELATION_GRAPH_*` pointed at
  scratch, then `cmp` the outputs and compare `jq -S`.
* Dependencies: `make -n -W file_reading.lua all` and `make -n -W utils.lua all`.
* Live checks: `curl -s -o /dev/null -w '%{http_code}'` on
  `https://www.symmetricfunctions.com/{unittest,topicsindex,goto}.htm`, and a
  `grep 'Gal<'` on the live `gammaPositivity.htm`.
