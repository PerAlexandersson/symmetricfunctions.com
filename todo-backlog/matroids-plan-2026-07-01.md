# Matroids Backlog Plan, 2026-07-01

This is the planning surface for the matroid backlog in `tex-source/matroids.tex`.
The goal is to turn raw links into short cited paragraphs, cross-links, and
possibly separate pages where a cluster becomes large enough.

## First Pass: Nearby Raw Links

- Characteristic polynomial: replace raw Rota--Heron--Welsh notes with cited
  prose and keep the focus on log-concavity and Lorentzian methods.
- Kazhdan--Lusztig and inverse Kazhdan--Lusztig polynomials: group the raw
  links around inverse KL, equivariant inverse KL, and thagomizer matroids.
- Chow rings and Chow polynomials: collect the uniform and Schubert-matroid
  items before deciding whether this deserves a dedicated subsection.
- Base-polytopes and Ehrhart theory: keep general base-polytope facts on
  `matroids.tex`, and move lattice-path-specific detail to
  `lattice-path-matroids.tex`.

## Family And Variant Cluster

- Shifted and threshold matroids.
- q-matroids and q-Delta-matroids.
- Symmetric lattice path matroids.
- Sparse paving matroids and their Schubert-calculus connections.
- Path-circular matroids, already cited, should remain near transversal
  matroids.

## Invariant Cluster

- The omega invariant is already integrated through `FinkShawSpeyer2024x`.
- Add the beta invariant from the base-polytope Ehrhart polynomial once the
  bibliography entry is present.
- Add the new matroid invariant item after identifying whether it belongs near
  Tutte, Chow, KL, or base-polytopes.
- Add the Dowling/Lorentzian item with enough context to explain which
  conjecture is resolved and which polynomial technology is used.

## Algorithm And Operation Cluster

- Transversal matroid contraction recognition should live near the
  transversal-matroid subsection, not in the raw-link tail.
- Matroid optimization currently has only a placeholder. This should become a
  short subsection with references to greedy algorithms and matroid
  intersection/union if it is kept.

## Polymatroids

- Keep this as a compact remark for now: Tutte polynomials for polymatroids,
  q-Delta-matroids, and related variants can point to a future polymatroid
  page if enough material accumulates.

## Workflow

1. Process one cluster at a time.
2. Add bibliography entries first, preferring published DOI data when
   available.
3. Promote only the shortest useful prose to `matroids.tex`.
4. Move lattice-path, rook, and panhandle details to
   `lattice-path-matroids.tex` when they are not genuinely general matroid
   material.
5. Delete or archive raw links only after the corresponding cited prose exists.

## Processed Batches

### 2026-07-01: KL, Chow, and Invariant Links

- Promoted inverse Kazhdan--Lusztig and braid-matroid leading-coefficient
  links to the Kazhdan--Lusztig section.
- Added a Chow-polynomial section for uniform matroids, including the Hoster
  formulas and Brändén--Vecchi real-rootedness result.
- Added the beta-invariant/Ehrhart-polynomial relation near base polytopes.
- Moved Bastida's single-element contraction result to the transversal-matroid
  subsection.
- Promoted the Dowling-polynomial-conjecture and arboricity-polynomial links
  to cited prose in the matroid links section.

### 2026-07-01: Polymatroids

- Added a polymatroid section with the rank-function definition, base
  polytope, and examples.
- Connected integral polymatroid bases with $M$-convex sets and normalized
  Lorentzian support polynomials.
- Promoted the finite-group realization and polymatroid Tutte polynomial links
  to cited prose.

### 2026-07-01: Family, Positroid, and Ehrhart Tail

- Promoted shifted/threshold matroids, q-matroids, q-delta-matroids, lattice
  path delta-matroids, sparse paving Schubert coefficients, tree/triple-set
  matroids, graph curve matroids, and flat-closed class extensions.
- Promoted positroid-envelope, unit-interval-positroid, and positroid-polytope
  Ehrhart links.
- Promoted general and special-family Ehrhart references for matroid base
  polytopes, including paving and panhandle matroids, Schubert matroids, mixed
  volumes, and the old De Loera--Haws--Köppe deletion-contraction observation.
- Promoted valuative Tutte-polynomial, valuated-matroid log-concavity,
  half-plane-property, and matroid-bingo links.
