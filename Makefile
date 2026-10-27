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

.PHONY: all gather meta bib render copy-assets svg clean unittest lint-html check deploy search ship
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

# Default target.  With FILE=page.tex only that page is gathered and rendered,
# against the existing site metadata; the merge and search index are skipped.
FILE ?=
ifeq ($(strip $(FILE)),)
all: gather meta render copy-assets search
else
all: gather render copy-assets
endif

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
	@# Only arXiv identifiers (2101.00001v2, math/0606360) become arXiv URLs.
	@sed -E 's/[Ee][Pp][Rr][Ii][Nn][Tt][[:space:]]*=[[:space:]]*\{([Aa][Rr][Xx][Ii][Vv]:)?([0-9]{4}\.[0-9]{4,5}(v[0-9]+)?|[a-z-]+(\.[A-Z]{2})?\/[0-9]{7}(v[0-9]+)?)\}/url = {https:\/\/arxiv.org\/abs\/\2}/g' $(BIBFILE) > $(TEMP_DIR)/bibfile_processed.bib
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
	@$(PANDOC) "$<" --from=$(READER) --to=json --lua-filter=$(GATHER_LUA) --fail-if-warnings | jq '.' > "$@"

# Test file gathering
$(TEST_JSON): $(TEST_META_DIR)/%.json: $(TEST_META_DIR)/%.pre.tex $(GATHER_DEPS) $(REFS_JSON)
	$(LOG) "Gathering $< → $@"
	@$(PANDOC) "$<" --from=$(READER) --to=json \
	        --lua-filter=$(GATHER_LUA) --fail-if-warnings -o "$@"

# === METADATA: Generate site-wide metadata ===
.PHONY: meta
meta: $(LABELS_JSON) $(POLYDATA_JSON) $(TODOS_JSON) $(SITEMAP_XML) $(GOTO_HTML) $(PUBLIC_LABELS_JSON) $(PUBLIC_KEYWORDS_JSON) $(PUBLIC_BIB_JSON) $(RELATION_GRAPH_HTML) $(RELATION_GRAPH_JSON)

# All site metadata outputs are produced by one merge pass, which rewrites an
# output only when its bytes change.  The stamp records that the merge ran, so
# an edit that leaves the metadata unchanged neither reruns the merge on every
# build nor triggers renders that depend on the outputs.  (A dry run, make -n,
# cannot see that the outputs kept their timestamps and lists every render.)
META_OUTPUTS := $(LABELS_JSON) $(POLYDATA_JSON) $(TODOS_JSON) $(SITEMAP_XML) $(GOTO_HTML) $(PUBLIC_LABELS_JSON) $(PUBLIC_KEYWORDS_JSON) $(PUBLIC_BIB_JSON) $(RELATION_GRAPH_HTML) $(RELATION_GRAPH_JSON)

# A missing output forces a new merge.
ifneq ($(words $(wildcard $(META_OUTPUTS))),$(words $(META_OUTPUTS)))
$(shell rm -f $(META_STAMP))
endif

$(META_STAMP): $(JSON_FILES) $(TIMESTAMP_FILES) $(MERGE_META_DEPS) $(REFS_JSON) $(BIBTEX_JSON) $(TEMPLATE) | $(TEMP_DIR)/.created $(WWW_DIR)/.created
	$(LOG) "Generating site metadata ..."
	@$(LUA) $(MERGE_META_LUA) $(JSON_FILES)
	@touch "$@"

$(META_OUTPUTS): $(META_STAMP) ;

# === RENDER: Generate HTML ===
.PHONY: render
ifeq ($(strip $(FILE)),)
# Full build: pages depend on the site metadata
render: $(HTML_FILES)
	$(LOG) "Rendered ALL → $(WWW_DIR)/*.htm"
PAGE_META_PREREQS := $(LABELS_JSON) $(POLYDATA_JSON)
else
# Single file build: read the existing site metadata (from an earlier full
# build) without regenerating it
render: $(WWW_DIR)/$(basename $(FILE)).htm
	$(LOG) "Rendered $(SRC_DIR)/$(basename $(FILE)).tex → $(WWW_DIR)/$(basename $(FILE)).htm"
PAGE_META_PREREQS :=
endif

# Cache source timestamps
$(TEMP_DIR)/%.timestamp: $(SRC_DIR)/%.tex | $(TEMP_DIR)/.created
	@stat -c '%Y' "$<" > "$@"

$(WWW_DIR)/%.htm: $(TEMP_DIR)/%.json $(TEMP_DIR)/%.timestamp $(RENDER_DEPS) $(TEMPLATE) $(REFS_JSON) $(BIBTEX_JSON) $(PAGE_META_PREREQS) | $(WWW_DIR)/.created
	$(LOG) "Rendering $< → $@"
	@SOURCE_TS=$$(cat $(TEMP_DIR)/$*.timestamp) \
	$(LUA) $(RENDER_LUA) "$<" > "$@"

# Test metadata is separate from site metadata so unittest links resolve against
# labels declared inside tests/*.tex.
$(TEST_LABELS_JSON) $(TEST_POLYDATA_JSON) $(TEST_TODOS_JSON) $(TEST_SITEMAP_XML) $(TEST_GOTO_HTML) $(TEST_PUBLIC_LABELS_JSON) $(TEST_PUBLIC_KEYWORDS_JSON) $(TEST_PUBLIC_BIB_JSON) $(TEST_RELATION_GRAPH_HTML) $(TEST_RELATION_GRAPH_JSON) &: $(TEST_JSON) $(MERGE_META_DEPS) $(REFS_JSON) $(BIBTEX_JSON) $(TEMPLATE) | $(TEST_META_DIR)/.created
	$(LOG) "Generating test metadata ..."
	@LABELS_JSON=$(TEST_LABELS_JSON) \
	  BIBTEX_JSON=$(BIBTEX_JSON) \
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
# make svg FORCE=1 regenerates every figure regardless of timestamps.
svg:
	$(LOG) "Generating SVG assets..."
	@$(LUA) tex_to_svg.lua $(if $(filter-out 0,$(FORCE)),--force)
	$(MAKE) copy-assets Q=$(Q)

# === UNITTEST ===
.PHONY: unittest
unittest: $(TEST_HTML) $(TEST_CHECK) $(TEST_EDGE_CHECK) $(TEST_JSON_CHECK) $(TEST_BACKEND_CHECK) $(TEST_SAFEGUARDS_CHECK)
	$(LOG) "Unittest pipeline finished — processed $(words $(TEST_TEX)) test file(s)"

$(TEST_CHECK): $(TEST_PUBLIC_KEYWORDS_JSON) $(TEST_JSON) $(TEST_LABELS_JSON) $(TEST_POLYDATA_JSON) $(TEST_HTML) tests/check_unittest.lua $(FILE_READING_LUA) $(UTILS_LUA)
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

$(TEST_JSON_CHECK): tests/check_json_determinism.lua $(FILE_READING_LUA) $(UTILS_LUA) $(RELATION_GRAPH_LUA) $(RELATION_REGISTRY_LUA) $(BIBHANDLER_LUA) | $(TEST_META_DIR)/.created
	$(LOG) "Checking deterministic JSON encoding ..."
	@$(LUA) tests/check_json_determinism.lua
	@touch $@

$(TEST_BACKEND_CHECK): tests/check_backend.py tests/fixtures/svg_runner.lua tex_to_svg.lua $(RENDER_DEPS) $(MERGE_META_DEPS) $(GATHER_DEPS) $(PREPROC_DEPS) $(BIBTEX_EXTRACT_LUA) $(BIB_MATH_FILTER) $(TEMPLATE) Makefile config.mk config_test.mk | $(TEST_META_DIR)/.created
	$(LOG) "Checking backend failure handling and build dependencies ..."
	@python3 tests/check_backend.py
	@touch $@

$(TEST_SAFEGUARDS_CHECK): tests/check_safeguards.lua tests/fixtures/bibliography.json tests/fixtures/bibtex-entries.json $(PREPROC_DEPS) $(GATHER_DEPS) $(RENDER_DEPS) $(MERGE_META_DEPS) $(REFS_JSON) $(BIBTEX_JSON) $(TEMPLATE) | $(TEST_META_DIR)/.created
	$(LOG) "Checking build safeguards ..."
	@TEST_META_DIR=$(TEST_META_DIR) READER=$(READER) $(LUA) tests/check_safeguards.lua
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
	staging_dir="$(TEMP_DIR)/_pagefind.new"; \
	rm -rf -- "$$staging_dir"; \
	if [[ "$(Q)" != "0" ]]; then \
	  $(PAGEFIND) --site "$$www_dir" --output-path "$$staging_dir" --glob "**/*.htm" > "$(TEMP_DIR)/pagefind.log" 2>&1 || { \
	    cat "$(TEMP_DIR)/pagefind.log" >&2; \
	    exit 1; \
	  }; \
	else \
	  $(PAGEFIND) --site "$$www_dir" --output-path "$$staging_dir" --glob "**/*.htm"; \
	fi; \
	if [[ ! -f "$$staging_dir/pagefind-entry.json" ]]; then \
	  echo "[ERROR] Pagefind did not create $$staging_dir/pagefind-entry.json" >&2; \
	  exit 1; \
	fi; \
	rm -rf -- "$$pagefind_dir"; \
	mv -- "$$staging_dir" "$$pagefind_dir"; \
	touch "$(PAGEFIND_STAMP)"

# === DEPLOY ===
# Deploys the built site after a full build and `make check`.  Files removed
# from www/ are not deleted on the server.
DESTPATH := symmetricf@ns12.inleed.net:domains/symmetricfunctions.com/public_html
deploy:
	$(MAKE) all
	$(MAKE) check
	@chmod -R u+rw,go+r,go-w $(WWW_DIR)/
	rsync -avizL -e "ssh -p 2020" --exclude='*~' --exclude='.created' $(WWW_DIR)/ $(DESTPATH)

# === SHIP: clean → build → check → deploy ===
ship:
	$(MAKE) clean
	$(MAKE) deploy
