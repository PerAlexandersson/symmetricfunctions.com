#!/bin/bash
# Setup script for arXiv frontend database on Ubuntu
# This script installs MariaDB, creates the database, and imports the schema

set -e  # Exit on any error

echo "========================================="
echo "arXiv Frontend - Database Setup"
echo "========================================="

# Load configuration from .env file (in parent directory)
if [ ! -f "../.env" ]; then
    echo "Error: .env file not found in parent directory!"
    echo "Please create .env file in the project root:"
    echo "  cd .."
    echo "  cp .env.example .env"
    echo "  nano .env  # Edit and set your password"
    exit 1
fi

# Source the .env file
export $(grep -v '^#' ../.env | xargs)

# Validate required variables
if [ -z "$DB_PASSWORD" ]; then
    echo "Error: DB_PASSWORD not set in .env file!"
    exit 1
fi

# Use defaults for other variables if not set
DB_NAME="${DB_NAME:-arxiv_frontend}"
DB_USER="${DB_USER:-arxiv_user}"
DB_HOST="${DB_HOST:-localhost}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Step 1: Installing MariaDB...${NC}"
sudo apt update
sudo apt install -y mariadb-server mariadb-client

echo -e "${YELLOW}Step 2: Starting MariaDB service...${NC}"
sudo systemctl start mariadb
sudo systemctl enable mariadb

echo -e "${GREEN}MariaDB installed and running!${NC}"

echo -e "${YELLOW}Step 3: Securing MariaDB installation...${NC}"
echo "You'll be prompted to set a root password and answer some security questions."
echo "Press Enter to continue..."
read
sudo mysql_secure_installation

echo -e "${YELLOW}Step 4: Creating database and user...${NC}"
sudo mysql -e "CREATE DATABASE IF NOT EXISTS ${DB_NAME} CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
sudo mysql -e "CREATE USER IF NOT EXISTS '${DB_USER}'@'localhost' IDENTIFIED BY '${DB_PASSWORD}';"
sudo mysql -e "GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DB_USER}'@'localhost';"
sudo mysql -e "FLUSH PRIVILEGES;"

echo -e "${GREEN}Database '${DB_NAME}' created!${NC}"
echo -e "${GREEN}User '${DB_USER}' created with password '${DB_PASSWORD}'${NC}"

echo -e "${YELLOW}Step 5: Importing schema...${NC}"
if [ -f "schema.sql" ]; then
    # Use MYSQL_PWD environment variable (more secure than command line)
    MYSQL_PWD="${DB_PASSWORD}" mysql -u ${DB_USER} ${DB_NAME} < schema.sql
    echo -e "${GREEN}Schema imported successfully!${NC}"
else
    echo -e "${RED}Error: schema.sql not found in current directory!${NC}"
    echo "Please make sure schema.sql is in the same directory as this script."
    exit 1
fi

echo ""
echo "========================================="
echo -e "${GREEN}Setup Complete!${NC}"
echo "========================================="
echo "Database Name: ${DB_NAME}"
echo "Username: ${DB_USER}"
echo "Password: (stored in .env file)"
echo ""
echo "To connect manually:"
echo "  mysql -u ${DB_USER} -p ${DB_NAME}"
echo "  (You'll be prompted for password)"
echo ""
echo -e "${YELLOW}IMPORTANT: Keep your .env file secure and never commit it to git!${NC}"