"""
config.py - Configuration management for arXiv frontend

Loads configuration from environment variables (.env file)
"""

import os
from dotenv import load_dotenv

# Load .env file if it exists
load_dotenv()

# Database configuration
DB_CONFIG = {
    'host': os.getenv('DB_HOST', 'localhost'),
    'user': os.getenv('DB_USER', 'arxiv_user'),
    'password': os.getenv('DB_PASSWORD'),
    'database': os.getenv('DB_NAME', 'arxiv_frontend'),
    'charset': os.getenv('DB_CHARSET', 'utf8mb4')
}

# Flask configuration (for later)
FLASK_CONFIG = {
    'SECRET_KEY': os.getenv('FLASK_SECRET_KEY', 'dev-secret-key-change-in-production'),
    'DEBUG': os.getenv('FLASK_DEBUG', 'False').lower() == 'true'
}

def validate_config():
    """Validate that required configuration is set."""
    if not DB_CONFIG['password']:
        raise ValueError(
            "DB_PASSWORD not set! "
            "Please create a .env file based on .env.example"
        )

if __name__ == '__main__':
    # Test configuration
    try:
        validate_config()
        print("Configuration loaded successfully:")
        print(f"  DB Host: {DB_CONFIG['host']}")
        print(f"  DB User: {DB_CONFIG['user']}")
        print(f"  DB Name: {DB_CONFIG['database']}")
        print(f"  Password: {'*' * len(DB_CONFIG['password'])}")
    except ValueError as e:
        print(f"Configuration error: {e}")