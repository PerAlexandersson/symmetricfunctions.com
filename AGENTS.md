# AGENTS.md

## Project overview

This is the source for [symmetricfunctions.com](https://symmetricfunctions.com),
a reference site for algebraic combinatorics. Each page is a `.tex` file in
`tex-source/` compiled through a custom Lua+Pandoc pipeline into static HTML.

Read `README.md` for the build commands, pipeline, directory layout, key Lua
files, prerequisites and the `site-keywords.json` schema, and
`CONVENTIONS.md` for page, metadata, bibliography and code conventions and
the content editing checklist. This file holds only the additional build,
test and deployment rules for agents.

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
