# Deploying to Shared Hosting (Web Hotel)

## Requirements Check

First, verify your hosting supports Python applications:

```bash
# SSH into your hosting
ssh -p 2020 symmetricf@ns12.inleed.net

# Check Python version
python3 --version

# Check if Passenger is available
passenger --version

# Check available modules
python3 -m pip list
```

## Common Shared Hosting Scenarios

### Scenario 1: Passenger WSGI (Best Case)

If your host supports Passenger (most modern shared hosts do):

1. **Setup subdomain in cPanel/control panel**
   - Create subdomain: `arxiv.symmetricfunctions.com`
   - Point document root to: `domains/symmetricfunctions.com/arxiv/public`

2. **Directory structure on server:**
   ```
   domains/symmetricfunctions.com/
   ├── public_html/          # Your main site
   └── arxiv/
       ├── public/           # Public directory (document root for subdomain)
       │   └── .htaccess
       ├── tmp/              # Passenger restart file location
       ├── src/              # Application code
       │   ├── app.py
       │   └── ...
       ├── venv/             # Virtual environment
       ├── .env              # Environment config
       ├── passenger_wsgi.py # Passenger entry point
       └── requirements.txt
   ```

3. **Deploy script** (see `deploy_shared.sh` below)

### Scenario 2: No Python Support

If your hosting doesn't support Python applications:

**Option A: Static export (LIMITED)**
- Generate static pages from Flask
- Won't have dynamic features (search, tags, etc.)
- Not recommended for this project

**Option B: Upgrade hosting**
- Get a VPS (~$5-10/month)
- Use the main DEPLOYMENT.md guide
- Full control over environment

**Option C: Use a different subdomain provider**
- Deploy to free tier: Railway, Render, Fly.io
- Point DNS CNAME for arxiv.symmetricfunctions.com

### Scenario 3: FastCGI (Older method)

Some older hosts use FastCGI instead of Passenger. Less common now but still supported.

## Deploying with Passenger (Recommended for Shared Hosting)

### 1. Test Python Support

```bash
ssh -p 2020 symmetricf@ns12.inleed.net "python3 --version && which python3"
```

### 2. Create Subdomain

In your hosting control panel:
- Add subdomain: `arxiv.symmetricfunctions.com`
- Document root: `domains/symmetricfunctions.com/arxiv/public`

### 3. Initial Setup on Server

```bash
ssh -p 2020 symmetricf@ns12.inleed.net

# Create directory structure
mkdir -p ~/domains/symmetricfunctions.com/arxiv/{public,tmp,src}

# Create virtual environment
cd ~/domains/symmetricfunctions.com/arxiv
python3 -m venv venv

# Activate venv
source venv/bin/activate

# Upgrade pip
pip install --upgrade pip
```

### 4. Deploy from Local Machine

Use the `deploy_shared.sh` script:

```bash
cd ~/Dropbox/symmetricfunctions.com/arxiv
./deployment/deploy_shared.sh
```

### 5. Database Setup

**Option A: SQLite (Simple, file-based)**
- No separate database server needed
- Good for small to medium sites
- Update config.py to use SQLite

**Option B: MySQL (Better performance)**
- Create database in cPanel
- Update .env with credentials
- Import schema

### 6. Restart Application

Passenger restarts when you touch the restart file:

```bash
ssh -p 2020 symmetricf@ns12.inleed.net "touch ~/domains/symmetricfunctions.com/arxiv/tmp/restart.txt"
```

## Troubleshooting

### Check if Passenger is working

Visit: `https://arxiv.symmetricfunctions.com`

If you see errors:
1. Check `~/domains/symmetricfunctions.com/arxiv/log/passenger.log`
2. Check `.htaccess` syntax
3. Verify Python version compatibility
4. Check file permissions

### Common Issues

**Import errors:**
- Make sure all requirements are installed in venv
- Check Python version matches between local and server

**Database errors:**
- Verify database credentials in .env
- Ensure database exists and user has permissions

**Passenger not starting:**
- Check `.htaccess` is in public/
- Verify passenger_wsgi.py exists
- Check Python path in passenger_wsgi.py

## Performance Considerations

Shared hosting has limitations:
- **Memory limits** - Usually 512MB-1GB per process
- **CPU limits** - Shared with other users
- **Process limits** - May kill long-running processes
- **Connection limits** - Limited concurrent connections

For better performance:
- Enable caching
- Optimize database queries
- Use CDN for static files
- Consider upgrading to VPS if site grows

## Cost Comparison

| Option | Monthly Cost | Control | Performance |
|--------|-------------|---------|-------------|
| Shared hosting | ~$5-15 | Limited | Shared resources |
| VPS | ~$5-10 | Full | Dedicated resources |
| Managed PaaS | ~$0-25 | Medium | Good |

## Next Steps

1. **Check Python support** on your hosting
2. **Test with a simple app** first
3. **If supported:** Use deploy_shared.sh script
4. **If not supported:** Consider VPS or PaaS options

Contact inleed.net support to ask:
- "Do you support Python/WSGI applications?"
- "Is Passenger available?"
- "What Python versions are supported?"
- "Can I create a virtual environment?"
