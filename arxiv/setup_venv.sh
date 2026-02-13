#!/bin/bash
# setup_venv.sh - Setup virtual environment for arXiv project
# This script should be run on each machine separately

set -e  # Exit on error

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "Setting up virtual environment for arXiv project..."

# Check if venv exists and is working
if [ -d "venv" ]; then
    echo "Virtual environment directory exists, testing if it works..."
    if source venv/bin/activate 2>/dev/null && python3 -c "import arxiv" 2>/dev/null; then
        echo "✓ Virtual environment is already set up and working!"
        deactivate
        exit 0
    else
        echo "Virtual environment is broken, recreating..."
        rm -rf venv
    fi
fi

# Create new virtual environment
echo "Creating new virtual environment..."
python3 -m venv venv

# Activate and install dependencies
echo "Installing dependencies..."
source venv/bin/activate
pip install --upgrade pip
pip install -r requirements.txt

echo ""
echo "✓ Virtual environment setup complete!"
echo ""
echo "To use the virtual environment:"
echo "  cd $SCRIPT_DIR/src"
echo "  source ../venv/bin/activate"
echo "  python3 fetch_arxiv.py --recent --days 7"
