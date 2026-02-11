#!/bin/bash
# Simple script to run the Flask app

cd "$(dirname "$0")/src"

# Activate virtual environment
source ../venv/bin/activate

# Run Flask app
echo "Starting arXiv Combinatorics Frontend..."
echo "Visit http://localhost:5000 in your browser"
echo "Press Ctrl+C to stop"
echo ""

python3 app.py
