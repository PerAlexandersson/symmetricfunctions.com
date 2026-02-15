#!/usr/bin/env python3
"""
passenger_wsgi.py - Entry point for Passenger WSGI
This file is required for deploying Flask apps on shared hosting with Passenger
"""

import sys
import os

# Set up paths (Passenger already uses correct Python from .htaccess)
sys.path.insert(0, os.path.expanduser('~/domains/arxiv.symmetricfunctions.com/src'))
sys.path.insert(0, os.path.expanduser('~/domains/arxiv.symmetricfunctions.com'))

# Load environment variables from .env file
from dotenv import load_dotenv
env_path = os.path.expanduser('~/domains/arxiv.symmetricfunctions.com/.env')
load_dotenv(env_path)

# Import the Flask application
from src.app import app as application
