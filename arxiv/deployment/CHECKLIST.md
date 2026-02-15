# Deployment Checklist

Use this checklist when deploying to production.

## Pre-Deployment

- [ ] Choose a domain name and point DNS to server IP
- [ ] Provision a VPS (minimum 1GB RAM, 25GB storage)
- [ ] Have SSH access with sudo privileges
- [ ] Purchase or set up domain name

## Server Setup

- [ ] Update system packages (`apt update && apt upgrade`)
- [ ] Install MariaDB, Nginx, Python3, certbot
- [ ] Secure MariaDB (`mysql_secure_installation`)
- [ ] Configure firewall (UFW: allow SSH, HTTP, HTTPS)

## Application Setup

- [ ] Upload/clone code to `/var/www/arxiv`
- [ ] Create virtual environment in `/var/www/arxiv/venv`
- [ ] Install dependencies (`pip install -r requirements.txt`)
- [ ] Create `.env` file with production values
  - [ ] Set strong `DB_PASSWORD`
  - [ ] Generate and set `FLASK_SECRET_KEY`
  - [ ] Set `FLASK_DEBUG=False`
- [ ] Create database and user
- [ ] Import schema (`mysql < schema.sql`)
- [ ] Test database connection
- [ ] Fetch initial papers (at least 7 days)

## Web Server Configuration

- [ ] Copy `deployment/arxiv.service` to `/etc/systemd/system/`
- [ ] Copy `deployment/gunicorn.conf.py` to `/var/www/arxiv/deployment/`
- [ ] Create log directory: `/var/log/arxiv`
- [ ] Set proper ownership: `chown www-data:www-data -R /var/www/arxiv`
- [ ] Enable and start arxiv service (`systemctl enable arxiv && systemctl start arxiv`)
- [ ] Verify service is running (`systemctl status arxiv`)

## Nginx Configuration

- [ ] Copy `deployment/nginx.conf` to `/etc/nginx/sites-available/arxiv`
- [ ] Update `server_name` to your domain
- [ ] Create symlink to sites-enabled
- [ ] Remove default site
- [ ] Test nginx config (`nginx -t`)
- [ ] Reload nginx (`systemctl reload nginx`)

## SSL/HTTPS

- [ ] Run certbot (`certbot --nginx -d yourdomain.com`)
- [ ] Test auto-renewal (`certbot renew --dry-run`)
- [ ] Verify HTTPS works

## Automation

- [ ] Set up daily paper fetch cron job
- [ ] Set up database backup cron job
- [ ] Test both cron jobs manually

## Security Hardening

- [ ] Review firewall rules
- [ ] Install fail2ban (optional but recommended)
- [ ] Review nginx rate limiting
- [ ] Ensure `.env` is not in git
- [ ] Ensure debug mode is off
- [ ] Review file permissions

## Testing

- [ ] Test homepage loads
- [ ] Test paper detail pages
- [ ] Test search functionality
- [ ] Test BibTeX generation
- [ ] Test author pages
- [ ] Test browse by date
- [ ] Test tools page
- [ ] Test all links work
- [ ] Test mobile responsiveness
- [ ] Test SSL certificate

## Monitoring & Logging

- [ ] Set up uptime monitoring (UptimeRobot, StatusCake, etc.)
- [ ] Verify logs are being written:
  - [ ] `/var/log/arxiv/gunicorn.log`
  - [ ] `/var/log/nginx/arxiv-access.log`
  - [ ] `/var/log/nginx/arxiv-error.log`
  - [ ] `/var/log/arxiv-fetch.log`
- [ ] Set up log rotation if needed

## Documentation

- [ ] Document server details (IP, login, etc.) securely
- [ ] Document database credentials (keep secure!)
- [ ] Create runbook for common tasks
- [ ] Note location of backups

## Go Live

- [ ] Announce to intended audience
- [ ] Submit to Google Search Console (optional)
- [ ] Add to relevant directories (optional)

## Post-Launch

- [ ] Monitor logs for first few days
- [ ] Check database is growing (new papers being added)
- [ ] Verify backups are working
- [ ] Monitor server resources (disk, RAM, CPU)
- [ ] Set calendar reminder to renew domain name

## Emergency Contacts

Document these somewhere secure:
- VPS provider support
- Domain registrar support
- Your own contact info for recovery

## Rollback Plan

If something goes wrong:
1. Check logs: `journalctl -u arxiv -n 100`
2. Restart service: `systemctl restart arxiv`
3. If database issue: restore from backup
4. If code issue: revert to previous version
5. If all else fails: disable site and debug offline
