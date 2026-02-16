#!/bin/bash
# backfill_production.sh - Run fetch_arxiv.py on the production server
#
# Usage:
#   ./backfill_production.sh --fill-gap                              # Auto-fill one month backward
#   ./backfill_production.sh --recent --days 7                       # Fetch last 7 days
#   ./backfill_production.sh --backfill --start-date 2000-01-01 --end-date 2000-03-31
#   ./backfill_production.sh --arxiv-id 2401.12345                   # Fetch specific paper

set -e

REMOTE_HOST="symmetricf@ns12.inleed.net"
REMOTE_PORT="2020"
REMOTE_PATH="domains/arxiv.symmetricfunctions.com"
REMOTE_VENV="~/virtualenv/domains/arxiv.symmetricfunctions.com/3.9/bin/activate"

if [ $# -eq 0 ]; then
    echo "Usage: $0 <fetch_arxiv.py arguments>"
    echo ""
    echo "Examples:"
    echo "  $0 --fill-gap                  # Auto-fill one month backward"
    echo "  $0 --recent --days 7           # Fetch last 7 days"
    echo "  $0 --backfill --start-date 2000-01-01 --end-date 2000-03-31"
    echo "  $0 --arxiv-id 2401.12345       # Fetch specific paper"
    exit 1
fi

echo "Running on production: fetch_arxiv.py $@"
echo ""

ssh -p $REMOTE_PORT $REMOTE_HOST "
    source $REMOTE_VENV
    cd ~/$REMOTE_PATH/src
    python3 fetch_arxiv.py $@
"
