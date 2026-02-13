#!/bin/bash
# Convenience script to fetch arXiv papers

set -e  # Exit on error

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Use .local/venv to avoid Dropbox sync conflicts
VENV_DIR=".local/venv"

# Check if venv exists and works, set it up if needed
if [ ! -d "$VENV_DIR" ] || ! source "$VENV_DIR/bin/activate" 2>/dev/null || ! python3 -c "import arxiv" 2>/dev/null; then
    echo "Virtual environment not found or broken, setting up..."
    ./setup_venv.sh
    echo ""
fi

# Activate virtual environment (if not already activated)
if [ -z "$VIRTUAL_ENV" ]; then
    source "$VENV_DIR/bin/activate"
fi

# Default to fetching last 7 days if no arguments provided
if [ $# -eq 0 ]; then
    echo "Fetching papers from the last 7 days..."
    cd src
    python3 fetch_arxiv.py --recent --days 7
else
    # Pass all arguments to the fetch script
    cd src
    python3 fetch_arxiv.py "$@"
fi
