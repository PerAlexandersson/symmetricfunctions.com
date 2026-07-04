# Editorial review follow-up, 2026-07-04

Larger improvement opportunities found during the site-wide typo and grammar
pass.  These need source checking, examples, figures, or mathematical decisions
before editing the public pages.

## CSP pages

- Resolved 2026-07-04 in `tex-source/cspTableau.tex`: the stretched-shape CSP
  for `\SYT(n\lambda)` is now stated as an explicit problem asking for a
  natural order-`n` action realizing the CSP.
- Resolved 2026-07-04 in `tex-source/cspWord.tex`: the RSK fixed-shape CSP on
  `\SYT(\lambda)\times\SYT(\lambda)` is now stated as an explicit problem
  asking for a natural order-`n` action realizing the CSP.
- `tex-source/cspTableau.tex`: Check Chen's formulas for two-row skew
  increasing tableaux.  The current page suggests they might exhibit CSP; this
  should either become a theorem with a precise action/polynomial or be recorded
  as a conjectural/open item.
- `tex-source/cyclic-sieving.tex`: The "proper statistic" definition is marked
  as unpublished.  Compare it with universal CSP statistics and decide whether
  to keep it, rename it, or move it to a conjectural subsection.

## Quasisymmetric and tableau examples

- `tex-source/qsymSchur.tex`: A visible note asking for a `q`-analog and cyclic
  sieving instance near the immaculate hook-length discussion was removed from
  the page.  Revisit this after checking whether the standard immaculate
  hook-length formula has a natural `q`-analog or CSP interpretation.
- `tex-source/superSymmetricSchur.tex`: The Hamel--Goulden determinant material
  now has a local `\todo`.  It still needs detailed worked examples.  Prefer
  `ytableau` examples where possible; use TikZ only if the decomposition really
  requires it and the conventions have been checked against the paper.
- `tex-source/borderStripTableaux.tex`: The Littlewood map section mentions
  Pak's different labeling convention.  Add a small comparison example or
  diagram so the convention difference is visible rather than only stated.

## Key/Lascoux/Stanley-family precision

- `tex-source/lascoux.tex`: The Monical--Pechenik--Scrimshaw crystal question is
  currently followed by "This seems to be answered in Yu2023."  Check Yu's exact
  theorem and replace this with a precise statement and citation.
- `tex-source/lascoux.tex`: Add the planned worked Monical set-valued skyline
  filling example for a small shape.  This should be backed by the Rust
  generators when feasible.
- `tex-source/stanleySymmetric.tex`: I changed the old phrase "(some?) affine
  Stanley symmetric functions" to "certain affine Stanley symmetric functions"
  as a prose cleanup.  Check the cited crystal proof and record the exact class.

## General polish

- Continue standardizing adjective forms such as "Schur-positive",
  "key-positive", and related positivity phrases when touching a page.
- The personal/About and minor-research pages intentionally use first person.
  Technical reference pages should continue to prefer "we" or impersonal prose.

## Bibliography cleanup

- A reference audit on 2026-07-04 fixed the genuinely ambiguous duplicate keys
  `Anderson2024x` and `Weising2024x`, which referred to different papers.  The
  same-paper duplicate keys found that day have now been normalized so that
  the unsuffixed key is unique.  Where possible, the unsuffixed key was kept on
  the published or DOI-rich record, while arXiv, FPSAC, sparse, and short
  records were given descriptive suffixes.
