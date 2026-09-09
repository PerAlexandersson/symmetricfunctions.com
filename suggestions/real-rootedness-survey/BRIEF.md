# Real-rootedness coverage survey

## Assignment

The user requests a new private agent to do a deep survey of results on
real-rootedness missing from the symmetric functions website which should be
included. Work autonomously toward a comprehensive, sourced editorial gap
report. This is research and planning, not permission to modify or deploy the
website. Survey date: 2026-09-09.

First read `/workspace/AGENTS.md`, this project's `AGENTS.md`, and `HANDOFF.md`.
Use the deep-research skill if available in your installed skill registry;
otherwise record its unavailability and follow the research requirements below.
Discover your runtime tools and run `codex mcp list` in Docker. Prefer the
arxiv-symmetricfunctions index and paper-cache for discovery and primary-paper
access, supplemented by broad web searches and original publisher/arXiv sources.
Record unavailable relevant tools. Do not restrict the survey to indexed papers.

## Scope and method

- Inventory local source coverage, bibliography, and relevant live pages before
  classifying gaps. Start with realRooted and realRootedInterlacing, then the
  words, Catalan, tableaux, graphs, stable-polynomial, Lorentzian,
  gamma-positivity, polytope, Ehrhart, and related symmetric-function pages.
  Follow relevant cross-links. The site is https://www.symmetricfunctions.com/.
- Cover foundational results and significant newer work through the survey
  date. Prioritize combinatorial relevance, useful methods, major families,
  and results which connect existing pages. Search beyond the first results
  and abstracts; inspect theorem statements and hypotheses in primary papers.
- Distinguish genuinely missing material, partial coverage, citation-only
  coverage, missing cross-links, and local changes not yet deployed. Do not
  recommend adding a theorem merely because it is absent from the overview.
  HANDOFF records several recent real-rootedness and stability additions and
  corrections; explicitly screen against these to avoid rediscovering them.
- Check exact polynomial normalization, parameter ranges, exceptional cases,
  multiplicities, interlacing convention, and real versus nonpositive roots.
  Distinguish proved theorems from conjectures and experiments. Do not infer
  real-rootedness from log-concavity, Lorentzianity, or gamma-positivity alone.
  Separate multivariate stability from univariate specialization consequences.
- Prefer published or latest corrected versions; check relevant errata,
  supersession, and author corrections. Give stable identifiers, dates,
  source links, and theorem/page locations. Mark uncertainty explicitly.
- Rank additions by editorial value and confidence, not just recency. Include
  a small number of well-justified adjacent topics, clearly separated from
  direct real-rootedness omissions. Stop only after broad coverage has been
  screened and remaining limitations are made explicit, not after a few hits.

## Deliverables and ownership

You exclusively own new research files under
`suggestions/real-rootedness-survey/` (leave this BRIEF unchanged) and the
opening survey status section of `HANDOFF.md` once launched. The host has
finished its setup edits before launch. Record your session identifier in
the opening handoff section when available.

1. `REPORT.md`: a substantial, self-contained Markdown survey for an expert
   editor, with an executive summary and ranked gap inventory. For each
   recommended addition give the precise result and conditions, primary
   citation and theorem/page, evidence of the current coverage gap, importance,
   exact proposed destination file/section, and a concise proposed insertion
   paragraph in Markdown. Include useful cross-link recommendations and a
   clearly separated uncertain/future-check section. Use numbered footnotes
   and a full sources list. Separate source-backed facts from editorial
   judgments. Keep process/tool discussion out of this artifact.
2. `CANDIDATES.tsv` or an equivalent compact Markdown ledger: all substantive
   screened candidates, identifiers, present/partial/missing/undeployed/
   excluded/unverified status, destination, priority, and supporting sources.
3. `SEARCH-LOG.md`: search coverage, local search evidence, unresolved checks,
   exclusions, and reproducible follow-up notes.

Keep HANDOFF's opening concise with progress, owned paths, verification, and
blockers. Make focused checkpoint commits of your own verified research notes
and handoff updates. Verify links/citations and compare recommendations against
the checkout again before finalizing. Do not absorb unrelated changes.

No edits to TeX, bibliography, generated HTML, build configuration, or unrelated
files. No build, deployment, push, outbound messages to authors, or changes in
other projects. Do not start additional persistent workers or alter profiles.
Do not run Lean/Lake builds. Keep this worker on its assigned private profile.
Return a concise completion summary with the report path and highest-priority
verified omissions, without claiming website updates have been made.
