#!/bin/bash
# Backfill arXiv papers from 2000 to present
# This script fetches papers year by year to avoid overwhelming the API

set -e

echo "========================================="
echo "Backfilling arXiv papers from 2000"
echo "========================================="
echo ""
echo "This will fetch ~10-12k papers. It may take 30-60 minutes."
echo "Press Ctrl+C to cancel, or Enter to continue..."
read

START_YEAR=2000
END_YEAR=$(date +%Y)

for year in $(seq $START_YEAR $END_YEAR); do
    echo ""
    echo "========================================="
    echo "Fetching papers from year $year"
    echo "========================================="
    
    python3 fetch_arxiv.py --backfill \
        --start-date "${year}-01-01" \
        --end-date "${year}-12-31"
    
    # Small delay to be nice to arXiv's API
    echo "Waiting 5 seconds before next year..."
    sleep 5
done

echo ""
echo "========================================="
echo "Backfill complete!"
echo "========================================="
echo ""
echo "To verify, connect to database and run:"
echo "  SELECT COUNT(*) FROM papers;"
echo "  SELECT MIN(published_date), MAX(published_date) FROM papers;"