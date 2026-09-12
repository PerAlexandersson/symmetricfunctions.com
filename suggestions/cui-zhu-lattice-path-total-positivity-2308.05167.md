# Cui--Zhu lattice-path total positivity (arXiv:2308.05167)

## Recommendation

This paper is useful for the site, but the best editorial addition is a compact
Jacobi--Stirling example rather than a transcription of its full weighted-path
machinery.  It also gives a good sequence of Lean targets, beginning with a
small product-of-linear-factors theorem and ending with the much harder planar
network theorem.

Primary source: Yu-Jie Cui and Bao-Xuan Zhu, *Total positivity from a kind of
lattice paths*, arXiv:2308.05167v1 (2023), especially Theorem 1.7,
Proposition 1.8, and Sections 7.5--7.8:
<https://arxiv.org/abs/2308.05167>.

The dedicated `arxiv-symmetricfunctions` MCP was present in the host registry
but failed during initialization on 2026-09-12.  The triage therefore used the
primary arXiv abstract, PDF, and the local website and Lean checkouts directly.

## Website additions

### Highest-value addition: Jacobi--Stirling specializations

The paper records the first-kind and second-kind Jacobi--Stirling numbers as
ordinary symmetric-polynomial evaluations:

\[
  \operatorname{Jc}_n^k(z)
  =e_{n-k}\bigl(1(1+z),2(2+z),\ldots,(n-1)(n-1+z)\bigr),
\]

and

\[
  \operatorname{JS}_n^k(z)
  =h_{n-k}\bigl(1(1+z),2(2+z),\ldots,k(k+z)\bigr).
\]

It also gives the recurrences

\[
  \operatorname{Jc}_n^k(z)=\operatorname{Jc}_{n-1}^{k-1}(z)
    +(n-1)(n-1+z)\operatorname{Jc}_{n-1}^{k}(z)
\]

and

\[
  \operatorname{JS}_n^k(z)=\operatorname{JS}_{n-1}^{k-1}(z)
    +k(k+z)\operatorname{JS}_{n-1}^{k}(z),
\]

together with their signed inverse relation.  These formulas would make a
natural example in `tex-source/standardSymmetricFunctions.tex`, cross-linked
from `tex-source/polyaFrequency.tex`.

For the first kind, the row-generating polynomial factors as

\[
  \sum_{k=0}^n \operatorname{Jc}_n^k(z)x^k
  =x\prod_{i=1}^{n-1}\bigl(x+i(i+z)\bigr).
\]

Thus for `z >= -1` its roots are non-positive and its coefficients form a PF
sequence.  The paper also recovers total non-negativity of the entire
first-kind triangle and of the Toeplitz matrix of every row.  Its terminology
often says “totally positive” where the site consistently uses TNN for
nonnegative minors; any addition should retain the site's TP/TNN distinction.

### Secondary addition: a master weighted-path example

Theorem 1.7 treats paths with vertical steps and jumps `(1,t+i)`.  When the
jump-weight polynomial factors into linear terms with nonnegative parameters,
it proves coefficientwise TNN for the path matrix and each row Toeplitz matrix;
with constant vertical weight it also proves column Toeplitz TNN, a Riordan
array formula, an explicit coefficient formula, and a bivariate generating
function.  This is a useful generalization of the existing Delannoy/Riordan
examples on `polyaFrequency.tex`, but it should be summarized only after the
notation is simplified.

Proposition 1.8 packages the corresponding PF and infinite-log-concavity
consequences.  Its hypothesis is stronger than merely asking each jump-weight
polynomial to be real-rooted: the factorizations use the same non-positive
zeros for every height.  Do not weaken this condition in the site statement.

## Lean targets, in recommended order

1. **Finite linear-factor PF bridge (small, reusable).**  For a finite family
   of nonnegative real weights `w i`, package that
   `prod i, (X + C (w i))` is an `IsPFPolynomial`, together with its coefficient
   formula in terms of elementary symmetric polynomials.  The local library
   already has `IsPolyaFreqSeq.prod_X_sub_C`, `IsPFPolynomial` for a
   nonnegative linear factor, and multiplication closure, so the PF fact is
   largely present.  The useful new content is a convenient polynomial-level
   wrapper plus the coefficient identity needed by the Jacobi--Stirling
   specialization.

2. **First-kind Jacobi--Stirling rows (small/medium).**  Define the triangle by
   its recurrence or elementary-symmetric specialization.  For `z >= -1`,
   prove the product formula above, nonnegative coefficients, PF, real-rootedness,
   and non-positive roots.  Then derive the Legendre--Stirling specialization
   at `z = 0`.

3. **First/second-kind inverse algebra (medium).**  Define the second-kind
   triangle through complete homogeneous polynomials and prove the two
   recurrences and signed inverse relation.  This is valuable symmetric-function
   infrastructure even before any matrix-total-positivity theorem.

4. **Bidiagonal-recursion TNN theorem (medium/large).**  Formalize the `ell=1`
   case (paper Theorem 1.4) as a generic theorem for lower-triangular recursive
   arrays.  It would imply TNN of the Jacobi--Stirling and classical Stirling
   triangles.  This should reuse the existing `Matrix.IsTotallyNonneg` API and
   avoid introducing a paper-specific matrix framework prematurely.

5. **General weighted-path/LGV theorem (large).**  Theorems 1.3, 1.5, and 1.7
   require coefficientwise ordered polynomial rings, infinite matrices, planar
   directed networks, nonpermutable source/sink families, and LGV.  They are
   worthwhile only as a later foundational project.  Formalizing the paper's
   explicit row/column/ray Toeplitz conclusions directly would otherwise
   duplicate a substantial network development.

The first target fits the current `RealRooted` PF API.  Targets 2--3 would be a
clean application module.  Targets 4--5 should wait until ownership and API
direction for the existing total-nonnegative matrix work are settled.

## Local coverage checked

- `tex-source/polyaFrequency.tex` already contains the TNN/PF definitions,
  planar-path and Riordan-array criteria, and Delannoy/Stirling-adjacent
  examples, but it does not cite this paper or discuss Jacobi--Stirling rows.
- `tex-source/standardSymmetricFunctions.tex` defines the elementary and
  complete homogeneous bases but has no Jacobi--Stirling specialization.
- The bibliography has related total-positivity/Riordan references, but no
  entry matching arXiv:2308.05167.
- `RealRooted` already exposes `Matrix.IsTotallyNonneg`, `IsPolyaFreqSeq`,
  `IsPFPolynomial`, multiplication closure, and `MvPolynomial.esymm`, but no
  Jacobi--Stirling declarations were found.
