#!/bin/bash
# Simple script to run the Flask app

set -e  # Exit on error

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Check if venv exists and works, set it up if needed
if [ ! -d "venv" ] || ! source venv/bin/activate 2>/dev/null || ! python3 -c "import flask" 2>/dev/null; then
    echo "Virtual environment not found or broken, setting up..."
    ./setup_venv.sh
fi

# Activate virtual environment (if not already activated)
if [ -z "$VIRTUAL_ENV" ]; then
    source venv/bin/activate
fi

# Run Flask app
cd src
echo ""
echo "Starting arXiv Combinatorics Frontend..."
echo "Visit http://localhost:5000 in your browser"
echo "Press Ctrl+C to stop"
echo ""

python3 app.py
