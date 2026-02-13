#!/usr/bin/env python3
"""
app.py - Flask web application for arXiv combinatorics frontend

Main web interface for browsing arXiv papers.
"""

from flask import Flask, render_template, request, jsonify, abort
import pymysql
from config import DB_CONFIG, FLASK_CONFIG, validate_config
from datetime import datetime
import re

# Validate configuration on startup
validate_config()

app = Flask(__name__)
app.config.update(FLASK_CONFIG)


def protect_capitals_for_bibtex(title):
    """
    Protect capital letters in a title for BibTeX by wrapping them in braces.
    This ensures BibTeX won't lowercase them.

    Example: "RNA-Binding Proteins" -> "{RNA}-{B}inding {P}roteins"
    """
    # Protect sequences of capitals (acronyms like RNA, DNA, etc.)
    def protect_match(match):
        text = match.group(0)
        return f"{{{text}}}"

    # Match sequences of 2+ capitals (acronyms): RNA, DNA, KaTeX, etc.
    result = re.sub(r'[A-Z]{2,}', protect_match, title)

    # Match single capitals that appear mid-word (after lowercase)
    result = re.sub(r'(?<=[a-z])[A-Z]', protect_match, result)

    # Match capitals after hyphens or slashes
    result = re.sub(r'(?<=[-/])[A-Z]', protect_match, result)

    return result


def get_db_connection():
    """Create and return a database connection."""
    return pymysql.connect(**DB_CONFIG, cursorclass=pymysql.cursors.DictCursor)


def get_paper_authors(cursor, paper_id):
    """Get ordered list of authors for a paper."""
    cursor.execute("""
        SELECT a.name
        FROM authors a
        JOIN paper_authors pa ON a.id = pa.author_id
        WHERE pa.paper_id = %s
        ORDER BY pa.author_order
    """, (paper_id,))
    return [row['name'] for row in cursor.fetchall()]


@app.route('/')
def index():
    """Homepage - list recent papers."""
    page = request.args.get('page', 1, type=int)
    per_page = 20
    offset = (page - 1) * per_page

    conn = get_db_connection()
    cursor = conn.cursor()

    # Get total count and author count
    cursor.execute("SELECT COUNT(*) as count FROM papers")
    total = cursor.fetchone()['count']

    cursor.execute("SELECT COUNT(*) as count FROM authors")
    total_authors = cursor.fetchone()['count']

    # Get latest published date
    cursor.execute("SELECT MAX(published_date) as latest FROM papers")
    latest_date = cursor.fetchone()['latest']

    # Get papers for current page
    cursor.execute("""
        SELECT id, arxiv_id, title, abstract, published_date, updated_date,
               journal_ref, doi, comment, primary_category
        FROM papers
        ORDER BY published_date DESC, id DESC
        LIMIT %s OFFSET %s
    """, (per_page, offset))

    papers = cursor.fetchall()

    # Get authors for each paper
    for paper in papers:
        paper['authors'] = get_paper_authors(cursor, paper['id'])

    cursor.close()
    conn.close()

    total_pages = (total + per_page - 1) // per_page

    return render_template('index.html',
                         papers=papers,
                         page=page,
                         total_pages=total_pages,
                         total=total,
                         total_authors=total_authors,
                         latest_date=latest_date)


@app.route('/paper/<arxiv_id>')
def paper_detail(arxiv_id):
    """Paper detail page."""
    conn = get_db_connection()
    cursor = conn.cursor()

    cursor.execute("""
        SELECT id, arxiv_id, title, abstract, published_date, updated_date,
               comment, journal_ref, doi, primary_category
        FROM papers
        WHERE arxiv_id = %s
    """, (arxiv_id,))

    paper = cursor.fetchone()

    if not paper:
        abort(404)

    paper['authors'] = get_paper_authors(cursor, paper['id'])

    cursor.close()
    conn.close()

    return render_template('paper.html', paper=paper)


@app.route('/api/bibtex/<arxiv_id>')
def bibtex(arxiv_id):
    """Generate BibTeX entry for a paper."""
    conn = get_db_connection()
    cursor = conn.cursor()

    cursor.execute("""
        SELECT id, arxiv_id, title, published_date, journal_ref, doi
        FROM papers
        WHERE arxiv_id = %s
    """, (arxiv_id,))

    paper = cursor.fetchone()

    if not paper:
        abort(404)

    paper['authors'] = get_paper_authors(cursor, paper['id'])

    cursor.close()
    conn.close()

    # Generate BibTeX key: FirstAuthorLastName + Year + x
    year = paper['published_date'].year
    if paper['authors']:
        # Get last name of first author
        first_author = paper['authors'][0]
        # Split by spaces and take the last part as last name
        last_name = first_author.split()[-1]
        # Remove any non-alphanumeric characters
        last_name = ''.join(c for c in last_name if c.isalnum())
        bibtex_key = f"{last_name}{year}x"
    else:
        # Fallback if no authors
        bibtex_key = f"arxiv{year}x"

    # Format authors
    author_str = ' and '.join(paper['authors']) if paper['authors'] else 'Unknown'

    # Clean arXiv ID (remove version number like v1, v2, etc.)
    clean_arxiv_id = paper['arxiv_id']
    if 'v' in clean_arxiv_id:
        clean_arxiv_id = clean_arxiv_id.split('v')[0]

    # Protect capital letters in title for BibTeX
    protected_title = protect_capitals_for_bibtex(paper['title'])

    bibtex = f"""@article{{{bibtex_key},
Author = {{{author_str}}},
Title = {{{protected_title}}},
Year = {{{year}}},
Eprint = {{{clean_arxiv_id}}},
  url = {{https://arxiv.org/abs/{clean_arxiv_id}}},
journal = {{arXiv e-prints}}"""

    if paper['journal_ref']:
        bibtex += f",\njournalref = {{{paper['journal_ref']}}}"

    if paper['doi']:
        bibtex += f",\ndoi = {{{paper['doi']}}}"

    bibtex += "\n}"

    return bibtex, 200, {'Content-Type': 'text/plain; charset=utf-8'}


@app.route('/api/doi-bibtex/<arxiv_id>')
def doi_bibtex(arxiv_id):
    """Fetch BibTeX from DOI for a paper."""
    import requests

    conn = get_db_connection()
    cursor = conn.cursor()

    cursor.execute("""
        SELECT doi
        FROM papers
        WHERE arxiv_id = %s
    """, (arxiv_id,))

    paper = cursor.fetchone()
    cursor.close()
    conn.close()

    if not paper or not paper['doi']:
        abort(404)

    # Fetch BibTeX from DOI content negotiation API
    doi_url = f"https://doi.org/{paper['doi']}"
    headers = {'Accept': 'application/x-bibtex'}

    try:
        response = requests.get(doi_url, headers=headers, timeout=10)
        response.raise_for_status()
        return response.text, 200, {'Content-Type': 'text/plain; charset=utf-8'}
    except requests.RequestException as e:
        return f"Error fetching DOI BibTeX: {str(e)}", 500, {'Content-Type': 'text/plain; charset=utf-8'}


@app.route('/search')
def search():
    """Search papers by title or author."""
    query = request.args.get('q', '').strip()
    page = request.args.get('page', 1, type=int)
    per_page = 20
    offset = (page - 1) * per_page

    if not query:
        return render_template('search.html', papers=[], query='', total=0)

    conn = get_db_connection()
    cursor = conn.cursor()

    search_term = f"%{query}%"

    # Get latest published date
    cursor.execute("SELECT MAX(published_date) as latest FROM papers")
    latest_date = cursor.fetchone()['latest']

    # Search in titles and authors
    cursor.execute("""
        SELECT COUNT(DISTINCT p.id) as count
        FROM papers p
        LEFT JOIN paper_authors pa ON p.id = pa.paper_id
        LEFT JOIN authors a ON pa.author_id = a.id
        WHERE p.title LIKE %s
           OR p.abstract LIKE %s
           OR a.name LIKE %s
    """, (search_term, search_term, search_term))

    total = cursor.fetchone()['count']

    cursor.execute("""
        SELECT DISTINCT p.id, p.arxiv_id, p.title, p.abstract,
               p.published_date, p.updated_date, p.journal_ref, p.doi,
               p.comment, p.primary_category
        FROM papers p
        LEFT JOIN paper_authors pa ON p.id = pa.paper_id
        LEFT JOIN authors a ON pa.author_id = a.id
        WHERE p.title LIKE %s
           OR p.abstract LIKE %s
           OR a.name LIKE %s
        ORDER BY p.published_date DESC, p.id DESC
        LIMIT %s OFFSET %s
    """, (search_term, search_term, search_term, per_page, offset))

    papers = cursor.fetchall()

    # Get authors for each paper
    for paper in papers:
        paper['authors'] = get_paper_authors(cursor, paper['id'])

    cursor.close()
    conn.close()

    total_pages = (total + per_page - 1) // per_page

    return render_template('search.html',
                         papers=papers,
                         query=query,
                         page=page,
                         total_pages=total_pages,
                         total=total,
                         latest_date=latest_date)


@app.route('/author/<author_name>')
def author_papers(author_name):
    """List all papers by a specific author."""
    page = request.args.get('page', 1, type=int)
    per_page = 20
    offset = (page - 1) * per_page

    conn = get_db_connection()
    cursor = conn.cursor()

    # Get author
    cursor.execute("SELECT id, name FROM authors WHERE name = %s", (author_name,))
    author = cursor.fetchone()

    if not author:
        abort(404)

    # Get latest published date
    cursor.execute("SELECT MAX(published_date) as latest FROM papers")
    latest_date = cursor.fetchone()['latest']

    # Get total count
    cursor.execute("""
        SELECT COUNT(*) as count
        FROM papers p
        JOIN paper_authors pa ON p.id = pa.paper_id
        WHERE pa.author_id = %s
    """, (author['id'],))
    total = cursor.fetchone()['count']

    # Get papers
    cursor.execute("""
        SELECT p.id, p.arxiv_id, p.title, p.abstract,
               p.published_date, p.updated_date, p.journal_ref, p.doi,
               p.comment, p.primary_category
        FROM papers p
        JOIN paper_authors pa ON p.id = pa.paper_id
        WHERE pa.author_id = %s
        ORDER BY p.published_date DESC, p.id DESC
        LIMIT %s OFFSET %s
    """, (author['id'], per_page, offset))

    papers = cursor.fetchall()

    # Get authors for each paper
    for paper in papers:
        paper['authors'] = get_paper_authors(cursor, paper['id'])

    cursor.close()
    conn.close()

    total_pages = (total + per_page - 1) // per_page

    return render_template('author.html',
                         author=author,
                         papers=papers,
                         page=page,
                         total_pages=total_pages,
                         total=total,
                         latest_date=latest_date)


@app.route('/browse')
def browse_by_date():
    """Browse papers by calendar date."""
    from datetime import datetime, date
    import calendar

    year = request.args.get('year', datetime.now().year, type=int)

    conn = get_db_connection()
    cursor = conn.cursor()

    # Get paper counts by date for the year
    cursor.execute("""
        SELECT DATE(published_date) as date, COUNT(*) as count
        FROM papers
        WHERE YEAR(published_date) = %s
        GROUP BY DATE(published_date)
    """, (year,))

    date_counts = {row['date']: row['count'] for row in cursor.fetchall()}

    # Get available years with paper counts
    cursor.execute("""
        SELECT YEAR(published_date) as year, COUNT(*) as count
        FROM papers
        GROUP BY YEAR(published_date)
        ORDER BY year DESC
    """)
    available_years = [(row['year'], row['count']) for row in cursor.fetchall()]

    cursor.close()
    conn.close()

    # Build calendar data for each month
    month_data = []
    month_names = ['', 'January', 'February', 'March', 'April', 'May', 'June',
                   'July', 'August', 'September', 'October', 'November', 'December']

    for month in range(1, 13):
        cal = calendar.monthcalendar(year, month)
        days = []
        for week in cal:
            for day in week:
                if day == 0:
                    days.append({'day': 0, 'count': 0})
                else:
                    date_obj = date(year, month, day)
                    count = date_counts.get(date_obj, 0)
                    days.append({
                        'day': day,
                        'count': count,
                        'date_str': f"{year:04d}-{month:02d}-{day:02d}"
                    })

        month_data.append({
            'name': month_names[month],
            'days': days
        })

    return render_template('browse.html',
                         year=year,
                         month_data=month_data,
                         available_years=available_years)


@app.route('/date/<date_str>')
def papers_by_date(date_str):
    """Show papers from a specific date."""
    from datetime import datetime
    try:
        date = datetime.strptime(date_str, '%Y-%m-%d').date()
    except ValueError:
        abort(404)

    conn = get_db_connection()
    cursor = conn.cursor()

    cursor.execute("""
        SELECT id, arxiv_id, title, abstract, published_date, updated_date,
               journal_ref, doi, comment, primary_category
        FROM papers
        WHERE DATE(published_date) = %s
        ORDER BY id DESC
    """, (date,))

    papers = cursor.fetchall()

    # Get authors for each paper
    for paper in papers:
        paper['authors'] = get_paper_authors(cursor, paper['id'])

    cursor.close()
    conn.close()

    return render_template('date.html',
                         date=date,
                         papers=papers)


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)
