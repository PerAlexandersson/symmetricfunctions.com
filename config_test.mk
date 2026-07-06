# === TEST BUILD CONFIGURATION ===

# === DIRECTORIES ===
TEST_DIR   = tests
TEMP_DIR   = temp
WWW_DIR    = www

# === TOOLS ===
PANDOC = pandoc
LUA    = lua

# === SCRIPTS ===
PREPROC_LUA = preprocess.lua
GATHER_LUA  = gather.lua
RENDER_LUA  = render.lua

# === SOURCE FILES ===
TEMPLATE   := template.htm
BIBFILE    := bibliography.bib
TEST_TEX   := $(wildcard $(TEST_DIR)/*.tex)
TEST_PRE   := $(patsubst $(TEST_DIR)/%.tex,$(TEMP_DIR)/%.pre.tex,$(TEST_TEX))
TEST_JSON  := $(patsubst $(TEST_DIR)/%.tex,$(TEMP_DIR)/%.json,$(TEST_TEX))
TEST_HTML  := $(patsubst $(TEST_DIR)/%.tex,$(WWW_DIR)/%.htm,$(TEST_TEX))
TEST_CHECK := $(TEMP_DIR)/unittest.check

# === GENERATED OUTPUTS ===
REFS_JSON := $(TEMP_DIR)/bibliography.json
BIBTEX_JSON := $(TEMP_DIR)/bibtex-entries.json
TEST_WWW_DIR := $(TEMP_DIR)/test-www
TEST_LABELS_JSON := $(TEMP_DIR)/test-site-labels.json
TEST_POLYDATA_JSON := $(TEMP_DIR)/test-site-polydata.json
TEST_TODOS_JSON := $(TEMP_DIR)/test-site-todo.json
TEST_SITEMAP_XML := $(TEST_WWW_DIR)/sitemap.xml
TEST_GOTO_HTML := $(TEST_WWW_DIR)/goto.htm
TEST_PUBLIC_LABELS_JSON := $(TEST_WWW_DIR)/site-labels.json

# === EXPORTS FOR SCRIPTS ===
export TEST_DIR TEMP_DIR WWW_DIR
export ASSETS_DIR
export TEMPLATE REFS_JSON BIBTEX_JSON
