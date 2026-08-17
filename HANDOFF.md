# Handoff

## Current scope

Completed: audit and integrate the thirteen supplied papers on
real-rootedness, interlacing, gamma-positivity, Lorentzian polynomials, and
character polynomials.

## Ownership

No files are actively owned by the editor worker; the preprint audit is
complete.

## Starting state

- The SymCat worktree was clean at the start.
- Local `master` was already three commits ahead of `origin/master`; those
  pre-existing commits must be preserved and not rewritten.
- No project `HANDOFF.md` existed before this task.
- No paper/PDF MCP servers are configured in this host session. The fallback is
  the live arXiv++ REST/BibTeX API, primary arXiv PDFs, and `pdf2txt.py`.

## Status

The preprint audit is complete.  No paper/PDF MCP servers were configured in
this host session (`codex mcp list` was empty), so the primary arXiv PDFs and
the live arXiv++ BibTeX endpoint were used.

- Added `Ma2026x` and the type $A/B/D$ half-interlacing theorem to
  `realRootedWords.tex`.  The preprint states simplicity for $n\geq2$, but
  also gives $D_2(t)=(1+t)^2$; the site records the valid $n\geq3$ statement
  and the exceptional $D_2$ case explicitly.
- Added the matroid Kazhdan--Lusztig polynomial pencil and the common
  $Z$-polynomial theorem for thagomizer and $K_{2,n}$ graphic matroids.  The
  citation key is `Zhang2026MatroidKLx`, since `Zhang2026x` already denotes
  Philip Zhang's normalized skew Schur paper.
- Expanded the Hoster--Stump coverage with the dual-poset interlacing result,
  the Fang--Ma coverage with its matroid classes and Rayleigh consequences,
  and the Park summary with its quantitative link-condition conclusions.
- Retained the published `Elizalde2021` entry instead of duplicating it as
  `Elizalde2020x`; the quasi-Stirling real-rootedness theorem and its stronger
  $r$-Eulerian form were already present.
- Confirmed adequate existing theorem-level coverage for Mao--Wang,
  Gaetz--Pierson, Athanasiadis--Wagner, Bencs, Ferroni--Panova--Venturello,
  Chin--Qin, and Liang--Sagan.

Verification completed with `make bib Q=1`, `make Q=1`, and
`make check Q=1`.  The two warnings from `make check` remain the pre-existing
unit-test fixtures whose synthetic polydata relations intentionally omit
bibliography keys.

## Completed classical-criteria scope

The real-rootedness overview now states Descartes' rule of signs and the
Hermite--Sylvester criterion.  It defines the root power sums, gives their
coefficient recurrences, and links to the Newton identities page.  The
interlacing page now distinguishes enumerative Sturm sequences from classical
Sturm chains and states Sturm's interval root-counting theorem.  The
`fullyInterlacingLace` subsection was moved to the end of the interlacing
sequences section.

The Hermite--Sylvester citation was obtained from the arXiv++ BibTeX endpoint.
Verification completed with `make bib Q=1`, `make Q=1`, and `make check Q=1`.
The two warnings from `make check` are the pre-existing unit-test fixtures
whose synthetic polydata relations intentionally omit bibliography keys.

## Completed August 2026 scope

The requested content is implemented:

- new weightedBondSymmetric.tex, with Rust-verified \(P_3\) and \(K_3\)
  examples, recurrences, properties, and open conjectures;
- new koornwinder.tex, with symmetric, electronic, and relative definitions
  and the new creation/alcove-walk/tableau formulas;
- cross-linked updates to the chromatic, parking-function, Schur, Schubert,
  Lorentzian, Macdonald \(P\), modified Macdonald, key, and plethysm pages;
- eight arXiv++-formatted preprint entries plus the original 1992 Koornwinder
  reference in bibliography.bib.

The arXiv++ endpoint generated the same key for the two Lapointe--Pena
preprints, so the entries use the distinct keys LapointePena2026Keysx and
LapointePena2026Macdonaldx while preserving the generated field format.

The isolated Rust verification is
rust/sym-poly/sym/examples/weighted_bond_symmetric_site_example.rs; ownership
and verification are recorded in /workspace/rust/HANDOFF.md.

Verification completed with make bib Q=1, make Q=1, and make check Q=1.

The two warnings from make check are the pre-existing unit-test fixtures whose
synthetic polydata relations intentionally omit bibliography keys.

On 2026-08-17, the Coxeter-groups page gained a brief definition of
crystallographic root systems and Coxeter groups, including the root-lattice
criterion and the standard finite noncrystallographic families.
