SHELL := /bin/bash
.SHELLFLAGS := -eu -o pipefail -c

# === LOAD CONFIGURATION ===
include config.mk
include config-test.mk

.PHONY: all gather meta bib render copy-assets clean unittest
.DELETE_ON_ERROR:
.SECONDARY: $(PRE_TEX)

# Default target
all: gather meta render copy-assets

# === CREATE BUILD DIRECTORIES ===
$(TEMP_DIR) $(WWW_DIR):
	@mkdir -p $@

# === 1) PREPROCESS: tex → pre.tex ===
# OPTIMIZATION: Run in parallel with make -j
$(TEMP_DIR)/%.pre.tex: $(SRC_DIR)/%.tex $(PREPROC_LUA) | $(TEMP_DIR)
	@echo "Preprocessing $< → $@"
	@$(LUA) $(PREPROC_LUA) "$<" < "$<" > "$@"

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
	@$(PANDOC) "$<" --from=latex+raw_tex --to=json \
		--lua-filter=$(GATHER_LUA) --fail-if-warnings -o "$@"

# Test file preprocessing
$(TEST_PRE): $(TEMP_DIR)/%.pre.tex: $(TEST_DIR)/%.tex $(PREPROC_LUA) | $(TEMP_DIR)
	@echo "Preprocessing $< → $@"
	@$(LUA) $(PREPROC_LUA) < "$<" > "$@"

# Test file gathering
$(TEST_JSON): $(TEMP_DIR)/%.json: $(TEMP_DIR)/%.pre.tex $(GATHER_LUA) $(REFS_JSON)
	@echo "Gathering $< → $@"
	@$(PANDOC) "$<" --from=latex+raw_tex --to=json \
		--lua-filter=$(GATHER_LUA) --fail-if-warnings -o "$@"

# === BIBLIOGRAPHY ===
.PHONY: bib
bib: $(REFS_JSON)

$(REFS_JSON): $(BIBFILE) | $(TEMP_DIR)
	@echo "Generating $@"
	@$(PANDOC) -f biblatex -t csljson $< --fail-if-warnings -o $@.tmp && mv $@.tmp $@

# === 3) METADATA: Generate site-wide metadata ===
.PHONY: meta
meta: $(LABELS_JSON) $(POLYDATA_JSON) $(SITEMAP_XML)

# Separate stamp file so we can skip metadata when building single files
$(TEMP_DIR)/site-meta.stamp: $(JSON_FILES) $(MERGE_META_LUA) | $(TEMP_DIR) $(WWW_DIR)
	@echo "Generating site metadata ..."
	@$(LUA) $(MERGE_META_LUA) $(JSON_FILES)
	@touch $@

$(LABELS_JSON) $(POLYDATA_JSON) $(SITEMAP_XML): $(TEMP_DIR)/site-meta.stamp

# === 4) RENDER: Generate HTML ===
FILE ?=

.PHONY: render
ifeq ($(strip $(FILE)),)
# Full build: require site metadata
render: $(LABELS_JSON) $(WWW_DIR) $(HTML_FILES) $(TEMPLATE)
	@echo "Rendered ALL → $(WWW_DIR)/*.htm"
else
# Single file build - use stale metadata if available
render: $(WWW_DIR) $(TEMPLATE) $(WWW_DIR)/$(basename $(FILE)).htm
	@echo "Rendered $(SRC_DIR)/$(basename $(FILE)).tex → $(WWW_DIR)/$(basename $(FILE)).htm"
endif

# Cache source timestamps in a file instead of calling stat every time
$(TEMP_DIR)/%.timestamp: $(SRC_DIR)/%.tex | $(TEMP_DIR)
	@stat -c '%Y' "$<" > "$@"

# OPTIMIZATION 6: Depend on timestamp file, read it instead of calling stat
$(WWW_DIR)/%.htm: $(TEMP_DIR)/%.json $(TEMP_DIR)/%.timestamp $(RENDER_LUA) $(TEMPLATE) $(REFS_JSON) $(LABELS_JSON) | $(WWW_DIR)
	@echo "Rendering $< → $@"
	@SOURCE_TS=$$(cat $(TEMP_DIR)/$*.timestamp) \
		$(LUA) $(RENDER_LUA) "$<" > "$@"

# Test file rendering (without metadata dependencies)
$(TEST_HTML): $(WWW_DIR)/%.htm: $(TEMP_DIR)/%.json $(RENDER_LUA) $(TEMPLATE) $(REFS_JSON) | $(WWW_DIR)
	@echo "Rendering test $< → $@"
	@SOURCE_TS=$$(stat -c '%Y' "$(TEST_DIR)/$*.tex") \
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
	@rm -rf $(TEMP_DIR) $(WWW_DIR)

# === PHONY TARGETS FOR PARALLEL BUILDS ===
# These ensure make -j works correctly
.NOTPARALLEL: $(TEMP_DIR)/site-meta.stamp

