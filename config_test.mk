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

# === GENERATED OUTPUTS ===
REFS_JSON := $(TEMP_DIR)/bibliography.json

# === EXPORTS FOR SCRIPTS ===
export TEST_DIR TEMP_DIR WWW_DIR
export TEMPLATE REFS_JSON
