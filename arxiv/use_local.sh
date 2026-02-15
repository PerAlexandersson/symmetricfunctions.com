#!/bin/bash
# Switch to local development environment

cp .env.local .env
echo "✓ Switched to local development environment"
echo "  - FLASK_DEBUG=True"
echo "  - Using local database settings"
echo ""
echo "Run: ./run_app.sh to start local server"
