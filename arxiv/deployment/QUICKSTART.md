# Quick Start - Deploy Now!

Your subdomain is ready: `arxiv.symmetricfunctions.com` → `/domains/arxiv.symmetricfunctions.com/public_html`

All paths have been updated to match your hosting structure. Follow these steps to deploy:

## Step 1: Update .env for Production (2 minutes)

```bash
cd ~/Dropbox/symmetricfunctions.com/arxiv

# Edit your .env file
nano .env
```

Update these values for production:
```bash
# Database (you'll create this in Step 3)
DB_HOST=localhost
DB_USER=symmetricf_arxiv     # Your MySQL username from cPanel
DB_PASSWORD=strong-password   # Your MySQL password from cPanel
DB_NAME=symmetricf_arxiv_db  # Your database name from cPanel

# Flask - Generate new secret key
FLASK_SECRET_KEY=PASTE_SECRET_KEY_HERE
FLASK_DEBUG=False  # IMPORTANT: Must be False for production!
```

Generate a secret key:
```bash
python3 -c "import secrets; print(secrets.token_hex(32))"
```

Copy the output and paste it as `FLASK_SECRET_KEY`.

**Note:** After deploying, you can switch back to local settings for development.

## Step 2: Initial Server Setup (5 minutes)

```bash
# SSH into your server
ssh -p 2020 symmetricf@ns12.inleed.net

# Create directory structure
cd ~/domains/arxiv.symmetricfunctions.com
mkdir -p tmp log data src

# Create virtual environment
python3 -m venv venv

# Test it works
source venv/bin/activate
python3 -c "import sys; print(f'Python {sys.version}')"

# Exit SSH for now
exit
```

## Step 3: Create Database (via cPanel)

1. Log into your hosting control panel
2. Go to **MySQL Databases**
3. Create new database:
   - Name: `symmetricf_arxiv_db` (or similar)
4. Create new user:
   - Username: `symmetricf_arxiv`
   - Password: (generate strong password)
5. Add user to database with **ALL PRIVILEGES**
6. **Important:** Update `.env.production.real` with these credentials!

## Step 4: Deploy! (5 minutes)

```bash
cd ~/Dropbox/symmetricfunctions.com/arxiv

# Deploy
./deployment/deploy_shared.sh
```

This will:
- Upload all application files
- Install Python dependencies (Flask 2.0.3 for Python 3.6)
- Configure Passenger
- Set up static files
- Restart the application

## Step 5: Setup Database Schema (3 minutes)

```bash
# First, upload the schema file
scp -P 2020 database/schema.sql symmetricf@ns12.inleed.net:domains/arxiv.symmetricfunctions.com/

# SSH into server
ssh -p 2020 symmetricf@ns12.inleed.net

# Import schema
mysql -u symmetricf_arxiv -p symmetricf_arxiv_db < ~/domains/arxiv.symmetricfunctions.com/schema.sql

# Verify tables were created
mysql -u symmetricf_arxiv -p symmetricf_arxiv_db -e "SHOW TABLES;"

# You should see: papers, authors, paper_authors, tags, paper_tags

# Exit
exit
```

## Step 6: Fetch Initial Papers (10 minutes)

```bash
# SSH into server
ssh -p 2020 symmetricf@ns12.inleed.net

# Go to app directory
cd ~/domains/arxiv.symmetricfunctions.com/src

# Activate venv
source ../venv/bin/activate

# Fetch recent papers (this may take a few minutes)
python3 fetch_arxiv.py --recent --days 7

# Check how many papers were added
mysql -u symmetricf_arxiv -p symmetricf_arxiv_db -e "SELECT COUNT(*) FROM papers;"

# Exit
exit
```

## Step 7: Test Your Site!

Visit: **https://arxiv.symmetricfunctions.com**

You should see your arXiv paper browser!

### If You See Errors

**500 Internal Server Error:**
```bash
# Check logs
ssh -p 2020 symmetricf@ns12.inleed.net "tail -50 ~/domains/arxiv.symmetricfunctions.com/log/passenger.log"
```

**404 Not Found:**
- DNS might still be propagating (wait 10-30 minutes)
- Check subdomain configuration in cPanel

**Database errors:**
- Verify credentials in `.env.production.real`
- Test database connection: `mysql -u symmetricf_arxiv -p symmetricf_arxiv_db -e "SELECT 1;"`

## Step 8: Setup Daily Updates (Optional, 2 minutes)

In cPanel → Cron Jobs:

**Command:**
```bash
cd /home/symmetricf/domains/arxiv.symmetricfunctions.com/src && /home/symmetricf/domains/arxiv.symmetricfunctions.com/venv/bin/python3 fetch_arxiv.py --recent --days 2 >> /home/symmetricf/domains/arxiv.symmetricfunctions.com/log/fetch.log 2>&1
```

**Schedule:** Once per day (e.g., 6:00 AM)

## Updating Your Site

After making local changes:

```bash
cd ~/Dropbox/symmetricfunctions.com/arxiv

# Deploy updates
./deployment/deploy_shared.sh

# If you changed Python code, restart:
ssh -p 2020 symmetricf@ns12.inleed.net "touch ~/domains/arxiv.symmetricfunctions.com/tmp/restart.txt"
```

## Useful Commands

```bash
# View logs
ssh -p 2020 symmetricf@ns12.inleed.net "tail -f ~/domains/arxiv.symmetricfunctions.com/log/passenger.log"

# Restart app
ssh -p 2020 symmetricf@ns12.inleed.net "touch ~/domains/arxiv.symmetricfunctions.com/tmp/restart.txt"

# Check database size
ssh -p 2020 symmetricf@ns12.inleed.net "mysql -u symmetricf_arxiv -p symmetricf_arxiv_db -e 'SELECT COUNT(*) as total_papers FROM papers;'"

# Backup database
ssh -p 2020 symmetricf@ns12.inleed.net "mysqldump -u symmetricf_arxiv -p symmetricf_arxiv_db > ~/arxiv_backup_$(date +%Y%m%d).sql"
```

## Next Steps

Once everything is working:

1. **Test all features:**
   - Browse papers by date
   - Search functionality
   - BibTeX generation
   - Author pages
   - Tools page

2. **Optional improvements:**
   - Set up SSL certificate (usually free in cPanel via Let's Encrypt)
   - Add more MSC tags to papers
   - Backfill more historical papers

3. **Ask your hosting to update Python:**
   Email support to request Python 3.9+ for better security and features

## That's It!

Your arXiv combinatorics browser should now be live at `arxiv.symmetricfunctions.com`! 🎉

Questions? Check the logs or the detailed guides in the `deployment/` directory.
