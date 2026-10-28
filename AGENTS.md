# AGENTS.md

## Project overview

This is the source for [symmetricfunctions.com](https://symmetricfunctions.com),
a reference site for algebraic combinatorics. Each page is a `.tex` file in
`tex-source/` compiled through a custom Lua+Pandoc pipeline into static HTML.

Read `README.md` for the build commands, pipeline, directory layout, key Lua
files, prerequisites and the arXiv++ keyword feed, and
`CONVENTIONS.md` for page, metadata, bibliography and code conventions and
the content editing checklist. This file holds only the additional build,
test and deployment rules for agents.

## Git workflow

- Per prefers one active branch and normally one worker per repository.
  Work directly on `master` when ownership and the working tree permit it;
  do not create parallel branches without a practical need.
- If a temporary branch or worktree is needed, integrate completed, verified
  work promptly into `master`, then remove its local and repository-owned
  remote branch. This routine cleanup is authorized; do not leave completed
  parallel branches behind.
- Before cleanup, verify ancestry, remote state, and worktree ownership.
  Preserve unfinished, dirty, unpublished, or unmerged work. For selectively
  integrated branches, verify all intended changes are accounted for before
  removal; do not force-delete merely because a task is marked done.
- This does not authorize bypassing review/protection, force-pushing,
  deleting contributors' fork branches, or deploying.

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
- Content that would otherwise be lost is an error: unsupported TeX blocks or
  macros, sections without labels, multi-paragraph text where inline text is
  expected, unknown or repeated `polydata` fields, malformed relation rows,
  relations without a bibliography key, and duplicate element ids on a page.
- Malformed required page, label or polynomial JSON fails rendering.
- SVG setup, compilation, PDF inspection and conversion failures return
  nonzero, preventing `make svg` from copying assets after a failed run.
- `make check` includes Python 3 standard-library backend regressions, with
  SVG tools mocked and fresh/incremental metadata builds in temporary trees.
  These cover malformed required JSON, SVG failure propagation and synthetic
  bibliographies; no test invokes a TeX compiler or writes SVG assets.
  It also performs a read-only allowlist audit of deployable `.htm` files,
  checks every deployed page for duplicate ids and leaked build attributes,
  and checks that the public label and keyword feeds point at existing
  anchors. `tests/check_safeguards.lua` holds one case per safeguard above.
- The metadata merge runs from a stamp file and rewrites outputs only when
  their bytes change, so `make -n` lists renders that a real build skips.
- Run `make all` after broad page edits and `make unittest` after Lua or
  pipeline changes.
- Bibliography lookup honors `REFS_JSON` and `BIBTEX_JSON`, including builds
  with a separate `TEMP_DIR`.
- The search target builds the index beside the old one and replaces
  `www/_pagefind` only after Pagefind succeeds; it does not prune any other
  local or remote output.

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
