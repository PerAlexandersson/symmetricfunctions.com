# === MAIN BUILD CONFIGURATION ===

# === DIRECTORIES ===
SRC_DIR    = tex-source
ASSETS_DIR = assets
TEMP_DIR   = temp
WWW_DIR    = www

# === SOURCE FILES ===
TEMPLATE   := template.htm
BIBFILE    := bibliography.bib

# ======================================================

# === TOOLS ===
PANDOC = pandoc
LUA    = lua

# === SCRIPTS ===
PREPROC_LUA    = preprocess.lua
GATHER_LUA     = gather.lua
RENDER_LUA     = render.lua
MERGE_META_LUA = merge_meta.lua
RELATION_GRAPH_LUA = relation_graph.lua

# === LUA LIBRARY DEPENDENCIES ===
# Utility modules loaded via dofile() — tracked so edits trigger rebuilds
UTILS_LUA          = utils.lua
FILE_READING_LUA   = file_reading.lua
BIBHANDLER_LUA     = bibhandler.lua
BIB_MATH_FILTER    = bib_math_filter.lua
FIG_TO_HTML_LUA    = figure_to_html.lua
POLY_TO_HTML_LUA   = polydata_to_html.lua
RELATION_REGISTRY_LUA = relation_registry.lua

PREPROC_DEPS    = $(PREPROC_LUA) $(UTILS_LUA)
GATHER_DEPS     = $(GATHER_LUA) $(UTILS_LUA) $(BIBHANDLER_LUA) $(RELATION_REGISTRY_LUA)
RENDER_DEPS     = $(RENDER_LUA) $(UTILS_LUA) $(BIBHANDLER_LUA) $(FILE_READING_LUA) $(FIG_TO_HTML_LUA) $(POLY_TO_HTML_LUA)
MERGE_META_DEPS = $(MERGE_META_LUA) $(UTILS_LUA) $(FILE_READING_LUA) $(BIBHANDLER_LUA) $(RELATION_REGISTRY_LUA) $(RELATION_GRAPH_LUA)

# === SOURCE FILES AND INTERMEDIATE FILES ===
TEX_FILES  := $(wildcard $(SRC_DIR)/*.tex)
PRE_TEX    := $(patsubst $(SRC_DIR)/%.tex,$(TEMP_DIR)/%.pre.tex,$(TEX_FILES))
JSON_FILES := $(patsubst $(SRC_DIR)/%.tex,$(TEMP_DIR)/%.json,$(TEX_FILES))
HTML_FILES := $(patsubst $(SRC_DIR)/%.tex,$(WWW_DIR)/%.htm,$(TEX_FILES))

# === GENERATED OUTPUTS ===
REFS_JSON     := $(TEMP_DIR)/bibliography.json
LABELS_JSON   := $(TEMP_DIR)/site-labels.json
POLYDATA_JSON := $(TEMP_DIR)/site-polydata.json
TODOS_JSON    := $(TEMP_DIR)/site-todo.json
SITEMAP_XML   := $(WWW_DIR)/sitemap.xml
GOTO_HTML     := $(WWW_DIR)/goto.htm
PUBLIC_LABELS_JSON := $(WWW_DIR)/site-labels.json
RELATION_GRAPH_HTML := $(WWW_DIR)/polynomial-relations.htm
RELATION_GRAPH_JSON := $(WWW_DIR)/polynomial-relations.json

# === EXPORTS FOR SCRIPTS ===
export SRC_DIR ASSETS_DIR TEMP_DIR WWW_DIR
export TEMPLATE REFS_JSON LABELS_JSON POLYDATA_JSON TODOS_JSON SITEMAP_XML
export RELATION_GRAPH_HTML RELATION_GRAPH_JSON
