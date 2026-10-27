# CONTRIBUTING

The goal of this project is to maintain a clean and accessible catalog of
symmetric functions, written in LaTeX and converted to static HTML.

## Where to edit

Most mathematical content and metadata live in `tex-source/*.tex`, one file
per page; for ordinary content changes, start there. Bibliography entries live
in `bibliography.bib`, and TikZ sources for card and figure SVGs in
`svg-tex/src/`, with shared local definitions in `svg-tex/lib/`.

See [`README.md`](../README.md) for the build commands, pipeline and directory
layout, and [`CONVENTIONS.md`](../CONVENTIONS.md) for page and metadata
conventions (including `polydata` blocks), the content editing checklist and
code conventions.

## Do not commit generated build files

`www/`, `temp/` and LaTeX auxiliary files are generated and ignored by
`.gitignore`. Generated SVG assets under `assets/` are committed when their
TikZ sources change.

## Tests

Run `make unittest` after Lua, metadata, reference or rendering changes, and
`make check` before larger content or build-system commits. Test HTML is
isolated under `temp/test-www/` and must never be copied into `www/`. Stale
deployable pages are reported, not deleted; removing a page or asset is a
deliberate manual step.

## Code contributions

If you want to improve or fix the build system:

* Lua scripts live in the project root (`*.lua`)
* Keep code minimal and dependency-free
* Document non-obvious behavior with short comments

## Filing issues

Feel free to open an issue on GitHub for:

* Incorrect content
* Missing families or topics
* Suggestions for improvements

## Style philosophy

* Keep `.tex` files readable and close to mathematical writing.
* Avoid complicated LaTeX packages.
* Prefer precise citations and small examples over broad unsourced summaries.
