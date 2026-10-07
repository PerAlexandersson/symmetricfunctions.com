# Handoff

## Verified deployment — 2026-10-07, 11:22 UTC

At the user's explicit request, deployed clean source
`23cf624f86b217012503e0aa8424a9b62bfb5030` through the constrained host bridge.
Receipt `20261007T112256-525adf5a0ec2` reports `deployed`; Pagefind manifest
verification passed. Includes the Ferroni–McGinnis Ehrhart reference and the
Shareshian–Wachs/Saxl announced-proof notes, including the clarified
permutation-statistic wording. `make Q=1`, `make check Q=1` and
`git diff --check` passed first (only expected fixture warnings).
Live HTTPS checks returned 200 and verified the new references on
`ehrhart.htm`, `chromaticQuasisymmetric.htm`, `chromaticEexpansion.htm` and
`schur.htm`, plus the hypersimplex and Lean links and clarified statistic.
Only this handoff changed after activation. Ownership released; no Git push.


## Completed scope — Saxl announced proof (2026-10-07)

Added `OpenAI2026Saxl` to `bibliography.bib` from the manuscript's citation
metadata and a concise announced-proof note beside Saxl's conjecture in
`tex-source/schur.tex`. Added a link and Related Lean breadcrumb to
`openai/math/lean/OAI/RepresentationTheory/Saxl/Main.lean`, declaration
`OAI.Saxl.saxl_conjecture`. Only these files and this handoff changed.

Checked Theorem 1.1 of the September 24 PDF (paper-cache 535, SHA-256
`42c2824b06a1114993095d44e1226e7f15f17caaa09358d68fa5dfddedbd8f44`):
all staircase sizes and all partitions of the corresponding triangular size.
The source uses (m,...,1), equivalent to the site's (k-1,...,1).
Read formalization catalogue entry, scope note 205, actual Main.lean theorem
and Saxl comparator configuration. The comparator file is a statement
with a placeholder, while Main.lean supplies the proof term and imports.
No local Lean build, axiom audit, or mathematical proof audit was performed;
the public note describes an announced proof and links the provided source.

Started clean at `112d750`. `make Q=1`, `make check Q=1`, rendered citation
and link inspection, and `git diff --check` pass (expected fixture warnings).
Ownership released. Local checkpoint only; no push or deployment.

## Completed scope — clarify the permutation statistic (2026-10-07)

Updated only `tex-source/chromaticEexpansion.tex` and this handoff. Replaced
“positive permutation formula” with a precise description: a terminating
algorithm using auxiliary geometric choices and ordered finite matchings.
Checked Sections 6.1–6.5 and Remark 7.1 of cached preprint 533: an encoding
order fixes the embedding and rational generic choices by enumeration;
local bijections match finite ranks. Thus the asserted construction is
algorithmic, not merely a nonconstructive existence statement, but it does
not supply a simple intrinsic permutation rule. No proof audit performed.

Started clean at `040c536`. `make Q=1`, `make check Q=1`, rendered citation
inspection and `git diff --check` pass (two expected fixture warnings).
Ownership released. Local checkpoint only; no push or deployment.

## Broken-stick bibliography — 2026-10-07

Host supervisor completed only bibliography.bib and this entry for two references
used by Recreational.Problems: PetersenTenner2020 and DukeBrokenStick.
Prior ownership is released and checkout was clean. The webpage worker is
reviewing a separate new preprint; guarded send refused delivery to its active
pane, which was left untouched. No website prose, push, or deployment in scope.
DOI metadata verified against arXiv; corrected the API's Tenner surname parsing.
Book BibTeX/pdflatex and `git diff --check` pass. Pandoc parses both entries;
the escaped percent in the Duke URL is needed by the book's backref package,
but Pandoc retains that backslash in CSL-JSON. Before citing this currently
unused web entry on SymCat, normalize that URL in its bibliography pipeline.
Local checkpoint only, preserving the existing no-push boundary. Ownership released.

## Completed scope — Shareshian–Wachs preprint (2026-10-07)

Added `OpenAI2026ChromaticPositivity` to `bibliography.bib` from the
manuscript's supplied citation metadata. Added concise announced-proof notes
to `tex-source/chromaticQuasisymmetric.tex` and
`tex-source/chromaticEexpansion.tex`; corrected stale open-problem wording.
Theorem 1.1 asserts elementary positivity over N[q] for natural unit interval
graphs and a positive permutation formula. The paper explicitly excludes
elementary unimodality; that conjecture remains separately stated. Existing
anchors and established-positivity metadata are preserved.

Checked the September 24 PDF (paper-cache record 533, SHA-256
`9e1c6414a9ea8ce93b8bea6d40639da43f744f04c938e57c12c72b29f9d4c8ea`;
GitHub paper revision `adc7f1241b42e322a6451854ab7e4b4c146bf78a`).
This was a statement/source check, not a proof audit. The release README
notes varying verification status; no matching entry was found in its Lean
formalization catalogue. Public text attributes an announced proof.

`make Q=1`, `make check Q=1`, rendered citation/link inspection and
`git diff --check` pass (two expected synthetic fixture warnings).
Started clean at `b505d54`; concurrent host-supervisor broken-stick additions
are preserved and excluded from this checkpoint. Ownership of this update's
four-file scope is released. Local commit only under the existing no-push
boundary; no deployment authorized or performed.

## Completed scope — prism-slice Ehrhart positivity reference (2026-10-07)

Added a short paragraph in `tex-source/ehrhart.tex` on positivity for slices
of prisms and independence polytopes of uniform matroids, with a link to the
existing hypersimplex discussion. Added `FerroniMcGinnis2025` to
`bibliography.bib`; these two files and this handoff are the complete scope.
Verified Theorem 1.1 and Corollary 6.4 against the primary paper and journal
version; the published issue year is 2025. The flag-Eulerian material discussed
in chat is outside this addition.

`make Q=1`, `make check Q=1`, generated citation/link inspection and
`git diff --check` pass; only the two expected synthetic fixture warnings
appear. Started clean at `8fc10b1`, with six existing unpublished commits
already ahead of origin/master. Checkpoint stays local to preserve the
existing no-push boundary. No deployment authorized or performed.
Ownership is released.

## Verified deployment — 2026-10-07

At the user's explicit request, deployed clean source commit
`7ba5d628fb797bed1d56e82935d22d3c3b56bf98` through the constrained SymCat
bridge. Receipt: `20261007T061926-b9d118a3ad59`; deployment and Pagefind
manifest verification succeeded. `make Q=1`, `make check Q=1` and
`git diff --check` passed first (only the two expected fixture warnings).
Live HTTPS checks returned 200 for `ehrhart.htm`, `gtpatterns.htm`,
`schur.htm` and `site-labels.json`; verified the corrected heading, direct
skew-GT theorem anchor, citations and both cross-page links. The Ehrhart mail
follow-up below is now live. Only this handoff changed after deployment;
no active ownership remains. No Git push was performed.

## Completed scope — Ehrhart positivity mail follow-up (2026-10-07)

Updated only `tex-source/ehrhart.tex`, `tex-source/gtpatterns.tex`,
`tex-source/schur.tex` and this handoff after reading mail UIDs 66–68.
Jochemko–Menon's result and the flagged-face/fixed-content distinction were
already present, and both bibliography entries existed. Renamed the overview
heading to "Ehrhart positivity: results and conjectures" while preserving its
anchor, removed stale conjectural framing of the skew-Schur case, and fixed
the overview's link from the Kostka section to a new direct skew-GT theorem
anchor. Added a short pointer under skew Schur specializations. Net public
text is shorter; no bibliography duplication or private correspondence added.

Checked public arXiv metadata and paper-cache records 251 and 263:
Jochemko–Menon Theorem 3.5 / Section 3.2 and Alexandersson–Alhajjar preprint
Conjecture 7 (the explicitly cited arXiv numbering). This is a statement and
citation check, not an audit of the private exploratory proof. General key
and fixed-content conjectures retain their existing status.

`make Q=1`, `make check Q=1`, generated theorem/citation/link inspection and
`git diff --check` pass; only the two expected synthetic fixture warnings
appear. Started clean at `699c8fc`, with four unrelated unpublished commits
already ahead of origin/master. Checkpoint stays local to avoid pushing those
commits as part of this task. No deployment authorized/performed. Ownership
is released.

## Pak survey reference for problem book — 2026-10-06

Host supervisor adds only `Pak2002PartitionBijections` to the master
bibliography for the authorized Recreational.Problems replacement exercise.
Metadata identifies the linked survey's September 18, 2002 version, whose
section 2.4.1 supplies the identity. No website content or deployment is in
scope. Fresh book BibTeX/pdflatex verification and `git diff --check` passed.
Ownership released. Checkpoint remains local because the branch contains
unrelated unpublished commits; no push or deployment performed.

## Bousch bibliography reference for problem book — 2026-10-06

Host supervisor adds only `Bousch2014` to the shared master bibliography,
as authorized for the Recreational.Problems Hanoi correction. Metadata came
from the site's DOI API; page range and theorem were checked against the
author's publication list and primary paper. No website text or deployment
is in scope. The book's fresh BibTeX and pdflatex passes and `git diff --check`
pass. Ownership released. Checkpoint is local only: the branch already has
two unrelated unpublished commits, so no push or deployment was performed.

## Completed scope — Liu Ehrhart operations reference (2026-10-06)

Added Feihu Liu's arXiv:2610.06338v1 with the collision-free bibliography key
`Liu2026EhrhartOperations`, a short `ehrhart.tex#ehrhartOperations` paragraph,
and a cross-reference in `polytopes.tex` (about 70 words total). Only those
three source files and this handoff were owned. Primary PDF cached as record
511; Corollary 3.2, equation (4.1), and Theorem 5.7 support the cited examples.
This is a source-checked summary, not an independent proof audit.
`make bib Q=1`, `make Q=1`, `make check Q=1`, rendered citation/cross-link
inspection, and `git diff --check` pass (only two expected fixture warnings).
Existing released statement corrections are preserved. No deployment was
requested or performed. Ownership is released.

## Completed scope — RealRooted statement corrections (2026-10-06)

Fixed five theorem statements flagged by the RealRooted coverage survey
(`/workspace/suggestions/realrooted-cleanup-2026-10-05/survey-site.md`),
editing only three `tex-source` files:

- `realRooted.tex#kurtzTheorem`: Kurtz inequalities only for 1 ≤ i ≤ n−1
  (`RealRooted.Kurtz.coefficient_criterion`).
- `realRootedGraphs.tex` Nijenhuis theorem: added the missing conclusion
  (real-rooted, nonnegative zeros) and "non-attacking"; checked against
  `Challenges/Nijenhuis.lean` and Liu–Wang (2007, Sec. 3). The original
  Nijenhuis paper is not in the paper cache.
- `realRootedInterlacing.tex`: Wronskian criterion gains
  deg f − deg g ∈ {0,1} (f = x³, g = 1 otherwise refutes it); the preserver
  theorem holds only up to order and sign normalization (Brändén's
  "alternate", RealRooted `preservesInterlacing_of_preservesRealRootedOrZero`);
  Liu's opposite-sign criterion needs the common-zero branch
  (`compatible_iff_theorem21RootCountBranchesWithCommon_nonconstant`).

The weak Wronskian converse with the degree hypothesis is a short standard
argument but is not yet formalized (only strict converses are). Focused
page builds and `make lint-html Q=1` pass. Commits are local, not pushed; no
deployment. Ownership is released.

## Completed scope — Schur--Szegő references and Lean issues (2026-10-05)

Changed only `bibliography.bib`, `tex-source/realRooted.tex`,
`tex-source/realRootedInterlacing.tex`, and this handoff for the two suggested
references and concise context (about 120 words). The checkout was clean. Cached primary
papers 111 and 114 cover Kostov--Shapiro (2006) and Kostov (2010); publisher
pages confirm journal metadata and the read-only site API supplies BibTeX.
The 2010 paper's arXiv deposit is from 2015, but the citation uses its journal
year. Its interlacing statements concern reduced eigenpolynomials of the
coefficient map, not a new unrestricted preservation theorem. Zhang's
degree-changing comparison is checked separately against Theorem 4.1 and
Lemma 4.2 of cached record 510. No private correspondence is published.
`make bib Q=1`, `make Q=1`, `make check Q=1`, rendered citation/link checks,
and `git diff --check` pass; only the two expected test warnings appeared.
After the final wording refinement, the build and HTML lint passed again.
No deployment is authorized or performed; ownership is released.

At the user's explicit request, opened detailed RealRooted issues after a
read-only source and existing-issue audit at `935f425d`:

- [#1108](https://github.com/PerAlexandersson/RealRooted/issues/1108):
  Schur--Szegő multiplicity refinements and strict finite multipliers.
- [#1109](https://github.com/PerAlexandersson/RealRooted/issues/1109):
  Zhang's general degree-changing compression theorem (depends on #1108's
  strict endpoint, not its full multiplicity classification).
- [#1110](https://github.com/PerAlexandersson/RealRooted/issues/1110):
  separable-permutation application and explicit combinatorial identity boundary.
- [#1111](https://github.com/PerAlexandersson/RealRooted/issues/1111):
  Kostov coefficient-map eigenpolynomials, a lower-priority independent project.

Each issue records precise hypotheses, source references, existing APIs,
proof milestones and verification criteria. In particular, Kostov (2010)
corrects the earlier multiplicity statement by requiring nonzero chosen roots;
RealRooted's `StrictInterl` has weak root inequalities, so the issues require
separate simplicity/no-common-root proofs. No Lean source or handoff was
modified and no Lean build was started; the active build owner's lane remains
untouched. These are formalization targets, not completed proof audits.

## Completed scope — separable-permutation OEIS reference (2026-10-05)

Added one sentence linking the coefficient triangle to A175124 in
`tex-source/realRootedWords.tex`; only that file and this handoff changed.
A175124 is explicitly identified in Fu--Lin--Zeng (paper-cache
record 137, introduction); its displayed OEIS rows agree with their listed
polynomials, with row n containing the coefficients of S_n starting at t^0.
The existing family-page A006318 link remains. The focused page build,
`make lint-html Q=1`, rendered link inspection, and `git diff --check` pass.
No deployment is authorized or performed; ownership is released.

## Completed scope — separable-permutation interlacing preprint (2026-10-05)

Added `Zhang2026SeparableInterlacing` to `bibliography.bib` with SSRN/DOI
links and preprint dates, alongside the original `FuLinZeng2018` reference.
`tex-source/realRootedWords.tex#separableDescentRealRooted` defines the descent
and gamma-polynomials and records their simple negative zeros and strict
consecutive interlacing/interleaving. `tex-source/permutationFamilies.tex`
and `tex-source/realRootedInterlacing.tex` carry concise cited cross-links.
The existing A006318 link is retained. Only these four source files and this
handoff changed; the requesting worker's compendium draft/citation/ledger is
untouched. No deployment is authorized or performed. Ownership is released.

The indexed primary SSRN abstract confirms Zhanhe Zhang, the title, written
date 2026-09-10, and posting date 2026-09-25. After direct SSRN access had
returned HTTP 403, the user supplied `/workspace/temp/ssrn-7510941.pdf`.
It is now paper-cache record 510. Equations (1.1) and (1.4) and Theorems 1.1
and 1.2 were checked against the extracted text and PDF page 2; this is a
statement/normalization check, not a full proof audit. We cite those verified
theorem numbers without spelling out gamma parity orientations. The original
Fu--Lin--Zeng abstract and publisher record confirm the conjecture; its
bibliography metadata comes from the site's read-only API. No private mail
text or address is used on the site.

`make bib Q=1`, `make Q=1`, `make check Q=1`, and `git diff --check` pass.
The check emits only the two expected synthetic-relation warnings. Rendered
HTML and CSL metadata inspection confirms the author, preprint status, dates,
DOI/SSRN URLs, theorem citations, displayed formulas, and cross-page anchors.

## Deployment completed — Jacobi–Stirling additions (2026-10-05)

At the user's explicit request, rebuilt and checked the clean checkout with
`make Q=1` and `make check Q=1`; only the two expected synthetic-relation
warnings appeared. The constrained host bridge deployed content commit
`897eee9de2a725fec12934a7f018786f9ecbb705` under receipt
`20261005T070719-3ae134dfebcc`. Site transfer, Pagefind transfer, and manifest
verification completed; `pagefind_manifest_match=true`.
An independent HTTPS fetch confirms the Jacobi–Stirling section, theorem
citations, strict coefficient inequalities, and A008517 link at
`realRootedWords.htm#jacobiStirlingDescentRealRooted`. Ownership is released.

## Completed scope — Jacobi–Stirling OEIS follow-up (2026-10-05)

Neither cached paper contains explicit OEIS references. Added a direct
A008517 link in the Jacobi–Stirling section and the indexing identity
`[t^j] A_{k,k}(t) = T(k,j+1)`, verified against the OEIS MCP entry and the
paper's second-order Eulerian specialization. The focused page build,
`make lint-html Q=1`, rendered link/formula inspection, and `git diff --check`
pass. No deployment was performed; ownership is released.

## Completed scope — Jacobi–Stirling descent polynomials (2026-10-05)

Added `jacobiStirlingDescentRealRooted` to `tex-source/realRootedWords.tex`:
the permutation and internal-descent definitions, Ma–Wang's five families of
weighted sums with simple negative zeros, all five strict interlacing
comparisons, and strict top-heaviness/increasing-left-half inequalities.
The general Gessel–Lin–Zeng conjecture remains marked as open; the older
paper's extra factor of the descent variable is explicit.

Primary sources are cached as paper-cache records 508–509. Both bibliography
entries came from the read-only arXiv site API; theorem numbers, barred-letter
order, and normalization were checked against the manuscripts. `make bib Q=1`,
the focused page build, `make Q=1`, `make check Q=1`, rendered formula/link/
citation inspection, and `git diff --check` pass. The check emits only the two
expected synthetic-relation warnings. A possible normalization inconsistency
in the pre-existing Stirling example is recorded in
`suggestions/stirling-descent-normalization.txt` for a separate focused review.
No new polynomial computations or other site edits were made. No deployment
is authorized or performed; ownership is released.

## Completed scope — fundamental specialization and X-descents (2026-10-02)

Implemented GitHub issue #3 across the Gessel, chromatic-quasisymmetric, and
graph real-rootedness pages.  The Gessel page defines the shifted and
unshifted fundamental-length maps, proves their principal-specialization and
omega-reversal identities, and records that they are linear rather than
multiplicative.  The chromatic page identifies the shifted image with
Brenti's $w$-polynomial, defines the Rédei--Berge and $X$-descent
specializations, and retains the Shareshian--Wachs $q$-weight.  The graph page
states Brenti's chordal theorem and gives one self-contained proof through a
simplicial-vertex recurrence and a differential root-preserving lemma.

The Shareshian--Wachs and Grinberg--Stanley manuscripts are cached as
paper-cache records 504--505.  The Brenti statement and numbering were checked
against the primary 1992 article; new BibTeX records came from the read-only
`arxiv.symmetricfunctions.com` API.  `make bib Q=1`, all three focused page
builds, `make Q=1`, `make check Q=1`, rendered formula/link/citation inspection,
and `git diff --check` pass.  The check emits only the two expected synthetic-
relation warnings.  No deployment is authorized or performed; ownership is
released.

## Completed scope — two current preprints (2026-10-02)

Added concise coverage of arXiv `2609.11691v3` and `2507.18852v3`.  The
$qt$-Catalan page now defines Oblomkov's type-$B_n$ $q,t$-Fuss--Catalan
polynomial, records its asymptotic localization formula and principal
specialization, and notes the conjectural labelled-path Frobenius model.  The
Schubert page now records that generalized chute moves make the reduced pipe
dreams of every permutation into the Rubey lattice, together with the
move-operator algorithms and pipe-dream-tableau comparability criterion.

The primary manuscripts are cached as paper-cache records 502--503, and both
BibTeX records came from the read-only `arxiv.symmetricfunctions.com` API.
`make bib Q=1`, both focused page builds, `make Q=1`, `make check Q=1`, rendered
formula/citation inspection, and `git diff --check` pass.  The check emits only
the two expected synthetic-relation warnings.  No deployment is authorized or
performed; ownership is released.

## Completed scope — three current preprints (2026-10-02)

Added concise theorem-level coverage of arXiv `2610.01708v1`, `2610.01617v1`,
and `2610.00966v1`.  The $k$-Schur page now records Bai--Guo's proof that every
$K$-$k$-Schur function is $k$-Schur-positive, the Catalan/Katalan mechanism,
the stable dual-Grothendieck specialization, and their counterexample to the
broader Katalan conjecture.  The chromatic page has a stable products-of-chains
subsection giving Zhang's explicit negative coefficient for
$n\geq4$, $m\geq3n-1$ and the combined nonpositivity range.  The real-rooted
words page defines the multiset Eulerian--Narayana polynomials and records
simple negative zeros, gamma-refinement monotonicity, total nonnegativity, and
strict adjacent-column interlacing.

The primary manuscripts are cached as paper-cache records 499--501.  BibTeX
records came from the read-only `arxiv.symmetricfunctions.com` API; the Kai
Zhang entry uses the collision-free key `Zhang2026Chainsx` because
`Zhang2026x` already belongs to Philip B. Zhang.  `make bib Q=1`, all three
focused page builds, `make Q=1`, `make check Q=1`, rendered anchor/citation
inspection, and `git diff --check` pass.  The check emits only the two expected
synthetic-relation warnings.  No deployment is authorized or performed;
ownership is released.

## Completed scope — OEIS proof collection refactor (2026-09-30)

The three proofs formerly embedded in `tex-source/various-research.tex` now
have sequence-specific pages, reached through the new `oeisProofs` landing
page.  The collection currently covers A152947, A189912, and A358628.  The
software-resources list also links to the collection, while the old headings
and anchors in `various-research.htm` remain as short compatibility pointers.

This was an architectural refactor only: the mathematical content was moved
without changing its claims, and no OEIS entry or build-pipeline file was
changed.  `make Q=1`, `make check Q=1`, rendered-link inspection, and
`git diff --check` pass; the check emits only its two expected synthetic-
relation warnings.

The constrained bridge deployed exact content commit
`6581cdd1c97063c391104ed98e27c7220c8fb3e4` under receipt
`20260930T094736-fb2e56b3f4ad`; the site, Pagefind, and manifest-verification
steps completed and `pagefind_manifest_match=true`.  Independent HTTPS fetches
find the landing page, all three sequence pages, and the compatibility pointer
from `various-research.htm`.  Ownership is released.

## Completed scope — A358628 column conjectures (2026-09-30)

The A358628 subsection in `tex-source/various-research.tex` gives a
self-contained proof of both conjectures currently stated in the OEIS entry.
It derives the coefficient formula and fixed-column generating function from
one bivariate coordinate sum, then proves
`A(i,j)=binomial(i+j,j)^2*p_j(i)`, including the exact degree, leading
coefficient, and reciprocity of `p_j`.

The same argument realizes each column as the Ehrhart polynomial of an
explicit `3j`-dimensional lattice polytope.  Its h-star polynomial is the
binomial-square polynomial, identified with a transformed Legendre polynomial;
the page records its normalized volume, negative simple zeros, recurrence,
log-concavity, and unimodality.  Summing the Legendre form also evaluates the
bivariate generating function from the OEIS entry.

Private research issue #28 and its source draft were read-only inputs.  The
unrelated dirty/behind research checkout was untouched.  The focused page
build, full `make Q=1`, `make check Q=1`, rendered HTML inspection, and
`git diff --check` pass; the check emits only its two expected synthetic-
relation warnings.  No build-pipeline file or OEIS edit was in scope.

The constrained bridge deployed exact content commit
`c0ef825dfbb547b0c31e404df9eaa3590c00512e` under receipt
`20260930T092448-2b7fabf88879`; the site, Pagefind, and manifest-verification
steps completed and `pagefind_manifest_match=true`.  An independent HTTPS
fetch finds the theorem, Ehrhart interpretation, factorization, reciprocity,
and bivariate generating function at
`various-research.htm#A358628Columns`.  Ownership is released.

## Completed scope — unit interval cographs and A152947 (2026-09-30)

The A152947 subsection in `tex-source/various-research.tex` proves that the
connected area sequences whose natural unit interval graphs are cographs are
counted by

```text
c_n = 1 + binomial(n - 1, 2),  n >= 1.
```

The proof classifies the connected graphs as `K_n` or
`K_r join (K_p disjoint-union K_q)` with positive `p,q,r`, identifies their
area sequences, and counts ordered positive triples.  It also derives the
ordinary generating function `(1-x)^3/(1-4x+5x^2-3x^3)` for all, possibly
disconnected, area sequences and records its first 13 terms.  The reusable
Rust certificate/predicate is `Graph::{induced_p4_witness,is_p4_free}` in
`combinatoric-core/src/graph.rs`.

The focused page build, full `make Q=1`, `make check Q=1`, rendered HTML
inspection, and `git diff --check` pass; the check emits only its two expected
synthetic-relation warnings.  No build-pipeline file was changed.

The constrained bridge deployed exact content commit
`5cb596c001471f50e921af34145132eefa1db386` under receipt
`20260930T090404-ea010156035a`; the site, Pagefind, and manifest-verification
steps all completed and `pagefind_manifest_match=true`.  An independent HTTPS
fetch finds the new heading, A152947 link, classification, and generating
function at `various-research.htm#unitIntervalCographsA152947`.  Ownership is
released.

## Completed scope — SearchAction and scoped Pagefind deployment (2026-09-29)

Codex owned `template.htm`, the focused generated-HTML regression surface under
`tests/`, this handoff, and any directly related website documentation needed
to replace the broken JSON-LD SearchAction URL.  The checkout started clean on
`master` at `3509698`, matching `origin/master`; no `.tex` content is in scope.
The user explicitly authorized the verified rebuild and constrained deployment
after this website fix and the separately owned Pagefind bridge change passed
review-quality checks.

The generated JSON-LD SearchAction now targets
`https://www.symmetricfunctions.com/search.htm?q={search_term_string}`.  The
real search page reads that `q` parameter and hands it to Pagefind's
`triggerSearch`, so the structured action both resolves and performs the
requested search.  The generated-HTML lint rejects the former
`topicsindex.htm` target and requires both the new target and query handoff.

Focused render/copy/lint checks pass.  `make Q=1`, `make check Q=1`, and
`git diff --check` pass from the final pre-deploy source; the check emits only
the two expected synthetic-relation warnings.  The rebuilt index contains the
new SearchAction, `www/search.htm` contains the Pagefind query handoff,
`www/_pagefind/pagefind-entry.json` reports 145 English pages, and
`www/unittest.htm` is absent.  No `.tex` content changed.

The host supervisor restarted the dedicated bridge and deployed exact website
commit `cad09a284e9c0ea16fa45058fa37843ba5674362`.  Receipt
`20260929T095826-36e7487198d2` reports `delivery_state=deployed`; the `site`,
`pagefind`, and `pagefind-verify` steps all completed and
`pagefind_manifest_match=true`.  Independent live checks find the new
SearchAction target on the homepage and both
`URLSearchParams(window.location.search).get("q")` and
`pagefindUI.triggerSearch(query)` on `search.htm`.  The live Pagefind entry
reports `page_count=145`, `unittest.htm` returns HTTP 404, deleted old shard
`index/en_137884b.pf_index` returns HTTP 404, and current shard
`index/en_01bd27f.pf_index` returns HTTP 200.  Ownership is released.

## Completed scope — ownership released (2026-09-29, accepted build-pipeline fixes)

Codex owned `Makefile`, `config.mk`, `config_test.mk`, the Lua build-pipeline
modules needed for D1--D8, D14--D16, D20, H5, deterministic/atomic metadata
writes, focused files under `tests/`, relevant build documentation, and this
handoff.  The starting checkout is clean at `c9272da` on `master`; the prior
audit owner released all files.  No mathematical/content file under
`tex-source/`, supervisor/deploy bridge, deployment, broad local prune, or
remote deletion was in scope.

Implementation and the four supervisor follow-ups are complete, supervisor
review is approved, and ownership is released.  D1 now keeps the rendered
fixture at `temp/test-www/unittest.htm` and its Pandoc
and merged metadata under `temp/test-www/meta/`; the exact stale local
`www/unittest.htm` was removed manually.  The HTML lint performs a read-only
allowlist audit and does not prune anything.  Pagefind removes only the exact
`www/_pagefind` directory immediately before indexing, with quiet-mode failure
output retained in `temp/pagefind.log`; no other local or remote deletion was
added.

Asset copying is now backed by `temp/copy-assets.stamp`, with every current
asset file as a prerequisite.  Pagefind is backed by both
`temp/pagefind.stamp` and its concrete `www/_pagefind/pagefind-entry.json`
output; site HTML, the generated HTML metadata pages, and the asset stamp are
prerequisites.  Thus unchanged builds skip both operations, while an HTML or
asset change schedules Pagefind.  Each actual Pagefind recipe validates
`WWW_DIR`, removes exactly `${WWW_DIR}/_pagefind`, and only then invokes the
indexer.  Make-time guards reject empty and filesystem-root `WWW_DIR` values;
the recipe has a second runtime guard.

The renderer/preprocessor fixes cover Unicode and TeX-accented `\name`
arguments and optional displays, Unicode-codepoint and hyphenated initials,
percent-encoded Scholar queries, colon punctuation, verbatim/comment/`\verb`
protection, environment-only proof renames, literal URLs, idempotent link
classes, citation prefix/suffix placement and unsupported modes, escaped table
ampersands, recursive escaped TOC text, single-escaped image text, escaped math
bodies, and bare `\none` tokenization.  Focused fixtures cover D2--D8, D14,
D15, D20, and H5.  The math-punctuation patterns are exactly `[.,]`, and a
literal percent-comment fixture guards against treating `%` as punctuation.
Table cells now preserve already encoded entities while still escaping
unrelated raw angle brackets; the regression combines `&amp;` and `<raw>` in
one cell.  D16 prerequisites now include `file_reading.lua`, metadata
depends on the CSL bibliography rather than raw BibTeX JSON, and the unittest
checker tracks both Lua dependencies.  D22 malformed-JSON behavior is
unchanged.

`file_reading.json_encode` now sorts object keys recursively.  Every
`merge_meta.lua` output uses same-directory temporary-file replacement and is
left untouched when its bytes match.  An immediate no-op merge reported all
eight outputs unchanged and preserved their SHA-256 bytes and nanosecond
mtimes: the three private metadata JSON files, sitemap, goto page, public label
JSON, and both relation-graph outputs.

Verification from the final source state after the supervisor follow-ups:

- `luac -p` passes for every edited pipeline/test script.  The focused
  edge-case checker and `make unittest Q=1` pass; the latter prints only the
  two existing expected synthetic-relation warnings.
- `make Q=1`, `make check Q=1`, and `git diff --check` pass.
- An actual second `make Q=1` preserves the nanosecond mtimes and sizes of the
  asset stamp, Pagefind stamp, and Pagefind entry.  Its dry-run plan contains
  no `cp -r`, Pagefind cleanup, or Pagefind invocation.  A forced
  `tex-source/gammaPositivity.tex` plan schedules its render and the Pagefind
  recipe; a forced `assets/style.css` plan schedules one asset-copy recipe and
  the Pagefind recipe.  In each Pagefind recipe the exact `_pagefind` removal
  precedes either quiet or normal indexing.
- `make -n WWW_DIR= search` and `make -n WWW_DIR=/ search` both fail at parse
  time with explicit safety diagnostics, and neither rejected plan contains
  `/_pagefind`.
- A direct no-change metadata pass preserves SHA-256 bytes, sizes, and
  nanosecond mtimes for all eight generated outputs.
- `www/unittest.htm` is absent; the isolated HTML and JSON exist only below
  `temp/test-www/`.  The read-only audit accepts exactly 147 top-level HTML
  outputs: 144 source pages, `assets/search.htm`, `goto.htm`, and
  `polynomial-relations.htm`.
- The rebuilt live examples contain `Ś. Gal`, `N. González`, `É. Tétreault`,
  and `M.-P. Schützenberger`, with the checked percent-encoded Gal query.
  Site-wide lint/count checks find zero U+FFFD characters and zero raw-TeX
  `author-name` links.
- Rebuilt `www/_pagefind` is 2.7 MB with one `pf_meta` file and reports 145
  indexed pages; the former stale 98 MB shard accumulation is gone locally.
- Dry-run dependency checks schedule 144 gathers when `file_reading.lua` is
  forced and one metadata merge when `temp/bibliography.json` is forced.

No `tex-source/` content, supervisor/deploy bridge, deployment, broad local
prune, or remote deletion was touched.  Supervisor review is approved and
ownership is released with the focused `master` checkpoint.

## Completed scope (2026-09-29, build-pipeline audit)

Claude Opus 5.5 was the sole audit owner for a read-only audit of the build
pipeline at `02f8941`.  It covered the Makefile and config, every Lua
module, the template, the tests and lint, the pagefind and SVG interfaces, the
incremental behaviour, and deploy staging.  The `.tex` corpus was out of
scope.  The ranked report is
`suggestions/build-pipeline-audit-opus55-20260929.md`.  It lists 23 confirmed
defects, 9 hardening items and 9 QoL items, each with file:line references, a
fix, and a regression-test idea.

Highest-priority findings:

- `make check` writes `unittest.htm` into `www/`.  The page is live on
  production (HTTP 200) and in the search index.
- `\name` corrupts non-ASCII initials and leaks TeX accents: 5 U+FFFD and 17
  raw-TeX names are visible, and 38 tooltips contain TeX, including live
  `�. Gal`.
- `$x$:` is moved to `$x:$` at 51 sites, which adds relation spacing before
  the colon.
- `make svg` exits 0 on failure and ignores `svg-tex/lib` changes.
- Stale pagefind files accumulate: 119 `pf_meta` files, 1 referenced.
- The eprint→url `sed` duplicates `url` in 1,035 entries.
- Required JSON loads fail open: malformed Pandoc JSON renders an `Untitled`
  page and exits 0.
- Deleted sources/assets are never pruned locally or remotely, and
  `www/.created` is included by the deploy rsync.

Reproductions ran only in the session scratchpad, using the existing `temp/`
metadata read-only.  The host supervisor added independent dry-run checks and
verified the two fail-open/pruning findings.  No build, check, deploy,
pipeline-source edit or generated-output change was made.  The only files
written are the report and this entry.  Ownership is released.  Removing the
live `unittest.htm` requires an explicitly authorized remote action.

## Completed scope (2026-09-27, copyable interlacing-matrix list)

Reverted the over-broad 56-case classification from source commit `41acf76`
after the user clarified the request.  The page again shows only the 18
matrices satisfying Brändén's criterion, now as a compact nested-list code
block.  The site's existing code-block control provides one-click copying.
Retained the useful stable `smallInterlacingMatrices` anchor, but removed the
added TP2/Lace comparison and all 38 failing cases.

The focused build, `make Q=1`, `make check Q=1`, rendered code-block and
anchor inspection, and `git diff --check` pass.  No Rust source was changed.
The user authorized deployment of source commit `6eac4de`; the constrained
bridge completed with exit code 0 under request
`20260928T053613-6b67d5afd820`.  The live homepage and interlacing page return
HTTP 200, and the live page and `site.js` match their local SHA-256 checksums.
The live page contains the stable anchor and both endpoints of the 18-matrix
code block.  No database mutation or migration was involved.  Ownership is
released and there are no blockers.

## Completed scope (2026-09-25, QSym geometry, word-QSym, and LLT positivity)

Added compact coverage of arXiv `2609.30257v1`, `2609.29927v1`, and
`2609.29957v1`.  New stable headings cover toric Richardson varieties and the
infinite quasisymmetric Grassmannian, word quasisymmetric functions and their
labeled-matroid invariant, snake-matroid shard polytopes, and single-row
Macdonald-cumulant LLT positivity.  Short reciprocal links connect the QSym,
NSym, lattice-path-matroid, matroid, modified-Macdonald, LLT, and diagonal
harmonics pages.  Existing public labels remain in place.

All three bibliography records came directly from the read-only
`arxiv.symmetricfunctions.com` BibTeX API.  Claims and theorem locators were
checked against the primary manuscripts cached as paper-cache records 455,
457, and 458.  `make bib Q=1`, `make Q=1`, `make check Q=1`, rendered-heading,
anchor, citation, and cross-link inspection, and `git diff --check` pass.  The
two warnings from `make check` are the existing missing-bibliography fixtures
in `tests/unittest.tex`.  No database mutation or migration was involved.  No
deployment is authorized or performed; ownership is released and there are
no blockers.

## Completed scope (2026-09-24, two current preprints)

Added compact coverage of Konoike's zonotope-average formula for integral
cyclic polytopes to `ehrhart.tex`, with a cross-link from the existing magic
positivity section in `polytopes.tex`.  The new result records magic
positivity of the Ehrhart polynomial and real-rootedness, log-concavity, and
unimodality of the corresponding (h^*)-polynomial.

Updated `key.tex` to mark the Reiner--Shimozono atom-positivity conjecture as
false.  The replacement records Hodges's infinite counterexample family, its
Narayana-factor coefficient formula, the first 28-variable negative
coefficients, the surviving three-variable theorem, and the failure of
Polo's Schubert-filtration conjecture.  Added the resulting (K)-theoretic
counterexample under products and Lascoux atoms in `lascoux.tex`, with
reciprocal stable cross-links.

Both bibliography records came directly from the read-only
`arxiv.symmetricfunctions.com` BibTeX API.  Claims and theorem locators were
checked against the primary manuscripts cached as paper-cache records 448
and 449.  `make bib Q=1`, `make Q=1`, `make check Q=1`, rendered-heading,
anchor, citation, and cross-link inspection, and `git diff --check` pass.  No
database mutation or migration was involved.  The user authorized deployment
of source commit `29bf8d6`; the constrained bridge completed with exit code 0
under request `20260924T081243-96919e370ef6`.  The live Ehrhart, polytopes,
key, and Lascoux pages expose the new anchors, cross-links, and citations.
Ownership is released and there are no blockers.

## Completed scope (2026-09-23, concise back stable page)

Shortened `backStableSchubert.tex` from 233 to 141 source lines to match the
compact style requested by the user.  The revision retains every public label,
the main definitions and formulas, all source-backed claims, and the links
used by other SymCat pages.  `make Q=1`, `make check Q=1`, rendered-heading
and anchor inspection, and `git diff --check` pass.  No deployment is
authorized or performed; ownership is released and there are no blockers.

## Completed scope (2026-09-23, back stable Schubert hub)

Added `backStableSchubert.tex`, a compact reference page for back stable
Schubert polynomials and their ambient ring.  Stable public anchors cover the
polynomial definition, ring, standard elementary and complete homogeneous
monomial bases, stabilization, Dynkin reversal, Stanley symmetric function
orbit sums, and shifted specializations that count reduced pipe dreams.

The page summarizes Rodriguez's arXiv `2609.25445v1`, with its bibliography
record copied from the site's BibTeX API and mathematical claims checked
against the cached primary manuscript.  It also cites the original
Lam--Lee--Shimozono basis theorem and the earlier standard elementary
monomial literature.  Added a generated navigation card and focused links
from the Schubert, Schubert-variations, Stanley-symmetric, and Grothendieck
pages; no existing public label was renamed or removed.

`make svg Q=1`, `make bib Q=1`, `make Q=1`, `make check Q=1`, rendered-link
and anchor inspection, and `git diff --check` pass.  No deployment is
authorized or performed; ownership is released and there are no blockers.

## Completed scope (2026-09-22, structural headings and anchors)

Added or re-leveled 45 descriptive headings across the long
`realRootedWords`, `stablePolynomials`, `diagonalHarmonics`, `qsymSchur`,
`realRootedCatalan`, `macdonaldEperm`, and `polytopes` pages.  The largest
catch-all blocks now expose stable camelCase anchors for their principal
families, definitions, formulas, examples, and applications.  Added precise
anchors for mixed RSK, the symplectic Rajchgot index, the Hibi--Li
face-number conjecture, and the diagonal superspace sign component.

No established label was renamed or removed.  The full build regenerated
`temp/site-labels.json`, where the new anchors resolve to their intended
pages.  `make Q=1`, `make check Q=1`, rendered-anchor inspection, global
duplicate-label inspection, and `git diff --check` pass.  No deployment is
authorized or performed; ownership is released and there are no blockers.

## Completed scope (2026-09-22, current arXiv coverage)

Added compact, search-oriented coverage of seven current preprints: matroid
Snapper polynomials, mixed RSK, symplectic Grothendieck regularity, Almkvist
unimodality, Sylvester simplices, Hibi--Li face numbers, and diagonal
superspace sign components.  The entries appear on the existing `matroids`,
`rsk`, `grothendieck`, `q-analogs`, `polytopes`, and `diagonalHarmonics`
pages.

All seven bibliography records came from the read-only
`arxiv-symmetricfunctions` BibTeX API for the exact cited versions.  Claims
and theorem locators were checked against primary manuscripts cached through
`paper-cache`; keyword-only matches were excluded.  `make bib Q=1`,
`make Q=1`, `make check Q=1`, rendered-page inspection, and
`git diff --check` pass.  The only check output is the two pre-existing
synthetic-polydata warnings.  No deployment is authorized or performed;
ownership is released and there are no blockers.

## Completed scope (2026-09-18, Lascoux tableauhedron)

Added a compact subsection on Lascoux's 2012 tableauhedron lecture to
`key.tex`, with cross-links from the Eulerian-polynomial and
Gelfand--Tsetlin pages.  The subsection treats the object as a
tableau/crystal graph and weighted Eulerian incidence structure: it records
left and right keys, defines compatible tableau chains, gives the associated
key--Ehrhart/Hilbert numerator, and states Lascoux's matrix Euler relation.
The worked `s_1s_2` example for `lambda=(4,2,0)` reproduces the five edge
multiplicities and the relation `2*2=1*3+1*1`; the later tableau-valued
relation `2t_3 ~ t_2t_5+t_2t_6` is also recorded with its precise scope.

The exposition explicitly does not call the tableauhedron a convex polytope.
It also records that Lascoux's `d_i` operators fail the braid relations, so a
reduced word is part of the raw graph/incidence presentation and the source
does not construct a canonical Euler quotient.  A disposable exact `A_2`
check supported this distinction: for `lambda=(4,2,0)`, the `121` and `212`
products agree on the highest-tableau input from Lascoux's proposition, but
differ by six formal terms on the nearby tableau with rows `1111/23`; the
difference becomes zero after evaluating left keys as key polynomials and
right tableaux by weight.  No experiment code was retained.

The eight `n=4` numerators on Lascoux's p. 25 were rechecked against the
`rho_4` table in the read-only Key-HStar-Bruhat-Interlacing notes and agree
exactly.  The current LS-path and statistic-preserving parking notes were
read only for context; no research-project file was changed.

Added the primary lecture-slides bibliography entry.  `make bib Q=1`, focused
builds for all three affected pages, `make Q=1`, `make check Q=1`, rendered
citation/cross-reference inspection, and `git diff --check` pass.  The only
check output is the two pre-existing synthetic-polydata warnings.  No figures
or deployment are involved; ownership is released and there are no blockers.

## Completed scope (2026-09-18, Boros--Moll infinite log-concavity)

Added Xie--Zhang, arXiv `2609.20653v1`, to the main real-rootedness page and
bibliography.  The new example defines the nonlinear log-concavity transform
and infinite log-concavity, gives the Boros--Moll coefficient formula, and
states the paper's strict interlacing of the first transformed polynomial
with the fixed-rank Narayana polynomial.  It cross-links that comparison
polynomial to the existing Catalan-family example and identifies the
integer-scaled coefficient triangle as OEIS A126936.

Opened low-priority RealRooted issue
`PerAlexandersson/RealRooted#847`, labeled `application` and `reference`.  It
records the precise gap between the existing Narayana formalization and the
new fixed-rank Boros--Moll interlacing theorem, along with a staged approach
and the paper's analytic/computational proof split.  No RealRooted files were
changed.

`make bib Q=1`, the focused page build, `make Q=1`, `make check Q=1`, rendered
citation/cross-reference inspection, and `git diff --check` pass.  The only
check output is the two pre-existing synthetic-polydata warnings.  No figures
or deployment are involved; ownership is released and there are no blockers.

## Completed scope (2026-09-17, published Macdonald-characters paper)

Reviewed mailbox UID 47 and the primary manuscript of Ben Dali--D'Adderio,
arXiv `2404.03904` (paper-cache record 418).  The existing Macdonald-page
paragraph now identifies the proved creation formula, shifted-symmetric basis
and characterization, and Jack-character limit with theorem locators.  It also
states explicitly that the two-parameter Matchings--Jack and $b$-positivity
extensions are conjectures.  The Jack-character section links back through the
proved specialization, without duplicating the Macdonald discussion.

Updated the bibliography from its arXiv-only record to the verified Selecta
Mathematica publication metadata: volume 32, issue 5 (2026), DOI
`10.1007/s00029-026-01201-6`.  `make bib Q=1`, both focused builds,
`make Q=1`, `make check Q=1`, rendered citation/cross-reference inspection,
and `git diff --check` pass.  The only check output is the two pre-existing
synthetic-polydata warnings.  No figures or deployment are involved;
ownership is released and there are no blockers.

## Completed scope (2026-09-17, growth-diagram display size)

Reduced the displayed RSK growth diagram from 98% to 78% of the text width, a
20.4% linear reduction, while retaining the centered figure wrapper.  The
focused RSK build, `make Q=1`, `make check Q=1`, rendered-width inspection,
and `git diff --check` pass.  The source SVG and mathematical content are
unchanged.  Ownership is released and there are no blockers; direct
deployment remains authorized for this debugging checkpoint.

## Completed scope (2026-09-17, generic growth-diagram example)

Replaced the involutive permutation by `57318264`.  Its top and right boundary
chains are now visibly different and yield distinct insertion and recording
tableaux of common shape `(3,3,2)`.  Every `1` has a pale blue circular marker;
the site's existing image inversion and hue rotation adapt the complete SVG
for explicit or system-preferred dark mode.

A source-data audit extracted all 64 displayed entries and 81 displayed
partitions, then independently reapplied Fomin's local rule at every cell.
There are no mismatches.  It also confirmed the permutation, the two boundary
chains, and both tableaux.  `make svg Q=1`, the focused RSK build,
`make Q=1`, `make check Q=1`, visual inspection, and `git diff --check` pass.
No bibliography or unrelated page changed.  Ownership is released and there
are no blockers; direct deployment remains authorized for this debugging
checkpoint.

## Completed scope (2026-09-17, growth-grid unit correction)

Corrected the actual source of the growth-diagram misalignment: TikZ's default
physical one-centimeter grid step did not follow the figure's 1.25-centimeter
coordinate units, producing eleven grid lines against nine partition
positions.  The shared primitive now draws vertical and horizontal lines at
explicit integer coordinates.  The regenerated eight-by-eight cell grid has
exactly nine lines and nine partition positions in each direction.

The focused RSK build, `make Q=1`, `make check Q=1`, visual inspection,
coordinate-count inspection, and `git diff --check` pass.  No prose,
bibliography, or unrelated asset changed.  Ownership is released and there
are no blockers; deployment is explicitly authorized for this checkpoint.

## Completed scope (2026-09-17, diagram alignment and larger rowmotion example)

The eight-by-eight RSK growth diagram now uses equal horizontal and vertical
units.  Cell entries sit at half-integer coordinates, vertex labels sit at
integer coordinates in uniform boxes, and partitions use compact words such
as `44` for `(4,4)`.  The page explains this notation outside the figure.  An
independent recurrence check confirms the matrix entries, all vertex labels,
the highlighted cell, and both boundary chains; there is no indexing shift.

The rowmotion example now uses all ten order ideals of `[2]\times[3]`, split
into two independently checked five-cycles.  Its ten Hasse diagrams use much
smaller nodes, put the element names inside the vertices, and render at 58%
page width.  The blue/white key and orbit contents remain in the prose.

`make svg Q=1`, both focused page builds, `make Q=1`, `make check Q=1`,
rendered HTML inspection, visual inspection of both regenerated figures, and
`git diff --check` pass.  No bibliography is involved.  Ownership is released
and there are no blockers; deployment is explicitly authorized for this
checkpoint.

## Completed scope (2026-09-17, enlarged growth diagram)

Replaced the two-by-two RSK figure by the full eight-by-eight growth diagram
of the involution `35172846`.  All 64 matrix entries are centered in their
cells, all 81 vertices carry partitions, and the shaded central cell exhibits
the nontrivial update from southwest label `(1,1)` and equal incoming labels
`(2,1)` to northeast label `(2,2)`.  The prose records the common boundary
tableau of shape `(4,4)`, and reusable row macros keep the TikZ data aligned.

Added `\wvec` to the shared KaTeX registry.  Removed both public-facing Rust
implementation notes and the source-level local Rust path from the
rowmotion-and-promotion page.  Its prose now states that blue vertices lie in
the ideal and white vertices lie outside, so the SVG needs no legend text.

`make svg Q=1`, both focused page builds, the Grothendieck focused build,
`make Q=1`, `make check Q=1`, rendered HTML inspection, direct KaTeX-registry
assertions, an independent partition check, visual SVG inspection, stale
local-reference searches, and `git diff --check` pass.  No bibliography or
deployment is involved.  Ownership is released and there are no blockers.

## Completed scope (2026-09-17, figure and display-math follow-up)

Centered the RSK and hybrid-Grothendieck SVGs through the site's figure
environment, and removed explanatory prose from those SVGs and the rowmotion
legend.  The promotion example now uses `[2]\times[3]`: its five linear
extensions and both promotion orbits are stated in the prose and drawn as
compact labeled Hasse diagrams.  A reusable TikZ macro fixes the geometry of
all five copies.  The orbit transitions were also checked independently.

The shared KaTeX macro table now defines `\defin` as bold mathematical content,
so the existing promotion and rowmotion definitions render inside display
math as well as in ordinary prose.  `make svg Q=1`, all three focused page
builds, `make Q=1`, `make check Q=1`, rendered-wrapper inspection, a direct
KaTeX-registry assertion, SVG prose searches, visual inspection of all four
affected figures, and `git diff --check` pass.  No bibliography or deployment
is involved.  Ownership is released and there are no blockers.

## Completed scope (2026-09-17, exposition and TikZ examples)

Revised the three preprint additions using the combinatorics-writing guidance.
The RSK page now presents row insertion and the basic correspondence before a
new growth-diagram section.  That section defines Fomin's local rule, works out
the permutation `21`, and then explains Petrov's Yang--Baxter derivation; two
unrelated RSK variants moved to the existing variants list.  The figure is
generated by `svg-tex/src/rsk-growth-diagram.tex`, using reusable primitives in
`svg-tex/lib/growth-diagrams.tex`.

The diagonal-harmonics page now has a dedicated Theta-and-Neguț subsection
that explains why the two operator families occur before stating the new
results.  It uses semantic elementary-function notation and removes the
formalization-status sentence from the mathematical narrative.  The
Grothendieck page now defines the three hybrid weights, gives a checked
set-valued reverse-plane-partition example with contribution
$t_1w_1w_2x_1x_2^2x_3$, and distinguishes the positive Schur/stable-$G$
expansions from the signed dual-stable-$g$ expansion.  Its figure is generated
by `svg-tex/src/hybrid-grothendieck-example.tex`.

`make svg Q=1`, all three focused page builds, `make Q=1`, `make check Q=1`,
rendered HTML inspection, grayscale figure inspection, added-line-length
review, and `git diff --check` pass.  Both TikZ sources compile through the
project's temporary PDF stage to tracked SVG assets.  No Rust, bibliography,
template, unrelated page, or deployment is involved.  Ownership is released
and there are no blockers.  The focused source-and-figure commit is `1e0f0b1`,
pushed non-forced to canonical `master` over authenticated HTTPS through `gh`.

## Completed scope (2026-09-17, three current preprints)

Reviewed arXiv `2608.14836v2`, `2609.18151v1`, and `2609.18502v1` through
the `arxiv-symmetricfunctions` API and their cached primary texts
(paper-cache records 414--416).  Added bibliography entries and placed their
durable theorem-level contributions on the nearest existing reference pages:

- D'Adderio--Interdonato--Iraci--Pagaria's explicit Neguț operators, extended
  Theta action, commutation relations, and $q=1$ Theta-conjecture theorem on
  `diagonalHarmonics.tex`, with the scope of the companion Lean development
  stated explicitly;
- Kundu's Demazure crystal on flagged set-valued reverse plane partitions and
  its key, Schur, stable-Grothendieck, and dual-stable-Grothendieck expansions
  on `grothendieck.tex`, with a cross-reference from `crystals.tex`; and
- Petrov's deterministic Yang--Baxter matching for RSK, its three-dimensional
  $R$ interpretation, and probabilistic deformations on `rsk.tex`, with a
  concise cross-reference from `latticeModel.tex`.

The review also corrected the pre-existing notation for the hybrid
Grothendieck polynomial from $G_{\lambda/\mu}$ to the authors' notation
$H_{\lambda/\mu}$.  `make bib Q=1`, all five focused page builds,
`make Q=1`, `make check Q=1`, rendered citation/cross-reference inspection,
line-length review, and `git diff --check` pass.  The only check output is the
two pre-existing synthetic-polydata warnings.  No Rust, images, generated
output, or deployment is involved.  Ownership is released and there are no
blockers.  The focused source commit is `0f3292a`, pushed non-forced to
canonical `master` over authenticated HTTPS through `gh`.

## Completed scope (2026-09-16, Kato v3 correction audit)

Audited mailbox UID 43 and the cached primary text of Kato,
arXiv `2505.23202v3` (paper-cache record 397), against every site citation.
The $k$-Schur and modified-Macdonald pages had repeated the withdrawn
unconditional claim and cited the obsolete Corollary 9.4.  They now distinguish
the unconditional Chen--Haiman module and affine Demazure results from general
$k$-Schur positivity, which is conditional on Conjecture 9.1 in v3 and proved
when $m\leq\max\{2k,19\}$.  The email's “Conjecture 9.2” corresponds in the
manuscript to Hypothesis 9.2, a sufficient condition that is not valid in
general.

The polynomial relation metadata now has a proved bounded-range edge and a
separate conjectural general edge.  An editorial remark records the v1--v2
withdrawal, the first failures of Hypothesis 9.2, and the convention caveat for
the original Lapointe--Lascoux--Morse family.  The bibliography is pinned to
v3.  `make bib Q=1`, both focused builds, `make Q=1`, `make check Q=1`,
rendered citation/relation inspection, the stale-claim audit, line-length
review, and `git diff --check` pass.  The only check output is the two
pre-existing synthetic-polydata warnings.  The focused commit is `d5c07bf`,
pushed non-forced to canonical `master` over authenticated HTTPS through
`gh`.  No deployment was performed; ownership is released and there are no
blockers.

## Deployment bridge available (2026-09-16)

Explicitly authorized Docker deployments now use the constrained host bridge:

```bash
/workspace/supervisor-tool symmetricfunctions-deploy status
/workspace/supervisor-tool symmetricfunctions-deploy run --json
```

Run the second command only after a clean verified build.  The bridge pins the
site checkout and production destination, keeps the SSH key on Euler, and
deploys only the existing `www/` tree.  A read-only status check at `ca08393`
returned `ready` with all checks passing.

The Kato v3 correction has not been deployed, as explicitly requested.  No
production files changed during this documentation update.

## Completed scope (2026-09-15, community-interest preprint integration)

Reviewed current combinatorics preprints through the
`arxiv-symmetricfunctions` API and checked the selected papers against their
cached primary texts.  Twelve papers with durable theorem-level results now
have concise placements on their natural reference pages:

- Gorin's Macdonald coherent-measure law of large numbers;
- Chin's oriented and valuated delta-matroids from stable polynomials;
- Kim's 0-Hecke model for homogeneous stable Grothendieck components;
- Jiang's real stability for antichain polynomials of three-chain products;
- Shimazaki's set-valued-tableau, five-vertex, and crystal bijections;
- Oh's classification of cyclic-induction Schur-positive Boolean sums;
- Smirnov's tableau-to-Gelfand--Tsetlin-cell bijection;
- Awan's first-derivative invariant for chromatic tree reconstruction;
- Kirillov--Nenashev--Shapiro--Vaintrob's loopy polynomial;
- Badalov's counterexamples to inverse matroid KL log-concavity;
- Fang--Gao's type C transpositions and strong marked tableaux; and
- Gu--Knauer's oriented-matroid simpliciality and mutation counterexamples.

The additions preserve important boundaries: the first inverse-KL
Turán inequality remains open, Fang--Gao do not prove the type C
$k$-Schur conjecture, and Chin's valuated result uses the
regular-subdivision definition rather than the stronger constant-parity
version.  Narrow computational results and papers without a natural site
home were left out.

`make bib Q=1`, focused page builds, `make Q=1`, `make check Q=1`, rendered
citation and cross-reference inspection, line-length review, and
`git diff --check` pass.  The only check output is the two pre-existing
synthetic-polydata warnings.  No Rust, image, index, or asset source was
changed; no generated output was tracked and no deployment was performed.
The focused site commit is `fdfa729`, pushed non-forced to canonical `master`
over authenticated HTTPS through `gh`; the configured SSH remote was not
changed.  Ownership is released and there are no blockers.

## Completed scope (2026-09-15, rowmotion/promotion page and preprints)

Added a dedicated rowmotion-and-promotion page with definitions via adjacent
involutions and order-ideal toggles, actual V-poset diagrams, worked promotion
and rowmotion orbits, toggle conjugacy, product-of-chains cyclic sieving, and
the new rational alt-Tamari invariance and homomesy results from arXiv
`2609.12983v1`.  The existing poset, tableau-operator, and Catalan-CSP pages
now route to this page, and the index has a generated TikZ-backed navigation
card.  The higher-Specht results from arXiv `2609.12255v1` were added to the
Specht-module page, including the three-row/hook basis theorem, nonvanishing
criteria, and known failure boundary.  Both papers were checked from their
cached primary texts and have full bibliography entries.

`make svg Q=1`, `make bib Q=1`, `make Q=1`, `make check Q=1`, rendered
anchor/citation inspection, visual inspection of all three new SVGs, line-
length review, and `git diff --check` pass.  The shared Rust library already
contained rowmotion; linear-extension promotion, validation, and orbit APIs
were added and verified in Rust commits `48543b5` and `eb47505`.  No deployment
was performed.  The focused site commit is `9f06677`.  After the configured
SSH transport was rejected, the site checkpoint was pushed non-forced to
canonical `master` over authenticated HTTPS through `gh`; the SSH remote was
not changed.  All site and Rust file ownership is released.

## Current scope (2026-09-15, preprint-triage follow-up)

RealRooted issue #796 now treats Liu--Zhang's central stable-eigenfunction
construction as an adversarial formalization audit.  The site still withholds
the paper's claimed resolution pending that audit.  The Shankar attribution
email was corrected to distinguish the classical gamma criterion from the
family-specific all-power result in Alexandersson's Theorem 5.1 and was sent
to `umeshshankar@outlook.com`.  The triage report records both actions.  No
website source or generated output changed; ownership is released.  This
follow-up and the earlier preprint commit remain local because the configured
SSH key is not accepted by the origin.

## Current scope (2026-09-15, new-preprint triage)

Completed the read-through of eight user-supplied preprints.  Seven concise
theorem-level references were added to the relevant matroid,
total-positivity, chromatic-symmetric, Lorentzian, powered-Eulerian, Laurent
symmetric-function, and key-polynomial pages.  The existing Thibon--Wang
record was updated to v2 rather than duplicated.  Liu--Zhang
arXiv:2609.15201v1 was held out pending an independent audit of its central
AI-assisted stability argument; the evidence and editorial defects are
recorded in `suggestions/preprints-2026-09-15.md`.

RealRooted issues #794 and #795 record the two low-priority formalization
targets.  The report also contains the unsent Shankar attribution email draft
and explains why the general gamma-polynomial equivalence should not be
reopened: it is already checked in Lean.

`make bib Q=1`, all seven focused page builds, `make Q=1`,
`make check Q=1`, rendered citation/link inspection, and
`git diff --check` pass.  The two check warnings are the pre-existing
synthetic-polydata warnings from the unit test.  No deployment was performed.
The focused commit is local: the routine push to `origin/master` failed because
this environment has no accepted SSH key.  Ownership is released; pushing the
commit is the only remaining infrastructure step.

## Current scope (2026-09-12, audited-link deployment)

Deployed the independently audited Eulerian cross-links through `fc734eb`.
Direct origin checks confirm all four live targets: the Eulerian
quasisymmetric refinement, run-sorted comparison, interlacing-survey link,
and Schur-$P$ alternating-permutation link.  No source, Lean, or Rust edits
were performed; ownership is released and there are no blockers.

## Current scope (2026-09-12, independent Eulerian-link audit)

Completed an independent audit of all 90 site-wide Eulerian mentions.  Added
four useful links: the Eulerian quasisymmetric refinement, run-sorted descent
comparison, a remaining interlacing-survey pointer, and the Schur-$P$
alternating-permutation connection.  Compound families such as
Chow--Eulerian, homogeneous Eulerian, mixed Eulerian, and $P$-Eulerian objects
remain routed to their own theory rather than the classical page.

All four focused builds, `make Q=1`, `make check Q=1`, rendered-link
inspection, and `git diff --check` pass.  This follow-up was subsequently
deployed.  No Lean or Rust work was performed; ownership is released and
there are no blockers.

## Current scope (2026-09-12, Eulerian deployment)

Deployed the verified Eulerian page and cross-link commits through `9c157a0`.
The live origin serves `eulerian.htm`, the canonical `eulerianPolynomial`
anchor, the navigation card, and the new links from the real-rootedness page.
No Lean or Rust work was performed; ownership is released and there are no
blockers.

## Current scope (2026-09-12, Eulerian cross-links)

Completed focused bidirectional cross-linking between the Eulerian page and
the real-rootedness, interlacing, stable-polynomial, gamma-positivity, and PF
pages.  The polytope and Ehrhart pages now link the cube, hypersimplex, and
permutohedron appearances to the relevant Eulerian material.  The
hypersimplex volume notation was also aligned with the site's descent
normalization as $A(n-1,k-1)$.

Focused builds of all eight affected pages, `make Q=1`, `make check Q=1`,
rendered bidirectional-link inspection, and `git diff --check` pass.  No
deployment, Lean, or Rust work was performed; ownership is released and there
are no blockers.

## Current scope (2026-09-12, Eulerian-polynomials reference page)

Completed the dedicated classical Eulerian-polynomials page.  It fixes the
descent normalization before giving the main recurrences, generating
functions, Worpitzky and Stirling formulas, symmetry and special values,
Frobenius interlacing, PF/TNN and limit-law consequences, gamma-positivity,
polytope interpretations, and concise q/Coxeter/poset generalizations.  The
page has curated OEIS links, a new navigation card, an exact open-access
Foata--Schützenberger bibliography entry, and Petersen's modern monograph.
The old canonical label and all incoming cross-links are preserved.

The formulas and attributions were checked against the primary
Foata--Schützenberger edition, the Frobenius scan, Petersen's contents and
author-uploaded text, and current OEIS records.  The binomial recurrence and
Stirling expansion were checked exactly through n=8.  `make svg Q=1`,
`make bib Q=1`, focused builds of all three affected pages, `make Q=1`,
`make check Q=1`, rendered HTML/anchor/reference inspection, visual card
inspection, and `git diff --check` pass; only the two pre-existing synthetic
polydata warnings remain.  No deployment, Lean, or Rust work was performed;
ownership is released and there are no blockers.

## Current scope (2026-09-12, Cui--Zhu site additions)

Completed the Cui--Zhu additions from arXiv 2308.05167v1.  The standard
symmetric-functions page now gives the two Jacobi--Stirling specializations,
recurrences, signed inverse, corrected Legendre--Stirling specialization
z=1, and the first-kind row factorization with its PF and TNN consequences.
The PF page gives a compact numerical form of the paper's fixed-factor
weighted-path theorem, including its row/column Toeplitz and Riordan
consequences.  All nonnegative-minor claims use the site's TNN terminology.

The statements and strict z>-1 hypothesis were checked against the primary
arXiv v1 HTML; the arXiv index and the site's BibTeX API confirmed the metadata
and exact bibliography entry.  paper-cache add_arxiv was temporarily blocked
by an arXiv API HTTP 429, but no fallback source was needed.  make bib Q=1,
both focused page builds, make Q=1, make check Q=1, rendered formulas,
cross-page anchors, citations, embedded BibTeX, the source URL, and
git diff --check pass.  The only check output is the two pre-existing
synthetic-polydata warnings.  No deployment, Lean, or Rust work was performed;
ownership is released and there are no blockers.

## Current scope (2026-09-12, Cui--Zhu paper triage)

Completed a read-only editorial/formalization triage of Cui--Zhu,
*Total positivity from a kind of lattice paths* (arXiv:2308.05167v1).  The
ranked website additions, exact Jacobi--Stirling specializations, terminology
warning, and five-stage Lean route are recorded in
`suggestions/cui-zhu-lattice-path-total-positivity-2308.05167.md`.  No TeX,
bibliography, generated output, deployment, or external communication was
performed.  The host `arxiv-symmetricfunctions` MCP failed to initialize, so
the primary arXiv PDF and local checkouts were used directly.  Ownership is
released and there are no blockers.

## Current scope (2026-09-11, gamma real-rootedness correction)

Completed the correction to Petersen's gamma-polynomial criterion.  The page
now attributes the argument to Petersen's Section 4.6 and gives the exact
$1/4$ root bound, its change-of-variables explanation, the nonnegative and
gamma-positive corollaries, and an example showing the bound is essential.
It also removes the unintended nonnegative-coefficient restriction from the
definition of a palindromic polynomial.

The printed statement and proof in Section 4.6, the author's October 2024
errata, the exact change of variables, rendered attribution, citation anchor,
and formulas were checked.  `make FILE=gammaPositivity.tex Q=1`, `make Q=1`,
`make check Q=1`, and `git diff --check` pass.  Commits through `746cd06` were
pushed and deployed, and the corrected criterion was verified on the live
page.  Ownership is released and there are no blockers.

## Current scope (2026-09-11, Hadamard LC-NIZ preservation)

Completed Liu--Mao's LC-NIZ preservation addition.  The real-rootedness page
distinguishes the series Hadamard product from finite coefficientwise products,
defines the numerator transform $W$, states the exact preservation theorem,
records the PF2/reverse-regular-kernel proof tool, and notes that no internal
zeros is essential.  The polytope page gives the finite Cartesian-product
$h^*$ consequence.  No real-rootedness claim or conjecture was inferred.

The v1 paper was cached and perused through its proof and Ehrhart application.
Current arXiv metadata, both theorem locations, rendered cross-links, citation
anchors, embedded BibTeX, and source URLs were checked.  `make bib Q=1`, both
affected-page builds, `make Q=1`, `make check Q=1`, and `git diff --check`
pass.  The addition was pushed and deployed with the gamma correction on
2026-09-11; ownership is released and there are no blockers.

## Current scope (2026-09-11, elephant and Stirling-code polynomials)

Completed the elephant-polynomial and Stirling-code additions.  The elephant
example states the full real parameter family, the random-walk subrange,
the $a=0$ degeneration, the $a=-1$ degree exception, and the real-rooted
rotation for $a<0$, with OEIS links for the $a=-1/2$ and $a=-1$
specializations.  The up-down-run example gives the exact recurrence, zero
multiplicities, interlacing, odd/even refinements, and OEIS A186370.  No
conjecture was added.

Both primary v2 papers and current metadata were checked.  Small recurrence
rows and consecutive interlacing were independently verified with `polytool`.
`make bib Q=1`, both affected-page builds, `make Q=1`, `make check Q=1`,
rendered-page inspection, URL checks, and `git diff --check` pass.  No
deployment or push was performed; ownership is released and there are no
blockers.

## Current scope (2026-09-11, theorem-family and OEIS follow-up)

Completed the theorem-only follow-up.  Added the cyclic-path, even-top descent,
and ternary increasing-run families; sharpened the peak and generalized
Narayana zero statements; and linked exact OEIS arrays for these, type $D$
Eulerian, and the first three Hoggatt specializations.  A restricted type-$D$
noncrossing-chain sequence is clearly marked as a subset.  No open conjecture
was added.  Also corrected the nonexistent colored-multiset v2 link to v1.

Statements were checked against the cached primary papers, current arXiv
metadata, and OEIS records.  `make bib Q=1`, all four affected-page builds,
`make Q=1`, `make check Q=1`, rendered-link inspection, URL checks, and
`git diff --check` pass.  No deployment or push was performed; ownership is
released and there are no blockers.

## Current scope (2026-09-11, main real-zero theory and families)

Completed the main theory/family pass.  Added the shelling, mixed-sign
compatibility, Veronese/symmetric-decomposition, colored-barycentric, and
Hadamard-power results; added the type-D/affine Eulerian, Baxter--Hoggatt,
symmetric-edge, biEulerian, chain-polynomial, and totally-nonnegative Chow
families with cross-links.  Statements were rechecked against cached primary
papers and publication metadata against the direct arXiv index and publisher
records.  The paper-cache bridge to that index failed because `pymysql` was
unavailable, but the local cache and direct index remained available.
`make bib Q=1`, all affected-page builds, `make Q=1`, `make check Q=1`,
rendered-page inspection, and `git diff --check` pass.  ArXiv links resolve;
DOI metadata was verified although three publisher targets return HTTP 403
and two eScholarship targets return HTTP 202 to automated requests.  No deploy
or push was performed; ownership is released and there are no blockers.

## Current scope (2026-09-11, real-zero attribution and references)

Completed the focused correction pass.  Restored Theo Douvropoulos's omitted
authorship and published citation for the restricted-Eulerian result; clarified
the Gaetz--Pierson conjecture and recorded Iskander's counterexample.  Confirmed
versions/publication data were refreshed, and the unused duplicate
`WangZhang2023x` entry was removed.  `make bib Q=1`, affected-page builds,
`make Q=1`, `make check Q=1`, rendered-reference inspection, URL checks, and
`git diff --check` pass.  No deployment or push was performed; ownership is
released and there are no blockers.

## Current scope (2026-09-10, cached-paper real-zero survey)

Completed the 46-paper read-only audit in `/workspace/real-zeros-survey/`:
`rr-conjectures.md`, `rr-theory.md`, `rr-families.md`, and `rr-misc.md`.  Every
paper was cached and text-extracted through paper-cache; direct PDF ingestion
recovered from temporary arXiv metadata rate limits.  The reports separate
proved families, reusable tools, open/disproved conjectures, adjacent results,
and present/partial/missing site coverage.

All 46 versioned arXiv links return HTTP 200; DOI redirects were checked (four
publisher targets block automation with HTTP 403 and three eScholarship
targets return HTTP 202).  Pandoc parses all four files, their numbered
footnotes resolve, the 46-row ledger is complete, and the leading gap claims
were rechecked against the checkout and live pages.  No relevant research tool
was unavailable.  No TeX, bibliography, build, deployment, push, or external
communication was performed; no blockers remain.

## Current scope (2026-09-10, type-B OEIS audit)

Completed the audit in
`oeis-todo/alexandersson-beyene-mantaci-type-b.md`.  Five coefficient triangles
have no exact OEIS match; the note gives definitions, recurrences, ten checked
rows, scalar matches, and submission priorities.  It also records five existing
entries needing the paper/new interpretation and four already-current entries.
A075497 and A217924 were the two non-obvious matches; A085852 is only a near
match and diverges in row 6.  Recurrence and gamma-expansion rows were checked
independently, all cited links return HTTP 200, Pandoc parses the note, and
`git diff --check` passes.  No external OEIS submission, website deployment, or
push was performed; ownership is released.

## Current scope (2026-09-10, Ferroni Ehrhart counterexamples)

Added the requested two-sentence note to the integer-decomposition section
of polytopes.tex: smooth IDP counterexamples to h-star unimodality and the
related Gorenstein h-star / IDP Ehrhart-series log-concavity counterexamples.
Checked arXiv 2609.10513v1, introduction Theorems 1.2--1.4 and the smoothness
discussion, against the primary HTML; metadata came from the read-only arXiv
index and the site's BibTeX API. The API's colliding Ferroni2026x key was
renamed Ferroni2026Unimodality. No construction formulas were added.

make bib Q=1, make FILE=polytopes.tex Q=1, make check Q=1 and git diff --check
pass (only the two existing synthetic-polydata warnings). Rendered prose,
cross-links, citation anchor, v1 arXiv link and embedded BibTeX were checked.
No deployment or push performed. Ownership of all three files is released.

## Current scope (2026-09-09, canon and type-B clarification)

Completed corrections to the shifted SYT generating function and Narayana/SYT
gamma normalizations, and added the canon-permutation real-rootedness
consequence with its limits.  The words page now also records the
Alexandersson--Beyene--Mantaci recurrence, interlacing, and separated-family
real-rootedness results, while distinguishing their gamma-positive
and real-rooted signed-permutation result.  Statements were checked against
versions 2 and 3 of the primary preprint;
`make Q=1`, `make check Q=1`, and `git diff --check` pass.  No deployment or
push was performed, and no files remain owned by this pass.

## Current scope (2026-09-09, PF and interlacing proof tools)

The PF page now states the Wang--Yeh coefficient transform and bilinear
triangular-recurrence criteria.  The real-rootedness page includes the
finite-degree multiplier-sequence test, and the interlacing page records
Fisk's constant-TNN mixing rule; Fisk is also credited for the earlier
mutual-interlacing theorem for Veronese sections.

The previous blanket claim that Hadamard products preserve TNN was false:
Wagner explicitly gives counterexamples even for arbitrary TNN Toeplitz
matrices.  The page now distinguishes the finite-support Schur--Pólya case
and Wagner's polynomial-diagonal case.

The statements were checked against the cached primary papers
math/0611825, math/0403364, and Fisk's math/0612833, and against the
publisher abstract for Wagner's 1992 paper.  Focused builds, make Q=1,
make check Q=1, and git diff --check pass; rendered labels, cross-links,
citation anchors, and BibTeX controls were spot-checked.  A clean `make ship`
build and deployment completed on 2026-09-09, and the changed live pages were
spot-checked.  No files remain owned.  No push was performed.

## Current scope (2026-09-09, real-rootedness toolkit expansion)

The pre-expansion state is preserved by the local annotated tag
`pre-real-rootedness-expansion-20260909` at `b7bf593`.  Commits `105f165`,
`6c8d006`, and `c797d66` add concise proof-tool and landmark coverage, replace
the stale toric fixed-row conjecture by its theorem, and add selected P1
combinatorial results.  The Ma--Wang hypothesis is corrected from the false
condition `v(r) != 0` to `v(r) <= 0`.

`make bib Q=1`, focused page builds, `make Q=1`, `make check Q=1`, and
`git diff --check` pass.  Rendered theorem statements, labels, cross-links,
citation anchors, and embedded BibTeX were spot-checked; all arXiv links and six
of eight DOI links returned HTTP 200, while the valid APS and PNAS DOI targets
returned automated HTTP 403.  No files remain owned.  No deployment, push, or
external communication was performed.

To keep the existing pages compact, the broader UMEL-shellability,
subdivision, lattice-width, graph-$\tau$, and gamma-boundary additions remain
in `suggestions/real-rootedness-survey/REPORT.md` for later editorial batches.

## Current scope (2026-09-09, real-rootedness coverage survey)

Private Docker session `01a08514-37bd-7ab2-938e-e25280b399e3` (role
`real-rooted-survey`) completed the read-only editorial survey in
`suggestions/real-rootedness-survey/`. Its deliverables are `REPORT.md` (ranked
gap report and insertion text), `CANDIDATES.tsv` (40-item ledger), and
`SEARCH-LOG.md` (reproducible coverage and limitations). `BRIEF.md` is unchanged.

The deep-research skill, arxiv-symmetricfunctions index, paper-cache, and broad
web search were used; no relevant research tool was unavailable. The 21 primary
sources and theorem locations were checked, all report links were tested (one
valid DOI returned an automated 403), current source/bibliography coverage was
rechecked, Pandoc parses the report, and TSV shape/control-character/whitespace
checks pass. Research checkpoints are `a218d01` and `0663f63`; the closing
handoff is committed separately. No website source, bibliography, generated output,
build, deployment, push, or external communication was performed. No blockers
remain; late arXiv v1 items should be version-checked before future insertion.

## Current scope (2026-09-08, marked-order-polytope Ehrhart positivity)

The polytope page now gives Jochemko--Menon's ideal-chain decomposition and
their general positivity criterion, including the exact marking and
ideal/filter-closure hypotheses and the skew-shape marked-order consequence.
It also defines the $m$-generalized Pitman--Stanley polytope and records both
its ordinary Ehrhart positivity and the stronger multivariate result when the
lower marking is zero.  The Ehrhart and GT pages explain why the general
closure criterion does not apply directly to skew GT posets, while preserving
the existing skew-GT theorem.  The GT and flagged-Schur pages now state the
precise weakly increasing row-interval hypotheses for the unsliced flagged
faces and retain the fixed-content affine-slice caveat.  The bibliography now
points to arXiv `2604.08394v2`.

### Ownership

No files remain actively owned for this completed update.

### Verification

The statements were checked against the cached primary v2 PDF (paper-cache
entry 251) and arXiv's v2 HTML.  `make bib Q=1`, focused builds of
`polytopes.tex`, `ehrhart.tex`, `gtpatterns.tex`, and `schurFlagged.tex`,
`make Q=1`, `make check Q=1`, and `git diff --check` pass.  The rendered
definition, decomposition formula, theorem hypotheses, cross-page links,
flagged-face caveat, v2 bibliography link, and embedded BibTeX were
spot-checked.  The only check output is the two pre-existing synthetic
polydata warnings.  The update is not deployed.

## Current scope (2026-09-07, canonical URL repair)

Rendered pages now default to their own `<filestem>.htm` canonical URL instead
of `index.htm`; the same corrected value feeds `og:url`. The sitemap excludes
`403.htm` and `404.htm`. The HTML lint now checks every sitemap entry against
the corresponding page's canonical and Open Graph URLs and rejects error-page
entries.

`make Q=1`, `make check Q=1`, and `git diff --check` pass. The sitemap has 140
unique page URLs, and `index.htm`, `schur.htm`, `ehrhart.htm`, and the generated
polynomial-relations page were spot-checked. The only check output is the two
pre-existing synthetic-polydata warnings. The correction was deployed on
2026-09-07. Cache-busted public fetches of those four pages and `sitemap.xml`
match the local files byte-for-byte; their live canonical URLs are correct and
the live sitemap contains neither error document. No files remain actively
owned.

## Current scope (2026-09-06, Pahuja RSK correction)

The RSK page still describes Pahuja's study of fixed-RSK-shape matrices with
the minimum number of inversions, but no longer presents the proposed
symmetric-Hankel characterization as an open conjecture.  It now records that
the author subsequently found a counterexample and is preparing a revision,
without speculating about a corrected result.

`make FILE=rsk.tex Q=1`, `make check Q=1`, and `git diff --check` pass.  The
rendered passage, author link, citation anchor, arXiv link, and bibliography
entry were spot-checked in `www/rsk.htm`.  No files remain actively owned, and
the correction is not deployed.

## Current scope (2026-09-06, gamma-positivity criterion correction)

The gamma-positivity page now identifies the criterion as a corrected form of
Petersen Observation 4.2, whose printed equivalence is over-strong.  For a
palindromic polynomial with non-negative coefficients, real-rootedness is
equivalent to the gamma-polynomial having only real non-positive zeros.  The
page also gives the equivalent gamma-positive formulation and the
counterexample `1+x+x^2`, whose gamma-polynomial is `1-x`.

`make FILE=gammaPositivity.tex Q=1`, `make check Q=1`, and
`git diff --check` pass.  The corrected equivalences, counterexample, and
Petersen--Brändén--Gal citations were spot-checked in the rendered page.  No
files remain actively owned, and the correction is not deployed.

## Current scope (2026-09-06, skew-GT Ehrhart positivity)

The Ehrhart and GT pages now replace the proved skew-GT positivity conjecture
by Jochemko--Menon's Theorem 3.5.  Those pages and the flagged-Schur page also
state explicitly that the unsliced flagged result from Section 3.2 does not
settle fixed-content flagged Kostka positivity.  The primary-source
bibliography record is `JochemkoMenon2026x`.

`make bib Q=1`, all three focused page builds, `make Q=1`, `make check Q=1`,
and `git diff --check` pass.  The theorem, caveat, cross-page link, citation,
and embedded BibTeX were spot-checked in all three rendered pages.  The two
check warnings are the pre-existing synthetic-polydata fixtures.  No files
remain actively owned, and the update is not deployed.

## Current scope (2026-09-06, order-polytope example)

The sharp fourteen-dimensional non-Ehrhart-positive order polytope
`O(P_{7,7})` is now in the order-polytope catalogue.  The example gives its
defining ordinal sum, first Ehrhart coefficients, negative linear coefficient,
minimal-dimension statement, and the contrast
`h^*_{O(P_{7,7})}(t)=A_7(t)^2`.  The Liu--Tsuchiya bibliography record now
uses its published metadata, and the dimension-at-most-thirteen theorem has a
new published bibliography record.

## Ownership

No files remain actively owned for this completed addition.

## Verification

`make bib Q=1`, `make FILE=polytopes.tex Q=1`, `make Q=1`,
`make check Q=1`, and `git diff --check` pass.  The rendered example,
cross-page links, both citation anchors, published DOI links, and embedded
BibTeX records were spot-checked in `www/polytopes.htm`.  The two check
warnings are the pre-existing synthetic-polydata fixtures.  The update is not
deployed.

## Previous completed scope (2026-09-06, Hurwitz stability)

The interlacing page now defines weak and strict Hurwitz stability and proves
that, for a real polynomial with positive leading coefficient, weak Hurwitz
stability implies nonnegative coefficients and strict Hurwitz stability
implies positive coefficients.  The factored example
`(t+3)(t^2-2t+10)` shows that the converse fails even for strictly positive
coefficients.  Page metadata now includes Hurwitz stability.

### Ownership

No files remain actively owned for this completed addition.

### Verification

`make FILE=realRootedInterlacing.tex Q=1`, `make Q=1`, `make check Q=1`, and
`git diff --check` pass.  The rendered definition, proposition, proof,
counterexample, and three new labels were spot-checked in
`www/realRootedInterlacing.htm`.  The update is not deployed.

## Previous completed scope (2026-09-03)

The 2026-09-02 preprint of Khai-Hoan Nguyen-Dang and Zhenpeng Wang on
realizable-volume models for Schubert, Grothendieck, and Lascoux polynomials
has been added to the Lorentzian-polynomials catalogue.  The update is
committed as `765cdcb`, with follow-up editorial corrections committed after
independent verification.  The complete verified site build was deployed on
2026-09-03.

## Independent verification (2026-09-03)

A second worker re-verified commit `765cdcb` without editing any content
files.  The theorem statement, the packet/volume-minor description, and the
ordinary single-alphabet type-A scope match the cached primary text of arXiv
`2609.02850v1` (paper-cache entry 244).  The conjecture attributions were
checked directly against the primary sources rather than the preprint's own
claims: Conjectures 15, 21, 22, and 23 of arXiv `1906.09633` are exactly the
normalized Schubert, sign-corrected homogeneous Grothendieck component,
homogenized Grothendieck packet, and normalized key statements, and
Conjectures 3.14 and 5.5--5.7 of arXiv `1703.02583` are exactly the
saturated-Newton-polytope statements for Demazure atoms, Grothendieck,
Lascoux, and Lascoux-atom polynomials.  Both bibliography keys resolve, the
`\key`, `\atom`, `\schubert`, `\grothendieck`, and `\setC` macros are defined
in `assets/tex-init.js`, and an independent `make Q=1` plus `make check Q=1`
passed with no errors; the rendered theorem, citation links, and bibliography
anchor were re-spot-checked in `www/lorentzianPolynomials.htm`.

No blocking errors were found.  Three minor editorial points were identified
and subsequently fixed by the verifying worker on 2026-09-03:

- The theorem's symmetric group is now written `\symS_n` per site convention,
  removing the glyph collision with the `\schubert` macro (`\mathfrak{S}`) in
  the same sentence.  The corpus again has no symmetric-group use of
  `\mathfrak{S}`.
- Cross-page links were restored and extended: the lead-in paragraph links to
  the key and Schubert pages, and the consequences paragraph links to the
  Demazure-atom and Lascoux sections.  All four resolve
  (`key.htm#key`, `schubert.htm#schubert`, `key.htm#demazureAtom`,
  `lascoux.htm#lascoux`).
- The page now uses "realizable volume polynomial" consistently and defines
  the term after its first use: a nonnegative rational multiple of the volume
  polynomial of semiample Cartier divisor classes on a `d`-dimensional
  integral projective variety, with the nef/Lorentzian consequence over the
  complex numbers cited to `BrandenHuh2020` Theorem 4.6.  The definition
  matches Definition 2.5 of arXiv `2609.02850v1`; no bibliography change was
  needed.

The corrections pass `make FILE=lorentzianPolynomials.tex Q=1`, `make Q=1`,
and `make check Q=1` with no errors, and the rendered definition, styled
`\defin` term, `\symS_n` notation, and all four cross-page links were
spot-checked in `www/lorentzianPolynomials.htm`.  The corrections are
committed and deployed.  A cache-busted public fetch confirms the theorem,
definition, author links, four cross-page links, and arXiv bibliography entry
are live.  The public and local `lorentzianPolynomials.htm` files have the
same SHA-256 checksum,
`a57c4138f062ad8a76bd8f8d60317e15dd0dc2ec597d6f063369ee056d89e030`.

## Ownership

No files remain actively owned for this completed update.

## Starting state

- No live worker owned the website project, and the worktree was clean.
- Local `master` was already twenty-three commits ahead of `origin/master`;
  those pre-existing commits were preserved unchanged.
- The paper was checked through the `arxiv-symmetricfunctions` index and the
  cached primary PDF/text for arXiv `2609.02850v1`.

## Current status

The Lorentzian-polynomials page now records Nguyen-Dang--Wang Theorem 1.1:
factorially normalized key polynomials, Demazure atoms, ordinary Schubert
polynomials, sign-corrected homogeneous Grothendieck components, and
homogeneous Lascoux and Lascoux-atom layers are realizable volume polynomials;
over the complex numbers, each nonzero polynomial in this list is Lorentzian.
The surrounding paragraph records the packet construction, the exact
Huh--Matherne--Mészáros--St. Dizier conjecture numbers, the related saturated
Newton-polytope consequences, and the ordinary single-alphabet type-A scope.
The obsolete statement that the key and Schubert cases remain open was
removed.  The bibliography key is `NguyenDangWang2026x`.

Verification passes with `make bib Q=1`, the focused Lorentzian-page build,
`make Q=1`, `make check Q=1`, and `git diff --check`.  The rendered theorem,
cross-page links, arXiv bibliography record, and embedded BibTeX entry were
spot-checked in `www/lorentzianPolynomials.htm`.  The two test warnings are the
pre-existing synthetic-polydata fixtures.

## Previous completed scope

The 2026-09-01 preprints of Qiqi Xiao and Peter L. Guo--Mingyang Kang have
been added to the polytopes catalogue.

## Ownership

No files remain actively owned for this completed update.

## Starting state

- The SymCat worktree was clean at the start of this task, and no live worker
  owned the website project.
- Local `master` was already twenty-one commits ahead of `origin/master`; those
  pre-existing commits must be preserved and not rewritten.
- The theorem statements were checked against arXiv `2609.00781v1` and
  `2609.01086v1`.  This is an editorial catalogue update rather than a new
  proof search, so `polytool` and `polynomial-lab` are not needed.

## Current status

The polytopes page now defines face (h)-polynomials separately from
(h^*)-polynomials and states the Guo--Kang realization theorem for monic
palindromic real-rooted polynomials with nonnegative integer coefficients.
It also defines the toric (g)-contribution polynomials, states Xiao's
real-rootedness and adjacent-rank interlacing theorem, and records her
row-interlacing conjecture and its consequence for simple polytopes with
nonnegative gamma-vectors.  The real-rootedness overview links directly to
the new section.  The bibliography keys are `GuoKang2026x` and `Xiao2026x`.

The arXiv metadata came from the site's BibTeX endpoint, while the statements
were checked against the cached primary PDFs for `2609.00781v1` and
`2609.01086v1`.  Verification passes with `make bib Q=1`, focused builds of
`polytopes.tex` and `realRooted.tex`, `make Q=1`, `make check Q=1`, and
`git diff --check`.  The rendered section, cross-page link, citations, arXiv
URLs, and embedded BibTeX records were spot-checked in `www/polytopes.htm`.
Content commit `bd1b441` was deployed with `make deploy` on 2026-09-02.
Cache-busted public fetches confirm that both theorem statements, the
row-interlacing conjecture, both arXiv bibliography records, and the
real-rootedness overview link are live.  The public and local
`polytopes.htm` files have matching SHA-256 checksums.

The gamma-positivity page now attributes the exact real-rootedness equivalence
to T. Kyle Petersen, *Eulerian Numbers*, Observation 4.2.  Brändén's Lemma 4.1
and Gal's Remark 3.1.1 remain cited as earlier related forms.  The new book
entry resolves to the Springer DOI.  `make bib Q=1`, the focused page build,
`make check Q=1`, and `git diff --check` pass; the two `make check` warnings
are the pre-existing synthetic-polydata fixtures.  A full `make all` and
`make deploy` succeeded on 2026-08-27; a cache-busted public fetch confirms
that the Petersen attribution and bibliography entry are live.

The proof-style follow-up is complete and ready to commit.  The revised entry
removes the dispensable initial examples, retains only the transfer and
final-letter recurrence, and links directly to the labelled matrix-preserving
interlacing theorem and Chudnovsky--Seymour compatibility theorem.  A new
label was added to the latter theorem for this exact cross-reference.  The
full build, rendered links, `make check Q=1`, and `git diff --check` pass.
Commit `c8e3d23` was deployed on 2026-08-23; cache-busted public fetches
confirm that both theorem links resolve to their exact statements.

The placement follow-up is complete and ready to commit.  The full definition,
examples, transfer identity, and interlacing proof now appear immediately
after the multiset Eulerian polynomials in `realRootedWords.tex`;
`parking-functions.tex` retains a short cross-reference.  The full build,
cross-page label resolution, rendered pages, `make check Q=1`, and
`git diff --check` all pass.  Commit `317e71b` was deployed on 2026-08-23;
cache-busted public fetches confirm both the catalogue proof and the
parking-page cross-reference are live.

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
