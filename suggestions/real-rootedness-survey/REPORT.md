# Real-rootedness coverage survey

**Editorial gap report for symmetricfunctions.com**

**Survey date:** 2026-09-09

**Scope:** source and live-site review only; no website changes are proposed as
already made.

## Executive summary

The site's core real-rootedness material is unusually strong. The main and
interlacing pages already cover Newton inequalities, classical root criteria,
Pólya--Schur theory, compatible/interlacing families, matrix and differential
criteria, and preservation operators. The specialized pages give substantial
coverage of Eulerian and Narayana families, straight-shape tableaux, matching and
claw-free independence polynomials, multivariate stability, Pólya-frequency
sequences, Lorentzian polynomials, gamma positivity, matroid Chow polynomials,
and several 2026 results. The most valuable work is therefore not a general
expansion of the overview. It is a focused set of theorem/status corrections at
existing junctions.

The urgent omission is a cutoff-sensitive one. The polytope page currently states
Xiao's fixed-row interlacing conjecture for the toric contribution polynomials
$g_{n,j}$ and gives the real-rootedness of nonnegative gamma-weighted sums only
conditionally. Alexandersson's 2026-09-04 preprint proves the entire fixed-row
sequence is interlacing, supplies the common interlacer
$g_{n,⌊n/2⌋}/t$,
and proves every nonzero nonnegative row sum real-rooted.[^1] This should be an
immediate status correction, not a new detached example.

The next editorial tier consists of results that fill whole missing bridges:

1. sparse-paving matroid $Z$-polynomials and their uniform-matroid
   interlacings;
2. the newly settled descent-derangement and super-Eulerian questions already
   adjacent to text on the words page;
3. noncrossing-partition Chow polynomials through tieless parking functions;
4. UMEL-shellable Chow/chain polynomials and rook-Eulerian polynomials, both of
   which connect the existing poset, matroid, rook, word, and stability pages;
5. the foundational barycentric-subdivision theorem and the newer local-$h$
   barycentric/edgewise results; and
6. the general large-lattice-width theorem for Ehrhart $h^*$-polynomials.

Two negative results deserve explicit treatment. Gal's original counterexamples
explain why gamma positivity was formulated as a weaker property than
real-rootedness, while Coron--Ferroni--Li now give flag chordal nestohedra whose
$h$-polynomials are gamma-positive but not real-rooted.[^12][^13] These are
particularly useful safeguards against the invalid implication
“gamma-positive $\Rightarrow$ real-rooted.”

Several apparently missing items are not gaps. Xiao's individual toric
$g$-contribution theorem, Guo--Kang's polytope realization theorem, generalized
snake order polytopes, thagomizer/$K_{2,n}$ matroid results, and the recent
type-$D$ correction are already in the checkout. The gamma-root criterion,
Lace/Hurwitz material, and Pitman--Stanley $h^*$-real-rootedness are present
locally but, according to the handoff, not yet deployed. They must not be added a
second time. Lorentzianity, log-concavity, gamma positivity, and Hurwitz stability
are also not substitutes for real-rootedness.

## Current coverage and gap taxonomy

### What is already covered well

- `tex-source/realRooted.tex` and `realRootedInterlacing.tex` provide the
  conceptual backbone, with a consistent weak interlacing convention that allows
  repeated roots.
- `realRootedWords.tex` covers ordinary/multiset/type $B,D$/$s$-Eulerian
  families, restricted descents, peaks and runs, classical excedance
  derangements, Stirling permutations, set partitions, and parking descents.
- `realRootedCatalan.tex` covers type $A$, type $B$, generalized, and
  Boolean Narayana polynomials, refined Dyck-path statistics, and Motzkin
  polynomials.
- `realRootedTableaux.tex` correctly separates straight-shape SYT descent
  real-rootedness from the open skew-shape problem, and separates Schur-Ehrhart
  numerator results from failure of real-rootedness for some skew Ehrhart
  polynomials.
- `realRootedGraphs.tex` covers matching, rook, claw-free independence,
  dependence, and Chow polynomials, including counterexamples and class
  restrictions.
- `stablePolynomials.tex`, `polyaFrequency.tex`, and
  `lorentzianPolynomials.tex` already distinguish multivariate stability,
  total positivity, and Lorentzianity. That separation should be preserved.

### Status meanings used below

- **Missing:** neither the result nor an equivalent theorem appears locally.
- **Partial:** the family or earlier theorem is present, but the new parameter
  range/status is absent.
- **Citation-only:** the source is cited for another result, without the relevant
  theorem being stated or cross-linked.
- **Undeployed:** the result is in the checkout but the live-site lag is recorded
  in `HANDOFF.md`; it is not a source gap.
- **Hold:** a potentially relevant item should not yet be inserted because its
  formulation or editorial fit is unsettled.

## Ranked direct omissions

### P0. Replace the toric fixed-row conjecture by the theorem

**Source-backed result.** Let $n\ge 2$, $m=\lfloor n/2\rfloor$, and let
$g_{n,j}(t)$ be the toric $g$-contribution polynomials in the normalization
already used on the polytope page. Then $g_{n,m}(t)/t$, of degree $m-1$,
weakly interlaces every $g_{n,j}(t)$, and

$$
  \bigl(g_{n,0}(t),g_{n,1}(t),\ldots,g_{n,m}(t)\bigr)
$$

is an interlacing sequence. Consequently every nonzero
$\sum_{j=0}^m\lambda_j g_{n,j}(t)$, with all $\lambda_j\ge0$, is
real-rooted. These are Theorem 8.1 and the discussion on pp. 10--14 of
Alexandersson.[^1] The paper explicitly notes that this proves Xiao's Conjecture
4.2 in the same oriented all-pairs convention. It also proves the stated
consequence for every simple polytope with nonnegative gamma-vector, and hence
the weak-ascent and strict-descent statements for weakly 123-avoiding parking
functions (Corollary 8.4, p. 14). Xiao's independent theorem remains the right
source for individual real-rootedness and the two adjacent-rank interlacings.[^2]

**Coverage gap.** `tex-source/polytopes.tex`, immediately after
`toricGContributionPolynomial`, still displays this fixed-row statement as
`conjecture` and phrases the simple-polytope consequence conditionally. No entry
for arXiv:2609.05131 is present in the bibliography.

**Editorial judgment.** This is the highest-value change because the page is now
factually stale at an existing conjecture. Preserve Xiao's theorem and
attribution, then replace only the conjecture/status paragraph.

**Destination.** `tex-source/polytopes.tex`, directly after the theorem labeled
by `toricGContributionPolynomial`; cross-link the consequence to
`gammaPositivity.tex#gammaPolynomial` and the parking-function application to
`realRootedWords.tex#parkingFunctionDescentsRealRooted`.

**Proposed insertion paragraph.**

> Alexandersson subsequently proved Xiao's fixed-row conjecture. If
> $m=\lfloor n/2\rfloor$ and $n\ge2$, then $g_{n,m}(t)/t$ weakly
> interlaces every $g_{n,j}(t)$, and
> $(g_{n,0},\ldots,g_{n,m})$ is an interlacing sequence. Thus every nonzero
> nonnegative linear combination of one row is real-rooted. In particular, the
> toric $g$-polynomial of every simple polytope with nonnegative gamma-vector
> is real-rooted [Alexandersson, Thm. 8.1 and Cor. 8.4].

### P1. Sparse-paving matroid $Z$-polynomials

**Source-backed result.** If $M$ is sparse paving, both its gamma polynomial
$\Gamma_M(x)$ and $Z$-polynomial $Z_M(x)$ have only negative real zeros
(Theorem 1.1, p. 2). For the uniform matroid $U_{m,d}$ of rank $d$ and
corank $m$, $Z_{U_{m,d}}$ strictly interlaces $Z_{U_{m,d+1}}$ for
$m,d\ge1$. The gamma polynomials have three stated strict comparisons:
fixed corank for $m,d\ge1$, fixed rank for $m\ge1,d\ge2$, and simultaneous
rank/corank increase for $m,d\ge1$ (Theorems 1.2--1.3, pp. 2--3).[^4]

**Coverage gap.** The matroid page already defines paving, sparse-paving, and
uniform matroids and discusses $Z$-polynomials, but its new real-rootedness
examples stop at thagomizer and $K_{2,n}$ graphic matroids. The 2026-09-07
paper is absent.

**Editorial judgment.** Add the class theorem first; the interlacing diagram is
worth one follow-up sentence because its rank/corank directions use definitions
already present and strengthen a major matroid conjecture for a large class.

**Destination.** `tex-source/matroids.tex`, in the Kazhdan--Lusztig/
$Z$-polynomial subsection, with a link from
`realRootedGraphs.tex#realRootsChow` only if that section is broadened to matroid
invariants.

**Proposed insertion paragraph.**

> Xie and Zhang prove that for every sparse-paving matroid $M$, both
> $Z_M(x)$ and its gamma polynomial $\Gamma_M(x)$ have only negative real
> zeros. Writing $U_{m,d}$ for the uniform matroid of corank $m$ and rank
> $d$, they also prove the strict interlacing
> $Z_{U_{m,d}}\prec Z_{U_{m,d+1}}$ for $m,d\ge1$, together with three
> corresponding rank/corank interlacings for the gamma polynomials [Thms.
> 1.1--1.3].

### P1. Update the derangement and super-Eulerian status

**Source-backed result.** Define the *descent* derangement polynomial

$$
  D_n(t)=\sum_{\pi\in\mathcal D_n}t^{\operatorname{des}(\pi)}.
$$

For every $n\ge2$, $D_n(t)$ has only nonpositive real zeros (Theorem 2.1,
p. 3). This is not the classical excedance derangement polynomial already
displayed on the site.[^3] In the same paper, for an integer $\ell\ge1$, define
$E^{(\ell)}_{1,0}=1$ and

$$
 E^{(\ell)}_{n,k}=(k+1)^\ell E^{(\ell)}_{n-1,k}
 +(n-k)^\ell E^{(\ell)}_{n-1,k-1}.
$$

Then $E_n^{(\ell)}(t)=\sum_k E^{(\ell)}_{n,k}t^k$ has only nonpositive real
zeros, $E_n^{(\ell)}\preceq E_{n+1}^{(\ell)}$, and its gamma polynomial is
real-rooted with nonnegative coefficients (Theorem 5.1, pp. 12--14).[^3]

**Coverage gap.** `realRootedWords.tex#peakRunDerangementPolynomials` proves
real-rootedness for the excedance normalization, but not the descent
normalization. Its Shankar paragraph explicitly says gamma-nonnegativity and
real-rootedness are questions. Thus one omission is a new family and the other is
an obsolete open-status statement.

**Editorial judgment.** Insert both in the existing locations, carefully naming
the statistic. The super-Eulerian theorem also belongs in the gamma examples;
do not describe gamma-positive alone as the reason for real-rootedness.

**Destinations.** `tex-source/realRootedWords.tex`, the Shankar example and the
derangement subsection; one cross-link from
`gammaPositivity.tex#gammaPositiveExamples`.

**Proposed insertion paragraphs.**

> The descent distribution on derangements is different from the classical
> excedance derangement polynomial above. Alexandersson proves that
> $D_n(t)=\sum_{\pi\in\mathcal D_n}t^{\operatorname{des}(\pi)}$ has only
> nonpositive real zeros for every $n\ge2$, settling the derangement part of
> the Fu--Lin--Zeng conjecture [Thm. 2.1].

> The real-rootedness question for Shankar's $r=1$ super-Eulerian rows is now
> settled: for every integer $\ell\ge1$, $E_n^{(\ell)}(t)$ has only
> nonpositive real zeros and weakly interlaces $E_{n+1}^{(\ell)}(t)$. Its
> gamma polynomial is itself real-rooted with nonnegative coefficients [Thm.
> 5.1].

### P1. Noncrossing Chow polynomials through Smirnov words

**Source-backed result.** For every $n\ge1$, the Chow polynomial of the
noncrossing partition lattice $NC_{n+1}$ is real-rooted (Theorem 1.1, pp.
1, 5). The exact transfer is

$$
 H_{NC_{n+1}}(t)=\frac1{n+1}
   \sum_{w\in\operatorname{Smir}_{n,n+1}}t^{\operatorname{des}(w)},
$$

where adjacent letters of a Smirnov word differ. At fixed word length $r\ge1$
and alphabet size $m\ge2$, the last-letter refinements form an interlacing
sequence (Theorem 4.2, p. 5).[^1]

**Coverage gap.** The words page has ordinary parking-function descents via all
words, and the graph page has general Chow results for positive-$h$ simplicial
posets and several geometric lattices. Neither states the noncrossing-lattice
theorem or the tieless/Smirnov normalization.

**Editorial judgment.** This belongs primarily with Chow polynomials, with a
short reciprocal cross-link from parking functions. It is more valuable than
adding several isolated 2026 word families because it connects three established
site topics.

**Destination.** `tex-source/realRootedGraphs.tex#realRootsChow`; cross-link
`tex-source/realRootedWords.tex#parkingFunctionDescentsRealRooted` and the
noncrossing-partition page.

**Proposed insertion paragraph.**

> The Chow polynomial of the noncrossing partition lattice is also
> real-rooted. More precisely,
> $H_{NC_{n+1}}(t)=\frac1{n+1}\sum_{w\in\operatorname{Smir}_{n,n+1}}
> t^{\operatorname{des}(w)}$, and the refinements by final letter form an
> interlacing sequence for every alphabet size at least two. This Smirnov-word
> transfer proves real-rootedness for all $n\ge1$ [Alexandersson, Thms. 1.1
> and 4.2].

### P1. UMEL-shellable Chow, augmented Chow, and chain polynomials

**Source-backed result.** For a UMEL-shellable poset $P$, its Chow and
augmented Chow polynomials have only real nonpositive roots (Theorem 1.2, p. 3),
and the $h$-polynomial of its order complex—equivalently the corresponding
chain polynomial under the standard change of variables—also has only real
nonpositive roots (Theorem 1.5, p. 5). The specialization includes uniform
matroids, projective and affine geometries, type $A$ and $B$ braid matroids,
Dowling geometries, rank-uniform supersolvable geometric lattices, and stated
rank selections (Theorem 1.8, p. 6).[^5]

**Coverage gap.** The Chow section currently covers maximally ranked/TN-style
families and positive-$h$ simplicial posets. It cites a different Brändén--Leite
theorem for perfect matroid designs, Dowling lattices, and paving-containing
classes. It does not name UMEL-shellability or state the simultaneous Chow,
augmented-Chow, and chain conclusion.

**Editorial judgment.** Add one compact class theorem rather than enumerating
overlapping special cases in separate pages. The simultaneous conclusion is the
reason this merits P1 placement.

**Destinations.** `tex-source/realRootedGraphs.tex#realRootsChow` and
`tex-source/matroids.tex#matroidChowPolynomials`; cross-link
`tex-source/coxeterGroups.tex` for braid/Dowling examples.

**Proposed insertion paragraph.**

> Coron, Ferroni, and Li introduce UMEL-shellable posets and prove that their
> Chow polynomials, augmented Chow polynomials, and order-complex
> $h$-polynomials all have only real nonpositive zeros. The class contains
> uniform matroids, projective and affine geometries, type $A$ and $B$ braid
> matroids, Dowling geometries, and rank-uniform supersolvable geometric
> lattices, together with the rank selections specified in their theorem
> [Thms. 1.2, 1.5, and 1.8].

### P1. Rook-Eulerian polynomials and their same-phase refinement

**Source-backed result.** Let $\lambda=(\lambda_1,\ldots,\lambda_n)$ be a
Ferrers board with $\lambda_i\ge i$, and let $Q_\lambda(t)$ enumerate
row-complete nonattacking rook placements by ascents. The refinements
$Q^\lambda_i(t)$ by the first-row column form an interlacing sequence, so
$Q_\lambda(t)$ is real-rooted (Theorem 12, p. 7). The multivariate ascent-set
enumerator is *same-phase stable* (Theorem 13, p. 8), not claimed stable in the
full multivariate sense.[^6] For a complete placement, the objects form the lower
Bruhat interval below the associated 312-avoiding permutation.

**Coverage gap.** The site covers classical rook polynomials and Ferrers hit
polynomials but contains neither “rook-Eulerian” nor this Bruhat-interval family.
The source is also absent from the bibliography.

**Editorial judgment.** This is an unusually efficient cross-link: it joins
Ferrers boards, Eulerian statistics, Bruhat order, interlacing matrices, and the
site's same-phase-stability definition.

**Destinations.** Main statement in `tex-source/realRootedWords.tex`; links to
`realRootedGraphs.tex` rook material, `permutations.tex#bruhatOrder`, and
`stablePolynomials.tex`.

**Proposed insertion paragraph.**

> For a Ferrers board $\lambda$ with $\lambda_i\ge i$, let
> $Q_\lambda(t)$ enumerate row-complete rook placements by ascents. The
> refinements by the column occupied in the first row form an interlacing
> sequence, so $Q_\lambda(t)$ is real-rooted. The ascent-set refinement is
> same-phase stable [Alexandersson--Jal--Quemener, Thms. 12--13]. In the
> complete-placement case these placements form a lower Bruhat interval below
> a 312-avoiding permutation.

### P1. Barycentric and local-$h$ subdivision theorems

**Source-backed results.** Brenti and Welker prove that if $\Delta$ is a
$(d-1)$-dimensional Boolean cell complex with nonnegative $h$-vector, then
$h_{\operatorname{sd}(\Delta)}(t)$ has only simple real zeros (Theorem 3.1,
p. 7).[^7] Athanasiadis proves the local counterpart: for every triangulation
$\Gamma$ of the $(n-1)$-simplex, the local $h$-polynomial of
$\operatorname{sd}(\Gamma)$ is real-rooted and interlaced by the Eulerian
polynomial $A_n$ (Theorem 1.2, p. 2). The same holds for every iterated
barycentric subdivision (Corollary 1.3). For the $r$-fold edgewise subdivision,
the local $h$-polynomial is real-rooted and interlaced by the appropriate word
descent polynomial when $r\ge n$ (Theorem 1.4, pp. 2--3); the paper explicitly
shows that this bound cannot be removed.[^8]

**Coverage gap.** Neither “barycentric subdivision” nor a local-$h$ theorem
appears in the real-rootedness/polytope source cluster. The bibliography has a
different paper title mentioning local $h$-polynomials but lacks these two
primary sources.

**Editorial judgment.** These are foundational geometric-combinatorics results,
not merely extra examples. They deserve a small new subsection on the polytope
page, with a method link to interlacing and a Catalan/word link for the edgewise
descent polynomial.

**Destination.** `tex-source/polytopes.tex`, a new subsection immediately before
the Ehrhart section or within face $h$-polynomials; cross-links to
`realRooted.tex#posetRealRooted`, `realRootedInterlacing.tex`, and
`realRootedWords.tex`.

**Proposed insertion paragraph.**

> Barycentric subdivision is a general source of real-rooted face
> polynomials. Brenti and Welker prove that if a Boolean cell complex has a
> nonnegative $h$-vector, then the $h$-polynomial of its barycentric
> subdivision has only simple real zeros. Athanasiadis proves the local
> analogue: the local $h$-polynomial of the barycentric subdivision of any
> triangulation of an $(n-1)$-simplex is real-rooted and interlaced by $A_n$.
> For the $r$-fold edgewise subdivision the corresponding assertion holds for
> $r\ge n$, and this restriction is essential [Thms. 1.2 and 1.4].

### P1. Large lattice width forces Ehrhart $h^*$-real-rootedness

**Source-backed result.** For every fixed $d\ge1$, a constant $C_d>0$
exists such that every $d$-dimensional lattice polytope of lattice width greater
than $C_d$ has an $h^*$-polynomial with positive coefficients and $d$
distinct negative real roots (Theorem 1.1, p. 1). For $d$-dimensional lattice
simplices, another threshold $C_d^\square$ gives a local $h^*$ (box)
polynomial with positive nonconstant coefficients, a simple root at zero, and
$d-1$ distinct negative roots (Theorem 1.2, pp. 1--2).[^9] The thresholds are
existential, not explicit useful bounds.

**Coverage gap.** The Ehrhart page has numerous family-specific
$h^*$-real-rootedness results and magic-positivity criteria, but no
dimension-fixed large-width theorem and no Nill entry.

**Editorial judgment.** Add the global theorem, because it reorganizes the
examples around a geometric sufficient condition. Include the simplex-only
qualification for the local statement and do not suggest large width implies
IDP; the paper explicitly notes it does not.

**Destination.** `tex-source/polytopes.tex#ehrhartPolytopes`, near general
$h^*$-criteria and before family examples.

**Proposed insertion paragraph.**

> Nill proves a dimension-fixed large-width theorem: for every $d$ there is
> $C_d>0$ such that the $h^*$-polynomial of every $d$-dimensional lattice
> polytope of lattice width greater than $C_d$ has positive coefficients and
> $d$ distinct negative roots. For lattice simplices, an analogous threshold
> makes the local $h^*$-polynomial have a simple root at zero and $d-1$
> distinct negative roots [Thms. 1.1--1.2]. The constants are not presented as
> sharp bounds, and large width does not imply the integer-decomposition
> property.

### P1. Complete the colored-multiset parameter range

**Source-backed result.** For positive integer vectors
$\mathbf m,\mathbf r$, Yan defines the existing descent enumerator
$A_{\mathbf m}^{\mathbf r}(x)$ and a sentinel ascent analogue
$S_{\mathbf m}^{\mathbf r}(x)$. Both are real-rooted for *all* positive
parameters. If $\mathbf m+\mathbf e_j$ increases one multiplicity, then
$S_{\mathbf m}^{\mathbf r}\preceq S_{\mathbf m+\mathbf e_j}^{\mathbf r}$ and
$A_{\mathbf m}^{\mathbf r}\preceq A_{\mathbf m+\mathbf e_j}^{\mathbf r}$
(Theorems 1.4--1.5, p. 4). Self-interlacing of the new ascent polynomial under
$r_j\ge m_j+1$ is Theorem 1.3, p. 3.[^10]

**Coverage gap.** The words page currently reports the earlier
Deligeorgaki--Han--Solus sufficient conditions for self-interlacing. It does not
state all-parameter real-rootedness, the componentwise interlacing, or the ascent
variant. The existing paragraph should be extended, not replaced.

**Editorial judgment.** The all-parameter statement is the important update.
The polyhedral interpretations—closed products of dilated simplices for $A$,
half-open products for $S$—justify one cross-link to Ehrhart theory.

**Destination.** `tex-source/realRootedWords.tex`, immediately after the colored
multiset paragraph; cross-link `tex-source/polytopes.tex#ehrhartPolytopes`.

**Proposed insertion paragraph.**

> Yan later proved real-rootedness without the self-interlacing parameter
> restriction. For all positive integer multiplicity and color vectors
> $\mathbf m,\mathbf r$, both the colored-multiset descent polynomial
> $A_{\mathbf m}^{\mathbf r}$ and its sentinel ascent analogue
> $S_{\mathbf m}^{\mathbf r}$ are real-rooted. Increasing one component of
> $\mathbf m$ gives a weak interlacing in each family [Thms. 1.4--1.5]. The
> two families are $h^*$-polynomials of closed and half-open products of
> dilated simplices, respectively.

### P1. The graph $\tau$-polynomial under joins

**Source-backed result.** For an $n$-vertex simple graph $G$, define
$c_i(G)$ by

$$
 \chi_G(x)=\sum_{i=0}^n(-1)^{n-i}c_i(G)
   \langle x\rangle_i,
 \qquad \langle x\rangle_i=x(x+1)\cdots(x+i-1),
$$

and $\tau_G(x)=\sum_i c_i(G)x^i$. If vertex-disjoint simple graphs $G,H$
both have real-rooted $\tau$-polynomials, then so does their graph join
$G\vee H$ (Theorem 1.1, p. 2). The underlying star-product theorem preserves
roots in $(-\infty,0]$ for nonzero real-rooted inputs divisible by $x$
(Theorem 1.2).[^11]

**Coverage gap.** The graph and chromatic pages contain no $\tau$-polynomial
definition or join theorem. This resolves a Brenti--Royle--Wagner conjecture from
1994 and is not implied by ordinary chromatic-root behavior.

**Editorial judgment.** Add the normalization explicitly; without it “the
$\tau$-polynomial” is opaque. The result belongs on the graph page with a
chromatic cross-link.

**Destination.** `tex-source/realRootedGraphs.tex`, a short graph-operations
example; cross-link `tex-source/chromaticQuasisymmetric.tex#chromaticPolynomial`.

**Proposed insertion paragraph.**

> Expanding the chromatic polynomial in rising factorials as
> $\chi_G(x)=\sum_i(-1)^{n-i}c_i(G)\langle x\rangle_i$, define
> $\tau_G(x)=\sum_i c_i(G)x^i$. Kang, Liu, Sun, and Zhang prove that if
> vertex-disjoint simple graphs $G$ and $H$ have real-rooted
> $\tau$-polynomials, then the join $G\vee H$ does as well, settling a 1994
> conjecture of Brenti, Royle, and Wagner [Thms. 1.1--1.2].

### P1. Record the sharp boundary between gamma positivity and real roots

**Source-backed results.** For a matroid $M$ of rank at most $6$, the Chow
polynomial with the maximal building set is real-rooted (Corollary 1.10, p. 7).[^12]
In contrast, Coron--Ferroni--Li construct a complete and flag building set on the
Boolean lattice $B_7$ with Chow polynomial

$$
  1+13t+48t^2+73t^3+48t^4+13t^5+t^6,
$$

which has four nonreal roots. Multiplication by powers of $1+t$ yields examples
in every dimension at least $6$; equivalently, there are flag chordal
nestohedra of every such dimension with non-real-rooted $h$-polynomial
(Example 9.5 and Theorem 9.6, pp. 49--50).[^12] These objects lie in classes for
which the same paper proves gamma positivity, so the example directly separates
the two notions.

**Coverage gap.** The gamma page has a different 2026 symmetric-edge-polytope
gamma counterexample, while the matroid Chow section does not state the rank-six
positive theorem or the arbitrary-building-set counterexample.

**Editorial judgment.** Pair the positive and negative statements. The contrast
prevents readers from overgeneralizing maximal-building-set results and gives a
concrete example for the corrected gamma-root criterion already in the local
checkout.

**Destinations.** Positive bound in
`tex-source/matroids.tex#matroidChowPolynomials`; counterexample in
`tex-source/gammaPositivity.tex#galConjecture`, with a return link to matroids.

**Proposed insertion paragraph.**

> Building-set hypotheses matter for real-rootedness. With the maximal building
> set, the Chow polynomial of every matroid of rank at most $6$ is
> real-rooted. On the other hand, Coron--Ferroni--Li construct a complete and
> flag building set on $B_7$ whose Chow polynomial is
> $1+13t+48t^2+73t^3+48t^4+13t^5+t^6$ and has nonreal zeros. Their
> construction gives flag chordal nestohedra with non-real-rooted
> $h$-polynomials in every dimension at least $6$ [Cor. 1.10; Ex. 9.5 and
> Thm. 9.6].

## P2 direct additions

### Flow-polynomial classification and planar chromatic corollary

**Source-backed result.** For a connected bridgeless finite graph, allowing
loops and parallel edges, the flow polynomial is real-rooted if and only if all
its roots are integral, if and only if the graph is the dual of a chordal plane
graph. Every root then lies in $\{1,2,3\}$ (Theorem 6, p. 3). Consequently a
loopless planar graph has only real chromatic roots exactly when it is chordal,
and those roots lie in $\{0,1,2,3\}$ (Corollary 7, pp. 3--4).[^17]

**Coverage gap and judgment.** No flow-polynomial theorem appears locally. This
is a clean classification and worthwhile graph-page addition, but ranks below
the join and Chow results because the site has no developed flow-polynomial
section.

**Destination.** `tex-source/realRootedGraphs.tex`; cross-link the chromatic
corollary to `chromaticQuasisymmetric.tex#chromaticPolynomial`.

**Proposed insertion paragraph.**

> Zhang and Dong classify real-rooted flow polynomials: a connected bridgeless
> graph has only real flow roots if and only if it is the dual of a chordal
> plane graph, and then every root is one of $1,2,3$. Dually, a loopless
> planar graph has only real chromatic roots if and only if it is chordal; its
> chromatic roots lie in $\{0,1,2,3\}$ [Thm. 6 and Cor. 7].

### Boolean--Eulerian polynomials

**Source-backed result.** If
$B_n(u)=\sum_{\pi\in S_n}2^{\operatorname{pk}(\pi)}
u^{\operatorname{des}(\pi)}$, equivalently the right-edge enumerator of
bicolored decreasing binary trees, then for $n\ge2$ it has $n-1$ simple
negative roots (Theorem 5.6), and the roots of $B_{n-1}$ strictly interlace
those of $B_n$ for $n\ge3$ (Corollary 5.8).[^18]

**Coverage gap and judgment.** The Catalan page contains Boolean--Narayana
polynomials, but no labeled Boolean--Eulerian analogue. A compact insertion is
valuable mainly because it completes that existing analogy.

**Destination.** `tex-source/realRootedWords.tex`, after ordinary Eulerian or
peak polynomials; cross-link
`realRootedCatalan.tex#booleanNarayanaNumberDefinition`.

**Proposed insertion paragraph.**

> The Boolean--Eulerian polynomial
> $B_n(u)=\sum_{\pi\in S_n}2^{\operatorname{pk}(\pi)}u^{\operatorname{des}(\pi)}$
> is the labeled analogue of the Boolean--Narayana family. For $n\ge2$ it
> has $n-1$ simple negative roots, and $B_{n-1}$ strictly interlaces
> $B_n$ for $n\ge3$ [Bóna--Vatter, Thm. 5.6 and Cor. 5.8].

### Chain polynomials of rank-selected and noncrossing posets

**Source-backed result.** Rank-selected subposets of Cohen--Macaulay simplicial
posets have real-rooted chain polynomials, as do the noncrossing partition
lattices $NC_W$ of all finite Coxeter groups (Theorems 1.2--1.3).[^14] The
latest arXiv version is v3 (2025-11-30), correcting notation typos in the proof
of Lemma 5.3; the published result is EJC 31 (2024), P4.16. Earlier work proves
the conjecture for subspace lattices, ordinary and type $B$ partition lattices,
and preserves it under pyramid/prism operations on bounded Cohen--Macaulay
posets.[^15]

**Coverage gap and judgment.** The newer paper is citation-only on the words
page for a descent specialization, while the graph page jumps from the general
geometric-lattice conjecture to later subclasses. One short historical paragraph
would make that progression intelligible; avoid duplicating all older special
cases once the UMEL theorem is added.

**Destination.** `tex-source/realRooted.tex#posetRealRooted` or the graph-page
chain paragraph; cross-links to `coxeterGroups.tex` and the noncrossing pages.

**Proposed insertion paragraph.**

> Important cases of the chain-polynomial conjecture are known.
> Athanasiadis, Douvropoulos, and Kalampogia-Evangelinou prove real-rootedness
> for every rank-selected subposet of a Cohen--Macaulay simplicial poset and
> for $NC_W$ for every finite Coxeter group $W$ [Thms. 1.2--1.3]. Earlier
> work covers ordinary, type $B$, and subspace partition lattices and shows
> that pyramid and prism operations preserve the property.

### State the finite-Coxeter Eulerian synthesis

**Source-backed result.** Savage and Visontai prove that the $s$-Eulerian
polynomial is real-rooted for every positive integer sequence $s$ (Theorem
1.1) and use their refinement to prove the type $D$ Eulerian theorem (Theorem
3.15), completing Brenti's conjecture that the Eulerian polynomial of every
finite Coxeter group is real-rooted.[^16]

**Coverage gap and judgment.** The words page already contains the necessary
type $A$, $B$, $D$, and $s$-Eulerian pieces. The gap is synthesis and a
cross-link, not another proof. Do not say all roots are simple: at the small type
$D$ boundary repeated roots occur.

**Destination.** One sentence in `tex-source/realRootedWords.tex` after the type
$D$ discussion, linked from `tex-source/coxeterGroups.tex`.

**Proposed insertion paragraph.**

> Together with the classical and exceptional cases, the type $D$ theorem
> completes Brenti's conjecture: the Eulerian polynomial of every finite
> Coxeter group has only real zeros [Savage--Visontai, Thm. 3.15]. This is a
> theorem of real-rootedness, not a blanket assertion of simple roots in every
> small rank.

### Explain the historical role of Gal's counterexample

**Source-backed result.** Gal constructs convex flag triangulations of spheres
of every dimension at least $5$ whose $h$-polynomials are not real-rooted,
while proving the real-root conjecture in dimensions below $5$ (Theorem 3.1.3
and Corollary 3.3.4). He then formulates gamma nonnegativity as the weaker
conjecture that could survive.[^13]

**Coverage gap and judgment.** The gamma page cites Gal for the gamma conjecture
and an equivalent-root criterion but does not state the counterexample that
motivates the weaker property. This is a citation-only conceptual gap. It should
be paired with the newer nestohedral example above and kept brief.

**Destination.** `tex-source/gammaPositivity.tex#galConjecture`.

**Proposed insertion paragraph.**

> Gamma positivity was proposed as a weaker replacement for a false
> real-root conjecture. Gal constructed convex flag sphere triangulations in
> every dimension at least $5$ whose $h$-polynomials are not real-rooted,
> while proving that no such failure occurs below dimension $5$. Thus Gal's
> conjecture should not be read as predicting real-rootedness.

## Lower-priority material from the 2026-09-07 Eulerian paper

If the editor wants a single “recent Eulerian families” paragraph after making
the two status corrections above, three further exact statements can be added
without creating separate subsections:[^3]

- The cyclic-descent polynomial of northeast paths from $(0,0)$ to $(n,n)$,
  $C_n(t)=2\sum_{k=1}^n\binom nk\binom{n-1}{k-1}t^k$, has one simple zero
  at $0$ and $n-1$ simple negative zeros (Theorem 3.1, p. 10).
- The polynomial counting descents with even top in $S_N$ has only simple
  negative roots for $N\ge2$, and consecutive rows strictly interlace
  (Theorem 4.1, p. 11). Earlier Ferrers-hit results already imply rowwise
  real-rootedness; strict consecutive interlacing is the new part.
- Ternary words counted by strictly increasing runs have real-rooted row
  polynomials with consecutive weak interlacing (Theorem 6.1, p. 14).
- The peak-value multivariate enumerator is stable; for every positive weight
  sequence, its consecutive diagonal specializations interlace (Theorem 6.3,
  p. 15). This last item should link to the stable-polynomial page and must keep
  “stable” separate from the univariate diagonal consequence.

**Proposed insertion paragraph.**

> Further families in the same paper include cyclic descents of balanced
> northeast paths (one simple zero at $0$, all others simple and negative),
> even-top descents (simple negative roots with consecutive strict
> interlacing), and ternary words by increasing runs (consecutive weak
> interlacing). The multivariate peak-value enumerator is stable, and all of
> its positive weighted consecutive diagonal specializations interlace [Thms.
> 3.1, 4.1, 6.1, and 6.3].

## Adjacent topic, clearly separated

### Poincaré polynomials of $\overline{\mathcal M}_{0,n}$

This is the one adjacent topic with enough connective value to recommend. For

$$
 P_n(t)=\sum_{i=0}^{n-3}\dim H^{2i}
   (\overline{\mathcal M}_{0,n};\mathbb Q)t^i,
$$

$P_n$ has $n-3$ simple negative roots for $n\ge4$, and the roots of
$P_n$ and $P_{n+1}$ strictly interlace in the explicitly stated alternating
order (Theorems 1.1--1.2, pp. 2--3). The Poincaré polynomial of the
Fulton--MacPherson space $\mathbb P^1[n]$ also has only negative real roots
(Theorem 5.1, p. 16).[^19]

The site has no moduli-space section, so this should not be forced into the main
real-rootedness taxonomy. If included, it belongs in `tex-source/varieties.tex`,
with a cross-link to the matroid-Chow discussion because
$\overline{\mathcal M}_{0,n+1}$ is the wonderful compactification for the braid
arrangement with the minimal building set.

**Proposed insertion paragraph.**

> The half-degree Poincaré polynomial of
> $\overline{\mathcal M}_{0,n}$ has $n-3$ simple negative roots for
> $n\ge4$, and consecutive polynomials strictly interlace. Bérczi and Kiem
> prove the same real-rootedness phenomenon for the Fulton--MacPherson spaces
> $\mathbb P^1[n]$ [Thms. 1.1--1.2 and 5.1]. The first family also connects
> to Chow rings of the braid arrangement with its minimal building set.

## Cross-link plan

These links carry more editorial value than adding isolated bibliography entries:

| From | To | Reason |
|---|---|---|
| `polytopes.tex#toricGContributionPolynomial` | `gammaPositivity.tex#gammaPolynomial` | The nonnegative row coefficients are the polytope gamma-vector. |
| Toric $g$ fixed-row theorem | parking-function section | Corollary 8.4 identifies concrete weakly 123-avoiding parking statistics. |
| `realRootedGraphs.tex#realRootsChow` | noncrossing partitions and parking functions | The Chow polynomial is the tieless-parking/Smirnov descent polynomial. |
| UMEL theorem | `matroids.tex#matroidChowPolynomials` and `coxeterGroups.tex` | Its named families are already defined there. |
| Rook-Eulerian result | rook polynomials, Bruhat order, and stable polynomials | It uses all three viewpoints, with same-phase rather than full stability. |
| Subdivision subsection | interlacing and Eulerian word polynomials | The local $h$ theorems specify common interlacers. |
| Colored-multiset update | Ehrhart $h^*$ section | The two variants are closed and half-open polytope numerators. |
| Graph $\tau$ and flow results | `chromaticQuasisymmetric.tex#chromaticPolynomial` | Both start from chromatic/flow polynomial normalizations, not independence polynomials. |
| Γ counterexamples | matroid Chow and polytope pages | They enforce the correct non-implication between gamma positivity and real-rootedness. |
| Finite Coxeter Eulerian sentence | `coxeterGroups.tex` | The specialized word-page results jointly settle a group-wide statement. |

## Uncertain and future-check items

### Hold arXiv:2609.06096v1 pending correction

The preprint on $h^*$-polynomials of $(132,213)$-avoiding permutation
polytopes states exact real-rootedness verification through $d=1000$ and an
eventual theorem for $d\ge272$, which together cover all $d$. Yet the same
introduction says an “intervening” range $1001\le d<d_0$, with $d_0=272$,
remains open.[^20] The displayed range is empty and reverses the apparent
intended inequality. This may be a typographical error, but the scope of the
proved uniform statement is not editorially safe to paraphrase from v1. Wait for
a corrected version or author clarification; do not reproduce the theorem now.

### Do not call the coordinator pattern classical interlacing

Liu and Ma locate all roots of the type $C_n$ and $D_n$ coordinator
polynomials and prove an alternating “second pattern” with parity-dependent
equalities at (-1). They explicitly distinguish it from classical
interlacing.[^21] The result is verified, but the site does not otherwise develop
coordinator polynomials and its interlacing page fixes a different standard
degree-sensitive convention. Hold it for a future coordinator-polynomial page,
or describe the inequalities verbatim without the unqualified word
“interlaces.”

### Other screened nonrecommendations

- The 2026 spider independence-polynomial result is Hurwitz stability, not
  real-rootedness; it should not be presented as a direct omission.
- Rectangle-tiling and generalized-Petersen independence examples are valid but
  have lower connective value than the graph/rook/Chow gaps above.
- No verified resolution of the skew-standard-tableau descent-polynomial
  problem was found by the cutoff. The current “open” label should remain.
- Lorentzian basis-generating polynomials of matroids and rook matroids support
  ultra-log-concavity. They do not by themselves prove univariate
  real-rootedness or multivariate stability, and the current site correctly
  keeps those implications separate.

## Local-but-undeployed material: do not duplicate

According to the opening and dated sections of `HANDOFF.md`, the following are
already in the checkout but not all are on the live site:

- the corrected palindromic gamma criterion, including the requirement that the
  gamma roots be nonpositive;
- Lace/Hurwitz matrix criteria and the distinction between Hurwitz stability and
  real-rootedness;
- marked-order and skew Gelfand--Tsetlin corrections;
- Pitman--Stanley $h^*$-real-rootedness through magic positivity;
- recent stability and interlacing refinements recorded in the September 3--8
  handoffs.

Editorial work should deploy or finish those existing changes separately. None
is a recommendation to insert duplicate source text.

## Sources

[^1]: Per Alexandersson, “Parking functions, Smirnov words, and noncrossing Chow polynomials,” arXiv:2609.05131v1, submitted 2026-09-04, especially Theorems 1.1, 4.2, 8.1 and Corollaries 8.2, 8.4. [arXiv](https://arxiv.org/abs/2609.05131v1)

[^2]: Qiongqiong Xiao, “The real-rootedness of the toric $g$-contribution polynomials,” arXiv:2609.01086v1, submitted 2026-09-01, Theorem 1.3 and Conjecture 4.2. [arXiv](https://arxiv.org/abs/2609.01086v1)

[^3]: Per Alexandersson, “Real-rooted Eulerian polynomials from permutations, words, and paths,” arXiv:2609.07325v1, submitted 2026-09-07, Theorems 2.1, 3.1, 4.1, 5.1, 6.1, and 6.3. [arXiv](https://arxiv.org/abs/2609.07325v1)

[^4]: Matthew H. Y. Xie and Philip B. Zhang, “Real-rootedness of the $Z$-polynomials of sparse paving matroids and strict interlacing for uniform matroids,” arXiv:2609.07636v1, submitted 2026-09-07, Theorems 1.1--1.3. [arXiv](https://arxiv.org/abs/2609.07636v1)

[^5]: Basile Coron, Luis Ferroni, and Shiyue Li, “Chow polynomials of rank-uniform labeled posets,” arXiv:2511.13819v2, revised 2025-12-18, Theorems 1.2, 1.5, 1.8; v2 adds an expanded interlacing theorem. [arXiv](https://arxiv.org/abs/2511.13819v2)

[^6]: Per Alexandersson, Aryaman Jal, and Maena Quemener, “Real-rootedness of rook-Eulerian polynomials,” arXiv:2502.05939v1, submitted 2025-02-09, Theorems 12--13. [arXiv](https://arxiv.org/abs/2502.05939v1)

[^7]: Francesco Brenti and Volkmar Welker, “$f$-Vectors of barycentric subdivisions,” *Mathematische Zeitschrift* 259 (2008), 849--865, Theorem 3.1. DOI: [10.1007/s00209-007-0251-z](https://doi.org/10.1007/s00209-007-0251-z); [arXiv:math/0606356v1](https://arxiv.org/abs/math/0606356v1).

[^8]: Christos A. Athanasiadis, “Local $h$-polynomials, uniform triangulations and real-rootedness,” *Combinatorica* 45 (2025), article 36, Theorems 1.2, 1.4 and Example 5.2. DOI: [10.1007/s00493-025-00162-2](https://doi.org/10.1007/s00493-025-00162-2); [arXiv:2402.06219v2](https://arxiv.org/abs/2402.06219v2).

[^9]: Benjamin Nill, “Lattice polytopes of large width have real-rooted Ehrhart $h^*$-polynomials,” arXiv:2608.03635v1, submitted 2026-08-04, Theorems 1.1--1.2. [arXiv](https://arxiv.org/abs/2608.03635v1)

[^10]: Xue Yan, “Variations of colored multiset Eulerian polynomials and applications,” arXiv:2608.15682v2, revised 2026-08-20, Theorems 1.3--1.5. [arXiv](https://arxiv.org/abs/2608.15682v2)

[^11]: Mingyang Kang, Zhixin Liu, Sophie C. C. Sun, and Philip B. Zhang, “Real-rootedness of the $\tau$-polynomial under graph joins,” arXiv:2609.07457v1, submitted 2026-09-07, Theorems 1.1--1.2. [arXiv](https://arxiv.org/abs/2609.07457v1)

[^12]: Basile Coron, Luis Ferroni, and Shiyue Li, “Matroid analogues of Gal's conjecture,” arXiv:2604.04550v3, revised 2026-07-10, Corollary 1.10, Theorem 1.12, Example 9.5 and Theorem 9.6. Version 3 adds the counterexamples that earlier versions left open. [arXiv](https://arxiv.org/abs/2604.04550v3)

[^13]: Światosław R. Gal, “Real root conjecture fails for five and higher dimensional spheres,” *Discrete & Computational Geometry* 34 (2005), 269--284, Theorem 3.1.3 and Corollary 3.3.4. DOI: [10.1007/s00454-005-1171-5](https://doi.org/10.1007/s00454-005-1171-5); [arXiv:math/0501046v1](https://arxiv.org/abs/math/0501046v1).

[^14]: Christos A. Athanasiadis, Theo Douvropoulos, and Katerina Kalampogia-Evangelinou, “Two classes of posets with real-rooted chain polynomials,” *Electronic Journal of Combinatorics* 31(4) (2024), P4.16, Theorems 1.2--1.3. DOI: [10.37236/12218](https://doi.org/10.37236/12218); latest [arXiv:2307.04839v3](https://arxiv.org/abs/2307.04839v3), revised 2025-11-30 to correct notation typos in Lemma 5.3.

[^15]: Christos A. Athanasiadis and Katerina Kalampogia-Evangelinou, “Chain enumeration, partition lattices and polynomials with only real roots,” *Combinatorial Theory* 3(1) (2023), Theorems 1.3--1.4. DOI: [10.5070/C63160425](https://doi.org/10.5070/C63160425); [arXiv:2205.03796v2](https://arxiv.org/abs/2205.03796v2).

[^16]: Carla D. Savage and Mirkó Visontai, “The $s$-Eulerian polynomials have only real roots,” *Transactions of the American Mathematical Society* 367 (2015), 1441--1466, Theorems 1.1 and 3.15; latest [arXiv:1208.3831v3](https://arxiv.org/abs/1208.3831v3).

[^17]: Meiqiao Zhang and Fengming Dong, “Real-rooted flow polynomials have only integral roots,” arXiv:2608.19780v2, revised 2026-08-29, Theorem 6 and Corollary 7. [arXiv](https://arxiv.org/abs/2608.19780v2)

[^18]: Miklós Bóna and Vincent Vatter, “Boolean--Eulerian numbers,” arXiv:2605.15415v1, submitted 2026-05-14, Theorem 5.6 and Corollary 5.8. [arXiv](https://arxiv.org/abs/2605.15415v1)

[^19]: Gergely Bérczi and Young-Hoon Kiem, “Real-rootedness of the Poincaré polynomials of $\overline{\mathcal M}_{0,n}$: an AI-assisted proof,” arXiv:2605.29151v2, revised 2026-06-11, Theorems 1.1--1.2 and 5.1. [arXiv](https://arxiv.org/abs/2605.29151v2)

[^20]: Pedro M. M. de Castro, “Ehrhart $h^*$-polynomials of $(132,213)$-avoiding permutation polytopes: A repair cone and eventual real-rootedness,” arXiv:2609.06096v1, submitted 2026-09-05, Theorems 1.3--1.4 and the conflicting range statement on p. 3. [arXiv](https://arxiv.org/abs/2609.06096v1)

[^21]: Jun-Ying Liu and Shi-Mei Ma, “An interlacing pattern between the types $C_n$ and $D_n$ coordinator polynomials,” arXiv:2608.11012v1, submitted 2026-08-11, Theorem 1. [arXiv](https://arxiv.org/abs/2608.11012v1)
