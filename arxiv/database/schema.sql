-- arXiv Combinatorics Frontend Database Schema
-- MariaDB/MySQL compatible

-- Drop tables if they exist (for clean reinstall)
DROP TABLE IF EXISTS paper_authors;
DROP TABLE IF EXISTS authors;
DROP TABLE IF EXISTS papers;

-- ============================================================================
-- Papers Table
-- Stores main metadata for each arXiv paper
-- ============================================================================
CREATE TABLE papers (
    id INT AUTO_INCREMENT PRIMARY KEY,
    
    -- arXiv identifiers
    arxiv_id VARCHAR(20) UNIQUE NOT NULL,           -- e.g., "2401.12345" or "math/0601001"
    primary_category VARCHAR(20) DEFAULT 'math.CO', -- Always math.CO for this project
    
    -- Paper metadata
    title TEXT NOT NULL,
    abstract TEXT NOT NULL,
    
    -- Dates
    published_date DATE NOT NULL,                   -- First submission date
    updated_date DATE,                              -- Last update/revision (NULL if never updated)
    
    -- Publication info (optional)
    comment TEXT,                                   -- e.g., "23 pages, 5 figures, to appear in Combinatorica"
    journal_ref TEXT,                               -- e.g., "J. Combin. Theory Ser. A 156 (2018), 1-23"
    doi VARCHAR(100),                               -- Digital Object Identifier
    
    -- Internal tracking
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- Indexes for common queries
    INDEX idx_arxiv_id (arxiv_id),
    INDEX idx_published_date (published_date),
    INDEX idx_updated_date (updated_date)
    
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================================
-- Authors Table
-- Stores unique author names to avoid duplication
-- ============================================================================
CREATE TABLE authors (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    
    -- Ensure uniqueness (same author name stored only once)
    UNIQUE KEY idx_unique_name (name),
    INDEX idx_name (name)
    
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================================
-- Paper-Authors Junction Table
-- Many-to-many relationship: papers can have multiple authors,
-- authors can have multiple papers
-- ============================================================================
CREATE TABLE paper_authors (
    paper_id INT NOT NULL,
    author_id INT NOT NULL,
    author_order INT NOT NULL,    -- Position in author list (1, 2, 3, ...)
    
    PRIMARY KEY (paper_id, author_id),
    
    -- Foreign key constraints
    FOREIGN KEY (paper_id) REFERENCES papers(id) ON DELETE CASCADE,
    FOREIGN KEY (author_id) REFERENCES authors(id) ON DELETE CASCADE,
    
    -- Indexes for common queries
    INDEX idx_author_id (author_id),
    INDEX idx_paper_id (paper_id),
    INDEX idx_author_order (paper_id, author_order)
    
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;