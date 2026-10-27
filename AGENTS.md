# AGENTS.md

## Project overview

This is the source for [symmetricfunctions.com](https://symmetricfunctions.com),
a reference site for algebraic combinatorics. Each page is a `.tex` file in
`tex-source/` compiled through a custom Lua+Pandoc pipeline into static HTML.

Read `README.md` for the build commands, pipeline, directory layout, key Lua
files, prerequisites and the `site-keywords.json` schema. This file holds only
the additional rules for agents and editors.

## TeX file conventions

Every `.tex` file starts with:
```tex
\metatitle{Page Title}
\metadescription{Brief description for SEO}
```

### Sections and labels

All sections must have a label in brackets:
`\section[labelId]{Display Title}`. Labels use **camelCase** (e.g.,
`stanleyMonotonicity`, `ehrhartMacdonaldReciprocity`). Kebab-case labels exist
in some older files (e.g., `parking-functions`) but camelCase is preferred.

### Key macros

| Macro | Purpose |
|-------|---------|
| `\defin{term}` | Mark a term being defined (renders styled) |
| `\name{Full Name}` | Mathematician name (auto-links to Google Scholar) |
| `\cite{Key}` | Bibliography citation (looks up in bibliography.bib) |
| `\hyperref[label]{text}` | Cross-page link (resolves via site-labels.json) |
| `\todo{message}` | Note for future work (excluded from HTML output, printed to stderr during build) |
| `\icon{name}` | Inline SVG icon |
| `\svgimg[width=0.8]{path}{alt}` | Scaled SVG image |

### Environments

Standard theorem-like environments: `definition`, `theorem`, `proposition`,
`lemma`, `conjecture`, `remark`, `example`, `proof`, and `proof*`
(unnumbered).

### Computed examples

When adding computed examples, tables, or expansion data, prefer backing them
with checked code in the main Rust workspace when practical.  For
quasisymmetric-function material, use:

```text
/home/paxinum/Dropbox/AI-projects/rust/sym-poly/qsym
```

Good breadcrumbs are durable notes in this `AGENTS.md`, the Rust crate
`README.md`, and named Rust examples/tests.  TeX comments such as
`% Related Rust:` are optional and should stay short; they are useful
navigation aids, not the primary record.

### Polynomial family metadata

```tex
\begin{polydata}{id}
  Name    & Display name \\
  Symbol  & $\schurS_\lambda$ \\
  Year    & 1900 \\
  PositiveIn  & schur | SomeBibKey \\
  Contains    & otherFamily \\
  Generalizes & schur \\
  Generalizes & hallLittlewoodP | SomeBibKey \\
  ...
\end{polydata}
```

Relation targets are other `polydata` ids. Preferred relation rows use:

```tex
RelationKey & target | BibKey[,BibKey...] | attr=value; attr=value \\
```

The older forms `target | BibKey` and `target [BibKey]` are still supported.
Multiple relation rows with the same key are allowed. Multiple targets can also
be separated by semicolons, but rows with attributes should use one target per
row.

### Content editing checklist

- Ignore content inside `\todo{...}` during prose, citation, and name cleanup.
- Replace raw arXiv or journal `\href{...}` links with `\cite{key}` when the
  source is already in `bibliography.bib`. Do not invent citation keys.
- Wrap plain-text mathematician names in `\name{...}` outside citations and
  theorem labels.
- Use `\defin{...}` or `\hyperref[label]{...}` for important technical terms
  when it improves navigation or clarity.
- Math is rendered client-side by KaTeX 0.16 with the macros in
  `assets/tex-init.js`. Brace macro scripts (`V^{\imath}`, not `V^\imath`):
  KaTeX defines some symbols as argument-taking macros that cannot be
  unbraced super- or subscripts.

## Code conventions

- Naming: kebab-case for HTML/CSS; snake_case for Lua variables.
- Lua modules use the `M` export pattern and `(result, error)` tuples for
  error handling.
- Add or edit card and figure images through `svg-tex/src/*.tex`, then run
  `make svg`. Do not hand-edit generated SVGs unless there is a deliberate
  one-off fix.

## Bibliography

References go in `bibliography.bib` in BibLaTeX format; cite them with
`\cite{Key}` or `\cite[Thm.~3.1]{Key}`. Entries can be obtained from the
arXiv-id or DOI API, for example:
https://arxiv.symmetricfunctions.com/api/bibtex.json?id=2001.00092
https://arxiv.symmetricfunctions.com/api/bibtex.json?doi=10.1002/jgt.22704

## Build changes

- Keep `www/site-keywords.json` distinct from the `site-labels.json` anchor
  catalogue, and include it in grouped metadata targets and test outputs when
  changing the build.
- Both metadata merge rules require CSL JSON, raw BibTeX JSON and the
  template, including isolated test builds.

## Error handling

- `make Q=1` suppresses all progress/info/todo messages; only `[ERROR]` and
  `[WARN]` print
- Normal `make` shows progress, todos, and warnings in color
- Pandoc runs with `--fail-if-warnings` — any warning stops the build
- Missing cross-reference labels print `[ERROR] hyperref to unknown label`
- Missing citations print `[ERROR] Citation not found`
- Malformed required page, label or polynomial JSON fails rendering.
- SVG setup, compilation, PDF inspection and conversion failures return
  nonzero, preventing `make svg` from copying assets after a failed run.
- `make check` includes Python 3 standard-library backend regressions, with
  SVG tools mocked and fresh/incremental metadata builds in temporary trees.
  These cover malformed required JSON, SVG failure propagation and synthetic
  bibliographies; no test invokes a TeX compiler or writes SVG assets.
  It also performs a read-only allowlist audit of deployable `.htm` files.
- Run `make all` after broad page edits and `make unittest` after Lua or
  pipeline changes.
- Bibliography lookup honors `REFS_JSON` and `BIBTEX_JSON`, including builds
  with a separate `TEMP_DIR`.
- The search target replaces only `www/_pagefind` immediately before indexing;
  it does not prune any other local or remote output.

## Deployment

Deploy only when explicitly authorized. From Docker, use the constrained host
bridge after a clean verified build:

```bash
/workspace/supervisor-tool symmetricfunctions-deploy status
/workspace/supervisor-tool symmetricfunctions-deploy run --json
```

Check status first.  The bridge pins the source and production destination,
deploys only the existing `www/` tree, and does not build, commit, push, or
expose the host SSH key.

## Common tasks

**Adding a new page**: Create `tex-source/newpage.tex` with `\metatitle` and
`\metadescription`. Add a `\topiccard{newpage}{Title}{Description}` to
`tex-source/index.tex`. Add or update the matching card source in
`svg-tex/src/` and run `make svg`; the generated card SVG belongs in
`assets/nav-images/`.

**Adding a reference**: Add a BibLaTeX entry to `bibliography.bib`, then use
`\cite{Key}` in `.tex` files.

**Cross-linking**: Use `\hyperref[label]{link text}` where `label` is any
section label on any page. The build resolves these across all pages.

**Renaming a label**: Grep for the old label across all `.tex` files to update
any `\hyperref` references.
