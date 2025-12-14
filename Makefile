SHELL := /bin/bash
.SHELLFLAGS := -eu -o pipefail -c

# Use 8 threads by default
MAKEFLAGS += -j8

# === LOAD CONFIGURATION ===
include config.mk
include config_test.mk

.PHONY: all gather meta bib render copy-assets clean unittest
.DELETE_ON_ERROR:
.SECONDARY: $(PRE_TEX)

# Supress file deletion messages
.SILENT:


# Default target
all: gather meta render copy-assets

# === CREATE BUILD DIRECTORIES ===
# Use stamp files to ensure directories are created exactly once
$(TEMP_DIR)/.created:
	@mkdir -p $(TEMP_DIR)
	@touch $@

$(WWW_DIR)/.created:
	@mkdir -p $(WWW_DIR)
	@touch $@

# === BIBLIOGRAPHY (must complete before gathering) ===
.PHONY: bib
bib: $(REFS_JSON)

$(REFS_JSON): $(BIBFILE) | $(TEMP_DIR)/.created
	@echo "Generating $@"
	@$(PANDOC) -f biblatex -t csljson $< --fail-if-warnings -o $@.tmp && mv $@.tmp $@

# === 1) PREPROCESS: tex → pre.tex ===
# Order-only dependency on directory ensures it exists without triggering rebuilds
$(TEMP_DIR)/%.pre.tex: $(SRC_DIR)/%.tex $(PREPROC_LUA) | $(TEMP_DIR)/.created
	@echo "Preprocessing $< → $@"
	@$(LUA) $(PREPROC_LUA) "$<" < "$<" > "$@"

# Test file preprocessing
$(TEST_PRE): $(TEMP_DIR)/%.pre.tex: $(TEST_DIR)/%.tex $(PREPROC_LUA) | $(TEMP_DIR)/.created
	@echo "Preprocessing $< → $@"
	@$(LUA) $(PREPROC_LUA) < "$<" > "$@"

# === 2) GATHER: Collect metadata to JSON ===
FILE ?=
.PHONY: gather
ifeq ($(strip $(FILE)),)
gather: $(JSON_FILES)
	@echo "Gathered ALL → $(TEMP_DIR)/*.json"
else
gather: $(TEMP_DIR)/$(basename $(FILE)).json
	@echo "Gathered $(FILE) → $(TEMP_DIR)/$(basename $(FILE)).json"
endif

# Here we use jq to format the json nicer
$(TEMP_DIR)/%.json: $(TEMP_DIR)/%.pre.tex $(GATHER_LUA) $(REFS_JSON)
	@echo "Gathering $< → $@"
	@$(PANDOC) "$<" --from=latex+raw_tex --to=json --lua-filter=$(GATHER_LUA) --fail-if-warnings | jq '.' > "$@"

# Test file gathering
$(TEST_JSON): $(TEMP_DIR)/%.json: $(TEMP_DIR)/%.pre.tex $(GATHER_LUA) $(REFS_JSON)
	@echo "Gathering $< → $@"
	@$(PANDOC) "$<" --from=latex+raw_tex --to=json \
	        --lua-filter=$(GATHER_LUA) --fail-if-warnings -o "$@"

# === METADATA: Generate site-wide metadata ===
.PHONY: meta
meta: $(LABELS_JSON)

# Synchronization barrier: All JSON files must be gathered before metadata generation
# The stamp file runs the merge script and produces all metadata outputs
$(TEMP_DIR)/site-meta.stamp: $(JSON_FILES) $(MERGE_META_LUA) | $(WWW_DIR)/.created
	@echo "Generating site metadata ..."
	@$(LUA) $(MERGE_META_LUA) $(JSON_FILES)
	@touch $@

# All metadata outputs depend on the stamp
# Recipe-less rule: if stamp is newer, outputs are already updated
$(LABELS_JSON) $(POLYDATA_JSON) $(SITEMAP_XML): $(TEMP_DIR)/site-meta.stamp
	@:

# === RENDER: Generate HTML ===
FILE ?=
.PHONY: render
ifeq ($(strip $(FILE)),)
# Full build: require site metadata
render: $(HTML_FILES)
	@echo "Rendered ALL → $(WWW_DIR)/*.htm"
else
# Single file build - use stale metadata if available
render: $(WWW_DIR)/$(basename $(FILE)).htm
	@echo "Rendered $(SRC_DIR)/$(basename $(FILE)).tex → $(WWW_DIR)/$(basename $(FILE)).htm"
endif

# Cache source timestamps
$(TEMP_DIR)/%.timestamp: $(SRC_DIR)/%.tex | $(TEMP_DIR)/.created
	@stat -c '%Y' "$<" > "$@"

$(WWW_DIR)/%.htm: $(TEMP_DIR)/%.json $(TEMP_DIR)/%.timestamp $(RENDER_LUA) $(TEMPLATE) $(REFS_JSON) $(LABELS_JSON) | $(WWW_DIR)/.created
	@echo "Rendering $< → $@"
	@SOURCE_TS=$$(cat $(TEMP_DIR)/$*.timestamp) \
	$(LUA) $(RENDER_LUA) "$<" > "$@"

# Test file rendering
$(TEST_HTML): $(WWW_DIR)/%.htm: $(TEMP_DIR)/%.json $(RENDER_LUA) $(TEMPLATE) $(REFS_JSON) | $(WWW_DIR)/.created
	@echo "Rendering test $< → $@"
	@SOURCE_TS=$$(stat -c '%Y' "$(TEST_DIR)/$*.tex") \
	$(LUA) $(RENDER_LUA) "$<" > "$@"

# === COPY ASSETS ===
.PHONY: copy-assets
copy-assets: | $(WWW_DIR)/.created
	@cp -r $(ASSETS_DIR)/* $(WWW_DIR)/

# === UNITTEST ===
.PHONY: unittest
unittest: $(TEST_HTML)
	@echo "Unittest pipeline finished — processed $(words $(TEST_TEX)) test file(s)"

# === CLEAN ===
.PHONY: clean
clean:
	@rm -rf $(TEMP_DIR) $(WWW_DIR)