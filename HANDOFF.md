# Handoff

## Current scope

Perform a site-wide editorial audit for definite mathematical errors,
terminology and notation mistakes, misplaced prose, duplicate labels, and
misleading page metadata.  Keep this pass to high-confidence corrections;
record larger reorganization candidates rather than splitting established
pages opportunistically.

## Ownership

The editor worker owns `HANDOFF.md` and the following files during this audit:
`assaf.tex`, `cycleIndexPolynomial.tex`, `gtpatterns.tex`,
`hallLittlewood.tex`, `jack.tex`, `loopSchur.tex`, `ncSchur.tex`, `posets.tex`,
`schurKP.tex`, `schurMisc.tex`, `permutationFamilies.tex`,
`permutationGeneralizations.tex`, `permutationPatterns.tex`, `permutations.tex`,
and `schubert.tex`.

## Starting state

- The SymCat worktree was clean at the start of this audit.
- Local `master` was already seven commits ahead of `origin/master`; those
  pre-existing commits must be preserved and not rewritten.
- `paper-cache` is registered but unavailable through the current tool
  session.  The two source-sensitive corrections were checked against the
  primary arXiv papers instead.

## Current status

The editorial audit and high-confidence correction batch are complete and
ready for review.  The loop-Schur page now has the correct terminal summation
indices, consistent tableau-weight notation, and the correct output partition
and variable-length bound in the Murnaghan--Nakayama rule.  These substantive
corrections were checked against Ross's primary paper (arXiv:1208.4369).

The NCSym page now uses the set-partition symbol `\vdash` rather than the
composition symbol `\vDash`, and its opening definition is a complete
sentence that identifies formal power series in noncommuting variables.  The
notation was checked against Aliniaeifard--Li--van Willigenburg
(arXiv:2105.09964).  Duplicate section/definition labels and a missing umlaut
were fixed on the posets page.  The Gelfand--Tsetlin and Jack pages now refer
to tableau entries rather than incorrectly calling their values contents.

The Adin--Bauer paragraph was moved from the general Hall--Littlewood
introduction into the existing Hall--Littlewood--Schubert subsection.  Page
metadata was broadened for the slide/forest/lock, cycle-index/higher-Lie, and
miscellaneous Schur-family pages; the K-theoretic Schur P/Q description no
longer contains rendering macros.

The most plausible future structural change is to split `schurMisc.tex` into
a classical symplectic/orthogonal and Schur-P/Q page and a page for newer
miscellaneous families.  This audit changed its misleading metadata but did
not split the established URL or disturb its cross-references.  No other page
move was compelling enough to justify that churn in this pass.

Verification completed with `git diff --check`, `make Q=1`, and
`make check Q=1`.  The generated HTML was spot-checked for the corrected
loop-Schur theorem, NCSym notation, metadata titles, and Hall--Littlewood
subsection placement.

The second pass through the permutation pages is complete.  The configured
`oeis` MCP server appears in `codex mcp list`, but no OEIS callable is exposed
in this tool session; all sequence matches were therefore verified directly
against the official OEIS pages.

The permutation-family page gained verified OEIS references for Baxter,
fireworks, bigrassmannian, parity-alternating, and Richardson/layered
permutations.  The flattened-permutation count was sharpened from an
unqualified Bell number to the shifted value $B_{n-1}$.  The inaccurate André
description was replaced by an explicit convention for counting both
orientations of alternating permutations.  The Baxter vincular patterns and
Boolean avoidance patterns were corrected, and the false statement that
bigrassmannian permutations are exactly the 2413-avoiders was removed.

The pattern page now uses the standard $\oplus$ and $\ominus$ notation for
direct and skew sums and no longer renders `pi_1` literally.  The dependent
Schubert factorization was updated to the same notation.  On the basic
permutations page, Lehmer-code entries are now correctly identified with
columns of the site's bottom-indexed Rothe diagram rather than rows.  The
generalizations page gained verified counts and OEIS links for Cayley, type
$B$, and Stirling permutations.

The four closed counts added or clarified on the named-families page were
also checked by direct enumeration through $n=7$.  The Richardson definition
was checked against Merzon--Smirnov (arXiv:1410.6857).  Verification completed
with `git diff --check`, `make Q=1`, and `make check Q=1`; the affected
generated HTML pages were spot-checked for OEIS links and notation.

## Completed backlog-triage status

The 55-paper backlog triage is complete.  Fifteen supplied arXiv IDs were
already present; the audit added 33 references and theorem-level coverage on
the relevant existing pages.  No new standalone page was needed.  The new
families fit naturally into the hive, Hall--Littlewood, loop-Schur,
Schur-$Q$, Schur-zeta, and related pages.

Seven absent papers were intentionally skipped: Romik--Śniady on infinite
RSK (peripheral to the current finite RSK page), Thomas--Tung on injective
partition maps and Green--Holmes--Im on quiver multisymmetric polynomials
(too peripheral), Mickler on Jack LR coefficients (mainly conjectural),
Mironov--Morozov--Popolitov on twisted Cherednik systems (too
mathematical-physics-specific), and Campbell plus Baolahy--Benjamin on
Kronecker products (not enough durable new structure beyond the existing
Kronecker section).

Collision-free keys were assigned to the two new Lee papers and the new
Qiu--Zhang paper.  The DOI attached to Cai--Jiang--Jing--Li--Ye by arXiv was
for an unrelated article; it was corrected to the publisher DOI
`10.1017/fms.2026.10256`.

`paper-cache` is registered in `codex mcp list`, but no paper-cache callable
is exposed in this Codex tool session and the server has no standalone query
CLI.  This expected MCP is therefore unavailable for the task; the fallback
is primary arXiv PDFs, `pdf2txt.py`, and the live arXiv++ BibTeX endpoint.

Verification completed with `make bib Q=1`, `make Q=1`, and
`make check Q=1`.  The two warnings from `make check` remain the pre-existing
unit-test fixtures whose synthetic polydata relations intentionally omit
bibliography keys.

## Completed real-rootedness preprint audit

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
