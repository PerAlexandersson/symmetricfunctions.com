# Tagging System + Keyword Linking Plan

## Context

The arXiv combinatorics browser has a fully designed but unintegrated tagging system. The DB schema (`tags`, `paper_tags` tables) and a CLI helper (`tags_helper.py`) already exist. The sister project (symmetric functions catalog at symmetricfunctions.com) has 134 polynomial families and 620 `\defin{term}` definitions across 82 LaTeX files.

Goals:
- Auto-extract arXiv cross-categories and MSC codes when papers are fetched
- Backfill MSC codes from existing comment fields in the DB
- Build a keyword dictionary from the catalog that serves dual purpose: tags + abstract links
- Discover additional keywords by analyzing all abstracts in the corpus
- Display tags on papers and add browsing-by-tag pages
- Link recognized keywords in abstracts to the catalog

---

## Phase A: Mechanical Tags (MSC codes + arXiv categories)

### Step 1: Add MSC code parser to `tags_helper.py`

Add `parse_msc_codes(comment_text)` that extracts MSC 2020 codes from arXiv comment strings. Handles formats like:
- `"23 pages; MSC 05A15, 05E05"`
- `"Primary 05E05; Secondary 05A19"`
- `"Mathematics Subject Classification: 05A15"`

Uses regex to find `\d{2}[A-Z]\d{2}` patterns near MSC-related keywords. Returns sorted list of code strings.

### Step 2: Modify `fetch_arxiv.py` to auto-tag on ingestion

In `insert_or_update_paper()`, after author handling:

1. **Clear auto-tags on update** (preserve personal tags):
   ```sql
   DELETE pt FROM paper_tags pt JOIN tags t ON pt.tag_id = t.id
   WHERE pt.paper_id = %s AND t.tag_type IN ('arxiv', 'msc')
   ```

2. **Extract arXiv cross-categories** from `paper.categories` (skip `math.CO` since every paper has it — only cross-listings like `math.AG`, `math.RT` are useful).

3. **Parse MSC codes** from `paper.comment` using `parse_msc_codes()`.

Both use `get_or_create_tag()` + `INSERT IGNORE INTO paper_tags`.

### Step 3: Create `backfill_tags.py`

New script that reads existing papers' `comment` fields from the DB and applies MSC code tags. Supports `--dry-run` to preview results before committing. Does NOT re-fetch from arXiv.

---

## Phase B: Keyword Dictionary (catalog terms + definitions)

### Step 4: Generate draft keyword dictionary from catalog

Create `generate_keyword_dict.py` — a one-time script that builds a JSON dictionary from two sources:

**Source 1: `temp/site-polydata.json`** (134 polynomial families)
- Extract `Name` field (e.g., "Modified Macdonald polynomials")
- Build URL from `page` + entry key (e.g., `macdonaldH.htm#macdonaldH`)
- Auto-generate variants (singular/plural, "polynomial"/"function" forms)

**Source 2: `\defin{term}` in `tex-source/*.tex`** (620 definitions)
- Extract term and source filename
- Map filename to catalog page URL (e.g., `schur.tex` → `schur.htm`)

Output: `arxiv/src/keyword_dictionary.json`
```json
{
  "Modified Macdonald polynomials": {
    "catalog_url": "https://www.symmetricfunctions.com/macdonaldH.htm#macdonaldH",
    "tag": "macdonald-polynomials",
    "variants": ["modified Macdonald polynomial", "modified Macdonald polynomials"]
  },
  "augmented filling": {
    "catalog_url": "https://www.symmetricfunctions.com/macdonaldEperm.htm",
    "tag": null,
    "variants": ["augmented fillings"]
  }
}
```

`tag: null` means "link to catalog but don't create a tag" (for terms not useful as browse tags).

### Step 5: Discover keywords from abstracts (one-time)

Create `discover_keywords.py` — analyzes all abstracts in the DB to find frequently occurring mathematical terms that could be useful tags or dictionary entries.

Approach:
- Extract all multi-word noun phrases / capitalized terms from abstracts (e.g., "Young tableaux", "Kazhdan-Lusztig", "crystal bases")
- Count frequency across all papers
- Filter out common English words and generic math terms ("we prove", "main result")
- Cross-reference against the catalog dictionary — flag terms already covered vs. new discoveries
- Output a ranked list of candidate keywords with frequencies

Output: `arxiv/src/discovered_keywords.txt` — a ranked list for manual review:
```
523  Young tableaux
412  Schur functions
387  symmetric group
245  crystal bases
198  Kazhdan-Lusztig
...
```

This is purely a suggestion tool — the user reviews the list and decides which terms to add to `keyword_dictionary.json` (with optional catalog URLs and tag names).

### Step 6: User curates the dictionary

Review `keyword_dictionary.json` and `discovered_keywords.txt`:
- Remove terms too generic or too specific
- Decide which terms should be tags vs. link-only (`tag` field)
- Add variant spellings/plurals
- Add catalog URLs for newly discovered terms where applicable
- Merge duplicates

This is a manual editorial step.

### Step 7: Abstract keyword scanner + linker

Add `linkify_abstract(abstract_text, keyword_dict)` to `app.py`:

- Case-sensitive matching (preserves mathematical convention)
- Longest-match-first to avoid partial matches
- Only links first occurrence of each term per abstract
- Returns HTML with `<a>` tags pointing to catalog

Register as a Jinja filter: `{{ paper.abstract | linkify_abstract }}`

### Step 8: Backfill keyword tags

Extend `backfill_tags.py` with a `--keywords` mode that scans all existing abstracts against the curated dictionary and applies keyword-based tags (where `tag` is not null).

---

## Phase C: Web Integration (tags display + browsing)

### Step 9: Add tag CSS to `style.css`

- `.tag` — small pill-style badges (0.7rem, rounded border, subtle)
- `.tag-msc` / `.tag-arxiv` / `.tag-personal` — type-specific border/text colors
- `.tag-cloud` — flex-wrap layout for the /tags browse page
- Dark mode overrides

### Step 10: Add tag display to `_macros.html`

After the `</details>` closing tag in `render_paper`:
```html
{% if paper.tags %}
<div class="paper-tags">
    {% for tag in paper.tags %}
        <a href="/tag/{{ tag.name }}" class="tag tag-{{ tag.tag_type }}">{{ tag.name }}</a>
    {% endfor %}
</div>
{% endif %}
```

### Step 11: Add tags section to `paper.html`

After the DOI meta section, add tags in a `<div class="paper-meta">`. On the detail page, also use `linkify_abstract` filter to render the abstract with catalog links.

### Step 12: Create `tags.html` template

Lists all tags grouped by type (MSC codes, arXiv categories, keyword tags) with paper counts. Tag-cloud layout.

### Step 13: Create `tag.html` template

Shows papers with a specific tag. Follows `author.html` pattern (paginated list using `render_paper` macro).

### Step 14: Add routes and helpers to `app.py`

- `get_paper_tags(cursor, paper_id)` — mirrors existing `get_paper_authors()` pattern
- Attach `paper['tags']` in all routes that list papers
- `/tags` route — all tags grouped by type with counts (`HAVING paper_count > 0`)
- `/tag/<tag_name>` route — paginated papers for a tag
- Load keyword dictionary once at startup for the `linkify_abstract` filter

### Step 15: Add "Tags" nav link to `base.html`

Insert between "Browse by date" and "Random" in the header.

---

## Implementation Order

1. **Steps 1-3**: MSC parser + fetch integration + backfill script
2. **Step 4**: Generate draft dictionary from catalog
3. **Step 5**: Discover keywords from abstracts
4. **Step 6**: User curates dictionary (manual editorial work)
5. **Steps 9-15**: Web integration (CSS, templates, routes)
6. **Steps 7-8**: Abstract linker + keyword backfill (depends on curated dictionary)

---

## Files

| File | Change |
|------|--------|
| `arxiv/src/tags_helper.py` | Add `parse_msc_codes()` |
| `arxiv/src/fetch_arxiv.py` | Auto-tag in `insert_or_update_paper()` |
| `arxiv/src/backfill_tags.py` | **New** — backfill script (MSC + keywords) |
| `arxiv/src/generate_keyword_dict.py` | **New** — builds draft dictionary from catalog |
| `arxiv/src/discover_keywords.py` | **New** — one-time abstract analysis for keyword suggestions |
| `arxiv/src/keyword_dictionary.json` | **New** — curated keyword -> tag/URL mapping |
| `arxiv/src/static/style.css` | Tag pill styles, tag cloud, dark mode |
| `arxiv/src/templates/_macros.html` | Tag display in render_paper |
| `arxiv/src/templates/paper.html` | Tags in detail + linked abstract |
| `arxiv/src/templates/tags.html` | **New** — tag browse page |
| `arxiv/src/templates/tag.html` | **New** — papers-by-tag page |
| `arxiv/src/app.py` | `get_paper_tags()`, `linkify_abstract`, routes, tag attachment |
| `arxiv/src/templates/base.html` | "Tags" nav link |

## Verification

1. `python backfill_tags.py --dry-run` — confirm MSC codes parse correctly
2. `python backfill_tags.py` — tag existing papers with MSC codes
3. `python generate_keyword_dict.py` — produces draft dictionary
4. `python discover_keywords.py` — produces ranked keyword suggestions
5. Review and curate `keyword_dictionary.json`
6. Start local server, verify tags appear on paper listings
7. Visit `/tags` — confirm grouped tag listing with counts
8. Click a tag — confirm papers list with pagination
9. Visit a paper detail page — confirm abstract has catalog links
10. `python fetch_arxiv.py --recent` — confirm new papers get arXiv categories + MSC tags
11. `python backfill_tags.py --keywords` — tag existing papers from keyword dictionary
12. Check dark mode + mobile
