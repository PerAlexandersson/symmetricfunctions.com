# Legacy Todo Backlog

This directory is a triage surface for the old legacy inbox in
`tex-source/todo-list.tex`.  It is not part of the rendered site, and it should
not become a second general paper feed.

New papers should normally be tracked through `arxiv.symmetricfunctions.com`.
Use this directory for older notes that need a concrete site action:

- `relation`: add or correct `polydata` relation metadata.
- `family`: add a new polynomial-family page or a new `polydata` block.
- `prose`: add a theorem, example, definition, or explanatory paragraph.
- `bib`: add a published reference, DOI, or better citation key.
- `archive`: no current site action; leave it only as historical backlog.

## Promotion Rules

Before changing TeX, convert a note into one of the action labels above.

For relation work:

- verify the source theorem, proposition, or stated conjecture;
- add a `bibliography.bib` key before adding the relation row;
- use one target per relation row when attributes are needed;
- record conjectures with `status=conjecture`;
- use relation directions consistent with the graph conventions:
  general or larger families point toward special or smaller families for
  containment/specialization, and positive-expansion edges point toward the
  target basis/family.

For page or prose work:

- prefer short additions with precise citations over broad survey paragraphs;
- link to existing sibling pages with `\hyperref[...]` rather than duplicating
  background material;
- add a new page only when a cluster has enough reusable content or a natural
  family node.

## Batch Workflow

1. Pick one cluster from `triage-2026-06-30.md`.
2. Verify the papers and theorem statements for 5--15 related entries.
3. Add or update bibliography entries.
   Use `https://arxiv.symmetricfunctions.com/api/bibtex.json?id=<arxiv-id>`
   to check whether older arXiv references have published DOI data; prefer
   the published data while keeping existing citation keys unless a key rename
   is part of the task.
4. Add the smallest useful `polydata` or prose changes.
5. Run the normal site checks.
6. Commit the batch.
7. Only then annotate or prune the corresponding old `todo-list.tex` entries.

Line references into `tex-source/todo-list.tex` are snapshot references from
2026-06-30 and may drift as that file is edited.
