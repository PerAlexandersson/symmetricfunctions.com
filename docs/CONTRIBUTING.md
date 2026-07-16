# CONTRIBUTING

The goal of this project is to maintain a clean and accessible catalog of
symmetric functions, written in LaTeX and converted to static HTML.

## Where to edit

Most mathematical content and metadata live in:

```text
tex-source/*.tex
```

Each page is a separate `.tex` file. For ordinary content changes, start
there.

Bibliography entries live in `bibliography.bib`. TikZ source for card and
figure SVGs lives in `svg-tex/src/`, with shared local definitions in
`svg-tex/lib/`.

## Metadata in LaTeX

Metadata is encoded directly in `.tex` files using macros, for example:

```tex
\begin{polydata}{booleanProduct}
  Name   & Boolean product polynomials \\
  Space  & Sym \\
  Basis  & False \\
  Rating & 1 \\
  Bib    & BilleraBilleyTewari2018 \\
  Year   & 2018 \\
  Category & Other \\
\end{polydata}
```

The build system extracts this metadata automatically.

## Build system

Useful local commands:

```bash
make          # full build
make Q=1      # quiet full build
make bib      # rebuild displayed bibliography JSON and raw BibTeX JSON
make svg      # rebuild TikZ-sourced SVG assets
make unittest # run test pages through the pipeline
```

The default build runs the Lua/Pandoc pipeline and writes generated output into:

```text
temp/     intermediate build files
www/      final website output
```

These directories are not version-controlled.

`make bib` regenerates both `temp/bibliography.json` and
`temp/bibtex-entries.json`. The displayed references use the CSL-JSON file;
the inline BibTeX copy/download controls use the raw BibTeX JSON sidecar.

`make svg` compiles TikZ sources under `svg-tex/src/` and writes SVG assets
under `assets/nav-images/`, `assets/svg-images/`, and `assets/icons/`.

## Do not commit generated build files

The following should not be committed:

* `www/`
* `temp/`
* LaTeX auxiliary files (`*.aux`, `*.log`, `*.fls`, `*.fdb_latexmk`,
  `*.synctex.gz`)

These are ignored by `.gitignore`.

Generated SVG assets under `assets/` are committed when their TikZ sources
change. Do not hand-edit generated SVGs unless there is a deliberate one-off
fix that cannot sensibly live in TikZ.

## Tests

Small example inputs and comparisons can be placed in:

```text
tests/
```

Run `make unittest` after Lua, metadata, reference, or rendering changes. Run
`make all` before larger content or build-system commits.

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
