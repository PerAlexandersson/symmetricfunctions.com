#!/bin/bash
# setup_venv.sh - Setup virtual environment for arXiv project
# This script should be run on each machine separately

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Use .local/venv to avoid Dropbox sync conflicts
VENV_DIR=".local/venv"

echo "Setting up virtual environment for arXiv project..."

# Check if venv exists and is working
if [ -d "$VENV_DIR" ]; then
    echo "Virtual environment directory exists, testing if it works..."
    if source "$VENV_DIR/bin/activate" 2>/dev/null && python3 -c "import arxiv" 2>/dev/null; then
        echo "✓ Virtual environment is already set up and working!"
        deactivate
        exit 0
    else
        echo "Virtual environment is broken, removing..."
        rm -rf "$VENV_DIR"
    fi
fi

# Create .local directory if it doesn't exist
mkdir -p .local

# Create new virtual environment
echo "Creating new virtual environment in $VENV_DIR..."
if ! python3 -m venv "$VENV_DIR"; then
    echo "Error: Failed to create virtual environment"
    echo "Cleaning up and retrying..."
    rm -rf "$VENV_DIR"
    python3 -m venv "$VENV_DIR" || {
        echo "ERROR: Could not create virtual environment"
        exit 1
    }
fi

# Activate and install dependencies
echo "Installing dependencies..."
if ! source "$VENV_DIR/bin/activate"; then
    echo "ERROR: Could not activate virtual environment"
    exit 1
fi

pip install --upgrade pip
pip install -r requirements.txt

echo ""
echo "✓ Virtual environment setup complete!"
echo ""
echo "To use the virtual environment:"
echo "  cd $SCRIPT_DIR/src"
echo "  source ../venv/bin/activate"
echo "  python3 fetch_arxiv.py --recent --days 7"
