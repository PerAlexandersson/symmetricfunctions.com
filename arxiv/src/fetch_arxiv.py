#!/usr/bin/env python3
"""
fetch_arxiv.py - Fetch papers from arXiv and store in database

Usage:
    # Fetch papers from the last N days (default: 2)
    python fetch_arxiv.py --recent --days 2
    
    # Backfill papers from a date range
    python fetch_arxiv.py --backfill --start-date 2000-01-01 --end-date 2000-12-31
    
    # Fetch a specific arXiv ID
    python fetch_arxiv.py --arxiv-id 2401.12345
"""

import argparse
import arxiv
import pymysql
from datetime import datetime, timedelta
import sys
import re
import unicodedata
from config import DB_CONFIG, validate_config


def strip_accents(text):
    """Strip diacritics/accents from text."""
    nfkd = unicodedata.normalize('NFKD', text)
    return ''.join(c for c in nfkd if not unicodedata.combining(c))


def slugify(name):
    """Convert a name to a URL-friendly slug."""
    s = strip_accents(name).lower()
    s = re.sub(r"[^a-z0-9\s-]", '', s)
    s = re.sub(r'[\s]+', '-', s.strip())
    s = re.sub(r'-+', '-', s)
    return s

# Validate configuration on startup
validate_config()


def get_db_connection():
    """Create and return a database connection."""
    return pymysql.connect(**DB_CONFIG)


def insert_or_update_paper(cursor, paper):
    """
    Insert a paper into the database, or update if it already exists.
    Also handles authors and the paper-author relationship.
    
    Args:
        cursor: Database cursor
        paper: arxiv.Result object
    
    Returns:
        paper_id: The database ID of the inserted/updated paper
    """
    
    # Extract paper metadata
    arxiv_id = paper.entry_id.split('/abs/')[-1]  # Extract ID from URL
    title = paper.title
    abstract = paper.summary
    published_date = paper.published.date()
    updated_date = paper.updated.date() if paper.updated else None
    comment = paper.comment if hasattr(paper, 'comment') else None
    journal_ref = paper.journal_ref if hasattr(paper, 'journal_ref') else None
    doi = paper.doi if hasattr(paper, 'doi') else None
    primary_category = paper.primary_category
    
    # Check if paper already exists
    cursor.execute("SELECT id FROM papers WHERE arxiv_id = %s", (arxiv_id,))
    result = cursor.fetchone()
    
    if result:
        # Update existing paper
        paper_id = result[0]
        cursor.execute("""
            UPDATE papers SET
                title = %s,
                abstract = %s,
                published_date = %s,
                updated_date = %s,
                comment = %s,
                journal_ref = %s,
                doi = %s,
                primary_category = %s
            WHERE id = %s
        """, (title, abstract, published_date, updated_date, comment, 
              journal_ref, doi, primary_category, paper_id))
        
        # Clear existing author relationships
        cursor.execute("DELETE FROM paper_authors WHERE paper_id = %s", (paper_id,))
        print(f"  Updated: {arxiv_id} - {title[:60]}...")
    else:
        # Insert new paper
        cursor.execute("""
            INSERT INTO papers 
            (arxiv_id, title, abstract, published_date, updated_date, 
             comment, journal_ref, doi, primary_category)
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s)
        """, (arxiv_id, title, abstract, published_date, updated_date,
              comment, journal_ref, doi, primary_category))
        paper_id = cursor.lastrowid
        print(f"  Inserted: {arxiv_id} - {title[:60]}...")
    
    # Handle authors
    for order, author in enumerate(paper.authors, start=1):
        author_name = str(author)
        author_slug = slugify(author_name)

        # Insert author if not exists (or get existing ID)
        cursor.execute("""
            INSERT INTO authors (name, slug) VALUES (%s, %s)
            ON DUPLICATE KEY UPDATE id=LAST_INSERT_ID(id), slug=COALESCE(slug, VALUES(slug))
        """, (author_name, author_slug))
        author_id = cursor.lastrowid
        
        # Link paper to author (ignore if duplicate)
        cursor.execute("""
            INSERT IGNORE INTO paper_authors (paper_id, author_id, author_order)
            VALUES (%s, %s, %s)
        """, (paper_id, author_id, order))
    
    return paper_id


def fetch_recent_papers(days=2):
    """
    Fetch papers from the last N days.

    Args:
        days: Number of days to look back (default: 2)
    """
    print(f"Fetching papers from the last {days} days...")

    # Calculate date range
    end_date = datetime.now()
    start_date = end_date - timedelta(days=days)

    # Build arXiv query
    query = f"cat:math.CO AND submittedDate:[{start_date.strftime('%Y%m%d')}0000 TO {end_date.strftime('%Y%m%d')}2359]"

    print(f"Query: {query}")

    # Search arXiv
    search = arxiv.Search(
        query=query,
        max_results=500,  # Adjust if needed
        sort_by=arxiv.SortCriterion.SubmittedDate,
        sort_order=arxiv.SortOrder.Descending
    )

    # Create client for fetching results
    client = arxiv.Client()

    # Process results
    conn = get_db_connection()
    cursor = conn.cursor()

    count = 0
    errors = 0
    try:
        for paper in client.results(search):
            try:
                insert_or_update_paper(cursor, paper)
                count += 1
            except Exception as e:
                errors += 1
                arxiv_id = paper.entry_id.split('/abs/')[-1] if hasattr(paper, 'entry_id') else 'unknown'
                print(f"  Error processing {arxiv_id}: {e}")
                # Continue processing other papers

        conn.commit()
        print(f"\nSuccessfully processed {count} papers.")
        if errors > 0:
            print(f"Encountered {errors} errors (skipped those papers).")
    except Exception as e:
        conn.rollback()
        print(f"Fatal error: {e}")
        raise
    finally:
        cursor.close()
        conn.close()


def fetch_date_range(start_date_str, end_date_str):
    """
    Fetch papers from a specific date range.

    Args:
        start_date_str: Start date in YYYY-MM-DD format
        end_date_str: End date in YYYY-MM-DD format
    """
    start_date = datetime.strptime(start_date_str, '%Y-%m-%d')
    end_date = datetime.strptime(end_date_str, '%Y-%m-%d')

    print(f"Fetching papers from {start_date_str} to {end_date_str}...")

    # Build arXiv query
    query = f"cat:math.CO AND submittedDate:[{start_date.strftime('%Y%m%d')}0000 TO {end_date.strftime('%Y%m%d')}2359]"

    print(f"Query: {query}")

    # Search arXiv
    search = arxiv.Search(
        query=query,
        max_results=5000,  # Increased for backfilling large date ranges
        sort_by=arxiv.SortCriterion.SubmittedDate,
        sort_order=arxiv.SortOrder.Descending
    )

    # Create client for fetching results
    client = arxiv.Client()

    # Process results
    conn = get_db_connection()
    cursor = conn.cursor()

    count = 0
    errors = 0
    try:
        for paper in client.results(search):
            try:
                insert_or_update_paper(cursor, paper)
                count += 1
            except Exception as e:
                errors += 1
                arxiv_id = paper.entry_id.split('/abs/')[-1] if hasattr(paper, 'entry_id') else 'unknown'
                print(f"  Error processing {arxiv_id}: {e}")
                # Continue processing other papers

        conn.commit()
        print(f"\nSuccessfully processed {count} papers.")
        if errors > 0:
            print(f"Encountered {errors} errors (skipped those papers).")
    except Exception as e:
        conn.rollback()
        print(f"Fatal error: {e}")
        raise
    finally:
        cursor.close()
        conn.close()


def fetch_by_arxiv_id(arxiv_id):
    """
    Fetch a specific paper by arXiv ID.

    Args:
        arxiv_id: The arXiv ID (e.g., "2401.12345")
    """
    print(f"Fetching paper: {arxiv_id}...")

    search = arxiv.Search(id_list=[arxiv_id])
    client = arxiv.Client()

    conn = get_db_connection()
    cursor = conn.cursor()

    try:
        paper = next(client.results(search))
        insert_or_update_paper(cursor, paper)
        conn.commit()
        print(f"Successfully processed {arxiv_id}")
    except StopIteration:
        print(f"Paper {arxiv_id} not found on arXiv")
    except Exception as e:
        conn.rollback()
        print(f"Error: {e}")
        raise
    finally:
        cursor.close()
        conn.close()


def fill_gap():
    """
    Find the first month (from 1991-01 onward) with no papers and backfill it.
    Scans forward from arXiv founding to the present, finds the earliest
    gap, and fills it. Run repeatedly to gradually fill all months.
    """
    from calendar import monthrange

    ARXIV_START_YEAR = 1991
    ARXIV_START_MONTH = 1

    conn = get_db_connection()
    cursor = conn.cursor()

    # Get all months that have at least one paper
    cursor.execute("""
        SELECT DISTINCT YEAR(published_date) as y, MONTH(published_date) as m
        FROM papers
        ORDER BY y, m
    """)
    filled_months = {(row[0], row[1]) for row in cursor.fetchall()}

    cursor.close()
    conn.close()

    now = datetime.now()
    current_year, current_month = now.year, now.month

    # Scan backward from current month to find most recent unfilled month
    y, m = current_year, current_month
    target = None
    while (y, m) >= (ARXIV_START_YEAR, ARXIV_START_MONTH):
        if (y, m) not in filled_months:
            target = (y, m)
            break
        m -= 1
        if m < 1:
            m = 12
            y -= 1

    if target is None:
        print("All months from 1991-01 to present are filled!")
        print("Nothing to do.")
        return

    target_year, target_month = target
    _, last_day = monthrange(target_year, target_month)
    start_date = f"{target_year}-{target_month:02d}-01"
    end_date = f"{target_year}-{target_month:02d}-{last_day:02d}"

    print(f"Filling gap: {start_date} to {end_date}")
    fetch_date_range(start_date, end_date)


def main():
    parser = argparse.ArgumentParser(description='Fetch arXiv papers and store in database')

    # Mode selection (mutually exclusive)
    mode_group = parser.add_mutually_exclusive_group(required=True)
    mode_group.add_argument('--recent', action='store_true',
                           help='Fetch recent papers')
    mode_group.add_argument('--backfill', action='store_true',
                           help='Backfill papers from a date range')
    mode_group.add_argument('--arxiv-id', type=str,
                           help='Fetch a specific paper by arXiv ID')
    mode_group.add_argument('--fill-gap', action='store_true',
                           help='Auto-fill the month before the earliest data')

    # Options for different modes
    parser.add_argument('--days', type=int, default=2,
                       help='Number of days to look back (for --recent mode)')
    parser.add_argument('--start-date', type=str,
                       help='Start date in YYYY-MM-DD format (for --backfill mode)')
    parser.add_argument('--end-date', type=str,
                       help='End date in YYYY-MM-DD format (for --backfill mode)')

    args = parser.parse_args()

    try:
        if args.recent:
            fetch_recent_papers(args.days)
        elif args.backfill:
            if not args.start_date or not args.end_date:
                print("Error: --backfill requires --start-date and --end-date")
                sys.exit(1)
            fetch_date_range(args.start_date, args.end_date)
        elif args.arxiv_id:
            fetch_by_arxiv_id(args.arxiv_id)
        elif args.fill_gap:
            fill_gap()
    except Exception as e:
        print(f"Fatal error: {e}")
        sys.exit(1)


if __name__ == '__main__':
    main()