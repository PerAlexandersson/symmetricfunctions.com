# Real-rootedness coverage survey: search log

Survey cutoff: **2026-09-09**. This is a reproducibility and limitations log;
editorial recommendations and mathematical statements belong in `REPORT.md`.

## Session, instructions, and tool availability

- Dedicated private Codex session: `01a08514-37bd-7ab2-938e-e25280b399e3`;
  role `real-rooted-survey`; starting checkout `7d26612`.
- Read before research: `/workspace/AGENTS.md`, project `AGENTS.md`, `HANDOFF.md`,
  and `suggestions/real-rootedness-survey/BRIEF.md`.
- Loaded the installed deep-research skill from
  `/home/dev/.codex/plugins/cache/openai-curated-remote/deep-research-work/0.1.15/skills/deep-research/SKILL.md`.
- `codex mcp list` reported these enabled servers: `arxiv-symmetricfunctions`,
  `axle`, `lean-realrooted`, `oeis`, `paper-cache`, `polynomial-lab`, and
  `polytool`. Relevant read-only arXiv-index and paper-cache calls were tested
  successfully. Broad web search and direct HTTP retrieval were available.
- No relevant discovery or primary-source tool was unavailable. `polytool` and
  `polynomial-lab` were available but were not needed: no new computational
  claim or conjecture was promoted on numerical evidence. Lean/Lake was not run.

## Checkout and live-site inventory

The checkout was searched with `rg` before candidate classification. The first
pass read the full relevant portions of:

- `tex-source/realRooted.tex` and `realRootedInterlacing.tex`;
- `realRootedWords.tex`, `realRootedCatalan.tex`,
  `realRootedTableaux.tex`, and `realRootedGraphs.tex`;
- `stablePolynomials.tex`, `polyaFrequency.tex`,
  `lorentzianPolynomials.tex`, and `gammaPositivity.tex`;
- `polytopes.tex`, `matroids.tex`, `lattice-path-matroids.tex`,
  `coxeterGroups.tex`, `chromaticQuasisymmetric.tex`, `varieties.tex`, and
  relevant cross-linked poset/permutation/Ehrhart pages;
- `bibliography.bib`, recent `git log`, and the dated status blocks in
  `HANDOFF.md`.

Representative local searches (rerun from the repository root):

```sh
rg -n -i 'real.root|interlac|stabl|Lorentz|gamma' tex-source bibliography.bib
rg -n 'barycentric|local .-polynomial|edgewise|rook-Eulerian|UMEL|rank-uniform' tex-source bibliography.bib
rg -n 'Xiao|toric .-contribution|Shankar|colored multiset|Chow|sparse paving' tex-source HANDOFF.md
rg -n 'Gal|nestohed|tau.polynomial|flow polynomial|coordinator|M.?0,n|Fulton.MacPherson' tex-source bibliography.bib
git log --oneline --decorate -n 80
```

The live pages at `https://www.symmetricfunctions.com/` were opened for the
same topic cluster and spot-checked against local source. Live-page publication
dates and content confirmed that several 2026-09-03 through 2026-09-08 checkout
changes are not yet deployed. One browser rendering of `realRootedGraphs.htm`
was impeded by a Cloudflare response; its live text was instead cross-checked
through the site search result/cache and against the checkout plus deployment
notes. This does not affect the classification of new-paper gaps.

## Recent-paper discovery

The `arxiv-symmetricfunctions` status endpoint was fresh through 2026-09-09
(latest indexed publication date 2026-09-08). Searches included exact and broad
queries for `real-rootedness`, `real-rooted`, `interlacing`, `stable polynomial`,
and combinations with words/permutations, Catalan, tableaux, graphs, matroids,
polytopes, Ehrhart, local h, Chow, gamma, and Coxeter. Results were screened past
the first page and not accepted from abstracts alone.

To avoid relying on index keyword ranking, a second independent arXiv API pass
listed every math.CO record since 2024 returned by the exact phrases
`"real-rootedness"` and `"real-rooted"`, sorted by submission date. It exposed,
among others, the late-cutoff papers `2609.05131`, `2609.06096`, `2609.07325`,
`2609.07457`, and `2609.07636`, as well as `2608.03635`, `2608.11012`,
`2608.15682`, `2608.19780`, `2605.15415`, `2605.29151`, `2604.04550`,
`2511.13819`, `2502.05939`, and `2402.06219`.

Additional broad web searches covered recent tableau/skew-tableau, Catalan,
Ehrhart, graph, matroid, stability, symmetric-function, chain-polynomial, and
subdivision results. Search-result claims were checked in an original arXiv or
publisher paper before entering the recommendation set.

## Primary papers inspected beyond abstracts

PDFs were resolved through `paper-cache` and theorem text inspected for:

- Alexandersson, arXiv `2609.05131v1` (Thms. 1.1, 4.2, 8.1; Cors. 8.2, 8.4);
- Alexandersson, arXiv `2609.07325v1` (Thms. 2.1, 3.1, 4.1, 5.1, 6.1, 6.3);
- Kang--Liu--Sun--Zhang, arXiv `2609.07457v1` (Thms. 1.1--1.2);
- Xie--Zhang, arXiv `2609.07636v1` (Thms. 1.1--1.3);
- Yan, arXiv `2608.15682v2` (Thms. 1.3--1.5);
- Nill, arXiv `2608.03635v1` (Thms. 1.1--1.2);
- Zhang--Dong, arXiv `2608.19780v2` (Thm. 6 and Cor. 7);
- Liu--Ma, arXiv `2608.11012v1` (Thm. 1 and its nonclassical convention);
- Coron--Ferroni--Li, arXiv `2604.04550v3` (Cor. 1.10, Thm. 1.12,
  Ex. 9.5/Thm. 9.6);
- Berczi--Kiem, arXiv `2605.29151v2` (Thms. 1.1--1.2, 5.1);
- Bona--Vatter, arXiv `2605.15415v1` (definition, Thm. 5.6, Cor. 5.8);
- Coron--Ferroni--Li, arXiv `2511.13819v2` (Thms. 1.2, 1.5, 1.8 and
  interlacing statement);
- Alexandersson--Jal--Quemener, arXiv `2502.05939v1` (Thms. 12--13);
- Athanasiadis, arXiv `2402.06219v2` / Combinatorica 45 (2025)
  (Thms. 1.2, 1.4 and Ex. 5.2 warning);
- Brenti--Welker, arXiv `math/0606356v1` / Math. Z. 259 (2008)
  (Thm. 3.1);
- Athanasiadis--Kalampogia-Evangelinou, arXiv `2205.03796v2`;
- Athanasiadis--Douvropoulos--Kalampogia-Evangelinou, latest arXiv
  `2307.04839v3` and published EJC paper (Thms. 1.2--1.3);
- Savage--Visontai, arXiv `1208.3831` (Thm. 1.1 and Thm. 3.15);
- Gal, arXiv `math/0501046` / DCG 34 (2005).

The exact current versions matter. In particular, `2307.04839v3` corrects
notation typos in Lemma 5.3, `2604.04550v3` adds the nestohedral
counterexamples that v2 left open, `2605.29151v2` is the current
moduli-space proof, and `2608.19780v2` is the current graph-flow version.

## Screening rules and exclusions

- A result was not called real-rooted merely because it is log-concave,
  Lorentzian, gamma-positive, or Hurwitz stable. This excludes the 2026 spider
  independence-polynomial paper from the direct list: left-half-plane roots do
  not have to be real.
- Multivariate stability results are described separately from the univariate
  positive-ray/specialization consequences. The rook-Eulerian paper proves only
  same-phase stability for its multivariate refinement, whereas the new
  peak-value refinement is genuinely stable.
- Root location and multiplicity were recorded only when the paper states them.
  In particular, nonnegative-coefficient nonconstant polynomials cannot have
  positive real roots, but the report does not silently upgrade real-rootedness
  to simplicity.
- The Liu--Ma coordinator result is held out of the main recommendations because
  its authors explicitly call the alternating pattern a “second pattern” distinct
  from classical interlacing.
- The pattern-avoiding permutation-polytope preprint `2609.06096v1` is held for
  correction. It simultaneously claims exact verification through dimension
  1000, an eventual theorem from dimension 272, and an “intervening” open range
  written as `1001 <= d < 272`. No editorial theorem should be copied from this
  internally inconsistent v1 without clarification or a revised version.
- Specialized tiling and generalized-Petersen examples were screened but ranked
  below additions that connect existing page clusters. Absence from an overview
  alone was not treated as a reason to add them.
- No verified post-cutoff resolution of the skew-SYT descent-polynomial problem
  was found. It remains correctly labeled open in `realRootedTableaux.tex`.

## Handoff screen against already-completed work

The dated handoff history prevented the following false positives:

- Xiao's individual toric-contribution real-rootedness and two adjacent-rank
  interlacings, and Guo--Kang's polytope realization theorem, are already present
  and deployed (2026-09-02). Only the later fixed-row theorem is missing.
- Generalized-snake order-polytopes, thagomizer/K2,n matroid KL/Z polynomials,
  the stable-determinant identity, parking-function descents, and the recent type
  D half-interlacing correction are already covered.
- The gamma-root criterion, Lace/Hurwitz material, skew Gelfand--Tsetlin
  corrections, marked-order/Pitman--Stanley material, and several stability
  distinctions are local but not yet deployed. They are recorded as
  `undeployed`, not `missing`.

## Remaining follow-up checks

- Recheck every arXiv-v1 recommendation for a new version before editing the
  website; late-cutoff papers may change quickly.
- Revisit `2609.06096` only after a corrected version resolves the dimension-range
  contradiction.
- If the editor elects to add the full six-family batch from `2609.07325`, copy
  each normalization separately from the paper; the present report proposes a
  compact subset and does not conflate descent and excedance derangements.
- Publisher metadata were verified where readily available. Preprints without a
  journal reference should retain the versioned arXiv identifier and survey date.

## Final reproducibility checks

- A final exact-identifier search across `tex-source/` and `bibliography.bib`
  returned no hits for the recommended recent papers; the existing Xiao
  conjecture remains at `tex-source/polytopes.tex:99-108`.
- All 21 numbered sources in `REPORT.md` have one definition and at least one
  in-text use. All 25 arXiv/publisher links returned HTTP 200 on 2026-09-09.
  The remaining DOI resolver, `10.5070/C63160425`, returned HTTP 403 to the
  automated request; its bibliographic metadata and paper were independently
  checked, so this is recorded as an access response rather than a broken DOI.
- `CANDIDATES.tsv` has 40 data rows and exactly seven tab-separated fields on
  every row. The final report contains no control characters, and
  `git diff --check` reports no whitespace errors in the owned files.
