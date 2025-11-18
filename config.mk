# === MAIN BUILD CONFIGURATION ===

# === DIRECTORIES ===
SRC_DIR    = tex-source
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

# === EXPORTS FOR SCRIPTS ===
export SRC_DIR TEMP_DIR WWW_DIR
export TEMPLATE REFS_JSON LABELS_JSON POLYDATA_JSON SITEMAP_XML
