-- arXiv Combinatorics Frontend Database Schema
-- MariaDB/MySQL compatible

-- Disable foreign key checks temporarily to allow dropping tables
SET FOREIGN_KEY_CHECKS = 0;

-- Drop tables if they exist (for clean reinstall)
DROP TABLE IF EXISTS paper_authors;
DROP TABLE IF EXISTS paper_tags;
DROP TABLE IF EXISTS authors;
DROP TABLE IF EXISTS papers;
DROP TABLE IF EXISTS tags;

-- Re-enable foreign key checks
SET FOREIGN_KEY_CHECKS = 1;

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
    slug VARCHAR(255),                    -- URL-friendly version of name

    -- Ensure uniqueness (same author name stored only once)
    UNIQUE KEY idx_unique_name (name),
    INDEX idx_name (name),
    INDEX idx_author_slug (slug)

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

-- ============================================================================
-- Tags Table
-- Stores all tags (MSC codes, personal tags, arXiv categories, etc.)
-- ============================================================================
CREATE TABLE tags (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,

    -- Tag type: 'msc' for MSC 2020 codes, 'personal' for custom tags,
    -- 'arxiv' for arXiv categories, 'other' for miscellaneous
    tag_type ENUM('msc', 'personal', 'arxiv', 'other') DEFAULT 'personal',

    -- Optional description
    description TEXT,

    -- For hierarchical tags (e.g., MSC 05A is parent of 05A15)
    parent_tag_id INT,

    -- Ensure unique name per type
    UNIQUE KEY idx_unique_tag (name, tag_type),
    INDEX idx_tag_name (name),
    INDEX idx_tag_type (tag_type),

    FOREIGN KEY (parent_tag_id) REFERENCES tags(id) ON DELETE SET NULL

) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================================
-- Paper-Tags Junction Table
-- Many-to-many relationship: papers can have multiple tags,
-- tags can be applied to multiple papers
-- ============================================================================
CREATE TABLE paper_tags (
    paper_id INT NOT NULL,
    tag_id INT NOT NULL,

    -- Track when tag was added (useful for personal tags)
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    PRIMARY KEY (paper_id, tag_id),

    -- Foreign key constraints
    FOREIGN KEY (paper_id) REFERENCES papers(id) ON DELETE CASCADE,
    FOREIGN KEY (tag_id) REFERENCES tags(id) ON DELETE CASCADE,

    -- Indexes for common queries
    INDEX idx_paper_id (paper_id),
    INDEX idx_tag_id (tag_id)

) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================================
-- Full-Text Search Index
-- Enable fast searching in title and abstract
-- ============================================================================
ALTER TABLE papers ADD FULLTEXT INDEX idx_fulltext_search (title, abstract);

-- ============================================================================
-- Pre-populate Common MSC 2020 Codes for Combinatorics
-- ============================================================================
INSERT INTO tags (name, tag_type, description) VALUES
    ('05A05', 'msc', 'Permutations, words, matrices'),
    ('05A10', 'msc', 'Factorials, binomial coefficients, combinatorial functions'),
    ('05A15', 'msc', 'Exact enumeration problems, generating functions'),
    ('05A16', 'msc', 'Asymptotic enumeration'),
    ('05A17', 'msc', 'Combinatorial aspects of partitions of integers'),
    ('05A18', 'msc', 'Partitions of sets'),
    ('05A19', 'msc', 'Combinatorial identities, bijective combinatorics'),
    ('05A20', 'msc', 'Combinatorial inequalities'),
    ('05A30', 'msc', 'q-calculus and related topics'),
    ('05A40', 'msc', 'Umbral calculus'),
    ('05E05', 'msc', 'Symmetric functions and generalizations'),
    ('05E10', 'msc', 'Combinatorial aspects of representation theory'),
    ('05E14', 'msc', 'Combinatorial aspects of algebraic geometry'),
    ('05E16', 'msc', 'Combinatorial structures in finite geometry'),
    ('05E18', 'msc', 'Group actions on combinatorial structures');