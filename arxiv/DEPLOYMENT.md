# Deployment Guide - arXiv Combinatorics Frontend

This guide covers deploying the application to a production server.

## Prerequisites

- **Server**: Ubuntu 22.04+ VPS (DigitalOcean, Linode, AWS, etc.)
- **Domain**: A domain name pointed to your server's IP address
- **Access**: SSH access with sudo privileges

## Step-by-Step Deployment

### 1. Server Setup

```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install required packages
sudo apt install -y git python3 python3-pip python3-venv \
    mariadb-server nginx certbot python3-certbot-nginx

# Enable and start services
sudo systemctl enable mariadb nginx
sudo systemctl start mariadb nginx
```

### 2. Secure MariaDB

```bash
sudo mysql_secure_installation
```

Follow the prompts to set root password and secure the installation.

### 3. Clone and Setup Application

```bash
# Create application directory
sudo mkdir -p /var/www/arxiv
sudo chown $USER:$USER /var/www/arxiv

# Clone repository (or upload files)
cd /var/www/arxiv
# If using git:
git clone <your-repo-url> .
# Or use rsync/scp to upload your local files

# Create virtual environment
python3 -m venv venv
source venv/bin/activate

# Install dependencies
pip install --upgrade pip
pip install -r requirements.txt
pip install gunicorn  # Production WSGI server
```

### 4. Configure Environment

```bash
# Create .env file
cp .env.example .env
nano .env
```

Set production values:
```bash
DB_HOST=localhost
DB_USER=arxiv_user
DB_PASSWORD=<strong-random-password>
DB_NAME=arxiv_frontend
FLASK_SECRET_KEY=<generate-with-python-secrets>
FLASK_DEBUG=False
```

Generate a secret key:
```bash
python3 -c "import secrets; print(secrets.token_hex(32))"
```

### 5. Setup Database

```bash
cd /var/www/arxiv/database

# Run setup script
./setup_database.sh

# Or manually:
sudo mysql -e "CREATE DATABASE arxiv_frontend CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
sudo mysql -e "CREATE USER 'arxiv_user'@'localhost' IDENTIFIED BY 'your_password';"
sudo mysql -e "GRANT ALL PRIVILEGES ON arxiv_frontend.* TO 'arxiv_user'@'localhost';"
sudo mysql -e "FLUSH PRIVILEGES;"

# Import schema
mysql -u arxiv_user -p arxiv_frontend < schema.sql
```

### 6. Initial Data Load

```bash
cd /var/www/arxiv
source venv/bin/activate
cd src

# Fetch recent papers
python3 fetch_arxiv.py --recent --days 30

# Or backfill historical data (be patient, this takes time)
python3 fetch_arxiv.py --backfill --start-date 2024-01-01 --end-date 2024-12-31
```

### 7. Configure Gunicorn

Create systemd service file:

```bash
sudo nano /etc/systemd/system/arxiv.service
```

Paste the contents from `deployment/arxiv.service` (see configuration files below).

```bash
# Reload systemd and start service
sudo systemctl daemon-reload
sudo systemctl enable arxiv
sudo systemctl start arxiv

# Check status
sudo systemctl status arxiv
```

### 8. Configure Nginx

```bash
sudo nano /etc/nginx/sites-available/arxiv
```

Paste the contents from `deployment/nginx.conf` (see configuration files below).

```bash
# Enable site
sudo ln -s /etc/nginx/sites-available/arxiv /etc/nginx/sites-enabled/
sudo rm /etc/nginx/sites-enabled/default  # Remove default site

# Test configuration
sudo nginx -t

# Reload nginx
sudo systemctl reload nginx
```

### 9. Configure Firewall

```bash
# Enable firewall
sudo ufw allow OpenSSH
sudo ufw allow 'Nginx Full'
sudo ufw enable

# Check status
sudo ufw status
```

### 10. Setup SSL with Let's Encrypt

```bash
# Obtain certificate (replace with your domain)
sudo certbot --nginx -d arxiv.yourdomain.com

# Test auto-renewal
sudo certbot renew --dry-run
```

Certbot will automatically update your Nginx configuration for HTTPS.

### 11. Setup Automatic Paper Fetching

```bash
# Edit crontab
crontab -e
```

Add daily fetch job (runs at 6 AM UTC):
```cron
# Fetch new arXiv papers daily
0 6 * * * cd /var/www/arxiv && /var/www/arxiv/venv/bin/python3 src/fetch_arxiv.py --recent --days 2 >> /var/log/arxiv-fetch.log 2>&1
```

Create log file:
```bash
sudo touch /var/log/arxiv-fetch.log
sudo chown $USER:$USER /var/log/arxiv-fetch.log
```

### 12. Configure Logging

```bash
# Create log directory
sudo mkdir -p /var/log/arxiv
sudo chown $USER:$USER /var/log/arxiv

# Logs will be in:
# - /var/log/arxiv/gunicorn.log (application logs)
# - /var/log/nginx/access.log (web server access)
# - /var/log/nginx/error.log (web server errors)
# - /var/log/arxiv-fetch.log (paper fetching)
```

### 13. Database Backups

```bash
# Create backup script
sudo nano /usr/local/bin/backup-arxiv-db.sh
```

Paste:
```bash
#!/bin/bash
BACKUP_DIR="/var/backups/arxiv"
DATE=$(date +%Y%m%d_%H%M%S)
mkdir -p $BACKUP_DIR
mysqldump -u arxiv_user -p'password' arxiv_frontend | gzip > $BACKUP_DIR/arxiv_$DATE.sql.gz
# Keep only last 30 days
find $BACKUP_DIR -name "arxiv_*.sql.gz" -mtime +30 -delete
```

```bash
sudo chmod +x /usr/local/bin/backup-arxiv-db.sh

# Add to crontab (daily at 2 AM)
sudo crontab -e
```

Add:
```cron
0 2 * * * /usr/local/bin/backup-arxiv-db.sh
```

## Configuration Files

See the `deployment/` directory for:
- `arxiv.service` - Systemd service configuration
- `nginx.conf` - Nginx reverse proxy configuration
- `gunicorn.conf.py` - Gunicorn WSGI server configuration

## Useful Commands

```bash
# Restart application
sudo systemctl restart arxiv

# View application logs
sudo journalctl -u arxiv -f

# View nginx logs
sudo tail -f /var/log/nginx/access.log
sudo tail -f /var/log/nginx/error.log

# Check nginx configuration
sudo nginx -t

# Reload nginx (without downtime)
sudo systemctl reload nginx

# Manual database backup
mysqldump -u arxiv_user -p arxiv_frontend > backup.sql
```

## Monitoring & Maintenance

### Health Checks

Check these regularly:
- Application status: `sudo systemctl status arxiv`
- Database status: `sudo systemctl status mariadb`
- Nginx status: `sudo systemctl status nginx`
- Disk space: `df -h`
- SSL certificate expiry: `sudo certbot certificates`

### Updating the Application

```bash
cd /var/www/arxiv

# Pull latest changes
git pull  # or upload new files

# Activate venv and install any new dependencies
source venv/bin/activate
pip install -r requirements.txt

# Restart application
sudo systemctl restart arxiv
```

### Database Maintenance

```bash
# Optimize tables
mysql -u arxiv_user -p arxiv_frontend -e "OPTIMIZE TABLE papers, authors, paper_authors, tags, paper_tags;"

# Check table sizes
mysql -u arxiv_user -p arxiv_frontend -e "
SELECT
    table_name,
    ROUND(((data_length + index_length) / 1024 / 1024), 2) AS 'Size (MB)'
FROM information_schema.TABLES
WHERE table_schema = 'arxiv_frontend'
ORDER BY (data_length + index_length) DESC;"
```

## Security Considerations

1. **Keep software updated**:
   ```bash
   sudo apt update && sudo apt upgrade -y
   ```

2. **Use strong passwords** for database and server access

3. **Enable fail2ban** to prevent brute force attacks:
   ```bash
   sudo apt install fail2ban
   sudo systemctl enable fail2ban
   sudo systemctl start fail2ban
   ```

4. **Rate limiting** - Consider adding rate limiting in Nginx:
   ```nginx
   limit_req_zone $binary_remote_addr zone=api:10m rate=10r/s;
   ```

5. **Regular backups** - Test restoring from backup periodically

6. **Monitor logs** for suspicious activity

## Troubleshooting

### Application won't start
```bash
# Check logs
sudo journalctl -u arxiv -n 50
# Check if port is already in use
sudo netstat -tulpn | grep 8000
```

### Database connection errors
```bash
# Test database connection
mysql -u arxiv_user -p arxiv_frontend -e "SELECT COUNT(*) FROM papers;"
# Check .env file has correct credentials
```

### 502 Bad Gateway
```bash
# Check if Gunicorn is running
sudo systemctl status arxiv
# Check Nginx error logs
sudo tail -f /var/log/nginx/error.log
```

## Performance Tuning

### For larger databases (10k+ papers):

1. **MariaDB optimization** - Edit `/etc/mysql/mariadb.conf.d/50-server.cnf`:
   ```ini
   [mysqld]
   innodb_buffer_pool_size = 1G  # 70% of available RAM
   query_cache_size = 128M
   query_cache_type = 1
   ```

2. **Gunicorn workers** - Adjust workers in `gunicorn.conf.py`:
   ```python
   workers = (2 * cpu_count) + 1
   ```

3. **Nginx caching** - Add to Nginx config:
   ```nginx
   proxy_cache_path /var/cache/nginx levels=1:2 keys_zone=arxiv_cache:10m;
   proxy_cache arxiv_cache;
   proxy_cache_valid 200 1h;
   ```

## Cost Estimates

- **VPS**: $5-10/month (1GB RAM, 25GB storage - sufficient for small deployments)
- **Domain**: $10-15/year
- **SSL**: Free (Let's Encrypt)
- **Total**: ~$70-130/year

## Next Steps

After deployment:
1. Test the site thoroughly
2. Set up monitoring (UptimeRobot, StatusCake, etc.)
3. Submit to Google Search Console
4. Share with community!
