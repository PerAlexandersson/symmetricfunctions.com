# Preprint triage, 2026-09-15

This note records an editorial and Lean-formalization triage of eight distinct
preprints supplied by Per. The PDF for 2609.15651v1 was listed twice. The
assessment is based on the complete cached PDFs, not only their abstracts.

## Website decisions

### Add concise references

- [Binder--Vecchi, arXiv:2609.15946v1](https://arxiv.org/abs/2609.15946v1):
  add the real-rooted refined Hodge--Poincaré polynomials for uniform matroids,
  the modified augmented version, the failure for the unmodified augmented
  version, and the all-loopless-matroids conjecture to matroids.tex.
- [Xu--Zeng, arXiv:2609.14386v1](https://arxiv.org/abs/2609.14386v1):
  add the Jacobi-fraction, gamma-positivity, and coefficientwise Hankel-total
  nonnegativity results to totalPositivity.tex.
- [Thibon--Wang, arXiv:2305.07858v2](https://arxiv.org/abs/2305.07858v2):
  update the existing v1 record and state the complete Schur-positivity results
  for the spider families \(S(a,2,1)\) and \(S(a,4,1)\) on
  chromaticQuasisymmetric.tex.
- [Bathija--Rohatgi--Soskin, arXiv:2609.05341v3](https://arxiv.org/abs/2609.05341v3):
  add the bounded-ratio cone, its \(M\)-convex dual, the ternary
  classification, and the linear-form boundary to
  lorentzianPolynomials.tex.
- [Shankar, arXiv:2609.15651v1](https://arxiv.org/abs/2609.15651v1):
  add the multivariate stability and strict-interlacing strengthening of the
  powered Eulerian result to realRootedWords.tex.
- [Fernández--Kleinwort--Li--Torres-Danta, arXiv:2609.15690v1](https://arxiv.org/abs/2609.15690v1):
  add the Laurent Schur basis, extended Hall inner product, inverse/direct
  limit construction, and representation-theoretic interpretation to
  standardSymmetricFunctions.tex.
- [Pena, arXiv:2609.15852v1](https://arxiv.org/abs/2609.15852v1):
  add the skew-Ferrers restricted-RSK theorem and the resulting
  Demazure-atom/key Cauchy expansions to key.tex.

These are short references to the papers' main contributions. Inclusion on
the site should not be read as independent verification of every proof.

### AI-use disclosures

Four papers disclose AI use, with materially different scopes.

- Liu--Zhang say ChatGPT helped check the correctness of some mathematical
  results and edit the English. This is the strongest reason for caution,
  especially because the new stability theorem is the heart of the proof.
- Bathija--Rohatgi--Soskin say Claude and ChatGPT supplied calculations, proof
  ideas, and editorial assistance, some of which was misleading. The site
  entry is therefore restricted to their main structural theorem. Their paper
  states that this theorem also follows from independent concurrent work of
  Baldi--Kummer.
- Fernández--Kleinwort--Li--Torres-Danta say ChatGPT was used for proofreading
  and to identify possible gaps. The authors state that every suggestion was
  checked, and they name two project supervisors.
- Shankar says AI was used for coding assistance, data collection, symbolic
  calculations, and language editing, but not to find proofs.

The other four PDFs contain no AI-use declaration found by a full-text search.
These disclosures are risk signals, not proofs of correctness or
incorrectness.

### Hold for review

[Liu--Zhang, arXiv:2609.15201v1](https://arxiv.org/abs/2609.15201v1) is not
obvious nonsense. Its authors have relevant affiliations and prior work, the
paper gives explicit definitions and a long proof chain, and its three printed
small gamma polynomials pass exact real-rootedness checks. These checks do not
verify the main theorem.

The paper itself says that ChatGPT assisted with checking some mathematical
results as well as with English editing. The central ingredient, a new stable
symmetric eigenfunction construction used to prove the constant-term
polynomial stable, is substantial and has no independent or formal
verification known to us. The draft also contains visible editorial defects,
including “thereby proving Theorem 1.1” when the cited item is Conjecture 1.1
and “Section Section 2.” We should therefore wait for a specialist check or a
revised version before adding its claimed resolution to the public reference
pages. No Lean issue is warranted until that mathematical audit has been
done.

## Relation to the deco project

Shankar's powered triangular recurrence is the closest neighboring result. It
shows that powering the two affine coefficients of an Eulerian-type triangular
recurrence admits stable cross-step refinements and gives strict univariate
interlacing. The deco recurrence has an additional lag term, so it is not an
instance of Shankar's theorem. The paper nevertheless supplies a useful model
for what a successful multivariate refinement of the weighted deco family
might look like.

Xu--Zeng's Jacobi fractions and coefficientwise Hankel total nonnegativity are
also relevant to the open production-matrix/J-fraction direction. Their
families do not currently give a continued fraction for the deco recurrence.

Binder--Vecchi use the Brändén--Solus deranged transformation and the
Athanasiadis Eulerian transformation. This is conceptually close to the
project's interval-preserver work, but it does not settle the open
\([-1,0)\)-zero-preserver question.

## Lean triage

Two sufficiently scoped, very-low-priority application issues were opened:

- [#794: Powered Eulerian stability and strict interlacing](https://github.com/PerAlexandersson/RealRooted/issues/794).
- [#795: Uniform-matroid refined Hodge--Poincaré real-rootedness](https://github.com/PerAlexandersson/RealRooted/issues/795).

The general equivalence relating real-rooted palindromic polynomials and their
gamma polynomials is already checked as
gammaRealRootedIffPolynomialRealRootedNonpos; it should not be opened again.

No issue was opened for the other papers:

- Xu--Zeng would first require a sizable formal theory of coefficientwise
  polynomial orders, formal continued fractions, and Hankel total
  nonnegativity.
- Thibon--Wang, Fernández--Kleinwort--Li--Torres-Danta, and Pena are primarily
  symmetric-function, tableau, or representation-theory projects rather than
  applications of the current RealRooted library.
- Bathija--Rohatgi--Soskin requires \(M\)-convex and polyhedral dual-cone
  infrastructure not presently in scope.
- Liu--Zhang should be independently audited before being made a
  formalization target.

## Draft attribution email

Subject: Small attribution clarification in arXiv:2609.15651

Dear Umesh,

Thank you for citing my preprint in your new paper. I noticed one attribution
point that may be worth clarifying in the next version. My Theorem 5.1 proves
the family-specific real-rootedness and consecutive interlacing for the
powered Eulerian polynomials. The final step asserting real-rootedness and
nonnegative coefficients of the associated gamma polynomial uses the older
general gamma-polynomial equivalence, cited there as Petersen's *Eulerian
Numbers*, Observation 4.2.

Could you perhaps separate these two contributions? For example, the sentence
in Section 3.3 could say:

> By the standard gamma-polynomial equivalence
> [Petersen, Observation 4.2], Alexandersson's real-rootedness theorem also
> implies that \(\Gamma_{n,\ell}\) is real-rooted with nonnegative
> coefficients.

The current wording is not false as a statement about this particular family,
but it can be read as attributing the general gamma-polynomial implication to
me.

Best wishes,

Per
