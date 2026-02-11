# arXiv Combinatorics Frontend - Quick Start Guide

## Setup Complete!

Your arXiv scraping and browsing system is now fully functional.

## What's Working

- ✅ Python virtual environment with all dependencies
- ✅ MariaDB database with schema
- ✅ arXiv fetch script (tested and working)
- ✅ Flask web application with full UI
- ✅ 116 papers already in the database

## How to Use

### 1. Fetch New Papers

Fetch papers from the last few days:
```bash
cd /home/peal0658/Dropbox/symmetricfunctions.com/arxiv/src
source ../venv/bin/activate
python3 fetch_arxiv.py --recent --days 7
```

Fetch a specific paper:
```bash
python3 fetch_arxiv.py --arxiv-id 2401.12345
```

Backfill historical data:
```bash
python3 fetch_arxiv.py --backfill --start-date 2024-01-01 --end-date 2024-12-31
```

### 2. Run the Web Interface

Start the Flask app:
```bash
cd /home/peal0658/Dropbox/symmetricfunctions.com/arxiv
./run_app.sh
```

Then visit **http://localhost:5000** in your browser.

### 3. Available Features

The web interface includes:
- **Homepage** - Browse all papers sorted by date
- **Paper Details** - View full abstracts and metadata
- **BibTeX Export** - One-click copy/download for citations
- **Search** - Search by title, author, or abstract
- **Author Pages** - View all papers by a specific author
- **Pagination** - Navigate through large result sets

### 4. Database Access

Connect to the database directly:
```bash
mysql -u arxiv_user -p arxiv_frontend
# Password: anaconda-revisits-the-maroon-panther
```

Useful queries:
```sql
-- Total papers
SELECT COUNT(*) FROM papers;

-- Papers by year
SELECT YEAR(published_date) as year, COUNT(*) as count
FROM papers
GROUP BY YEAR(published_date)
ORDER BY year DESC;

-- Most prolific authors
SELECT a.name, COUNT(*) as paper_count
FROM authors a
JOIN paper_authors pa ON a.id = pa.author_id
GROUP BY a.name
ORDER BY paper_count DESC
LIMIT 10;
```

### 5. Set Up Daily Updates (Optional)

Add to crontab to automatically fetch new papers:
```bash
crontab -e
```

Add this line (runs at 2 AM daily):
```
0 2 * * * cd /home/peal0658/Dropbox/symmetricfunctions.com/arxiv/src && source ../venv/bin/activate && python3 fetch_arxiv.py --recent --days 2 >> /var/log/arxiv_fetch.log 2>&1
```

## File Structure

```
arxiv/
├── .env                    # Database credentials (DO NOT COMMIT)
├── venv/                   # Python virtual environment
├── src/
│   ├── config.py          # Configuration loader
│   ├── fetch_arxiv.py     # arXiv scraping script
│   ├── app.py             # Flask web application
│   └── templates/         # HTML templates
├── database/
│   ├── schema.sql         # Database schema
│   └── setup_database.sh  # Database setup script
├── run_app.sh             # Quick start script
└── README.md              # Full documentation
```

## Troubleshooting

**"No papers showing"**
- Run the fetch script to populate the database
- Check database connection: `python3 src/config.py`

**"Can't connect to database"**
- Verify MariaDB is running: `systemctl status mariadb`
- Check credentials in `.env` file

**"Port 5000 already in use"**
- Stop other Flask apps or change port in `src/app.py`

**"Module not found"**
- Activate virtual environment: `source venv/bin/activate`

## Next Steps

1. **Backfill more data** - Populate the database with historical papers
2. **Set up cron job** - Automate daily updates
3. **Deploy to web server** - Make it publicly accessible
4. **Add features** - Favorites, RSS feeds, etc.

## Support

For issues or questions, refer to:
- [README.md](README.md) - Full documentation
- [SPEC.md](SPEC.md) - Project specification
