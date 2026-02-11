# arXiv Browser - Recent Updates

## ✅ Completed Improvements

### 1. **Design System Integration**
- Adapted the symmetricfunctions.com design system
- Matching color palette (orange brand, blue links)
- Consistent typography with Palatino and system fonts
- Dark mode support via CSS media queries
- Responsive layout with proper spacing

### 2. **BibTeX Format Fixed**
The BibTeX entries now match your bibliography format:

```bibtex
@article{Yang2023x,
Author = {Runjia Yang and Beining Shi},
Title = {Sector Rotation by Factor Model and Fundamental Analysis},
Year = {2023},
Eprint = {2401.00001},
  url = {https://arxiv.org/abs/2401.00001},
journal = {arXiv e-prints}
}
```

Key features:
- Citation key: `LastName+Year+x` (e.g., `Yang2023x`)
- Capitalized field names (`Author`, `Title`, `Year`, `Eprint`)
- Clean arXiv ID (version number removed)
- Direct URL to arXiv abstract
- `journal = {arXiv e-prints}`

### 3. **Collapsible Abstracts**
- Abstracts are now in `<details>/<summary>` elements
- Click "Show abstract" to expand
- More papers visible per page
- Cleaner, more scannable interface

### 4. **Improved Title Formatting**
Each paper entry shows:
- **Title** - Links directly to arXiv abstract
- **Authors** - Clickable to view author's other papers
- **Date** - Publication and update dates with 📅 icon
- **Quick actions**:
  - 🔗 arXiv - View on arXiv
  - 📄 PDF - Direct PDF download
  - 📋 Copy BibTeX - One-click copy to clipboard
  - ℹ️ Details - Full paper details page

### 5. **KaTeX Math Rendering**
- Full KaTeX integration with your custom macros
- Supports `$...$` inline math and `$$...$$` display math
- Same macro library as symmetricfunctions.com
- Automatically renders LaTeX in titles and abstracts

## Testing the Updates

Start the Flask app:
```bash
cd /home/peal0658/Dropbox/symmetricfunctions.com/arxiv
./run_app.sh
```

Then visit **http://localhost:5000**

### What to Test:
1. **Homepage** - Browse recent papers with collapsible abstracts
2. **Search** - Try searching for "Schur" or an author name
3. **Author pages** - Click on an author name
4. **BibTeX** - Click "Copy BibTeX" on any paper
5. **Math rendering** - Look for papers with LaTeX in titles

## File Structure

```
arxiv/src/
├── app.py              # Flask application (updated BibTeX logic)
├── static/
│   └── style.css       # New CSS matching symmetricfunctions.com
├── templates/
│   ├── base.html       # Base template with KaTeX
│   ├── index.html      # Homepage with collapsible abstracts
│   ├── paper.html      # Paper detail page
│   ├── author.html     # Author listing page
│   └── search.html     # Search results page
├── fetch_arxiv.py      # arXiv scraper (unchanged)
└── config.py           # Configuration (unchanged)
```

## Next Steps (Not Yet Implemented)

### 5. Browse by Date Calendar View
Create a calendar interface to browse papers by date:
- URL parameter: `?year=2024`
- Shows 12-month calendar for the year
- Clickable dates with paper counts
- Click a date to see papers from that day

This will require:
- New route `/browse?year=YYYY`
- Template with calendar grid
- SQL queries to count papers by date
- JavaScript for interactive calendar

Let me know when you'd like to implement the browse-by-date feature!
