# === TEST BUILD CONFIGURATION ===

# === DIRECTORIES ===
TEST_DIR   = tests
TEST_WWW_DIR := $(TEMP_DIR)/test-www
TEST_META_DIR := $(TEST_WWW_DIR)/meta

# === SOURCE FILES ===
TEST_TEX   := $(wildcard $(TEST_DIR)/*.tex)
TEST_PRE   := $(patsubst $(TEST_DIR)/%.tex,$(TEST_META_DIR)/%.pre.tex,$(TEST_TEX))
TEST_JSON  := $(patsubst $(TEST_DIR)/%.tex,$(TEST_META_DIR)/%.json,$(TEST_TEX))
TEST_HTML  := $(patsubst $(TEST_DIR)/%.tex,$(TEST_WWW_DIR)/%.htm,$(TEST_TEX))
TEST_CHECK := $(TEST_META_DIR)/unittest.check
TEST_EDGE_CHECK := $(TEST_META_DIR)/edge-cases.check
TEST_JSON_CHECK := $(TEST_META_DIR)/json-determinism.check
TEST_BACKEND_CHECK := $(TEST_META_DIR)/backend.check

# === GENERATED OUTPUTS ===
TEST_LABELS_JSON := $(TEST_META_DIR)/site-labels.json
TEST_POLYDATA_JSON := $(TEST_META_DIR)/site-polydata.json
TEST_TODOS_JSON := $(TEST_META_DIR)/site-todo.json
TEST_SITEMAP_XML := $(TEST_WWW_DIR)/sitemap.xml
TEST_GOTO_HTML := $(TEST_WWW_DIR)/goto.htm
TEST_PUBLIC_LABELS_JSON := $(TEST_WWW_DIR)/site-labels.json
TEST_PUBLIC_KEYWORDS_JSON := $(TEST_WWW_DIR)/site-keywords.json
TEST_RELATION_GRAPH_HTML := $(TEST_WWW_DIR)/polynomial-relations.htm
TEST_RELATION_GRAPH_JSON := $(TEST_WWW_DIR)/polynomial-relations.json

# === EXPORTS FOR SCRIPTS ===
export TEST_DIR TEST_WWW_DIR TEST_META_DIR
