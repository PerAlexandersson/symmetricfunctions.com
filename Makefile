SHELL := /bin/bash
.SHELLFLAGS := -eu -o pipefail -c

# Use 8 threads by default
MAKEFLAGS += -j8

# === LOAD CONFIGURATION ===
include config.mk
include config_test.mk

ifeq ($(strip $(WWW_DIR)),)
$(error WWW_DIR must not be empty)
endif
ifeq ($(abspath $(WWW_DIR)),/)
$(error WWW_DIR must not be the filesystem root)
endif

.PHONY: all gather meta bib render copy-assets svg clean unittest lint-html check deploy search
.DELETE_ON_ERROR:
.SECONDARY: $(PRE_TEX)

# Suppress file deletion messages
.SILENT:

# Quiet mode: only show errors/warnings (no progress messages)
# Usage: make Q=1  or  make quiet
Q ?= 0
ifneq ($(Q),0)
  LOG = @true
  export QUIET_BUILD=1
else
  LOG = @echo
endif

# Default target
all: gather meta render copy-assets search

# Quiet build alias
.PHONY: quiet
quiet:
	$(MAKE) all Q=1

# === CREATE BUILD DIRECTORIES ===
# Use stamp files to ensure directories are created exactly once
$(TEMP_DIR)/.created:
	@mkdir -p $(TEMP_DIR)
	@touch $@

$(WWW_DIR)/.created:
	@mkdir -p $(WWW_DIR)
	@touch $@

$(TEST_WWW_DIR)/.created: | $(TEMP_DIR)/.created
	@mkdir -p $(TEST_WWW_DIR)
	@touch $@

$(TEST_META_DIR)/.created: | $(TEST_WWW_DIR)/.created
	@mkdir -p $(TEST_META_DIR)
	@touch $@

# === BIBLIOGRAPHY (must complete before gathering) ===
.PHONY: bib
bib: $(REFS_JSON) $(BIBTEX_JSON)

$(REFS_JSON): $(BIBFILE) $(BIB_MATH_FILTER) | $(TEMP_DIR)/.created
	$(LOG) "Generating $@"
	@sed -E 's/[Ee][Pp][Rr][Ii][Nn][Tt][[:space:]]*=[[:space:]]*\{([Aa][Rr][Xx][Ii][Vv]:)?([^}]*)\}/url = {https:\/\/arxiv.org\/abs\/\2}/g' $(BIBFILE) > $(TEMP_DIR)/bibfile_processed.bib
	@$(PANDOC) -f biblatex -t csljson $(TEMP_DIR)/bibfile_processed.bib \
	  --lua-filter=bib_math_filter.lua --fail-if-warnings -o $@.tmp && mv $@.tmp $@

$(BIBTEX_JSON): $(BIBFILE) $(BIBTEX_EXTRACT_LUA) $(FILE_READING_LUA) $(UTILS_LUA) | $(TEMP_DIR)/.created
	$(LOG) "Generating $@"
	@$(LUA) $(BIBTEX_EXTRACT_LUA) $(BIBFILE) > "$@.tmp" && mv "$@.tmp" "$@"


# === 1) PREPROCESS: tex → pre.tex ===
# Order-only dependency on directory ensures it exists without triggering rebuilds
$(TEMP_DIR)/%.pre.tex: $(SRC_DIR)/%.tex $(PREPROC_DEPS) | $(TEMP_DIR)/.created
	$(LOG) "Preprocessing $< → $@"
	@$(LUA) $(PREPROC_LUA) "$<" < "$<" > "$@"

# Test file preprocessing
$(TEST_PRE): $(TEST_META_DIR)/%.pre.tex: $(TEST_DIR)/%.tex $(PREPROC_DEPS) | $(TEST_META_DIR)/.created
	$(LOG) "Preprocessing $< → $@"
	@$(LUA) $(PREPROC_LUA) "$<" < "$<" > "$@"

# === 2) GATHER: Collect metadata to JSON ===
FILE ?=
.PHONY: gather
ifeq ($(strip $(FILE)),)
gather: $(JSON_FILES)
	$(LOG) "Gathered ALL → $(TEMP_DIR)/*.json"
else
gather: $(TEMP_DIR)/$(basename $(FILE)).json
	$(LOG) "Gathered $(FILE) → $(TEMP_DIR)/$(basename $(FILE)).json"
endif

# Here we use jq to format the json nicer
$(TEMP_DIR)/%.json: $(TEMP_DIR)/%.pre.tex $(GATHER_DEPS) $(REFS_JSON)
	$(LOG) "Gathering $< → $@"
	@$(PANDOC) "$<" --from=latex+raw_tex --to=json --lua-filter=$(GATHER_LUA) --fail-if-warnings | jq '.' > "$@"

# Test file gathering
$(TEST_JSON): $(TEST_META_DIR)/%.json: $(TEST_META_DIR)/%.pre.tex $(GATHER_DEPS) $(REFS_JSON)
	$(LOG) "Gathering $< → $@"
	@$(PANDOC) "$<" --from=latex+raw_tex --to=json \
	        --lua-filter=$(GATHER_LUA) --fail-if-warnings -o "$@"

# === METADATA: Generate site-wide metadata ===
.PHONY: meta
meta: $(LABELS_JSON) $(POLYDATA_JSON) $(TODOS_JSON) $(SITEMAP_XML) $(GOTO_HTML) $(PUBLIC_LABELS_JSON) $(RELATION_GRAPH_HTML) $(RELATION_GRAPH_JSON)

# All site metadata outputs are produced by one merge pass. Grouped targets make
# Make regenerate the whole set when any one output is missing or stale.
$(LABELS_JSON) $(POLYDATA_JSON) $(TODOS_JSON) $(SITEMAP_XML) $(GOTO_HTML) $(PUBLIC_LABELS_JSON) $(RELATION_GRAPH_HTML) $(RELATION_GRAPH_JSON) &: $(JSON_FILES) $(MERGE_META_DEPS) $(REFS_JSON) | $(TEMP_DIR)/.created $(WWW_DIR)/.created
	$(LOG) "Generating site metadata ..."
	@$(LUA) $(MERGE_META_LUA) $(JSON_FILES)

# === RENDER: Generate HTML ===
FILE ?=
.PHONY: render
ifeq ($(strip $(FILE)),)
# Full build: require site metadata
render: $(HTML_FILES)
	$(LOG) "Rendered ALL → $(WWW_DIR)/*.htm"
else
# Single file build - use stale metadata if available
render: $(WWW_DIR)/$(basename $(FILE)).htm
	$(LOG) "Rendered $(SRC_DIR)/$(basename $(FILE)).tex → $(WWW_DIR)/$(basename $(FILE)).htm"
endif

# Cache source timestamps
$(TEMP_DIR)/%.timestamp: $(SRC_DIR)/%.tex | $(TEMP_DIR)/.created
	@stat -c '%Y' "$<" > "$@"

$(WWW_DIR)/%.htm: $(TEMP_DIR)/%.json $(TEMP_DIR)/%.timestamp $(RENDER_DEPS) $(TEMPLATE) $(REFS_JSON) $(BIBTEX_JSON) $(LABELS_JSON) $(POLYDATA_JSON) | $(WWW_DIR)/.created
	$(LOG) "Rendering $< → $@"
	@SOURCE_TS=$$(cat $(TEMP_DIR)/$*.timestamp) \
	$(LUA) $(RENDER_LUA) "$<" > "$@"

# Test metadata is separate from site metadata so unittest links resolve against
# labels declared inside tests/*.tex.
$(TEST_LABELS_JSON) $(TEST_POLYDATA_JSON) $(TEST_TODOS_JSON) $(TEST_SITEMAP_XML) $(TEST_GOTO_HTML) $(TEST_PUBLIC_LABELS_JSON) $(TEST_RELATION_GRAPH_HTML) $(TEST_RELATION_GRAPH_JSON) &: $(TEST_JSON) $(MERGE_META_DEPS) $(REFS_JSON) | $(TEST_META_DIR)/.created
	$(LOG) "Generating test metadata ..."
	@LABELS_JSON=$(TEST_LABELS_JSON) \
	  POLYDATA_JSON=$(TEST_POLYDATA_JSON) \
	  TODOS_JSON=$(TEST_TODOS_JSON) \
	  SITEMAP_XML=$(TEST_SITEMAP_XML) \
	  WWW_DIR=$(TEST_WWW_DIR) \
	  RELATION_GRAPH_HTML=$(TEST_RELATION_GRAPH_HTML) \
	  RELATION_GRAPH_JSON=$(TEST_RELATION_GRAPH_JSON) \
	  $(LUA) $(MERGE_META_LUA) $(TEST_JSON)

# Test file rendering
$(TEST_HTML): $(TEST_WWW_DIR)/%.htm: $(TEST_META_DIR)/%.json $(RENDER_DEPS) $(TEMPLATE) $(REFS_JSON) $(BIBTEX_JSON) $(TEST_LABELS_JSON) $(TEST_POLYDATA_JSON) | $(TEST_WWW_DIR)/.created
	$(LOG) "Rendering test $< → $@"
	@SOURCE_TS=$$(stat -c '%Y' "$(TEST_DIR)/$*.tex") \
	LABELS_JSON=$(TEST_LABELS_JSON) \
	POLYDATA_JSON=$(TEST_POLYDATA_JSON) \
	$(LUA) $(RENDER_LUA) "$<" > "$@"

# === COPY ASSETS ===
.PHONY: copy-assets
copy-assets: $(COPY_ASSETS_STAMP)

$(COPY_ASSETS_STAMP): $(ASSET_FILES) $(WWW_DIR)/.created | $(TEMP_DIR)/.created
	$(LOG) "Copying assets..."
	@cp -r $(ASSETS_DIR)/* $(WWW_DIR)/
	@touch "$@"

# === SVG ASSETS ===
.PHONY: svg
svg:
	$(LOG) "Generating SVG assets..."
	@$(LUA) tex_to_svg.lua
	$(MAKE) copy-assets Q=$(Q)

# === UNITTEST ===
.PHONY: unittest
unittest: $(TEST_HTML) $(TEST_CHECK) $(TEST_EDGE_CHECK) $(TEST_JSON_CHECK)
	$(LOG) "Unittest pipeline finished — processed $(words $(TEST_TEX)) test file(s)"

$(TEST_CHECK): $(TEST_JSON) $(TEST_LABELS_JSON) $(TEST_POLYDATA_JSON) $(TEST_HTML) tests/check_unittest.lua $(FILE_READING_LUA) $(UTILS_LUA)
	$(LOG) "Checking unittest metadata ..."
	@LABELS_JSON=$(TEST_LABELS_JSON) \
	  POLYDATA_JSON=$(TEST_POLYDATA_JSON) \
	  TEST_HTML="$(TEST_HTML)" \
	  WWW_DIR="$(WWW_DIR)" \
	  $(LUA) tests/check_unittest.lua
	@touch $@

$(TEST_EDGE_CHECK): tests/check_edge_cases.lua tests/fixtures/preprocess.tex tests/fixtures/unsupported-cite.tex $(PREPROC_DEPS) $(GATHER_DEPS) $(FIG_TO_HTML_LUA) $(REFS_JSON) | $(TEST_META_DIR)/.created
	$(LOG) "Checking preprocess and citation edge cases ..."
	@$(LUA) tests/check_edge_cases.lua
	@touch $@

$(TEST_JSON_CHECK): tests/check_json_determinism.lua $(FILE_READING_LUA) $(UTILS_LUA) | $(TEST_META_DIR)/.created
	$(LOG) "Checking deterministic JSON encoding ..."
	@$(LUA) tests/check_json_determinism.lua
	@touch $@

# === GENERATED HTML LINT ===
.PHONY: lint-html
lint-html: $(HTML_FILES) $(SITEMAP_XML) $(GOTO_HTML) $(RELATION_GRAPH_HTML) copy-assets tests/lint_html.lua
	$(LOG) "Linting generated HTML ..."
	@WWW_DIR="$(WWW_DIR)" SRC_DIR="$(SRC_DIR)" ASSETS_DIR="$(ASSETS_DIR)" $(LUA) tests/lint_html.lua

.PHONY: check
check: unittest lint-html

# === CLEAN ===
.PHONY: clean
clean:
	@rm -rf $(TEMP_DIR) $(WWW_DIR)

# === SEARCH INDEX (pagefind) ===
.PHONY: search
search: $(PAGEFIND_STAMP) $(PAGEFIND_ENTRY)

$(PAGEFIND_STAMP) $(PAGEFIND_ENTRY) &: $(HTML_FILES) $(GOTO_HTML) $(RELATION_GRAPH_HTML) $(COPY_ASSETS_STAMP) | $(TEMP_DIR)/.created
	$(LOG) "Building search index with pagefind..."
	@www_dir="$(strip $(WWW_DIR))"; \
	if [[ -z "$$www_dir" || "$$www_dir" == "/" ]]; then \
	  echo "[ERROR] Refusing Pagefind cleanup with unsafe WWW_DIR='$$www_dir'" >&2; \
	  exit 2; \
	fi; \
	pagefind_dir="$${www_dir%/}/_pagefind"; \
	rm -rf -- "$$pagefind_dir"; \
	if [[ "$(Q)" != "0" ]]; then \
	  npx pagefind --site "$$www_dir" --output-path "$$pagefind_dir" --glob "**/*.htm" > "$(TEMP_DIR)/pagefind.log" 2>&1 || { \
	    cat "$(TEMP_DIR)/pagefind.log" >&2; \
	    exit 1; \
	  }; \
	else \
	  npx pagefind --site "$$www_dir" --output-path "$$pagefind_dir" --glob "**/*.htm"; \
	fi; \
	if [[ ! -f "$$pagefind_dir/pagefind-entry.json" ]]; then \
	  echo "[ERROR] Pagefind did not create $$pagefind_dir/pagefind-entry.json" >&2; \
	  exit 1; \
	fi; \
	touch "$(PAGEFIND_STAMP)"

# === DEPLOY ===
DESTPATH := symmetricf@ns12.inleed.net:domains/symmetricfunctions.com/public_html
deploy: copy-assets
	@chmod -R u+rw,go+r,go-w $(WWW_DIR)/
	rsync -avizL -e "ssh -p 2020" --exclude='*~' $(WWW_DIR)/ $(DESTPATH)

# === SHIP: clean → build → deploy (parallel-safe) ===
.PHONY: ship
ship:
	$(MAKE) clean
	$(MAKE) all
	$(MAKE) deploy
