#!/bin/bash
# Reset/recreate the arXiv frontend database
# Use this if MariaDB is already installed and you just want to reset the database

set -e

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

echo "========================================="
echo "Resetting arXiv Frontend Database"
echo "========================================="
echo "This will DROP and recreate the database!"
echo "All data will be lost. Press Ctrl+C to cancel."
echo "Press Enter to continue..."
read

# Drop and recreate database
sudo mysql -e "DROP DATABASE IF EXISTS ${DB_NAME};"
sudo mysql -e "CREATE DATABASE ${DB_NAME} CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"

echo "Database dropped and recreated."

# Import schema
if [ -f "schema.sql" ]; then
    # Use MYSQL_PWD environment variable (more secure than command line)
    MYSQL_PWD="${DB_PASSWORD}" mysql -u ${DB_USER} ${DB_NAME} < schema.sql
    echo "Schema imported successfully!"
else
    echo "Error: schema.sql not found!"
    exit 1
fi

echo "========================================="
echo "Database reset complete!"
echo "========================================="