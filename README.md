# README


This project is a static site generator that converts LaTeX source files into HTML pages. 
It uses `pandoc` for conversion, custom Lua filters for processing, and `make` for orchestrating the build pipeline.

Several functions are specialized for www.symmetricfunctions.com,
such as index of polynomials, Young tableau rendering etc.

AI tools have been extensively used to generate and refactor the code.

## Directory structure
```
.
├── assets/              # Static assets (CSS, images, JS)
├── docs/                # Documentation (.md)
├── tex-source/          # LaTeX source files (.tex)
├── test/                # Test files for validation
├── temp/                # Intermediate build files (generated)
│   ├── *.pre.tex        # Preprocessed LaTeX files
│   ├── *.json           # Pandoc JSON AST files
│   ├── *.timestamp      # Source file modification times
│   ├── bibliography.json   # Bibliography data
│   ├── site-labels.json    # Cross-reference labels
│   ├── site-polydata.json  # Collected metadata
│   └── site-meta.stamp     # Metadata generation marker
├── www/                 # Output directory (generated)
│   ├── *.htm            # Generated HTML files
│   └── sitemap.xml      # Site sitemap
├── README.md            # This file
├── config.mk            # Build configuration
├── config-test.mk       # Test configuration
├── Makefile             # Build orchestration
├── template.htm         # HTML template
├── preprocess.lua       # LaTeX preprocessor
├── families_to_html.lua # Module for generating index
├── gather.lua           # Metadata gathering filter
├── merge_meta.lua       # Site-wide metadata merger
├── render.lua           # HTML renderer
├── bibhandler.lua       # Bibliography handler
├── figure_to_html.lua   # LaTeX → HTML converter
├── file_reading.lua     # File I/O utilities
└── utils.lua            # Utility functions
```

## Build Process

### Full Build
Run `make all` to build the entire site. This executes the following pipeline:

```bash
make all              # Build everything
make -j8 all          # Build with 8 parallel jobs (faster)
make -j all           # Build with unlimited parallelism
```

### Build Steps

The build process consists of six stages:

#### 1. **Bibliography** (`make bib`)
- **Input:** `references.bib` (or configured `.bib` file)
- **Output:** `temp/bibliography.json`
- **Tool:** Pandoc
- **Description:** Converts BibLaTeX bibliography to JSON format for citation processing

```bash
pandoc -f biblatex -t csljson references.bib -o temp/bibliography.json
```

#### 2. **Preprocess** (automatic)
- **Input:** `tex-source/*.tex`
- **Output:** `temp/*.pre.tex`
- **Tool:** `preprocess.lua`
- **Description:** Prepares LaTeX files for Pandoc by:
  - Resolving custom macros
  - Handling special environments
  - Normalizing LaTeX syntax

```bash
lua preprocess.lua tex-source/example.tex > temp/example.pre.tex
```

#### 3. **Gather** (`make gather`)
- **Input:** `temp/*.pre.tex`
- **Output:** `temp/*.json`
- **Tool:** Pandoc + `gather.lua` filter
- **Description:** Converts preprocessed LaTeX to Pandoc's JSON AST format and extracts metadata (labels, citations, todos)

```bash
pandoc temp/example.pre.tex \
    --from=latex+raw_tex --to=json \
    --lua-filter=gather.lua \
    -o temp/example.json
```

**Parallel execution:** Each `.tex` file is processed independently in parallel.

#### 4. **Metadata** (`make meta`)
- **Input:** `temp/*.json`
- **Output:** 
  - `temp/site-labels.json` - Cross-reference labels for internal links
  - `temp/site-polydata.json` - Aggregated site metadata
  - `www/sitemap.xml` - XML sitemap for search engines
- **Tool:** `merge_meta.lua`
- **Description:** Merges metadata from all JSON files to create site-wide indexes

```bash
lua merge_meta.lua temp/*.json
```

**Synchronization barrier:** This step runs serially after all gathering is complete.

#### 5. **Render** (`make render`)
- **Input:** `temp/*.json`, `template.htm`, metadata files
- **Output:** `www/*.htm`
- **Tool:** `render.lua`
- **Description:** Converts Pandoc JSON to final HTML using:
  - Template substitution
  - Cross-reference resolution
  - Bibliography generation
  - Table of contents creation
  - LaTeX table conversion

```bash
SOURCE_TS=$(stat -c '%Y' tex-source/example.tex) \
lua render.lua temp/example.json > www/example.htm
```

**Parallel execution:** Each HTML file is rendered independently in parallel.

#### 6. **Copy Assets** (`make copy-assets`)
- **Input:** `assets/*`
- **Output:** `www/*`
- **Description:** Copies static assets (CSS, JavaScript, images) to output directory

```bash
cp -r assets/* www/
```

### Single File Build
To build only one file (useful during development):

```bash
make FILE=example.tex gather    # Only gather this file
make FILE=example.tex render    # Only render this file
```

This uses stale metadata from previous full builds, so cross-references may be outdated.

### Testing
Run unit tests on test files:

```bash
make unittest
```

This processes files in `test/` directory through the full pipeline without requiring metadata.

### Cleaning
Remove all generated files:

```bash
make clean
```

This deletes `temp/` and `www/` directories.

## Dependencies

### Required Tools
- **Lua 5.3+** - Scripting language for build tools
- **Pandoc 2.x+** - Document converter
- **GNU Make 4.x+** - Build orchestration
- **bash** - Shell for Make recipes

### Tools for .svg generation
- **pdflatex** - For compiling latex to .pdf
- **dvisvgm** - Converting .pdf to .svg
- **pdfinfo** - To count pages in a .pdf file


### Lua Modules
All Lua dependencies are included in the repository:
- `bibhandler.lua` - Bibliography processing
- `figure_to_html.lua` - LaTeX figure conversion
- `families_to_html.lua` - Creates index of all families of polynomials
- `file_reading.lua` - File I/O utilities
- `utils.lua` - Common utilities

## Configuration

Edit `config.mk` to customize:
- `ASSETS_DIR` - Web page assets (default: `assets`)
- `SRC_DIR` - Source directory (default: `tex-source`)
- `TEMP_DIR` - Temporary files (default: `temp`)
- `WWW_DIR` - Output directory (default: `www`)
- `TEMPLATE` - HTML template file (default: `template.htm`)
- `BIBFILE` - Bibliography file (default: `references.bib`)

