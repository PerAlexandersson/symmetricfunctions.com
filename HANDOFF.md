# Handoff

## Current scope

Move the parking-function descent proof to the real-rootedness results
catalogue, where users will find it among the other Eulerian-type descent and
interlacing examples.  Keep a short cross-reference on the parking-functions
page, then build, commit, and deploy the corrected placement.

## Ownership

The host supervisor owns only `HANDOFF.md`,
`tex-source/parking-functions.tex`, and `tex-source/realRootedWords.tex` for
this follow-up.
The worktree was clean at the start; all other files remain outside scope.

## Starting state

- The SymCat worktree was clean at the start of this task.
- Local `master` was already thirteen commits ahead of `origin/master`; those
  pre-existing commits must be preserved and not rewritten.
- No live Docker worker currently owns the website project.  The transfer
  theorem was checked against Diaconis--Hicks, *Probabilizing parking
  functions*, Theorem 8.  This is an editorial presentation of an existing
  proof, so `polytool` and `polynomial-lab` are not needed.

## Current status

The placement follow-up is complete and ready to commit.  The full definition,
examples, transfer identity, and interlacing proof now appear immediately
after the multiset Eulerian polynomials in `realRootedWords.tex`;
`parking-functions.tex` retains a short cross-reference.  The full build,
cross-page label resolution, rendered pages, `make check Q=1`, and
`git diff --check` all pass.

The initial placement was committed as `077cf98` and deployed on 2026-08-23;
this follow-up supersedes that location without changing the mathematics or
the published `DiaconisHicks2017` bibliography entry.

The hybrid-pipe-dream citation task is complete and remains uncommitted and
undeployed.  `key.tex` now cites Xiao--Xiong--Zhang, *Hybrid pipe dreams for
key polynomials*, Advances in Applied Mathematics 173 (2026), 102979, DOI
`10.1016/j.aam.2025.102979`, with arXiv preprint `2411.01637`.  The paragraph
summarizes the hybrid tile models and their local weight-preserving bijections,
and links directly to the existing `schubertPipeDream` subsection for the
classical Schubert pipe-dream formula.  The new bibliography key is
`XiaoXiongZhang2026`.

Verification passes with `make bib Q=1`, `make FILE=key.tex Q=1`,
`git diff --check`, `make Q=1`, and `make check Q=1`.  The rendered key page,
cross-page pipe-dream link, and published bibliography record were spot-
checked in `www/key.htm`; the only check output is the two pre-existing
synthetic-polydata warnings.

The determinantal-stability follow-up is complete and committed locally, but
remains undeployed.  `stablePolynomials.tex` now has a labelled
`determinantalStability` subsection stating the Borcea--Brändén Hermitian/PSD
matrix-pencil theorem, including the alternative that the determinant is
identically zero.  A short kernel argument explains the theorem: a zero in the
product upper half-plane forces a common kernel vector for the Hermitian
constant matrix and every PSD coefficient matrix.

The subsection also states the exact bivariate converse from Borcea--Brändén
Theorem 1.13/Corollary 6.7 and explains its derivation from the ternary Lax
theorem by homogenization.  It records the Helton--Vinnikov and
Lewis--Parrilo--Ramana proofs, then cites Brändén's Vámos-matroid obstruction
to representing a real-zero/hyperbolic polynomial or any positive power.  The
text explicitly distinguishes this failed polynomial-level strengthening from
the open generalized cone-level Lax conjecture.  Missing bibliography entries
`HeltonVinnikov2007`, `LewisParriloRamana2005`, and `Branden2011` were added;
the two Borcea--Brändén entries were already present.

Primary statements were checked against arXiv `math/0607755`,
`math/0606360`, `math/0306180`, `math/0304104`, and `1004.1382`.
`paper-cache` is registered but has no callable in this session, as noted in
the starting state.  Verification passes with `make bib Q=1`,
`make FILE=stablePolynomials.tex Q=1`, `git diff --check`, `make Q=1`, and
`make check Q=1`; the only check output is the two pre-existing unit-test
warnings for synthetic polydata relations without bibliography keys.  The
rendered subsection, table-of-contents anchor, theorem citations, and three new
bibliography records were spot-checked in `www/stablePolynomials.htm`.

Commit `10eaccd` was deployed to the configured production `public_html`
directory on 2026-08-18.  The environment did not have `rsync`, so after the
standard `make deploy` failed before transferring any files, the complete
`www/` tree was copied as a compressed archive over the same configured SSH
connection.  This preserves the deploy target's overwrite-without-deletion
behavior.  The public permutation-family, interlacing, and Lorentzian pages
were fetched successfully, and their remote SHA-256 checksums exactly match
the local build.

The citation-localization follow-up is complete.  Direct citations were added
to the foundational Lorentzian-polynomial attribution (`BrandenHuh2020`),
Postnikov's cylindric-shape notation (`Postnikov2005`), the Wan--Wang--
Mohammadian Laplacian-matching results (`WanWangMohammadian2022`), the
Haglund--Visontai Stirling-permutation refinement (`HaglundVisontai2012`), and
Rhoades's nonnegative-integer-matrix biCSP result (`Rhoades2010b`).  All five
keys were already present, so `bibliography.bib` was not changed in this
follow-up.  Searches of the primary arXiv literature found the standard
Haglund conjecture and its partial results, but no published source for the
stronger transition-positivity conjecture attributed to Arun Ram; the existing
attribution in `macdonaldP.tex` was therefore left unchanged rather than given
a misleading citation.  Focused renders of all five edited pages,
`git diff --check`, `make Q=1`, and `make check Q=1` all pass, and the rendered
citation links were spot-checked.

The requested read-only Claude editorial audit is complete.  Claude Sonnet
used corpus-wide scans plus targeted inspection across all 141 TeX sources,
the 2,447 generated labels, and the bibliography.  It found no broken
hyperrefs, missing citation keys, duplicate labels, malformed OEIS identifiers,
convincing spelling errors, duplicated misplaced prose, or unsupported hedge
language.  Claude made no file changes and ran no builds or network commands.

Claude returned six possible uncited attributions.  Local verification reduced
these to two useful follow-ups.  The Lorentzian-polynomial introduction should
cite the already-present key `BrandenHuh2020` directly.  The stronger Macdonald
positivity conjecture attributed to Arun Ram in `macdonaldP.tex` should either
receive a published citation or be identified as a personal communication.
The other four reports were already supported by nearby citations or existing
keys: `Postnikov2005`, `WanWangMohammadian2022`, and `HaglundVisontai2012`; the
Rhoades nonnegative-matrix statement appears continuous with the immediately
preceding `Rhoades2010b` citation, though repeating that citation locally would
improve clarity.  No content patch was applied in this audit-only turn.

The fixed-point/excedance addition to `realRootedInterlacing.tex` is complete.
It records
`d_{n,k}(x) = D(x^k(1+x)^{n-k})` as the excedance enumerator for
permutations whose fixed points lie in `[n-k]`, and proves by fixed-point
deletion and inclusion-exclusion that forbidding fixed points on any set `S`
gives the same polynomial whenever `|S|=k`.  The Brändén--Solus root-order
theorem is then applied pairwise to show that
`(d_{n,k}(x))_{0 <= k <= n}` is an interlacing sequence, so every member is
real-rooted.  The text also notes the individual fixed-point weights already
present in the proof of Brändén--Solus Lemma 3.5 and distinguishes this earlier
row result from the later Liu--Yan column Sturm refinement.

Both requested bibliography keys were already present.  The Brändén--Solus
entry now also records arXiv `1808.04141`; the Athanasiadis entry already
recorded `2302.00754`.  The theorem statements and numbering were checked
against the primary arXiv HTML for both papers.  `paper-cache`, `polytool`, and
`polynomial-lab` are registered, but no callable for them is exposed in this
tool session; this was an editorial incorporation of published results rather
than a new proof search, so no polynomial-lab ledger or computational fallback
was needed.

Verification completed with `make bib Q=1`, the focused
`make FILE=realRootedInterlacing.tex Q=1`, `git diff --check`, `make Q=1`, and
`make check Q=1`.  The two `make check` warnings are the pre-existing unit-test
fixtures whose synthetic polydata relations omit bibliography keys.  The
uncommitted permutation-family table and alphabetical reorganization remain
intact and were not modified during this follow-up.

The named permutation-families follow-up is complete.  The page now has an
alphabetized enumeration table for all 18 listed families with a single
specified counting sequence, giving the counts in `S_2` through `S_9` and
working OEIS links.  Shifted indexing is normalized by permutation size and
explained explicitly; this covers flattened, bigrassmannian, layered,
separable, and simsun permutations.  The accompanying definitions were also
sorted alphabetically and use layered as the primary name for Richardson
permutations.  The OEIS values were checked against the official sequence
pages.  Verification completed with `git diff --check`, `make Q=1`, and
`make check Q=1`, and the rendered table and links were spot-checked in
`www/permutationFamilies.htm`.

The most substantial remaining omissions from the named-family overview are
involutions (including fixed-point-free involutions), simple and sum/skew
indecomposable permutations, stack-sortable permutations, and smooth
permutations.  These are better candidates for a focused subsequent addition
than further extending the present table without definitions and references.

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
