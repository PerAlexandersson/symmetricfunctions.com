# Handoff

## Ready: reciprocal Hermite--Biehler link — 2026-10-26

Added the return link in `tex-source/realRootedInterlacing.tex` to the
stable-polynomial formulation; source now links both ways.
Full build, make check, whitespace and rendered href checks pass
(two existing fixture warnings). Clean tree at intake; ownership released.
Source-only checkpoint; return link not yet deployed.

## Deployed: Hermite--Biehler and region criteria — 2026-10-26

Published `fbd69ae4b505d944c838bd84a1cf8cde24afa58f` through the constrained
bridge at 16:54:58 UTC. Receipt: `20261026T165458-d5720753ef72`.
Full build, make check, whitespace and clean-tree gates passed;
only the two existing fixture bibliography warnings remain.
Pagefind manifest matched. Live stablePolynomials.htm and
realRootedInterlacing.htm return HTTP 200, match the checked build
byte for byte, and retain their respective Hermite--Biehler anchors.
Repository-wide duplicate check found the existing even--odd/Hurwitz
formulation on realRootedInterlacing.tex and a passing mention on
gammaPositivity.tex. The new upper-half-plane/proper-position treatment
complements and links to the existing theorem; no duplicate removed.
Ownership released; this record-only checkpoint needs no further deployment.

## Ready: Hermite--Biehler and region-dependent stability — 2026-10-26

Ownership released after source-only integration in `tex-source/stablePolynomials.tex`
and `bibliography.bib`; clean tree confirmed at intake.
Added open disk/upper and right half-plane pencil criteria, proofs,
Hermite--Biehler with Q << P convention, strict-modulus and derivative
criteria, proportional/zero cases, the disk boundary counterexample,
and a link to the existing even--odd formulation. Original
`stablePolynomial` anchor preserved; nearby closure statement now permits
zero outputs. Academic-writing guidance kept definitions before use and
proofs compact.

Verified Borcea--Brändén, published DOI 10.1112/plms/pdp049,
Theorem 1.4 and Lemmas 2.2--2.3 against cached arXiv math/0606360v6;
added its arXiv identifier to the existing bibliography record.
The supplied Crelle.pdf is an older three-author version, not this final record.
Full `make Q=1`, `make check`, and `git diff --check` pass
(two existing test-fixture bibliography warnings).
Chromium desktop/mobile inspection: no KaTeX errors or document overflow;
section anchors, DOI link and interlacing cross-link checked.
Ready for a separately authorized deployment; not deployed.

## Deployed: weighted recurrence theory — 2026-10-25

Published `d2f6c1d552764208b410602498ddebbd7559da9d` through the constrained
bridge at 19:33:46 UTC. Receipt: `20261025T193346-26ece35a0616`.
Full build, `make check`, whitespace and clean-state checks passed; the two
existing test-fixture bibliography warnings remain. Pagefind manifest matched.
Live `polynomialRecurrences.htm` and `realRootedGraphs.htm` return HTTP 200,
match the checked build byte for byte, and contain the new section anchors.
Ownership released; this deployment record requires no further upload.

## Ready: weighted recurrence theory and BKW support — 2026-10-25

Ownership released. Added weightedDelayRecurrences / weightedRenewalRecurrences
and renewalLimitingZeros to polynomialRecurrences.tex with complete proofs.
The latter uses the existing BKW statement and proves the support ray via
H(u)=uR(u)^ell, angular modulus monotonicity, and dominant-pair continuation.
Credited Fisk, Wagner, Engström and the rigid endpoint's Forgács–Tran antecedent.
Corrected realRootedGraphs.tex: Leake–Ryder gives same-phase stability, not
full multivariate real stability. Added a reciprocal recurrence link and
corrected Engstrom2007's issue/article/pages metadata from the primary PDF.
Full make Q=1, make check, whitespace and Chromium 1366/375 checks pass;
new anchors/links, expanded proof math and horizontal overflow checked.
The two existing unit-test bibliography warnings remain. Screenshots/build
logs: /tmp/symcat-renewal. Research proof/density note:
projects/Real-Zero-Preservers/notes/tiling-renewal-bkw-support.md.
Source changes only; no deployment, manuscript edit, or Lean work.

## Deployed: expanded algebra definitions — 2026-10-25

Codex `/root` owns this deployment-record opening only until its checkpoint.
Published c7eab76 through the constrained bridge at 09:23:21 UTC after the
clean-tree gate, full build, `make check`, and whitespace checks passed.
Receipt: `20261025T092321-e62d4f930712`; Pagefind manifest verification passed.
Live `algebras-and-rings.htm`, `diagonalHarmonics.htm`, `stanleySymmetric.htm`,
and `rsk.htm` return HTTP 200 and match the checked build byte for byte.
No content changes during deployment. Ownership released with this
record-only checkpoint; no further upload needed.

## Ready: coinvariant, operator, plactic, and graph algebras — 2026-10-25

Added coinvariant, nilCoxeter/nilHecke, plactic, Kirchhoff, and
Postnikov--Shapiro definitions to `algebras-and-rings.tex`. Included the
coinvariant Hilbert series, nilHecke operator/sign convention, tableau basis,
and distinct tree/forest power ideals. Added reciprocal links from diagonal
harmonics, affine Schur functions, and RSK. The Kirchhoff apolar construction
is explicitly distinguished from the Postnikov--Shapiro algebras.

Added Kostant--Kumar, Postnikov--Shapiro, and Akama references. Checked the
cached Postnikov--Shapiro source and Akama v3 source, the original journal
metadata, and existing coinvariant/plactic references. Academic-writing
conventions keep the additions definition-first and compact.
Full build, `make check`, and whitespace checks pass (two existing fixture
warnings). Chromium at 1366/375 checks all new anchors, internal links and
backlinks, zero math errors, and no horizontal overflow. Desktop screenshot
inspected; evidence: `/tmp/symcat-algebras-expanded-{1366,375}.png`.

Tree was clean at intake. Codex `/root` releases exact ownership of
`tex-source/algebras-and-rings.tex`, `tex-source/diagonalHarmonics.tex`,
`tex-source/stanleySymmetric.tex`, `tex-source/rsk.tex`, `bibliography.bib`,
and this opening at the focused checkpoint. Not deployed.

## Deployed: brief algebra definitions — 2026-10-25

Codex `/root` owns this deployment-record opening only until its checkpoint.
Published 633092f through the constrained bridge at 09:00:29 UTC after the
clean-tree gate, full build, `make check`, and whitespace checks passed.
Receipt: `20261025T090029-10b29e074f17`; Pagefind manifest verification passed.
Live `algebras-and-rings.htm` and `macdonaldE.htm` return HTTP 200 and match
the checked build byte for byte. No content changes during deployment.
Ownership released with this record-only checkpoint; no further upload needed.

## Ready: brief algebra definitions — 2026-10-25

Added Clifford and Temperley--Lieb definitions to `algebras-and-rings.tex`,
including the quadratic-form/sign convention, diagram basis, Hecke quotient,
and Sergeev/Schur Q connection. Added a short DAHA overview and repaired the
Macdonald E link to its dedicated anchor. Existing sections are preserved.
Added Wan--Wang's spin-representation lectures after checking the cached
source; checked Abramsky's TL exposition and Etingof's DAHA overview.

Full build, `make check`, and whitespace checks pass (two existing fixture
warnings). Chromium at 1366/375 verifies math rendering, all internal links,
new anchors, the Macdonald backlink, and no horizontal overflow; desktop
screenshot inspected. Evidence: `/tmp/symcat-algebras-{1366,375}.png`.
Tree was clean at intake. Codex `/root` releases ownership of
`tex-source/algebras-and-rings.tex`, `tex-source/macdonaldE.tex`,
`bibliography.bib`, and this opening at this checkpoint. Not deployed.

## Deployed: A046739 gamma interpretation — 2026-10-23

Codex `/root` owns this deployment-record opening only until its checkpoint.
Published 3a4a861 through the constrained bridge at 10:42:47 UTC after a
clean-tree gate, full build, `make check`, and whitespace checks passed.
Receipt: `20261023T104247-39338e9df40e`; Pagefind manifest verification passed.
Live `oeisA046739.htm` and `oeisProofs.htm` return HTTP 200 and match the
checked build byte for byte. No source/content changes during deployment.
Ownership released with this record-only checkpoint; no further upload needed.

## Complete: A046739 gamma interpretation — 2026-10-23

Added `tex-source/oeisA046739.tex` and its `oeisProofs.tex` collection link:
definitions, two counting models, modified Foata--Strehl orbit proof,
n=4 example, shifted normalization, and A097899 row sums. The fundamental
transformation is applied to the inverse to send excedances to descents.
Added both primary bibliography records. Official EJC metadata verifies
Sun--Wang DOI 10.37236/3723 (not the research note/cache's 10.37236/3874).
No journal DOI found for Athanasiadis--Savvidou; journal PDF and arXiv retained.
Read-only research sources were not edited.

Full `make Q=1`, `make check`, and whitespace checks pass (two existing
fixture warnings). Chromium at 1366/375 verifies rendered math, citation
anchors, DOI link, collection/back links, and no horizontal overflow.
Screenshots inspected: `/tmp/symcat-a046739-{1366,375}.png`.
Tree was clean at intake; exact ownership of the new page, collection index,
`bibliography.bib`, and this opening is released at this focused checkpoint.
No deployment performed.

## Complete: publication-reference discovery with Luna — 2026-10-23

Three user-requested GPT-6-Luna agents checked 866 arXiv-only entries; root
checked 27 additional arXiv entries. The arXiv feed, paper-cache and Crossref
yielded 281 strong publication matches, 47 DOI candidates needing review/retry,
and eight no-DOI publication hints. There were 25 arXiv API errors. Details:
`suggestions/reference-publication-audit-20261023.txt`; verbose scratch reports
remain in `/tmp/symcat-publication-audit-20261023/`.

Do not bulk-import: five feed DOI mappings are wrong, several entries duplicate
existing journal keys, and issue years need checking against online dates.
Urgent separate content review: `FinkShawSpeyer2024x` was retracted (publisher
notice DOI 10.1093/imrn/rnag125, Theorem 1.5 false); see `tex-source/matroids.tex`
near line 984. The report records the notice and affected paragraph location.

Discovery only: no bibliography/page edits or deployment. Reports parse and
whitespace checks pass; no build needed for these internal notes. Ownership
released. Next step is a focused verified bibliography update, keeping all
existing citation keys/arXiv IDs, and separate review of the retracted claim.

## Deployed: chromatic rewrite, references, width control, LLT example — 2026-10-23

Published ede83f6 through the constrained bridge at 2026-10-23T07:54:55Z.
Receipt `20261023T075455-c155c61c7aad` confirms deployment of the expected
commit and matching Pagefind manifest. The three edited topic pages and
shared JS/CSS match the checked build byte for byte. Live Chromium at
1366/375 verifies theorem/example anchors, Hwang's journal link, the circular
positivity theorem, zero KaTeX errors, and shared width-preference persistence
across both chromatic pages, unicellular LLT, and Schur. Full build/checks
pass (two existing fixture warnings). Ownership remains released. This final
record-only update requires no further upload.

## Ready: LLT flip-component example — 2026-10-23

Retained the Alexandersson--Dai theorem with its stable cross-link anchor and
made Flip classes a contents-listed subsection after the full elementary
expansion. Added the smallest component from cached arXiv:2610.26294v1,
source example `ex:smallestFlip`: two orientations of K3, displayed with
ascending-edge diagrams, highest reachable vertices, class sum e21+e3, and
weighted contribution q^2(e21+e3). No new computed examples were generated.

Full build, `make check`, and whitespace checks pass (two existing fixture
warnings). Chromium at 1366/375 confirms the contents link, example, zero
math errors, and no horizontal overflow; screenshots inspected at
`/tmp/symcat-llt-flip-1366.png` and `/tmp/symcat-llt-flip-375.png`.
Ownership released for `tex-source/unicellular-llt.tex` and this opening.
No deployment performed.

## Ready: published chromatic references — 2026-10-23

Audited 61 arXiv references without DOIs cited by the two chromatic pages
through arxiv-symmetricfunctions MCP. Updated 15 matching journal records
after checking titles/authors and publisher-deposited Crossref metadata.
These cover Wang--Yu--Zhang, Arunkumar et al., Gonzalez--Orellana--Tomba,
Aliste-Prieto et al., Blasiak et al., Shelburne--van Willigenburg, Cho--Hong,
Hwang's skewing paper, Skandera, Novelli--Thibon, Hikita, Wang--Zhou,
Li--Qiu--Yang--Zhang, Gillespie--Pappe--Salois, and Martin--Trist.
Preserved citation keys and arXiv identifiers; corrected Xingxing Yu's name.
Hikita's JAMS DOI has no assigned volume/pages in the record, so none were
invented. ECA's publisher PDF confirms the 2025 issue year and article S2R8
despite the earlier online date in Crossref. No conclusion about publication
status was drawn for entries without feed DOIs.

Full build, `make check`, and whitespace checks pass (two existing fixture
warnings); all 15 DOI links and raw BibTeX controls verified in rendered
chromatic pages. Ownership released for `bibliography.bib` and this opening.
No deployment performed.

## Ready: chromatic exposition and width control — 2026-10-23

Reorganized the chromatic quasisymmetric page around definitions, symmetry
and basis expansions, LLT and chromatic specializations, geometry, graph
families, and variants. Shortened the historical overview, clarified the
coloring definition, removed duplicated variant prose, and made the separate
elementary-expansion page and timeline prominent. Detailed circular-arc
positivity, Hwang's elementary refinement, and centered positivity now live
on the elementary-expansion page. All previous labels and citations survive;
old theorem anchors lead to a summary linking the relocated statement.

The live width button was restricted to the recurrence page by JavaScript.
It now works on all text pages, using a shared `symcat-text-width` preference
and migrating the old recurrence setting. Landing/index/search/relation tools
retain their layouts. Template asset versions and README were updated.

Full build, `make check`, and whitespace checks pass (two existing fixture
warnings). Chromium checks six text pages and four non-article pages at
1366/375: toggle, keyboard, cross-page persistence, migration, links, math,
and overflow pass. Storage unavailable, dark mode, print, and no-JS checks
also pass. Screenshots inspected; evidence is under
`/cargo-target/symcat-chromatic-rewrite-20261023/` and the temporary browser
check is `/tmp/symcat-chromatic-review.cjs`. Ownership released for the two
TeX pages, `assets/site.js`, `template.htm`, `README.md`, and this opening.
No deployment performed.

## Ready: chromatic/LLT flip-class theorem cross-links — 2026-10-23

Added the Alexandersson--Dai flip definition and classwise elementary-expansion
theorem to the unicellular LLT page, cited as Theorem 14 of arXiv:2610.26294v1.
The chromatic page now states Hwang's flip construction more precisely, links
to the LLT theorem, and the LLT discussion links back to Hwang's chromatic flip
components.  The text distinguishes the two local moves and notes that Hwang's
chromatic classwise elementary-positivity conjecture remains open.

The statement and comparison were checked against the exact paper-cache
sources for arXiv:2610.26294v1 and arXiv:2208.09857v2.  Full build,
`make check`, and whitespace checks pass with only the two existing fixture
warnings.  Chromium renders both edited pages with 507 KaTeX expressions and
zero KaTeX errors; both cross-page anchors resolve.  Evidence:
`/cargo-target/symcat-flip-crosslinks-20261023/`.  Ownership released.  No
deployment authorized or performed.

## Ready: Hwang Transactions reference — 2026-10-23

Updated `Hwang2022x` from the arXiv-only record to *Transactions of the
American Mathematical Society* 377(4) (2024), 2855--2896, DOI
10.1090/tran/9096, while retaining arXiv:2208.09857v2.  Removed the stray bare
AMS URL above the entry.  Full build, `make check`, and whitespace pass (only
the two existing fixture warnings).  The rendered chromatic-quasisymmetric
page links the title to the DOI and exposes the updated raw BibTeX; Chromium
reports zero KaTeX errors.  Ownership released.  No deployment authorized or
performed.

## Deployed: recent SymCat preprint citations — 2026-10-22

Published ffc57e2 through the constrained bridge at 2026-10-22T12:07:49Z.
Receipt `20261022T120749-07b3391c33ba` confirms deployment of the expected
commit with a matching Pagefind manifest.  All eight affected public pages
return 200 and match the verified build byte for byte.  Live Chromium finds
the intended arXiv identifier on each page and reports zero KaTeX errors.
Ownership remains released.  Final record-only edits need no further upload.

## Ready: recent SymCat preprint citations — 2026-10-22

Added exact-v1 references for arXiv:2610.29950 and arXiv:2610.28691 after
reviewing their paper-cache PDF/source artifacts.  Stewart's restricted
non-attacking fillings now appear on the Macdonald E page; Zeng's Narayana
results appear on the real-rootedness, total-positivity, and Pólya-frequency
pages with their parameter ranges and conjectural/proved scope preserved.

A fresh `arxiv-symmetricfunctions` MCP review identified four further direct
extensions of existing sections.  Added arXiv:2610.29893 for Whitney-number
ultra-log-concavity on the matroid page, arXiv:2610.29844 for rectangular
Schur/Toeplitz identities on the Schur page, arXiv:2610.28544 for Newton--
Maclaurin inequalities on the elementary symmetric-function page, and
arXiv:2610.27819 for the smooth-polytope facet threshold on the Ehrhart page.
Their exact-v1 sources are cached and were checked before editing.

Full build, `make check`, and `git diff --check` pass; only the two existing
synthetic-polydata warnings remain.  Headless Chromium loaded all eight edited
pages with zero KaTeX errors, and every new citation has a rendered reference
and raw BibTeX control.  Ownership is released for all edited files.  No
deployment was authorized or performed.

## Deployed: square recurrence icon — 2026-10-21

Published d5dd894 through the constrained bridge at 2026-10-21T20:47:44Z.
Receipt `20261021T204744-1b8508df08ce` confirms deployed and matching search
manifest. Build/checks and whitespace pass (two existing fixture warnings).
Live Chromium at 1366/375 confirms 64 x 64 pixels, equal to the Eulerian
icon, with light/dark rendering, navigation, title and math checks passing.
Public index and SVG return 200 and match the build exactly. Evidence:
`/cargo-target/symcat-square-icon-deploy-20261021/`. Ownership released.
Final record-only edits need no further upload.

## Ready: standard square recurrence icon — 2026-10-21

Restored the standard square bounds in
`svg-tex/src/card-polynomialRecurrences.tex` and regenerated its SVG.
The approved equation continues at the plus sign over three lines.
Chromium at 1366/375 confirms exactly 64 x 64 pixels, matching the Eulerian
icon in both dimensions. Light/dark screenshots inspected; card/link/title,
math and collapsed-proof checks pass. `make svg`, full build/checks and
whitespace pass (two existing fixture warnings). Evidence:
`/cargo-target/symcat-square-icon-20261021/`. Ownership released for the
source, generated SVG and this opening; preview stopped. Published above.

## Deployed: recurrence presentation updates — 2026-10-21

Published aa03e17 through the constrained bridge at 2026-10-21T20:40:32Z.
Receipt `20261021T204032-bb51c29f4918` confirms deployed and matching search
manifest. The equation icon, shorter title, notation review and main-page
section move are live. Full build/checks and whitespace pass (two existing
fixture warnings). Live Chromium at 1366/375 verifies card placement,
light/dark image rendering, title/link, math, both widths and proof toggles;
native disclosures work without JavaScript. Public index, recurrence page
and SVG return 200 and match the build exactly. Evidence:
`/cargo-target/symcat-recurrence-release-20261021/`. Ownership released.
Final record-only edits need no further upload.

## Ready: recurrence equation icon and shorter title — 2026-10-21

Replaced the staircase with P_{n+1}=x P_n+P_n', set over two lines in a
slightly wider rounded frame for readable subscripts. The equality sign
uses the existing blue accent; terms retain contrast in both themes.
The page heading, metadata and main-page card now say Polynomial recurrences.
Owned sources: `svg-tex/src/card-polynomialRecurrences.tex`, generated
`assets/nav-images/card-polynomialRecurrences.svg`,
`tex-source/polynomialRecurrences.tex`, `tex-source/index.tex`, and this opening.
`make svg`, full build/checks and whitespace pass (two existing fixture
warnings). Chromium at 1366/375 verifies the card, image, section, link,
destination title, math and collapsed proofs. Light/dark screenshots inspected;
no horizontal overflow. Evidence: `/cargo-target/symcat-recurrence-icon-20261021/`.
Ownership released and preview stopped. Published in the deployment above.

## Ready: recurrence notation review — 2026-10-21

Applied the academic-writing skill and its style, notation, LaTeX and
proofreading guides to `tex-source/polynomialRecurrences.tex`. The sequence
and generating function are defined visibly at the start; shifted generating
functions and the proper-tail notation are explicit. Recurrence coefficients
are c_i, ansatz coefficients gamma, and amplitudes a_i; mu denotes the maximum
amplitude degree while M remains the unknown count. Polynomial first-order
coefficients use tilde A/B. Sequence zeros are bold, sum ranges are explicit,
and the repeated-pole criterion links back to its amplitude convention.
The finite allowed set is explicitly nonempty so its maximum is defined.
Full build/checks and whitespace pass (two existing fixture warnings).
Chromium 1366/375 verifies math, vectors, all proof toggles, both widths,
and no overflow; no-JavaScript disclosure works. Evidence:
`/cargo-target/symcat-notation-review-20261021/`. Ownership released and
preview stopped. Published in the deployment above.

## Ready: main-page recurrence card placement — 2026-10-21

Moved Polynomial recurrences and derivatives into Real-rooted polynomials,
immediately after Interlacing polynomials, in `tex-source/index.tex`.
Full build, `make check`, and whitespace checks pass (two existing fixture
warnings). Chromium DOM verification confirms exactly one card in the
requested section/order and an existing destination anchor. Ownership
released for the index and this opening. Published in the deployment above.

## Deployed: complexity notation, vectors, proofs and Vailaya — 2026-10-21

Published 3806c8b through the constrained bridge at 2026-10-21T20:09:47Z.
Receipt `20261021T200947-7ee32a598da3` confirms deployed and matching search
manifest. Full build/checks and whitespace pass (two existing fixture
warnings). Live Chromium at 1366/375 verifies calligraphic O, bold vectors,
five initially collapsed proofs, pointer/keyboard operation, both widths,
and no math errors or overflow; native proofs also work without JavaScript.
The Vailaya theorem, bibliography and cross-links pass at both widths.
All three changed public pages return 200 and match the build byte-for-byte.
Evidence: `/cargo-target/symcat-prepared-deploy-20261021/`.
Ownership released. Final record-only edits need no further upload.

## Ready: recurrence complexity notation — 2026-10-21

Changed the complexity estimate in `tex-source/polynomialRecurrences.tex`
to `\mathcal{O}`. KaTeX supports this directly; no shared macro change.
Full build, `make check` and whitespace checks pass (the two existing
fixture warnings remain). Chromium verifies the calligraphic glyph, no
KaTeX errors, and all five proofs initially collapsed. Ownership released
for the page and this opening. Published in the deployment recorded above.

## Ready: recurrence-page proofs and vector notation — 2026-10-21

All five proofs now use the existing collapsible `proof*` environment,
closed by default. The sequence is explicitly defined as bold P, scalar
polynomials remain P_n, and amplitude/coordinate vectors are consistently
bold. Only `tex-source/polynomialRecurrences.tex` and this opening changed.

Full build/checks and whitespace pass (two existing fixture warnings).
Chromium at 1366/375 verifies every disclosure by click and keyboard,
both text widths, bold/scalar notation, no math errors or page overflow,
and native operation without JavaScript. Screenshot inspected. Evidence:
`/cargo-target/symcat-proof-vectors-20261021/`. Ownership released after
the focused checkpoint; preview server stopped. Published in the deployment
recorded above, together with the Vailaya addition below.

## Ready: Vailaya circular-arc positivity result — 2026-10-21

Added arXiv:2609.33124v1 as `Vailaya2026x` and its Theorem 21 to
`chromaticQuasisymmetric.tex`, with proper circular-arc definition, circular
Dyck path specialization and the q=1 Ellzey conclusion. Cross-linked from
`chromaticEexpansion.tex`. No other source edits. Verified metadata against
arXiv and the arxiv-symmetricfunctions API; theorem/definition checked in the
current paper-cache source (`ProperCircularArcGraph_1_.tex`, lines 143,
881–908) and verified text (Theorem 21). Source tree:
`/papers/math-co/arxiv-extract/arxiv-sources/2609.33124v1/`.

Full build/checks and whitespace pass (only the two existing fixture
warnings). Chromium 1366/375 checks theorem rendering, reference links and
cross-page navigation; screenshot inspected. Artifacts:
`/cargo-target/symcat-vailaya-20261021/`. Owned preview server stopped.
Ownership released for the two pages, bibliography and handoff opening.
Published in the deployment recorded above.

## Deployed: real-rootedness links and example — 2026-10-21

Replaced the local real-rootedness subsection and repeated general criterion
with links to the existing real-rootedness page and Ma--Wang theorem. The
quadratic derivative coefficient is now an example with its sign argument;
its previous destination anchor remains valid. Site commit 6cd6ffb is live.
Bridge receipt `20261021T173613-ef5589467ed0` confirms deployed and matching
search manifest. Build/checks, local/live desktop/mobile example rendering,
anchor and cross-page links pass. Public HTML matches the build. Evidence:
`/cargo-target/symcat-real-roots-example-20261021/`.

Ownership released; preview server stopped. Final record edits need no upload.

## Deployed: recurrence coefficient notation — 2026-10-21

The page uses D for every left-hand coefficient formerly written delta or
Delta. The generating-function denominator is Q; its quotient V(Q)/Q is
written explicitly. Site commit af242b6 is deployed; bridge receipt
`20261021T145017-6694836eb621` confirms deployed and matching search manifest.
Build/checks and local/live desktop/mobile math rendering pass; the public
page matches the build. Evidence:
`/cargo-target/symcat-coefficient-notation-20261021/`.

Ownership released; preview server stopped. This is a notation-only change.
Final deployment records need no further upload.

## Deployed: sidebar gap and tooltips — 2026-10-21

Restored the 1rem desktop sidebar gap and rounded corners. Width-icon
tooltips are exactly Narrow text / Wide text. Published site commit d0441e2;
bridge receipt `20261021T144610-e0c524464c75` confirms deployed and matching
search manifest. Build/checks and local/live Chromium at 1366/901/375 pass,
including exact gap/tooltips; public HTML/JS/CSS match the build. Only the
two existing fixture warnings remain. Evidence:
`/cargo-target/symcat-width-gap-20261021/`.

Ownership released; preview server stopped. Final record-only edits need
no upload. Existing icon, saved preference and bottom edit link are preserved.

## Deployed: recurrence layout refinement — 2026-10-21

Replaced the width text button with a small SVG icon matching and adjacent
to the dark-mode button. Its icon, tooltip and accessible pressed state track
the saved width setting. Desktop contents and article panels now share an
edge in both modes. Moved Improve this page below the references. Scoped
math scrolling also prevents overflow at the 901px desktop breakpoint.

Published SymCat commit a8eaea5fcae983a8bc57f1be3ae41e2cd204e85e at
2026-10-21T14:41:04.689881+00:00 through the constrained bridge. Receipt
`20261021T144104-8fa6be9c7e0d` confirms deployed and matching search manifest.
JS syntax, build, required checks and whitespace pass; only the two existing
synthetic-polydata warnings remain. Local/live Chromium at
1920/1366/1024/901/768/375 pixels verifies icon size/state, sidebar adjacency,
edit-link placement, widths, equation scrolling, keyboard/persistence,
unavailable storage, no-JS fallback, dark mode, print, mobile contents and
page isolation. Screenshots inspected. Public HTML/JS/CSS return 200 and
match the build. Artifacts: `/cargo-target/symcat-width-icon-20261021/`.

Ownership released for assigned source and records. The owned preview server
is stopped. Other pages retain their layout; no mathematical content or
bridge edits. This final record-only checkpoint needs no additional upload.

## Deployed: recurrence page width toggle — 2026-10-21

Added a Narrow text / Wide text button at the top of the recurrence page.
Wide retains the original layout and is the default. Narrow centers a 72ch
text column (576px at the current font size), with unchanged fonts, internal
scrolling for long equations, and a saved per-page preference. On phones,
both modes fit the available width. Other pages retain their layout.

Published SymCat commit 0957ae36f461ffb8c2dfa83e9d58e8165d277b1a through
the constrained bridge at 2026-10-21T14:33:40.085951+00:00. Receipt
`20261021T143340-755e9c1c5f86` confirms deployed and matching search manifest.
JS syntax, full build, required checks and whitespace pass; only the two
existing synthetic-polydata warnings remain. Local and live Chromium at
1920/1366/768/375 pass width measurements, fonts, equation scrolling,
keyboard use, saved preferences, unavailable storage, no-JS fallback,
print hiding, dark mode and page isolation. Screenshots inspected. Public
HTML/JS/CSS return 200 and match the build byte-for-byte. Evidence:
`/cargo-target/symcat-width-toggle-20261021/`.

Ownership released for assigned site code/docs and research records. The
preview server is stopped. Shared asset cache versions are updated; no
mathematical content or deployment-bridge changes. These final record edits
need no further upload.

## Deployed: recurrence prose revision — 2026-10-21

Removed the worked example's nonexistence/optimality paragraph and several
redundant qualifications elsewhere, following the user's further style
correction. The example now ends with its table. Theorems, their proofs,
hypotheses, citations and anchors remain intact; the private research notes
retain the omitted optimality argument.

Published SymCat commit b39c1bb3eccf9fcaf90473e3d0a6aa57f4d600c4 through
the constrained bridge at 2026-10-21T14:08:54.233765+00:00. Receipt
`20261021T140854-a08fcfb12dfb` confirms deployed with matching Pagefind
manifest. Full build/checks and local/live Chromium at 1366/375 pixels pass;
only the two existing synthetic-polydata warnings remain. Public HTML is
HTTP 200 and byte-identical to the build. Artifacts:
`/cargo-target/symcat-recurrence-prose-20261021/`.

Ownership released for the assigned prose and records. The preview server
is stopped. Documentation-only deployment records need no further upload.

## Deployed — recurrence table and terminology correction, 2026-10-21

Published clean/pushed commit c055dce00df801ca5290d9d408a86804f593676b
through the constrained bridge at 2026-10-21T11:59:17.041897+00:00.
Receipt `20261021T115917-3c7e8a80a96b` reports deployed, exit 0, and matching
Pagefind manifest. Removed the literal hline command from the table and
replaced coined labels with standard terminology or plain descriptions.
Mathematical statements and anchor IDs are preserved.

Full build, checks and whitespace pass, with only the two existing
synthetic-polydata warnings. Local and live HTTPS Chromium at 1366/375
pixels verify all twelve table cells, absence of leaked hline and removed
labels, math, references, links, width and homepage navigation. Table
screenshots inspected. Fresh public page, keywords and labels return 200
and match the build byte-for-byte. Artifacts, public hashes and receipt:
`/cargo-target/symcat-recurrence-correction-20261021/`.

Ownership released for this opening and the recurrence TeX page. The owned
preview server is stopped. No renderer, bibliography or bridge changes.
This deployment-record-only checkpoint needs no additional upload.

## Deployed — recurrence theory and BKW page, 2026-10-21

The user explicitly authorized deployment. Published clean/pushed commit
`1e60a9ebd2f41e1dc385c599a1de8a27826207ff` through the constrained SymCat
bridge at `2026-10-21T11:32:37.907579+00:00`. This includes the recurrence
page, BKW section, homepage card/cross-links and completed catalogue-reference
bibliography update. Bridge exit code 0, state `deployed`, Pagefind manifest
matches. Receipt:
`/cargo-target/symmetricfunctions-deploy-bridge/results/20261021T113237-54ed9f3f2980.json`.

Live page: <https://www.symmetricfunctions.com/polynomialRecurrences.htm>.
BKW anchor: `#recurrenceLimitingZeros`. Fresh public responses for the page,
homepage, both linked topic pages, card SVG, labels/keywords/bibliography feeds
and Pagefind entry all return HTTP 200 and match the local build byte-for-byte.
Live Pagefind search returns the new page. Actual HTTPS Chromium checks at
1366/375 pixels pass KaTeX, theorem rendering, bibliography, cross-page
anchors, viewport width and homepage-card navigation.

Before deployment, `NO_COLOR=1 make Q=1`, `NO_COLOR=1 make check Q=1` and
`git diff --check` passed. Only the two existing synthetic-polydata warnings
remain. Receipt copy, public files/hashes, build/check logs, browser harness,
log and screenshots: `/cargo-target/symcat-recurrence-deploy-20261021/`.
Ownership of this handoff opening is released. No content or bridge changes,
no retry or additional upload. This handoff-only checkpoint is not deployed;
the published content remains the exact commit recorded above.

## Completed — Beraha--Kahane--Weiss connection, 2026-10-21

Added `recurrenceLimitingZeros` to the polynomial-recurrence page: the
analytic BKW theorem with nonzero analytic amplitudes, explicit dominance
and nondegeneracy conditions, both types of limiting points, and the
all-sufficiently-large-index neighborhood conclusion. The statement was
checked against Sokal's published Theorem 1.5 (2004, p. 226), using the
convenient stronger exclusion of every constant unit-modulus ratio.
The existing three-base example gives two circular arcs and two rays by
exact modulus comparisons, illustrating the connection to the recurrence
spectrum. Repeated-pole polynomial-in-index amplitudes are explicitly outside
this version of BKW. Existing BKW/Sokal references were reused.

Cross-linked the transfer-matrix discussion and supplied its previously
missing non-identically-zero amplitude hypothesis (and m>=2). Ownership is
released for this opening and those two TeX pages. The catalogue-reference
checkpoint and bibliography are unchanged. No new computation or deployment.
Academic-writing guidance continues to apply.

`NO_COLOR=1 make Q=1`, `NO_COLOR=1 make check Q=1`, `git diff --check`, and
Chromium at 1366/375 pixels pass. Checks cover KaTeX, theorem environments,
both references, cross-page anchors, page width and homepage navigation.
Only the two existing synthetic-polydata warnings remain. Screenshots were
inspected and the owned preview server stopped. Logs/screenshots/harness:
`/cargo-target/symcat-bkw-page/`, with sibling build/check logs.

## Completed — RealRooted catalogue references, 2026-10-21

Appended 42 entries to `bibliography.bib` for works cited in the RealRooted
catalogue (DOIs and arXiv ids from its unmatched-reference ledger). Entries
come from the arXiv++ `api/bibtex.json` endpoint and are normalised to the
recent house style: `Last, First` authors, `--` page ranges, `doi` plus
`https://doi.org/` url, no publisher/issn on articles. Two key collisions
became `Branden2011b` and `LiuZhang2026bx`; the arXiv copy of Kozlov's
"Stirling complexes" was dropped in favour of the journal entry `Kozlov2022`.
Checks: `NO_COLOR=1 make Q=1` and `NO_COLOR=1 make check Q=1` pass; the
public feed has 2,619 entries. Live since the recurrence-page deployment
(commit `751203a`); verified in the public `bibliography.json`.

## Completed — polynomial recurrences and derivatives page, 2026-10-21

Added `tex-source/polynomialRecurrences.tex` in the existing catalogue style:
worked length/derivative frontier, complete bounded-kernel iff and h*k
verification bound, residual propagation, generating-function denominator
criterion, repeated-pole spectral model, first-order iff/uniqueness, and the
importance of the coefficient class. The page includes proofs, a Polytool
link, and a Ma--Wang application with the degree and sign hypotheses.
It is standalone mathematical exposition, without private research links or
claims that the proposed general theory has been formalized in Lean.

Added its homepage card and a separate TikZ-sourced navigation SVG, plus
cross-links from the transfer-matrix and interlacing pages. Added primary-source
bibliography entries for Chyzak--Salvy (1998) and Koutschan's thesis (2009);
checked Ma--Wang Theorem 2 against the published PDF. The academic-writing
skill guided exposition and proofreading. The theory is adapted from the
existing derivative-lift research lane; no new computational data or sequence
generators were introduced.

Verification passed: `make svg Q=1`, `NO_COLOR=1 make Q=1`,
`NO_COLOR=1 make check Q=1`, and `git diff --check`. Only the two established
synthetic-polydata warnings remain. Chromium at 1366/375 pixels verifies
KaTeX without errors, theorem environments, bibliography, cross-page anchors,
page width, and the homepage card/image/navigation. The existing cookie
notice is acknowledged through its normal button in the test. Desktop/mobile
screenshots and the compiled icon were visually inspected. Artifacts:
`/cargo-target/symcat-recurrence-page/` and sibling build/check/SVG logs.
The owned local preview server is stopped after verification.

Ownership released: this opening, the new page, `tex-source/index.tex`,
`tex-source/transfer-matrix.tex`, `tex-source/realRootedInterlacing.tex`,
`bibliography.bib`, `svg-tex/src/card-polynomialRecurrences.tex`, and
`assets/nav-images/card-polynomialRecurrences.svg`. No shared styling/build
code or other source files changed. Source is prepared for publication;
no deployment was performed for this page.

## Completed — public bibliography feed, 2026-10-21

The build now also writes `www/bibliography.json` (schema 1): citation key ->
`{label, csl, bibtex}`. `label` is the site's own short label (e.g. `Bre95`),
`csl` the CSL-JSON entry, and `bibtex` the raw BibTeX. The RealRooted Lean
catalog uses it, together with `site-labels.json`, to share references and
link statements. `bibhandler.public_bibliography()` builds it; `merge_meta.lua`
writes it next to `site-labels.json` and `site-keywords.json`.

Verification: `make Q=1`, `NO_COLOR=1 make check Q=1` and `git diff --check`
pass; 2575 entries are written. Without `NO_COLOR`, the SVG backend tests fail
in a colour terminal because they expect the plain `[ERROR]` prefix. This is
environmental and unrelated to the change. Ownership is released.

Deployed commit `27b65c87828815a0970f5021c2d8b72bed9f1df0` through the
constrained bridge on 2026-10-21. The receipt reports exit code 0 and a matching
Pagefind manifest:
`/cargo-target/symmetricfunctions-deploy-bridge/results/20261021T104619-360873a4e3be.json`.
The live `https://www.symmetricfunctions.com/bibliography.json` returns HTTP 200
with 2575 entries. This handoff-only checkpoint is not deployed.

## Verified deployment — split-page navigation cards, 2026-10-20

Deployed SymCat commit `521c43d6ae91254e043cb1dfc29703b08735c536`
through the constrained bridge after a clean `make Q=1` build,
`make check Q=1`, and `git diff --check`.  The only diagnostics were the two
established synthetic-polydata warnings, and the bridge was ready and pinned
to the expected clean commit.

Deployment request `20261020T104930-be7cb60cd88c` reports `deployed` with
exit code `0` at `2026-10-20T10:49:30.492581+00:00`; its Pagefind manifest
matches.  Receipt:
`/cargo-target/symmetricfunctions-deploy-bridge/results/20261020T104930-be7cb60cd88c.json`.
The live homepage and both new destination anchors return HTTP `200`, and the
live rational-shuffle and set-partition SVGs match the local assets by
SHA-256.  This handoff-only checkpoint is not deployed.

## Completed — navigation cards for split pages, 2026-10-20

Added homepage cards for the rational-shuffle/Delta page and the
set-partition/Stirling-permutation page.  Their TikZ sources in
`svg-tex/src/card-icons.tex` depict a rational Dyck path above its diagonal
and a colored set-partition arc diagram.  The documented `make svg` pipeline
generated `card-rationalShuffle.svg` and `card-sturmSetPartitions.svg`; both
were visually inspected from the compiled PDF.

Verification passed: `make svg Q=1`, `make Q=1`, `make check Q=1`, rendered
homepage link/image inspection, copied-asset byte comparison, and
`git diff --check`.  The only diagnostics were the two established
synthetic-polydata warnings.  Ownership is released.  No deployment was
performed.

## Completed — prose pruning and approved page splits, 2026-10-20

Split `schurMisc.tex` into a 194-line hub plus dedicated 442-line
symplectic/orthogonal and 367-line Schur P/Q pages.  Split
`realRootedWords.tex` into 746-line permutation and 276-line set-partition
pages, and `diagonalHarmonics.tex` into 537-line diagonal-harmonics and
699-line rational-shuffle/Delta pages.  All pre-existing section and explicit
labels were preserved, and each original page links to its moved material.

Pruned the qtBench paragraph and the Jacobi--Stirling discussion while
retaining result status and open cases.  Rewrote the OEIS A189912 parity
argument with valid summation ranges, and corrected `Schur-{P}ositve` in the
bibliography.  Academic-writing guidance was used.

Verification passed: `make bib Q=1`, two full `make Q=1` builds,
`make check Q=1`, rendered anchor/link and bibliography inspection, label-set
comparison, and `git diff --check`.  The only diagnostics were the two
established synthetic-polydata warnings.  Ownership is released.  No
deployment was performed.

## Completed — quantum Littlewood--Richardson branching reference, 2026-10-20

Added the exact-v7 bibliography record for Olga Azenhas's arXiv
`2603.16698v7` and a two-sentence reference beside the symplectic branching
models in `tex-source/schurMisc.tex`.  The exact v7 source was inspected
directly after the paper-cache extractor reported a conflicting indexed
artifact; the addition records the explicit inverse to Watanabe's quantum
Littlewood--Richardson map, the symplectic branching bijection, and its
orthogonal-transpose symmetry.  Academic-writing guidance was used.

Verification passed: `make bib Q=1`, `make FILE=schurMisc.tex Q=1`,
`make Q=1`, `make check Q=1`, rendered citation/link inspection, and
`git diff --check`.  The only diagnostics were the two established synthetic
polydata warnings.  Ownership is released.  No deployment was performed.

## Completed — three current preprints, 2026-10-20

Added exact-v1 bibliography records and short, source-checked references for
arXiv `2610.26303v1`, `2610.26294v1`, and `2610.25036v1`.  The
partition-division result is on `standardSymmetricFunctions.tex`; the
flip-class refinement is on `unicellular-llt.tex`; and Siegl's network method
is summarized on `chromaticQuasisymmetric.tex` with a short pointer from
`schurPositivity.tex`.  Academic-writing guidance was used.

Verification passed: `make bib Q=1`, focused builds of all four pages,
`make Q=1`, `make check Q=1`, rendered citation/link inspection, and
`git diff --check`.  The only diagnostics were the two established synthetic
polydata warnings.  Ownership is released.  No deployment was performed.

## Completed — recent catalogue references, 2026-10-16

Added source-checked references for arXiv `2610.21921v1` (rectangular Kostka
stretching) to `tex-source/kostkaFoulkes.tex`; `2610.21894v1` (positroid
algebras, Theta/Delta operators, Eulerian quasisymmetric functions, and Chow
rings) and `2610.21501v1` (Ehrhart positivity for paving positroids) to
`tex-source/positroids.tex`; `2610.21535v1` (rectangular symmetry for Catalan
functions) to `tex-source/kschur.tex`; `2610.21289v1` (rooted Hopf algebras)
to `tex-source/algebras-and-rings.tex`; and `2610.21053v1` (skew divided
differences and triple Schubert coefficients) to
`tex-source/schubertVariations.tex`.  The existing chromatic-symmetric-
function reference for `2610.01617` was already correctly placed, so its
bibliography title and versioned link were updated from v1 to v2 without
duplicating the page entry.  Because the six new papers had not yet entered
the archive's math.CO metadata, their exact cached v1 source packages were
inspected directly; all package SHA-256 values matched the cache records.  The
exact v2 package for `2610.01617v2` was checked likewise.  Academic-writing
guidance was used.

Verification passed: `make bib Q=1`, focused builds for all six affected
pages, `make Q=1`, `make check Q=1`, rendered prose/reference inspection, and
`git diff --check`; the only diagnostics were the two established
synthetic-polydata warnings from `make check`.  Ownership is released.  No
deployment or publication was performed.

## Completed — stable plethysm coefficients, 2026-10-15

Added the indexed-API bibliography record for Soumyadip Sarkar, *Stability of
plethysm coefficients and modified polynomial induction*, pinned to arXiv
`2610.07929v2`.  Added two sentences to the stability discussion in
`tex-source/plethysm.tex`, recording the improved stable range, the closed
formula for the stable Foulkes coefficient, and the positive polyhedral
formula when the indexing partition has at most four columns.  The exact v2
source tree (SHA-256
`618a9c847921d28bcf6b50a579c2e9c54bae950155275b4c64818d5f79c56119`) was
inspected directly after the paper-cache text converter reported a conflicting
indexed artifact; the fallback and all claims were source-checked.
Academic-writing guidance was used.  Verification passed: `make bib Q=1`,
`make FILE=plethysm.tex Q=1`, `make Q=1`, `make check Q=1`, rendered-reference
inspection, and `git diff --check`; the only diagnostics were the two
established synthetic-polydata warnings from `make check`.  Ownership is
released.  No deployment or publication was performed.

## Completed — matroid parity module and bicolored Eulerian QSFs, 2026-10-15

Added indexed-API bibliography records for Braden--Huh--Matherne--Proudfoot--
Wang, arXiv `2610.20234v1`, and Liao--Zhu, arXiv `2610.19363v1`.  Added a
concise source-checked summary of the parity module and its characteristic-
$p$ Kazhdan--Lusztig consequences to `tex-source/matroids.tex`, and a concise
summary of the affine-length refinement, Theta-operator symmetry result, and
conjectural Schur positivity to `tex-source/eulerianSymmetric.tex`.  Exact v1
paper-cache sources and hash-verified extracted text were inspected, and the
`academic-writing` skill guided the mathematical prose.  Verification passed:
`make bib Q=1`, focused builds for both pages, `make Q=1`, `make check Q=1`,
rendered-reference inspection, and `git diff --check`; the only diagnostics
were the two established synthetic-polydata warnings from `make check`.
Ownership is released.  No deployment or publication was performed.

## Completed — rho-Naples parking functions, 2026-10-15

Added the indexed-API bibliography record for Luca Ferrari and Francesco
Verciani, *A new generalization of parking functions: $\rho$-Naples parking
functions*, pinned to arXiv `2610.20267v1`.  The exact-current paper-cache
source and hash-verified text agree on the title, authors, version, and main
results.

Added two sentences to the variations section of
`tex-source/parking-functions.tex`.  They define the per-car backward
allowance, record that successful strategies for a fixed preference form an
up-set, and mention the classifications of minimum-total-backward-step
strategies and the zero--one case.  Academic-writing guidance was used.

`make bib Q=1`, `make FILE=parking-functions.tex Q=1`, `make Q=1`,
`make check Q=1`, and `git diff --check` pass.  The full check emits only the
two pre-existing synthetic-polydata warnings.  The rendered page contains the
two-author citation, exact title, versioned arXiv link, and downloadable
BibTeX.  Owned files were `HANDOFF.md`, `bibliography.bib`, and
`tex-source/parking-functions.tex`; ownership is released.  No deployment was
requested or run.

## Completed — qtBench catalogue entry, 2026-10-14

Added the indexed-API bibliography record for Eugenio Cainelli, Lorenzo
Luccioli, Alessandro Iraci, and Giovanni Paolini, *AI Discovery in
Combinatorics: From Problems to Solutions and Back to Bigger Problems*, pinned
to arXiv `2610.16555v1`.  The exact-current paper-cache source and hash-verified
full text agree on the title, authors, version, and preprint status.

Placed one concise resource paragraph in the introductory references of
`tex-source/diagonalHarmonics.tex`.  It identifies the benchmark's 29 open
problems and one solved calibration problem, explains the supplied finite data
and automated checks, and names the Theta, Delta, $\Xi$, super-nabla,
area--bounce, and parking-function area--dinv content relevant to this page.
The text preserves the paper's status distinctions: the proposed area--bounce
bijection is still under assessment, while negative coefficients rule out the
zero-rooted tiered-tree $\Xi$, multi-labelled Dyck-path super-nabla, and
rise-decorated rectangular-path Delta statistic interpretations.

`make bib Q=1`, `make FILE=diagonalHarmonics.tex Q=1`, `make Q=1`,
`make check Q=1`, and `git diff --check` pass.  The full check emits only the
two pre-existing synthetic-polydata warnings.  The rendered page contains the
four-author citation, exact title, and versioned arXiv link.  Owned files were
`HANDOFF.md`, `bibliography.bib`, and `tex-source/diagonalHarmonics.tex` in the
isolated worktree `/tmp/symcat-2610-16555`; ownership is released at this
checkpoint.  No deployment was requested or run.

## Verified deployment — transfer-matrix prose deletion, 2026-10-14

The user confirmed that the existing five-line deletion after the
Beraha--Kahane--Weiss theorem in `tex-source/transfer-matrix.tex` is
intentional, and authorized committing, pushing, and deploying it.  The
deleted paragraph concerned vanishing amplitudes, equal-modulus curves, and a
real-rootedness caveat.  No other source files changed.

The focused `transfer-matrix.tex` render, `make Q=1`, `make check Q=1`, and
`git diff --check` pass.  The rendered theorem now ends after its two
alternatives, with none of the deleted prose present.  Owned files are the
source file and this `HANDOFF.md`; the source has SHA-256
`5138bb8f6f55fb81cebf9e3b7e2034967668ba179cb7a8965d427d786b5af0d1`.

Committed and pushed the scoped source checkpoint as
`013ad30979ed23d259bdc6aed1011421558db349`.  A subsequent clean
`make clean && make Q=1`, `make check Q=1`, and `git diff --check` passed at
that exact commit, again with only the two pre-existing synthetic-polydata
warnings.  The constrained bridge reported `ready · idle` and pinned the
source commit before deployment.

Deployment request `20261014T152403-c912b0b5beab` reports `deployed` with
exit code `0` at `2026-10-14T15:24:03.769157+00:00`, with a matching Pagefind
manifest.  Receipt:
`/cargo-target/symmetricfunctions-deploy-bridge/results/20261014T152403-c912b0b5beab.json`.
The fresh HTTPS `transfer-matrix.htm` returned `200`, matched the local build
byte-for-byte, and no longer contains the deleted paragraph.  Only this
handoff entry changes after deployment; the handoff-only checkpoint is not
deployed.  Ownership is released.

## Verified deployment — two catalogue updates, 2026-10-14

The user explicitly authorized deployment of the two latest SymCat catalogue
updates through commit `245623405142be7953638567aa69c01519903a05`.  The
unrelated five-line deletion in `tex-source/transfer-matrix.tex` was isolated
in the file-specific stash commit `90056c036a1c41269a029c41f9958d76a3d2f982`.
The resulting clean worktree matched both `HEAD` and `origin/master` at the
requested commit.

On that clean commit, `make clean && make Q=1`, `make check Q=1`, and
`git diff --check` passed.  The only check output was the two pre-existing
synthetic-polydata warnings.  The constrained `symmetricfunctions-deploy`
bridge reported `ready · idle` and pinned the expected commit before the run.

Deployment request `20261014T121511-4b7b54a4cf53` reports `deployed` with
exit code `0` at `2026-10-14T12:15:11.300843+00:00`; its expected commit is
`245623405142be7953638567aa69c01519903a05`, and the Pagefind manifest matches.
Receipt:
`/cargo-target/symmetricfunctions-deploy-bridge/results/20261014T121511-4b7b54a4cf53.json`.

Fresh HTTPS copies of `realRootedGraphs.htm`, `matroids.htm`, `polytopes.htm`,
`diagonalHarmonics.htm`, `hallLittlewood.htm`, and `llt.htm` all returned
successfully and matched the clean local build byte-for-byte.  The first three
contain arXiv `2610.17135v1`; the latter three contain arXiv `2610.16756v1`,
including the new theorem text and cross-page anchors.

The transfer-matrix edit was restored from the stash before the stash was
dropped.  It again has exactly five deleted lines and SHA-256
`5138bb8f6f55fb81cebf9e3b7e2034967668ba179cb7a8965d427d786b5af0d1`;
it remains unstaged and was not included in the build or deployment.  Only
this handoff entry changes after deployment; the resulting handoff-only
checkpoint is not itself deployed.  Deployment ownership is released.

## Completed — nabla, Hall--Littlewood, and LLT positivity, 2026-10-14

Added the indexed-API bibliography record for Feng Gu, Mingyang Kang, Dun Qiu,
and Minhao Zhang, *The nabla operator, Hall--Littlewood polynomials and LLT
polynomials*, pinned to arXiv `2610.16756v1`.  The exact-current paper-cache
source and hash-verified full text agree on the title, authors, version, and
preprint status.

Replaced the obsolete Bergeron--Garsia--Haiman--Tesler Conjecture~II block in
`tex-source/diagonalHarmonics.tex` with the proved signed and unsigned
Schur-positivity statements and the dominance theorem, all for every positive
power `\nabla^r`.  The text distinguishes the shuffle-theorem proof of
Conjecture~II from Gu--Kang--Qiu--Zhang's proof of both parts of
Conjecture~III.  Added a short pointer from the modified Hall--Littlewood
section of `tex-source/hallLittlewood.tex`.

Added a complementary subsection to `tex-source/llt.tex`: for a dominance
cover, the Hall--Littlewood difference is minus an integral power of `t` times
one explicitly constructed LLT polynomial, and applying `\nabla^r` gives a
finite LLT-positive Laurent expansion.  Cross-links connect this mechanism to
the full dominance theorem without repeating its statement.  The specialized
Schiffmann-algebra extension was not needed for this catalogue-level summary.
Academic-writing guidance was used to keep the result hierarchy and notation
precise.

Verification passes with `make bib Q=1`, focused renders of
`diagonalHarmonics.tex`, `hallLittlewood.tex`, and `llt.tex`, `make Q=1`,
`make check Q=1`, and `git diff --check`.  Rendered HTML contains the exact v1
title, four authors, arXiv number and link, citation anchors, downloadable
BibTeX, formulas, and reciprocal cross-page links.  The only check output is
the two pre-existing synthetic-polydata warnings.

Owned files were `bibliography.bib`, `tex-source/diagonalHarmonics.tex`,
`tex-source/hallLittlewood.tex`, `tex-source/llt.tex`, and this `HANDOFF.md`;
ownership is released with the verified checkpoint.  The shared checkout's
unrelated dirty `tex-source/transfer-matrix.tex` remained byte-identical
(SHA-256 `5138bb8f6f55fb81cebf9e3b7e2034967668ba179cb7a8965d427d786b5af0d1`)
and was not edited, staged, or absorbed.  No deployment was requested or run;
the checkpoint is undeployed and requires a future explicit deployment request.

## Completed — matroid polynomial counterexamples, 2026-10-14

Added the indexed-API bibliography record for Bérczi--Coron--Eur--Li,
*Chow polynomials and chain polynomials of matroids are not log-concave*,
pinned to arXiv `2610.17135v1`.  The indexed metadata and paper-cache source
agree on the title, four authors, version, and preprint status.

Placed the theorem-level summary in `tex-source/realRootedGraphs.tex` directly
after the Athanasiadis--Kalampogia-Evangelinou chain-polynomial conjecture.  It
distinguishes the chain, ordinary Chow, augmented Chow, and order-complex
$h$-polynomial counterexamples; records the minimal ranks $4$ and $7$ only for
chain and ordinary Chow polynomials; and notes the simple, $3$-connected
rank-$7$ Chow examples.  Added a short cross-reference from the positive-class
survey in `tex-source/matroids.tex`, without duplicating the summary.  Added the
graph-associahedron result after the associahedron definition in
`tex-source/polytopes.tex`: the rooted $1540$-vertex graph, wedge construction,
and non-log-concave $h$-polynomials for every $s\geq23$.

Verification passes with `make bib Q=1`, focused renders of
`realRootedGraphs.tex`, `matroids.tex`, and `polytopes.tex`, `make Q=1`,
`make check Q=1`, and `git diff --check`.  Rendered HTML contains the exact v1
title, author list, arXiv number and link, citation anchors, downloadable
BibTeX, and the intended cross-page links.  The only check output is the two
pre-existing synthetic-polydata warnings.

Owned files were `bibliography.bib`, `tex-source/realRootedGraphs.tex`,
`tex-source/matroids.tex`, `tex-source/polytopes.tex`, and this `HANDOFF.md`;
ownership is released with the verified checkpoint.  The shared checkout's
pre-existing dirty `tex-source/transfer-matrix.tex` remained byte-identical
(SHA-256 `5138bb8f6f55fb81cebf9e3b7e2034967668ba179cb7a8965d427d786b5af0d1`)
and was not edited, staged, or absorbed.  No deployment was requested or run;
the checkpoint is undeployed and requires a future explicit deployment request.

## Completed — Jin--Lin Macdonald superization update, 2026-10-14

Updated the existing `JinLin2026x` bibliography record from the earlier title
to *Combinatorial formulas for Macdonald polynomials by superizations* and
pinned its eprint and URL to arXiv `2602.12672v4`.  The arXiv++ API, primary
arXiv metadata, and cached v4 paper agree on the title, Emma Yu Jin and Xiaowei
Lin as authors, and preprint status without a journal reference or DOI.

Placed symmetric content in `tex-source/macdonaldP.tex`, in the
`macdonaldPTableauFormula` subsection immediately after Mandelshtam's compact
tableau formula.  The new paragraph records the non-attacking and sorted
non-attacking tableau formulas, the fewer-summand comparison for partitions
with repeated parts, and the explicit monomial-coefficient formula from
Theorems 1.3--1.4.  Removed the older, less precise Jin--Lin paragraph from the
Macdonald J section.

Placed nonsymmetric content in `tex-source/macdonaldE.tex`, immediately after
the introduction of the `multilineQueueMacdonald` model.  The paragraph
records the super-filling compression of the Haglund--Haiman--Loehr formula,
its validity for arbitrary weak compositions, its specialization to the
Corteel--Mandelshtam--Williams partition formula, and the still-open status of
a general multiline-queue extension, following Theorem 1.5 and the final
remarks.  Academic-writing guidance was used for the mathematical exposition.

Verification passes with `make bib Q=1`, focused renders of
`macdonaldP.tex` and `macdonaldE.tex`, `make Q=1`, `make check Q=1`, and
`git diff --check`.  The rendered pages contain the new contextual text and
the exact v4 title, arXiv number, link, citation anchors, and downloadable
BibTeX.  The only check output is the two pre-existing synthetic-polydata
warnings.  Owned files were `bibliography.bib`, `tex-source/macdonaldP.tex`,
`tex-source/macdonaldE.tex`, and `HANDOFF.md`; ownership is released after the
verified checkpoint.  The main checkout's unrelated dirty
`tex-source/transfer-matrix.tex` was neither edited nor staged.  No deployment
was requested or run; this checkpoint is undeployed.

## Verified push and deployment — backend fixes, 2026-10-10

User explicitly authorized push and deployment, superseding the prior local-only
boundary. Pushed master through be2cfeb (including its 29 previously unpublished
ancestor commits) to origin/master without force. Clean checkout, make Q=1,
make check Q=1 and git diff --check passed before deploying be2cfeb through the
constrained host bridge. Receipt 20261010T101429-0626c6c912c3 reports deployed,
exit 0, matching Pagefind manifest, at 10:14 UTC.

Fresh HTTPS checks: index.htm, hallLittlewood.htm, rsk.htm, gtpatterns.htm,
site-keywords.json, site-labels.json and _pagefind/pagefind-entry.json all
returned 200 and matched the local build byte-for-byte. The keyword feed has
1,126 records and no double-hyphen page titles. Logs:
/tmp/symcat-backend-deploy-{build,check}.log and
/tmp/symcat-backend-deploy-live.json. Bridge receipt:
/cargo-target/symmetricfunctions-deploy-bridge/results/20261010T101429-0626c6c912c3.json.
Only this handoff changed after deployment; its checkpoint is also pushed.
Ownership released. No arXiv-site deployment, keyword import or retagging.


## Completed — verified backend audit fixes, 2026-10-10

Fixed the five issues summarized after the Opus audit: required render JSON
now fails strictly (including malformed document shape); SVG setup/compiler/
PDF inspection/conversion failures return nonzero; both metadata merges
track raw BibTeX and the template; keyword anchors allow SoftBreak; titles
and descriptions become plain text before HTML/feed output. The isolated
merge regression also exposed and fixed the hard-coded bibliography default:
bibhandler now honors REFS_JSON/BIBTEX_JSON and TEMP_DIR.

Verification: make unittest Q=1, make Q=1, make check Q=1 and git diff --check
pass. Five Python test methods cover malformed/missing input, valid empty
pages, 13 mocked SVG failures, three success modes, and fresh/incremental
site/test metadata builds with a synthetic bibliography. Existing Lua checks
also verify metadata punctuation/escaping and newline keyword anchors.
Generated output: all 2,232 label and 1,126 keyword references resolve across
147 pages; zero remaining double-hyphen titles in either catalogue. Only the
two expected missing-reference fixture warnings remain.
Logs: /tmp/symcat-backend-fix-{unittest,build,check}.log.

Owned files: render.lua, tex_to_svg.lua, gather.lua, bibhandler.lua, Makefile,
config_test.mk, tests/check_backend.py, tests/fixtures/svg_runner.lua,
tests/unittest.tex, tests/check_unittest.lua, README.md, AGENTS.md, HANDOFF.md.
Ownership released after the local checkpoint. No tex-source/, bibliography
content or SVG asset changes; no real SVG compiler run, push or deployment.
Python is only subprocess/temporary-fixture orchestration, not mathematical
computation. Other historical audit findings remain proposals in
suggestions/backend-audit-opus55-20261010.txt; this checkpoint addresses the
five verified findings summarized to the user and the related path defect.

## Completed — Claude Opus backend audit, 2026-10-10

User-requested read-only code audit at baseline d611816 completed with
claude-opus-5-5/high, exit 0, under a monitored 20-minute cap. TeX content,
bibliography content and other sites excluded. Read/Glob/Grep tools only.
Report: suggestions/backend-audit-opus55-20261010.txt, including parent
verification, qualifications, exact commands and the unmodified Opus findings.
Parent isolated probes confirm malformed JSON renders successfully, SVG
compiler errors can return success, a required bibliography dependency is
missing, and SoftBreak loses keyword anchors. Generated titles also retain
raw --. Remaining static findings and untested cases are marked in the report.
No backend source changes, builds, deployments or pushes. Only report and
handoff changed; ownership released after local checkpoint. No consultant
remains running and no background follow-up is promised. Fixes await request.
Artifacts: /home/dev/.local/state/symmetricfunctions/audits/2026-10-10-opus-backend-095558
Session: 713b14f6-a852-4d88-8db3-c52c7c91e26a.

## Verified deployment — keyword feed, 2026-10-10

At the user's request, deployed clean checkpoint 5bd05fe via the constrained
host bridge. Receipt 20261010T091003-8650a89b2621 reports deployed and matching
Pagefind manifest. make Q=1, make check Q=1 and clean-Git checks passed first.
Live site-keywords.json returns HTTPS 200 and is byte-identical to www output
(1,126 records). The deployed arXiv consumer accepts all 1,051 normalized terms.
The arXiv site was then deployed separately as authorized. Only this handoff
changed afterward; ownership released. No SymCat Git push.
Logs: /tmp/symcat-keywords-deploy-{build,check}.log.

## Completed — SymCat keyword export, 2026-10-10

Generated www/site-keywords.json (schema_version 1) from readable defin spans
in gather.lua, using an immediately following label when present, otherwise
a page reference. Single-letter math is supported; general formulae/raw TeX
are omitted. Merge output is sorted/deduplicated and wired into grouped build
and isolated fixture targets. The existing label catalogue is byte-unchanged.

Verification: make Q=1 and make check Q=1 pass (only two expected fixture
warnings). All 1,126 exported references resolve across 120 local pages; the
arXiv importer accepts the entire feed as 1,051 normalized phrases. Regression
covers definition text, Unicode, labels, simple math and formula exclusion.
Logs: /tmp/symcat-keywords-{build,tests,check}.log.

Owned files: gather.lua, merge_meta.lua, config.mk, config_test.mk, Makefile,
tests/unittest.tex, tests/check_unittest.lua, README.md, AGENTS.md, HANDOFF.md.
Ownership released after the focused local checkpoint. Not deployed or pushed,
preserving the existing SymCat no-push policy. Deploy this feed before enabling
the new arXiv Retag fetch button in production; no website/database production
state was changed. Related consumer: ../arxiv.symmetricfunctions.com/src/symcat_keywords.py.

## Verified deployment — 2026-10-09, 11:58 UTC

At the user's request, deployed clean checkpoint be28d29 through the host
bridge. Receipt 20261009T115816-5cde26a9edad reports deployed with matching
Pagefind manifest. Build, make check Q=1 and clean-Git checks passed. Live
transfer-matrix.htm returns HTTPS 200 and matches the local build byte-for-byte:
A219968 link present, Cayley--Hamilton attribution absent. Only this handoff
changed afterward; ownership released. No push or other-site deployment.

## Tiling sequence wording — 2026-10-09, complete

Removed the Cayley--Hamilton attribution from the triomino recurrence and
linked its displayed counts to OEIS A219968. The OEIS description, offset and
initial values agree. Matrix, characteristic polynomial and recurrence intact.
make Q=1, make check Q=1, rendered link/wording inspection and git diff --check
pass. Logs: /tmp/symcat-triomino-oeis-{build,check}.log. Ownership released for
tex-source/transfer-matrix.tex and HANDOFF.md after local checkpoint.
Not deployed or pushed.

## Verified deployment — 2026-10-09, 11:49 UTC

At the user's request, deployed clean checkpoint adf5964 through the constrained
host bridge. Receipt 20261009T114926-0fa534ecbbdb reports deployed and a matching
Pagefind manifest. Includes laminar matroids, the native triomino transition
table, and the Mickler, Xie--Zhang--Zhang and Jing--Liu references.
make Q=1, make check Q=1 and git diff --check passed before deployment.
All seven changed pages and 22 new SVGs return HTTPS 200 and match the local
build byte-for-byte. Only this handoff changed afterward; ownership released.
No Git push or other-site deployment. Earlier "not deployed" entries below
describe their individual checkpoints; these changes are now live.

## Laminar matroids — 2026-10-09, complete

Added a brief definition after partition matroids: laminar set families,
nonnegative integer capacities, independent-set inequalities, and partition
matroids as a special case. Labels laminarMatroids, laminarFamily, laminarMatroid.
Cites published FifeOxley2017, European Journal of Combinatorics 62 (2017),
206--216, DOI 10.1016/j.ejc.2017.01.002. DOI obtained from arxiv site API and
published BibTeX retrieved via /api/bibtex.json?doi=10.1016/j.ejc.2017.01.002;
publisher and LSU repository metadata agree. Primary abstract checked;
paper-cache item 547. Academic-writing skill used.

make Q=1, make check Q=1, rendered definition/anchor/DOI citation inspection
and git diff --check pass (two expected fixture warnings). Logs:
/tmp/symcat-laminar-{build,check}.log. Ownership released for bibliography.bib,
tex-source/matroids.tex and HANDOFF.md after local checkpoint. Not deployed
or pushed; no other site changed.

## Native triomino transition table — 2026-10-09, complete

Expanded the existing triomino/square example immediately after the domino
section on transfer-matrix.htm. Replaced the overview figure with a native
site table: nine profile diagrams and 13 completion diagrams, each rendered
as a separate SVG from one multipage TikZ source. Retained supplied patterns,
colors and the A-to-D multiplicity 2. Added table/matrix transpose explanation,
closure/reachability description and t_3 example. Existing matrix, counts and
recurrence preserved. Page-local CSS keeps diagrams legible and scrolls the
table on phones. Old overview asset retained.

The table renderer now preserves inline img elements already produced by the
trusted TeX pipeline; a fixture checks SVG, alt text and adjacent math in a cell.
Owned/released: tex-source/transfer-matrix.tex, figure_to_html.lua,
tests/unittest.tex, tests/check_unittest.lua, new svg-tex/src/transfer-matrix-
triomino-transitions.tex, 22 matching profile/transition SVGs, and HANDOFF.md.
Academic-writing skill used. No changes to Rostkur or any other site; only
its previously cached Chromium installation was reused for browser testing.

Verification: make svg Q=1, make Q=1, make check Q=1 and git diff --check pass
(two expected fixture warnings). Reused exact 15-state/9-class verification:
all transitions, matrix, characteristic polynomial, recurrence through n=30
and independent board counts through n=9 pass. Browser checks at 1280px and
390px (light/dark) verify 22 loaded images, all transition cell positions,
no overlapping/compressed diagrams, no page overflow or KaTeX errors. Table
scroll width is 728px within a 326px mobile viewport. Screenshots inspected.
Browser script/screenshots: /home/dev/.local/state/symmetricfunctions/verification/
2026-10-09-triomino-table/. Build logs: /tmp/symcat-triomino-table-*.log.
Local checkpoint only; not deployed or pushed.

## Mirabolic Hecke and super RSK reference — 2026-10-09, complete

Added JingLiu2026Mirabolic (arXiv:2610.11101), two sentences in the Hecke
section and one item among further RSK variants. Notes cover generic-parameter
quantum super Schur--Weyl duality, character formulas in hook Schur functions,
and super mirabolic insertion with the extra even letter recorded separately.
Read primary introduction and Theorems A/C/D; paper-cache item 546.
Academic-writing skill used. No proof audit or computation claimed.

make Q=1, make check Q=1, rendered citation/cross-link inspection and git diff
--check passed (only two expected fixture warnings). Logs:
/tmp/symcat-mirabolic-{build,check}.log. Ownership released for bibliography.bib,
tex-source/algebras-and-rings.tex, tex-source/rsk.tex and HANDOFF.md after local
checkpoint. Not deployed or pushed; no other site changed.

## Infinite log-concavity reference — 2026-10-09, complete

Added XieZhangZhang2026InfiniteLogConcavity (arXiv:2610.12237) and a short
paragraph after the Boros--Moll example in tex-source/realRooted.tex. Mentions
the analytic/computer-assisted criterion, transposed Boros--Moll sequences for
integer ell >= 3, and the power-sequence classification for positive integer d
(exactly d != 2). Extended the operator definition to one-sided infinite
sequences with zero extension. Primary introduction and Theorems 4.1/7.1
checked; paper-cache item 545. Academic-writing skill used. No proof audit.

make Q=1, make check Q=1, rendered math/citation inspection and git diff
--check passed (only two expected fixture warnings). Logs:
/tmp/symcat-infinite-logconcavity-{build,check}.log. Ownership released for
bibliography.bib, tex-source/realRooted.tex and HANDOFF.md after local checkpoint.
Not deployed or pushed; no other site changed.

## Mickler Macdonald Lax reference — 2026-10-09, complete

Added Mickler2026Lax (arXiv:2610.12326), two sentences beside the Macdonald
Littlewood--Richardson coefficients, and one short cross-reference from the
Jack page. The note mentions the corner eigenbasis and coefficient identities,
with Warnaar's product formula credited for the two-parameter strengthening.
Primary introduction/theorem statements read; paper-cache item 544. Academic-
writing skill used. No proof audit or computation claimed.

make Q=1, make check Q=1, rendered citation/cross-link inspection and git diff
--check passed (only the two expected fixture warnings). Logs:
/tmp/symcat-mickler-{build,check}.log. Ownership released for bibliography.bib,
tex-source/macdonaldP.tex, tex-source/jack.tex and HANDOFF.md after local
checkpoint. Not deployed or pushed; no other site changed.

## Verified deployment — 2026-10-09, 09:47 UTC

At the user's request, deployed clean checkpoint 4d8b2bb through the constrained
host bridge. Receipt 20261009T094706-11c83525152d reports deployed, with matching
Pagefind manifest. make Q=1, make check Q=1 and git diff --check passed first
(only expected fixture warnings). Live HTTPS returned 200 for transfer-matrix.htm
and svg-images/transfer-matrix-triomino-profiles.svg; both match the local build
byte-for-byte. This deploy includes the previously committed rational h-star
reference. Only this handoff changed afterward. Ownership released; no Git push.

## Transfer-matrix profiles — 2026-10-09, complete

Root changed only tex-source/transfer-matrix.tex, the new
svg-tex/src/transfer-matrix-triomino-profiles.tex and generated matching SVG,
and this opening handoff entry. Started clean at 7deeba7. Added a concise
auxiliary-state explanation and three-row square/straight-triomino example,
with the nine-class matrix, counts and Cayley--Hamilton recurrence. Rendered
the nine profiles as a separate TikZ-sourced SVG in a compact 3-by-3 layout.
Corrected the existing binary-word generating function numerator to 1+z.
Academic-writing skill used. Rust capability guide, cargo metadata and source
search completed: no general profile-tiling/characteristic-polynomial API found;
existing tiling experiments handle other tile families. A bounded one-off Python
verification of the supplied integer matrix/state space is proportionate here;
no new polynomial family or reusable computation is being introduced.
Verification: exhaustive reachable-state enumeration gives exactly 15 profiles;
reflection aggregation gives the supplied nine-class matrix. Exact characteristic
polynomial and recurrence checks through n=30 pass; independent finite-board
counts agree for n=0 through 9. Script and output retained outside Dropbox at
/home/dev/.local/state/symmetricfunctions/verification/2026-10-09-triomino/.
TikZ compilation, visual figure inspection, make Q=1, make check Q=1, rendered
HTML/figure/anchor inspection and git diff --check pass. Only the two expected
fixture warnings. Build logs: /tmp/symcat-triomino-{build,check}.log.
Ownership released after local checkpoint. This site's no-push policy retained;
not deployed. Other sites and bibliography untouched.

## Rational h-star monotonicity reference — 2026-10-08, complete

User requests the reference discussed in key-schubert-kostka. `/root` owns
only bibliography.bib, tex-source/polytopes.tex
and this opening entry. Checkout starts clean; preserve other workers' files.
Add Beck--Braun--Vindas-Melendez's published reference and cite its rational
monotonicity theorem beside Stanley's theorem on the general Ehrhart/h-star
page. User explicitly prefers this placement; leave schurFlagged.tex unchanged.
Academic-writing
skill used. Build/check citations and links. Local checkpoint only; no push
or deployment, preserving the existing website policy.

Added BeckBraunVindasMelendez2022 (DCG 68(1), 50--71) with DOI and arXiv
metadata checked against the publisher, arXiv v2 and bibliography API.
Cited Theorem 3.3 beside Stanley's monotonicity theorem on polytopes.tex,
the general Ehrhart/h-star reference page. The rational common-denominator
statement was already present. schurFlagged.tex is unchanged, as requested.
make Q=1, make check Q=1, rendered citation/DOI inspection and git diff
--check pass (only the two expected fixture warnings). Ownership released
after the local checkpoint; not deployed or pushed.

## Exoo reference for book audit — 2026-10-07

Supervisor added only Exoo1989 in bibliography.bib, using the DOI metadata API
and checking the publisher abstract (42-vertex coloring gives R(5,5) >= 43).
make bib and the book BibTeX pass succeed; git diff --check is clean.
Ownership released. Local-only checkpoint, no push or deployment.

## Completed book references — 2026-10-07

Host supervisor added AngeltveitMcKay2026, BursicsKomjath2023 and
McGuireTugemannCivario2014 to bibliography.bib for Recreational.Problems,
and normalized MO292's author field. Existing Pak2002PartitionBijections reused.
Primary articles and DOI metadata checked; make bib, book BibTeX/pdflatex
and git diff --check passed. Only bibliography.bib and this handoff owned.
Ownership released. Local-only checkpoint; no website prose, push or deployment.

## Circle-game reference — 2026-10-07

Host supervisor completed only the new MO298443 master-bibliography entry and this
note for the authorized Recreational.Problems exercise. Prior worker ownership
released and checkout clean. Question author, title, date and URL checked on
MathOverflow. Book BibTeX/pdflatex and `git diff --check` passed. Ownership
released. No website prose or deployment; preserve local-only checkpoint policy.

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
