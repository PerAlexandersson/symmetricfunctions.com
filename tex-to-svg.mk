# ==============================================================================
# CONFIGURATION
# ==============================================================================

# Directories
SRC_DIR  := svg-tex/src
LIB_DIR  := svg-tex/lib
TEMP_DIR := temp/svg-tex

# Destinations
NAV_DEST := assets/nav-images
SVG_DEST := assets/svg-images

# Export TEXINPUTS so LaTeX finds your 'lib' folder
# The trailing colon ':' is critical (appends system paths)
export TEXINPUTS := .:$(LIB_DIR)/:

# ==============================================================================
# FILE DISCOVERY
# ==============================================================================

# Find all .tex files in source
ALL_TEX := $(wildcard $(SRC_DIR)/*.tex)

# Filter: Files starting with "card-" go to nav-images
NAV_TEX := $(filter $(SRC_DIR)/card-%, $(ALL_TEX))
# Filter: Everything else goes to svg-images
SVG_TEX := $(filter-out $(NAV_TEX), $(ALL_TEX))

# Map Sources to Targets
NAV_OBJS := $(patsubst $(SRC_DIR)/%.tex, $(NAV_DEST)/%.svg, $(NAV_TEX))
SVG_OBJS := $(patsubst $(SRC_DIR)/%.tex, $(SVG_DEST)/%.svg, $(SVG_TEX))

# ==============================================================================
# TOOLS & FLAGS
# ==============================================================================

# -interaction=nonstopmode: Don't halt on errors (useful for bulk builds)
# -output-directory: Keeps build artifacts out of your source folder
LATEX   := latex -interaction=nonstopmode -output-directory=$(TEMP_DIR)

# --no-fonts: Converts text to paths (ensures identical look on all devices)
# --zoom=1.5: Slight upscale for crisper rendering on high-DPI screens
DVISVGM := dvisvgm --no-fonts --zoom=1.5

# ==============================================================================
# TARGETS
# ==============================================================================

.PHONY: all clean dirs help

all: dirs $(NAV_OBJS) $(SVG_OBJS)

# Rule for Navigation Images (Cards)
$(NAV_DEST)/%.svg: $(SRC_DIR)/%.tex | $(TEMP_DIR)
	@echo "Compiling Card: $(notdir $<)"
	@$(LATEX) $< > /dev/null
	@$(DVISVGM) --output=$(TEMP_DIR)/$*.svg $(TEMP_DIR)/$*.dvi > /dev/null
	@cp $(TEMP_DIR)/$*.svg $@

# Rule for General Images
$(SVG_DEST)/%.svg: $(SRC_DIR)/%.tex | $(TEMP_DIR)
	@echo "Compiling Image: $(notdir $<)"
	@$(LATEX) $< > /dev/null
	@$(DVISVGM) --output=$(TEMP_DIR)/$*.svg $(TEMP_DIR)/$*.dvi > /dev/null
	@cp $(TEMP_DIR)/$*.svg $@

# Create directories if they don't exist
dirs:
	@mkdir -p $(NAV_DEST)
	@mkdir -p $(SVG_DEST)
	@mkdir -p $(TEMP_DIR)

clean:
	@echo "Cleaning temp files..."
	@rm -rf $(TEMP_DIR)

help:
	@echo "Targets:"
	@echo "  all    : Compile all SVGs"
	@echo "  clean  : Remove temp files"