# Quick Setup for arxiv.symmetricfunctions.com

Follow these steps to deploy your Flask app to shared hosting.

## Step 1: Check Hosting Compatibility (5 minutes)

```bash
# SSH into your hosting
ssh -p 2020 symmetricf@ns12.inleed.net

# Run these checks:
python3 --version          # Should show Python 3.7+
which python3              # Should show path
python3 -m venv --help     # Should show help (venv support)
passenger --version        # Check if Passenger is available

# Exit SSH
exit
```

**If Python 3 is not available or venv doesn't work**, contact inleed.net support or consider VPS option.

## Step 2: Configure Subdomain (via cPanel/Control Panel)

1. Log into your hosting control panel
2. Go to "Domains" or "Subdomains" section
3. Add new subdomain:
   - **Subdomain**: `arxiv`
   - **Domain**: `symmetricfunctions.com`
   - **Document Root**: `domains/symmetricfunctions.com/arxiv/public`
4. Save and wait for DNS propagation (~5-30 minutes)

## Step 3: Setup Database

**Option A: MySQL (Recommended if available)**

In cPanel:
1. Create new MySQL database: `symmetricf_arxiv`
2. Create new MySQL user: `symmetricf_arxiv_user`
3. Add user to database with ALL PRIVILEGES
4. Note down the credentials

**Option B: SQLite (Simpler)**

Will be created automatically, just need to set permissions later.

## Step 4: Initial Server Setup

```bash
# SSH into server
ssh -p 2020 symmetricf@ns12.inleed.net

# Create directory structure
mkdir -p ~/domains/symmetricfunctions.com/arxiv/{public,tmp,src,log,data}

# Create virtual environment
cd ~/domains/symmetricfunctions.com/arxiv
python3 -m venv venv

# Activate venv
source venv/bin/activate

# Install Flask to test
pip install flask

# Test Python is working
python3 -c "import flask; print(f'Flask {flask.__version__} installed successfully')"

# Exit for now
exit
```

## Step 5: Prepare Local Files

```bash
cd ~/Dropbox/symmetricfunctions.com/arxiv

# Create .htaccess from template
cp deployment/htaccess_template deployment/.htaccess

# Edit .htaccess - update username if needed:
# Change /home/symmetricf/ to match your actual home directory
nano deployment/.htaccess

# Create production .env
cp .env.production .env.production.tmp
nano .env.production.tmp

# Fill in:
# - Database credentials (from Step 3)
# - Secret key: python3 -c "import secrets; print(secrets.token_hex(32))"
# - Set FLASK_DEBUG=False
```

## Step 6: Deploy!

```bash
cd ~/Dropbox/symmetricfunctions.com/arxiv

# Run deploy script
./deployment/deploy_shared.sh
```

The script will:
- Upload all application files
- Install Python dependencies on server
- Configure Passenger
- Restart the application

## Step 7: Setup Database Schema

```bash
# SSH into server
ssh -p 2020 symmetricf@ns12.inleed.net

cd ~/domains/symmetricfunctions.com/arxiv

# Activate venv
source venv/bin/activate

# If using MySQL:
# Upload schema.sql first, then:
mysql -u symmetricf_arxiv_user -p symmetricf_arxiv < database/schema.sql

# If using SQLite:
# You'll need to adapt the schema for SQLite or use a migration tool

# Exit
exit
```

## Step 8: Fetch Initial Papers

```bash
# SSH into server
ssh -p 2020 symmetricf@ns12.inleed.net

cd ~/domains/symmetricfunctions.com/arxiv/src
source ../venv/bin/activate

# Fetch recent papers
python3 fetch_arxiv.py --recent --days 7

# Exit
exit
```

## Step 9: Setup Cron Job for Daily Updates

In cPanel:
1. Go to "Cron Jobs"
2. Add new cron job:
   - **Common Settings**: Once Per Day (@ midnight)
   - **Command**:
     ```bash
     cd /home/symmetricf/domains/symmetricfunctions.com/arxiv/src && /home/symmetricf/domains/symmetricfunctions.com/arxiv/venv/bin/python3 fetch_arxiv.py --recent --days 2 >> /home/symmetricf/domains/symmetricfunctions.com/arxiv/log/fetch.log 2>&1
     ```

## Step 10: Test!

Visit: `https://arxiv.symmetricfunctions.com`

If you see errors:
```bash
# Check logs
ssh -p 2020 symmetricf@ns12.inleed.net
tail -50 ~/domains/symmetricfunctions.com/arxiv/log/passenger.log
```

Common issues:
- **404 Not Found**: Subdomain not configured or DNS not propagated yet
- **500 Internal Error**: Check passenger.log, usually Python path or import errors
- **503 Service Unavailable**: Passenger configuration issue, check .htaccess

## Updating the Application

After making changes locally:

```bash
cd ~/Dropbox/symmetricfunctions.com/arxiv

# Deploy updates
./deployment/deploy_shared.sh

# Restart app
ssh -p 2020 symmetricf@ns12.inleed.net "touch ~/domains/symmetricfunctions.com/arxiv/tmp/restart.txt"
```

## Useful Commands

```bash
# View logs
ssh -p 2020 symmetricf@ns12.inleed.net "tail -f ~/domains/symmetricfunctions.com/arxiv/log/passenger.log"

# Restart app
ssh -p 2020 symmetricf@ns12.inleed.net "touch ~/domains/symmetricfunctions.com/arxiv/tmp/restart.txt"

# Check disk usage
ssh -p 2020 symmetricf@ns12.inleed.net "du -sh ~/domains/symmetricfunctions.com/arxiv"

# Backup database (MySQL)
ssh -p 2020 symmetricf@ns12.inleed.net "mysqldump -u user -p dbname > ~/arxiv_backup.sql"
```

## Troubleshooting

### Python Import Errors

Make sure paths in `passenger_wsgi.py` match your server structure:
- Check `~/domains/` vs `/home/username/domains/`
- Verify username is correct

### Database Connection Errors

- Verify credentials in `.env`
- Check database exists: `mysql -u user -p -e "SHOW DATABASES;"`
- Test connection: `mysql -u user -p dbname -e "SELECT 1;"`

### Static Files Not Loading

- Check `public/static/` directory exists
- Verify `.htaccess` allows static files
- Check file permissions: `chmod -R 755 public/`

## Getting Help

1. **Check passenger.log** - This has detailed error messages
2. **Contact support** - inleed.net support can help with Passenger configuration
3. **Test locally first** - Make sure app works with `./run_app.sh` locally

## Alternative: If Shared Hosting Doesn't Work

If your shared hosting doesn't support Python/Passenger well:

1. **Free tiers** (good for testing):
   - Railway.app (500 hours/month free)
   - Render.com (free tier available)
   - Fly.io (free tier available)

2. **Budget VPS** (~$5/month):
   - DigitalOcean
   - Linode
   - Hetzner
   - Vultr

Use CNAME DNS record to point `arxiv.symmetricfunctions.com` to the service.
