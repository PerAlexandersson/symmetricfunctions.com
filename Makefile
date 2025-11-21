SHELL := /bin/bash
.ONESHELL:
.SHELLFLAGS := -eu -o pipefail -c

# === LOAD CONFIGURATION ===
include config.mk
include config-test.mk

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
	$(LUA) $(PREPROC_LUA) "$<" < "$<" > "$@"


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


# Test file preprocessing
$(TEST_PRE): $(TEMP_DIR)/%.pre.tex: $(TEST_DIR)/%.tex $(PREPROC_LUA) | $(TEMP_DIR)
	@echo "Preprocessing $< → $@"
	$(LUA) $(PREPROC_LUA) < "$<" > "$@"

# Test file gathering
$(TEST_JSON): $(TEMP_DIR)/%.json: $(TEMP_DIR)/%.pre.tex $(GATHER_LUA) $(REFS_JSON)
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
FILE ?=
.PHONY: render
ifeq ($(strip $(FILE)),)
render: $(LABELS_JSON) $(WWW_DIR) $(HTML_FILES) $(TEMPLATE)
	@echo "Rendered ALL → $(WWW_DIR)/*.htm"
else
# When rendering a single file, avoid depending on site-wide metadata
# which would force generation of all JSON files. Only depend on the
# template and the single output target; the output target itself will
# depend on the corresponding per-file JSON.
render: $(WWW_DIR) $(TEMPLATE) $(WWW_DIR)/$(basename $(FILE)).htm
	@rm -f $(WWW_DIR)/$(basename $(FILE)).htm
	@$(MAKE) $(WWW_DIR)/$(basename $(FILE)).htm
	@echo "Rendered $(SRC_DIR)/$(basename $(FILE)).tex → $(WWW_DIR)/$(basename $(FILE)).htm"
endif


$(WWW_DIR)/%.htm: $(TEMP_DIR)/%.json $(RENDER_LUA) $(TEMPLATE) $(REFS_JSON) $(LABELS_JSON) | $(WWW_DIR)
	@echo "Rendering $< → $@"
	SOURCE_TS=$$(stat -c '%Y' "$(SRC_DIR)/$*.tex") \
	$(LUA) $(RENDER_LUA) "$<" > "$@"


# Test file rendering (without metadata dependencies)
$(TEST_HTML): $(WWW_DIR)/%.htm: $(TEMP_DIR)/%.json $(RENDER_LUA) $(TEMPLATE) $(REFS_JSON) | $(WWW_DIR)
	@echo "Rendering test $< → $@"
	SOURCE_TS=$$(stat -c '%Y' "$(TEST_DIR)/$*.tex") \
	$(LUA) $(RENDER_LUA) "$<" > "$@"



# === COPY ASSETS ===
.PHONY: copy-assets
copy-assets:
	@cp -r $(ASSETS_DIR)/* $(WWW_DIR)/

# === UNITTEST ===
.PHONY: unittest
unittest: $(TEMP_DIR) $(WWW_DIR) $(TEST_HTML)
	@echo "Unittest pipeline finished — processed $(words $(TEST_TEX)) test file(s)"

# === CLEAN ===
.PHONY: clean
clean:
	@rm -f $(TEMP_DIR)/*.json $(TEMP_DIR)/*.pre.tex $(WWW_DIR)/*.htm
