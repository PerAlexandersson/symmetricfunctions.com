#!/bin/bash
# Deploy script for shared hosting
# Based on your existing deploy script but adapted for Flask app

set -e  # Exit on error

# Configuration
LOCAL_PATH=~/Dropbox/symmetricfunctions.com/arxiv
REMOTE_HOST="symmetricf@ns12.inleed.net"
REMOTE_PORT="2020"
REMOTE_PATH="domains/arxiv.symmetricfunctions.com"

echo "========================================="
echo "Deploying arXiv Frontend to Shared Host"
echo "========================================="

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Step 1: Preparing files...${NC}"

# Make sure we're in the right directory
cd $LOCAL_PATH

# Set permissions
chmod -R u+rw,go+r,go-w $LOCAL_PATH
chmod +x deployment/*.sh

echo -e "${YELLOW}Step 2: Syncing application files...${NC}"

# Sync application code (excluding venv, database, logs)
rsync -avizL -e "ssh -p $REMOTE_PORT" \
    --exclude='*~' \
    --exclude='.git' \
    --exclude='__pycache__' \
    --exclude='*.pyc' \
    --exclude='venv/' \
    --exclude='database/' \
    --exclude='*.log' \
    --exclude='.env' \
    --exclude='deployment/deploy_shared.sh' \
    --exclude='DEPLOYMENT.md' \
    src/ \
    $REMOTE_HOST:$REMOTE_PATH/src/

echo -e "${YELLOW}Step 3: Syncing static files...${NC}"

# Sync static files to public_html directory
rsync -avizL -e "ssh -p $REMOTE_PORT" \
    --exclude='*~' \
    src/static/ \
    $REMOTE_HOST:$REMOTE_PATH/public_html/static/

# Sync templates
rsync -avizL -e "ssh -p $REMOTE_PORT" \
    --exclude='*~' \
    src/templates/ \
    $REMOTE_HOST:$REMOTE_PATH/src/templates/

# Sync database schema
echo -e "${YELLOW}Step 3.5: Syncing database schema...${NC}"
rsync -avizL -e "ssh -p $REMOTE_PORT" \
    --exclude='*~' \
    --exclude='*.db' \
    --exclude='*.sqlite' \
    database/ \
    $REMOTE_HOST:$REMOTE_PATH/database/

echo -e "${YELLOW}Step 4: Syncing configuration files...${NC}"

# Upload Passenger WSGI file
scp -P $REMOTE_PORT passenger_wsgi.py \
    $REMOTE_HOST:$REMOTE_PATH/

# Upload requirements.txt
scp -P $REMOTE_PORT requirements.txt \
    $REMOTE_HOST:$REMOTE_PATH/

# Upload .htaccess (you'll need to customize this first!)
if [ -f "deployment/.htaccess" ]; then
    scp -P $REMOTE_PORT deployment/.htaccess \
        $REMOTE_HOST:$REMOTE_PATH/public_html/
else
    echo -e "${YELLOW}Warning: .htaccess not found. Create it from htaccess_template${NC}"
fi

# Upload .htaccess for static directory (disables mod_security)
if [ -f "deployment/static_htaccess" ]; then
    scp -P $REMOTE_PORT deployment/static_htaccess \
        $REMOTE_HOST:$REMOTE_PATH/public_html/static/.htaccess
fi

echo -e "${YELLOW}Step 5: Uploading .env...${NC}"

# Use .env.production for deployment
if [ -f ".env.production" ]; then
    scp -P $REMOTE_PORT .env.production \
        $REMOTE_HOST:$REMOTE_PATH/.env
    echo -e "${GREEN}.env.production uploaded as .env${NC}"
elif [ -f ".env" ]; then
    scp -P $REMOTE_PORT .env \
        $REMOTE_HOST:$REMOTE_PATH/.env
    echo -e "${GREEN}.env uploaded${NC}"
else
    echo -e "${YELLOW}Warning: .env.production not found. You'll need to create .env on the server manually.${NC}"
    echo -e "${YELLOW}Make sure to set FLASK_DEBUG=False for production!${NC}"
fi

echo -e "${YELLOW}Step 6: Installing dependencies on server...${NC}"

# SSH into server and install dependencies
ssh -p $REMOTE_PORT $REMOTE_HOST << 'ENDSSH'
cd ~/domains/arxiv.symmetricfunctions.com

# Use cPanel virtualenv (created via Python App Manager)
source ~/virtualenv/domains/arxiv.symmetricfunctions.com/3.9/bin/activate

# Install dependencies
pip install --upgrade pip
pip install -r requirements.txt

# Create necessary directories
mkdir -p tmp
mkdir -p public_html/static
mkdir -p log

# Set permissions
chmod -R 755 public_html
chmod 755 passenger_wsgi.py

# Set static files to 664 (required for cPanel/CloudLinux)
chmod 664 public_html/static/*.css public_html/static/*.js 2>/dev/null || true
ENDSSH

echo -e "${YELLOW}Step 7: Restarting application...${NC}"

# Restart Passenger by touching restart.txt
ssh -p $REMOTE_PORT $REMOTE_HOST "touch ~/domains/arxiv.symmetricfunctions.com/tmp/restart.txt"

echo ""
echo -e "${GREEN}=========================================${NC}"
echo -e "${GREEN}Deployment Complete!${NC}"
echo -e "${GREEN}=========================================${NC}"
echo ""
echo "Your app should be live at: https://arxiv.symmetricfunctions.com"
echo ""
echo "Useful commands:"
echo "  View logs: ssh -p $REMOTE_PORT $REMOTE_HOST 'tail -f domains/arxiv.symmetricfunctions.com/log/passenger.log'"
echo "  Restart:   ssh -p $REMOTE_PORT $REMOTE_HOST 'touch domains/arxiv.symmetricfunctions.com/tmp/restart.txt'"
echo ""
echo "If you see errors:"
echo "  1. Check that subdomain is configured in cPanel"
echo "  2. Verify .env file exists on server with correct database credentials"
echo "  3. Check passenger.log for detailed errors"
echo ""
