SHELL := /bin/bash
.ONESHELL:
.SHELLFLAGS := -eu -o pipefail -c

# === DIRECTORIES ===
SRC_DIR    = tex-source
TEST_DIR   = tests
TEMP_DIR   = temp
WWW_DIR    = www
ASSETS_DIR = assets

# === TOOLS ===
PANDOC = pandoc
LUA    = lua

# === SCRIPTS ===
PREPROC_LUA    = preprocess.lua
GATHER_LUA     = gather.lua
RENDER_LUA     = render.lua
MERGE_META_LUA = merge_meta.lua

# === SOURCE FILES ===
TEMPLATE   := template.htm
BIBFILE    := ~/Dropbox/latex/bibliography.bib
TEX_FILES  := $(wildcard $(SRC_DIR)/*.tex)
PRE_TEX    := $(patsubst $(SRC_DIR)/%.tex,$(TEMP_DIR)/%.pre.tex,$(TEX_FILES))
JSON_FILES := $(patsubst $(SRC_DIR)/%.tex,$(TEMP_DIR)/%.json,$(TEX_FILES))
HTML_FILES := $(patsubst $(SRC_DIR)/%.tex,$(WWW_DIR)/%.htm,$(TEX_FILES))

# === GENERATED OUTPUTS ===
REFS_JSON     := $(TEMP_DIR)/bibliography.json
LABELS_JSON   := $(TEMP_DIR)/site-labels.json
POLYDATA_JSON := $(TEMP_DIR)/site-polydata.json
SITEMAP_XML   := $(WWW_DIR)/sitemap.xml

# === UNITTEST ===
UNIT_SRC   := $(TEST_DIR)/unittest.tex
UNIT_PRE   := $(TEMP_DIR)/unittest.pre.tex
UNIT_JSON  := $(TEMP_DIR)/unittest.json
UNIT_HTML  := $(WWW_DIR)/unittest.htm

# === EXPORTS FOR SCRIPTS ===
export SRC_DIR TEMP_DIR WWW_DIR
export TEMPLATE REFS_JSON LABELS_JSON POLYDATA_JSON SITEMAP_XML

.PHONY: all gather meta bib render copy-assets clean unittest
.DELETE_ON_ERROR:
.SECONDARY: $(PRE_TEX)

all: gather meta render copy-assets

# === CREATE BUILD DIRECTORIES ===
$(TEMP_DIR) $(WWW_DIR):
	@mkdir -p $@

# === 1) PREPROCESS: tex → pre.tex ===

$(TEMP_DIR)/%.pre.tex: $(SRC_DIR)/%.tex $(PREPROC_LUA) | $(TEMP_DIR)
	@echo "Preprocessing $< → $@"
	$(LUA) $(PREPROC_LUA) < "$<" > "$@"

# === 2) GATHER: Collect metadata to JSON ===
FILE ?=
.PHONY: gather
ifeq ($(strip $(FILE)),)
gather: $(TEMP_DIR) $(REFS_JSON) $(JSON_FILES)
	@echo "Gathered ALL → $(TEMP_DIR)/*.json"
else
gather: $(TEMP_DIR) $(REFS_JSON) $(TEMP_DIR)/$(basename $(FILE)).json
	@echo "Gathered $(FILE) → $(TEMP_DIR)/$(basename $(FILE)).json"
endif

$(TEMP_DIR)/%.json: $(TEMP_DIR)/%.pre.tex $(GATHER_LUA) $(REFS_JSON)
	@echo "Gathering $< → $@"
	$(PANDOC) "$<" --from=latex+raw_tex --to=json \
	  --lua-filter=$(GATHER_LUA) --fail-if-warnings -o - | jq -S . > "$@"


# === BIBLIOGRAPHY ===
.PHONY: bib
bib: $(REFS_JSON)

$(REFS_JSON): $(BIBFILE) | $(TEMP_DIR)
	@echo "Generating $@"
	$(PANDOC) -f biblatex -t csljson $< --fail-if-warnings -o $@.tmp && mv $@.tmp $@

# === 3) METADATA: Generate site-wide metadata ===
.PHONY: meta
meta: $(LABELS_JSON) $(POLYDATA_JSON) $(SITEMAP_XML)

# Run merge once and touch a stamp so downstream targets don't rerun it
$(TEMP_DIR)/site-meta.stamp: $(JSON_FILES) $(MERGE_META_LUA) | $(TEMP_DIR)
	@echo "Generating site metadata ..."
	$(LUA) $(MERGE_META_LUA) $(JSON_FILES)
	@touch $@

$(LABELS_JSON) $(POLYDATA_JSON) $(SITEMAP_XML): $(TEMP_DIR)/site-meta.stamp

# === 4) RENDER: Generate HTML ===
.PHONY: render
render: $(LABELS_JSON) $(WWW_DIR) $(HTML_FILES) $(TEMPLATE)

$(WWW_DIR)/%.htm: $(TEMP_DIR)/%.json $(RENDER_LUA) $(TEMPLATE) $(REFS_JSON) $(LABELS_JSON) | $(WWW_DIR)
	@echo "Rendering $< → $@"
	$(LUA) $(RENDER_LUA) "$<" > "$@"

# === COPY ASSETS ===
.PHONY: copy-assets
copy-assets:
	@cp -r $(ASSETS_DIR)/* $(WWW_DIR)/

# === UNITTEST ===
.PHONY: unittest
unittest: $(TEMP_DIR) $(WWW_DIR) $(REFS_JSON) $(UNIT_HTML)
	@echo "Unittest pipeline finished for $(UNIT_SRC)"

# === CLEAN ===
.PHONY: clean
clean:
	@rm -f $(TEMP_DIR)/*.json $(TEMP_DIR)/*.pre.tex $(WWW_DIR)/*.htm
