#!/usr/bin/env python3
"""
tags_helper.py - Helper functions for managing tags

Usage:
    from tags_helper import add_tag_to_paper, get_paper_tags, search_by_tag
"""

import pymysql
from config import DB_CONFIG


def get_db_connection():
    """Create and return a database connection."""
    return pymysql.connect(**DB_CONFIG)


def get_or_create_tag(cursor, tag_name, tag_type='personal', description=None):
    """
    Get existing tag ID or create a new tag.

    Args:
        cursor: Database cursor
        tag_name: Name of the tag (e.g., '05A15' or 'symmetric-functions')
        tag_type: Type of tag ('msc', 'personal', 'arxiv', 'other')
        description: Optional description

    Returns:
        tag_id: The ID of the tag
    """
    # Try to find existing tag
    cursor.execute("""
        SELECT id FROM tags
        WHERE name = %s AND tag_type = %s
    """, (tag_name, tag_type))

    result = cursor.fetchone()

    if result:
        return result[0]
    else:
        # Create new tag
        cursor.execute("""
            INSERT INTO tags (name, tag_type, description)
            VALUES (%s, %s, %s)
        """, (tag_name, tag_type, description))
        return cursor.lastrowid


def add_tag_to_paper(arxiv_id, tag_name, tag_type='personal', description=None):
    """
    Add a tag to a paper.

    Args:
        arxiv_id: The arXiv ID of the paper (e.g., '2401.12345')
        tag_name: Name of the tag
        tag_type: Type of tag ('msc', 'personal', 'arxiv', 'other')
        description: Optional description for new tags

    Returns:
        bool: True if successful, False otherwise
    """
    conn = get_db_connection()
    cursor = conn.cursor()

    try:
        # Get paper ID
        cursor.execute("SELECT id FROM papers WHERE arxiv_id = %s", (arxiv_id,))
        result = cursor.fetchone()

        if not result:
            print(f"Paper {arxiv_id} not found")
            return False

        paper_id = result[0]

        # Get or create tag
        tag_id = get_or_create_tag(cursor, tag_name, tag_type, description)

        # Link paper to tag (ignore if already exists)
        cursor.execute("""
            INSERT IGNORE INTO paper_tags (paper_id, tag_id)
            VALUES (%s, %s)
        """, (paper_id, tag_id))

        conn.commit()
        print(f"✓ Added tag '{tag_name}' to paper {arxiv_id}")
        return True

    except Exception as e:
        conn.rollback()
        print(f"Error: {e}")
        return False
    finally:
        cursor.close()
        conn.close()


def remove_tag_from_paper(arxiv_id, tag_name, tag_type='personal'):
    """
    Remove a tag from a paper.

    Args:
        arxiv_id: The arXiv ID of the paper
        tag_name: Name of the tag to remove
        tag_type: Type of tag

    Returns:
        bool: True if successful, False otherwise
    """
    conn = get_db_connection()
    cursor = conn.cursor()

    try:
        # Get paper ID and tag ID
        cursor.execute("""
            SELECT p.id, t.id FROM papers p, tags t
            WHERE p.arxiv_id = %s
            AND t.name = %s
            AND t.tag_type = %s
        """, (arxiv_id, tag_name, tag_type))

        result = cursor.fetchone()

        if not result:
            print(f"Paper {arxiv_id} or tag '{tag_name}' not found")
            return False

        paper_id, tag_id = result

        # Remove relationship
        cursor.execute("""
            DELETE FROM paper_tags
            WHERE paper_id = %s AND tag_id = %s
        """, (paper_id, tag_id))

        conn.commit()
        print(f"✓ Removed tag '{tag_name}' from paper {arxiv_id}")
        return True

    except Exception as e:
        conn.rollback()
        print(f"Error: {e}")
        return False
    finally:
        cursor.close()
        conn.close()


def get_paper_tags(arxiv_id):
    """
    Get all tags for a paper.

    Args:
        arxiv_id: The arXiv ID of the paper

    Returns:
        list: List of tag dictionaries with keys: name, type, description
    """
    conn = get_db_connection()
    cursor = conn.cursor(pymysql.cursors.DictCursor)

    try:
        cursor.execute("""
            SELECT t.name, t.tag_type, t.description
            FROM tags t
            JOIN paper_tags pt ON t.id = pt.tag_id
            JOIN papers p ON pt.paper_id = p.id
            WHERE p.arxiv_id = %s
            ORDER BY t.tag_type, t.name
        """, (arxiv_id,))

        return cursor.fetchall()

    finally:
        cursor.close()
        conn.close()


def search_by_tag(tag_name, tag_type=None, limit=100):
    """
    Find all papers with a specific tag.

    Args:
        tag_name: Name of the tag to search for
        tag_type: Optional tag type filter
        limit: Maximum number of results

    Returns:
        list: List of paper dictionaries
    """
    conn = get_db_connection()
    cursor = conn.cursor(pymysql.cursors.DictCursor)

    try:
        if tag_type:
            cursor.execute("""
                SELECT p.arxiv_id, p.title, p.published_date
                FROM papers p
                JOIN paper_tags pt ON p.id = pt.paper_id
                JOIN tags t ON pt.tag_id = t.id
                WHERE t.name = %s AND t.tag_type = %s
                ORDER BY p.published_date DESC
                LIMIT %s
            """, (tag_name, tag_type, limit))
        else:
            cursor.execute("""
                SELECT p.arxiv_id, p.title, p.published_date
                FROM papers p
                JOIN paper_tags pt ON p.id = pt.paper_id
                JOIN tags t ON pt.tag_id = t.id
                WHERE t.name = %s
                ORDER BY p.published_date DESC
                LIMIT %s
            """, (tag_name, limit))

        return cursor.fetchall()

    finally:
        cursor.close()
        conn.close()


def get_all_tags(tag_type=None):
    """
    Get all tags, optionally filtered by type.

    Args:
        tag_type: Optional tag type filter

    Returns:
        list: List of tag dictionaries
    """
    conn = get_db_connection()
    cursor = conn.cursor(pymysql.cursors.DictCursor)

    try:
        if tag_type:
            cursor.execute("""
                SELECT t.*, COUNT(pt.paper_id) as paper_count
                FROM tags t
                LEFT JOIN paper_tags pt ON t.id = pt.tag_id
                WHERE t.tag_type = %s
                GROUP BY t.id
                ORDER BY t.name
            """, (tag_type,))
        else:
            cursor.execute("""
                SELECT t.*, COUNT(pt.paper_id) as paper_count
                FROM tags t
                LEFT JOIN paper_tags pt ON t.id = pt.tag_id
                GROUP BY t.id
                ORDER BY t.tag_type, t.name
            """)

        return cursor.fetchall()

    finally:
        cursor.close()
        conn.close()


def fulltext_search(query, limit=50):
    """
    Perform full-text search on paper titles and abstracts.

    Args:
        query: Search query (can use boolean operators like +word -word "exact phrase")
        limit: Maximum number of results

    Returns:
        list: List of paper dictionaries with relevance scores
    """
    conn = get_db_connection()
    cursor = conn.cursor(pymysql.cursors.DictCursor)

    try:
        cursor.execute("""
            SELECT
                arxiv_id,
                title,
                abstract,
                published_date,
                MATCH(title, abstract) AGAINST(%s IN NATURAL LANGUAGE MODE) as relevance
            FROM papers
            WHERE MATCH(title, abstract) AGAINST(%s IN NATURAL LANGUAGE MODE)
            ORDER BY relevance DESC, published_date DESC
            LIMIT %s
        """, (query, query, limit))

        return cursor.fetchall()

    finally:
        cursor.close()
        conn.close()


# CLI interface for testing
if __name__ == '__main__':
    import sys

    if len(sys.argv) < 2:
        print("Usage:")
        print("  python tags_helper.py add <arxiv_id> <tag_name> [tag_type]")
        print("  python tags_helper.py remove <arxiv_id> <tag_name> [tag_type]")
        print("  python tags_helper.py list <arxiv_id>")
        print("  python tags_helper.py search <tag_name>")
        print("  python tags_helper.py fulltext <query>")
        print("  python tags_helper.py tags [tag_type]")
        sys.exit(1)

    command = sys.argv[1]

    if command == 'add' and len(sys.argv) >= 4:
        arxiv_id = sys.argv[2]
        tag_name = sys.argv[3]
        tag_type = sys.argv[4] if len(sys.argv) > 4 else 'personal'
        add_tag_to_paper(arxiv_id, tag_name, tag_type)

    elif command == 'remove' and len(sys.argv) >= 4:
        arxiv_id = sys.argv[2]
        tag_name = sys.argv[3]
        tag_type = sys.argv[4] if len(sys.argv) > 4 else 'personal'
        remove_tag_from_paper(arxiv_id, tag_name, tag_type)

    elif command == 'list' and len(sys.argv) >= 3:
        arxiv_id = sys.argv[2]
        tags = get_paper_tags(arxiv_id)
        print(f"\nTags for {arxiv_id}:")
        for tag in tags:
            print(f"  [{tag['tag_type']}] {tag['name']}: {tag['description'] or ''}")

    elif command == 'search' and len(sys.argv) >= 3:
        tag_name = sys.argv[2]
        papers = search_by_tag(tag_name)
        print(f"\nPapers with tag '{tag_name}':")
        for paper in papers:
            print(f"  {paper['arxiv_id']}: {paper['title']}")

    elif command == 'fulltext' and len(sys.argv) >= 3:
        query = ' '.join(sys.argv[2:])
        papers = fulltext_search(query)
        print(f"\nSearch results for '{query}':")
        for paper in papers:
            print(f"  [{paper['relevance']:.2f}] {paper['arxiv_id']}: {paper['title']}")

    elif command == 'tags':
        tag_type = sys.argv[2] if len(sys.argv) > 2 else None
        tags = get_all_tags(tag_type)
        print(f"\nAll tags{' of type ' + tag_type if tag_type else ''}:")
        for tag in tags:
            print(f"  [{tag['tag_type']}] {tag['name']} ({tag['paper_count']} papers)")

    else:
        print("Invalid command or arguments")
        sys.exit(1)
