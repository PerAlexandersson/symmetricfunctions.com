# arXiv Combinatorics Frontend - Setup & Usage

## Quick Start (Local Development)

### 1. Install Dependencies

```bash
# Use a virtual environment (recommended)
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```

### 2. Create Environment File

**CRITICAL FOR SECURITY:** Never commit passwords to git!

```bash
# Copy the example file
cp .env.example .env

# Edit .env and set your actual password
nano .env  # or use your preferred editor
```

Your `.env` file should look like:
```
DB_HOST=localhost
DB_USER=arxiv_user
DB_PASSWORD=your_actual_password_here
DB_NAME=arxiv_frontend
DB_CHARSET=utf8mb4
```

The `.env` file is in `.gitignore` and will NOT be committed to git.

### 3. Setup Database

The setup script now reads from your `.env` file!

```bash
chmod +x setup_database.sh
./setup_database.sh
```

This will:
- Install MariaDB
- Create database `arxiv_frontend`
- Create user `arxiv_user` (with password from `.env`)
- Import schema from `schema.sql`

### 4. Test Configuration

```bash
# Verify your config is loaded correctly
python3 config.py
```

Fetch a single paper to test:

```bash
python3 fetch_arxiv.py --arxiv-id 2401.12345
```

Fetch recent papers (last 2 days):

```bash
python3 fetch_arxiv.py --recent --days 2
```

### 5. Backfill Historical Data (Optional)

To populate the database with papers from 2000 to present:

```bash
chmod +x backfill_all.sh
./backfill_all.sh
```

This will take 30-60 minutes. You can also backfill specific date ranges:

```bash
python3 fetch_arxiv.py --backfill --start-date 2020-01-01 --end-date 2020-12-31
```

---

## Daily Updates (Cron Job)

To automatically fetch new papers daily, add this to your crontab:

```bash
# Edit crontab
crontab -e

# Add this line (runs at 2 AM daily)
0 2 * * * cd /path/to/arxiv-frontend && /usr/bin/python3 fetch_arxiv.py --recent --days 2 >> /var/log/arxiv_fetch.log 2>&1
```

---

## Verify Database

Connect to the database:

```bash
mysql -u arxiv_user -p arxiv_frontend
```

Check some statistics:

```sql
-- Count total papers
SELECT COUNT(*) FROM papers;

-- Count total authors
SELECT COUNT(*) FROM authors;

-- Show recent papers
SELECT arxiv_id, title, published_date 
FROM papers 
ORDER BY published_date DESC 
LIMIT 10;

-- Papers by year
SELECT YEAR(published_date) as year, COUNT(*) as count
FROM papers
GROUP BY YEAR(published_date)
ORDER BY year DESC;
```

---

## File Structure

```
arxiv-frontend/
├── .env.example              # Template for environment variables
├── .env                      # Your actual config (NOT in git!)
├── .gitignore                # Prevents committing secrets
├── config.py                 # Configuration loader
├── SPEC.md                   # Project specification
├── README.md                 # This file
├── requirements.txt          # Python dependencies
├── schema.sql                # Database schema
├── setup_database.sh         # Database setup script
├── reset_database.sh         # Database reset script
├── fetch_arxiv.py            # Main fetch script
├── backfill_all.sh          # Backfill helper script
└── (Flask app coming soon)
```

---

## Troubleshooting

**"DB_PASSWORD not set in environment variables"**
- Create a `.env` file: `cp .env.example .env`
- Edit `.env` and set your actual password
- Test: `python3 config.py`

**"Access denied for user"**
- Check that the password in `.env` matches the one you set in `setup_database.sh`
- Try connecting manually: `mysql -u arxiv_user -p`

**"No module named 'arxiv'"**
- Install dependencies: `pip3 install -r requirements.txt`

**"Too many results"**
- The arXiv API has rate limits. The scripts include delays.
- If backfilling fails, try smaller date ranges (month by month instead of year by year)

**"Connection refused"**
- Make sure MariaDB is running: `sudo systemctl status mariadb`
- Start it if needed: `sudo systemctl start mariadb`