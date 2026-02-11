# arXiv Combinatorics Frontend - Specification

## Project Overview

A web interface for browsing arXiv papers in combinatorics (math.CO category). 
The goal is to provide an easier way to:
- Browse recent and historical submissions
- Get BibTeX entries quickly
- Search by author
- (Future) Track favorites and organize papers
- (Future) Keyword search.

**Domain:** arxiv.symmetricfunctions.com

---

## Tech Stack

- **Backend:** Python 3 + Flask
- **Database:** MariaDB (MySQL-compatible)
- **Frontend:** Plain HTML/CSS with minimal JavaScript
- **Data source:** arXiv API
---

## Features 

### Core Functionality
1. **Daily paper sync** - Cron job fetches new math.CO papers daily
2. **Browse recent papers** - Paginated list of recent submissions
3. **View paper details** - Title, authors, abstract, arXiv link
4. **BibTeX export** - One-click copy/download for any paper
5. **Author index** - Browse all papers by a specific author
6. **Simple search** - Search by title, author name


## Database Design

See `database/schema.sql` for the complete schema.

### Tables
 **`papers`** - Main paper metadata (arxiv_id, title, abstract, dates)
 **`authors`** - Author names (normalized, no duplicates)
 **`paper_authors`** - Many-to-many junction table

---

## Local Development Plan

### Phase 1: Get data flowing
1. Set up local MariaDB database
2. Create database schema
3. Write arXiv fetch script (test manually first)
4. Populate database with sample data

### Phase 2: Build Flask app
1. Basic Flask app structure
2. Database connection
3. Homepage + paper listing
4. Single paper view
5. BibTeX generation

### Phase 3: Search & browse
1. Author index page
2. Search functionality
3. Pagination
4. Basic styling

