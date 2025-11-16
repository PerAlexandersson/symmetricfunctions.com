# -- sudo apt install lua
# -- sudo apt install lua-dkjson
# -- sudo apt install pandoc

# For making .json nicer
# -- sudo apt install jq



SHELL := /bin/bash
.ONESHELL:
.SHELLFLAGS := -eu -o pipefail -c

# Folders
SRC_DIR  = tex-source
TEMP_DIR = temp
WWW_DIR  = www

# Tools
PANDOC  = pandoc
LUA     = lua

# Scripts
PREPROC_LUA     = preprocess.lua
GATHER_LUA      = gather.lua
RENDER_LUA      = render.lua
MERGE_META_LUA  = merge_meta.lua

# Files
TEMPLATE    := template.htm
TEX_FILES   := $(wildcard $(SRC_DIR)/*.tex)
PRE_TEX     := $(patsubst $(SRC_DIR)/%.tex,$(TEMP_DIR)/%.pre.tex,$(TEX_FILES))
JSON_FILES  := $(patsubst $(SRC_DIR)/%.tex,$(TEMP_DIR)/%.json,$(TEX_FILES))
HTML_FILES  := $(patsubst $(SRC_DIR)/%.tex,$(WWW_DIR)/%.htm,$(TEX_FILES))
BIBFILE     := ~/Dropbox/latex/bibliography.bib
REFS_JSON   := $(TEMP_DIR)/bibliography.json

# Merge outputs
LABELS_JSON     = $(TEMP_DIR)/site-labels.json
POLYDATA_JSON   = $(TEMP_DIR)/site-polydata.json
TODOS_JSON      = $(TEMP_DIR)/site-todo.json
SITEMAP_XML     = $(WWW_DIR)/sitemap.xml


# Unittest single-file pipeline
UNIT_SRC   := $(SRC_DIR)/unittest.tex
UNIT_PRE   := $(TEMP_DIR)/unittest.pre.tex
UNIT_JSON  := $(TEMP_DIR)/unittest.json
UNIT_HTML  := $(WWW_DIR)/unittest.htm


export SRC_DIR TEMP_DIR WWW_DIR
export TEMPLATE REFS_JSON LABELS_JSON POLYDATA_JSON TODOS_JSON SITEMAP_XML


.PHONY: all gather meta bib render todo clean
.DELETE_ON_ERROR:
# Keep preprocessed files; don't let make auto-delete them as intermediates
.SECONDARY: $(PRE_TEX)

all: gather meta render

# Ensure build directories exist
$(TEMP_DIR) $(WWW_DIR):
	@mkdir -p $@

# --------------------------------------------------------------------
# 1) Preprocess: source/*.tex → temp/*.pre.tex
# --------------------------------------------------------------------

$(TEMP_DIR)/%.pre.tex: $(SRC_DIR)/%.tex $(PREPROC_LUA) | $(TEMP_DIR)
	@echo "Preprocessing $< → $@"
	$(LUA) $(PREPROC_LUA) < "$<" > "$@"


# --------------------------------------------------------------------
# 2) Gather: build JSON with the metadata gather filter
#    Use stem-specific prereqs instead of 'all pre files'
# --------------------------------------------------------------------


gather: $(TEMP_DIR) $(REFS_JSON) $(JSON_FILES)

$(TEMP_DIR)/%.json: $(TEMP_DIR)/%.pre.tex $(GATHER_LUA) $(REFS_JSON)
	@echo "Gathering $< → $@"
	$(PANDOC) "$<" --from=latex+raw_tex --to=json --lua-filter=$(GATHER_LUA) --fail-if-warnings -o - | jq -S . > "$@"

# Pandoc ≥ 2.11 (incl. 3.8): convert .bib → CSL-JSON
$(REFS_JSON): $(BIBFILE) | $(TEMP_DIR)
	@echo "Generating $@"
	$(PANDOC) -f biblatex -t csljson $< --fail-if-warnings -o $@.tmp && mv $@.tmp $@

.PHONY: bib
bib: $(REFS_JSON)


# --------------------------------------------------------------------
# 3) Generate all meta data
# --------------------------------------------------------------------

.PHONY: meta
meta: $(LABELS_JSON) $(POLYDATA_JSON) $(SITEMAP_XML)

# Run merge once and touch a stamp so downstream targets don’t rerun it
$(TEMP_DIR)/site-meta.stamp: $(JSON_FILES) $(MERGE_META_LUA) | $(TEMP_DIR)
	@echo "Generating site metadata ..."
	$(LUA) $(MERGE_META_LUA) $(JSON_FILES)
	@touch $@

# Each output depends on the stamp (created by one run)
$(LABELS_JSON) $(POLYDATA_JSON) $(SITEMAP_XML): $(TEMP_DIR)/site-meta.stamp


# --------------------------------------------------------------------
# 4) Render: www/*.htm
# --------------------------------------------------------------------
render: $(LABELS_JSON) $(WWW_DIR) $(HTML_FILES) $(TEMPLATE)

$(WWW_DIR)/%.htm: $(TEMP_DIR)/%.json $(RENDER_LUA) $(TEMPLATE) $(REFS_JSON) $(LABELS_JSON) | $(WWW_DIR)
	@echo "Rendering $< → $@"
	$(LUA) $(RENDER_LUA) "$<" > "$@"


.PHONY: unittest
unittest: $(TEMP_DIR) $(WWW_DIR) $(REFS_JSON) $(UNIT_HTML)
	@echo "Unittest pipeline finished for $(UNIT_SRC)"


# --------------------------------------------------------------------
# c) Clean
# --------------------------------------------------------------------
clean:
	@rm -f $(TEMP_DIR)/*.json $(TEMP_DIR)/*.pre.tex $(WWW_DIR)/*.htm
