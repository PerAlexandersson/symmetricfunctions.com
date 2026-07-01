# Backlog Source Status, 2026-06-30

This file records source checks from the first backlog pass.  It is especially
for papers that are inaccessible, ambiguous, or not yet ready for TeX edits.

## Deferred Follow-Up Passes

- After the source backlog is mostly processed, do a dedicated `polydata`
  relation pass.  Recent prose-only additions should be revisited for
  `PositiveIn`, `Contains`, `SpecializesTo`, `Generalizes`,
  `KTheoreticAnalogueOf`, and related poset metadata.  Some of these will
  require new family nodes before the relation can be recorded cleanly.
- Add explicit examples and tableaux where they help the page.  For tableau
  families, prefer small `ytableau` examples; for families with many variants,
  consider first writing Rust generators/checkers so the examples are correct
  and reproducible.
- If a source is inaccessible or needs user credentials, leave a short
  `\todo{...}` marker near the relevant page location and record the reference
  here, rather than guessing from secondary descriptions.

## Processed in This Batch

- `tex-source/todo-list.tex:34--44`, arXiv:2202.00706,
  2111.08993, 2508.10772, 2505.01732, 2110.08808, 1904.05015,
  2105.09964, and 2312.00574.
  Accessible.  Added the published row-strict dual immaculate citation and
  details in `qsymSchur.tex`, added Chiu--Marberg's $K$-theoretic Schur
  $Q$-to-$P$ expansion in `schurKP.tex`, and added wreath Macdonald
  eigenstate, difference-operator, Tesler, and Ext-operator sources in
  `macdonaldP.tex`.  The noncommuting-variable Schur item and the
  noncommuting superspace item were already covered in `ncSchur.tex` and
  `nonCommutativeFunctions.tex`.

- `tex-source/todo-list.tex:47--59`, arXiv:2105.02604,
  2104.12336, 2102.05731, 2105.11404, 2009.14141, 1904.10602,
  1805.07250, and 1203.4465.
  Accessible.  Added multi-Schur and Littlewood--Schur notes to
  `superSymmetricSchur.tex`, $\imath$ Hall--Littlewood notes to
  `hallLittlewood.tex`, enriched and infinite-flag Schubert notes to
  `schubert.tex`, a fuller complete multipartite basis note to
  `weightedChromatic.tex`, bounded lecture hall tableaux in `schurMisc.tex`,
  and affine-nilCoxeter/strong Schur context in `stanleySymmetric.tex`.
  Upgraded the complete multipartite bibliography entry to its published
  form under the existing key.

- `tex-source/todo-list.tex:26--32`, arXiv:2602.12623,
  2510.25524, 2510.17116, and 2405.05867.
  Accessible.  Added orbit-harmonic/Foulkes plethysm context in
  `plethysm.tex`, substring-compatible statistic notes in
  `standardQuasiSymmetricFunctions.tex`, and pattern-avoiding peak functions
  in `peakQuasisymmetric.tex`.  The peak quasisymmetric Schur item
  arXiv:2405.05867 was already covered in `qsymSchur.tex` with the published
  bibliography key `ChoiNamOh2025`.

- `tex-source/todo-list.tex:65--76`, arXiv:1907.04631,
  2002.11796, 2508.03150, 1904.03386, and 1906.05966.
  Accessible.  Added vector-valued/highest-weight Jack--Macdonald context and
  the symplectic-forms finite-field characteristic map to `macdonaldP.tex`.
  Added ninth-variation Schur, $P$/$Q$, Pfaffian, and Schur multiple-zeta
  sources to the factorial/supersymmetric Schur section of
  `superSymmetricSchur.tex`.

- `tex-source/todo-list.tex:81--99`, arXiv:1908.11531,
  1811.05440, 1907.09975, 2105.03895, 1702.06666, 2003.07879,
  1904.01358, 2004.02947, and 1906.00907.
  Accessible.  Added type $C$ vexillary Schubert/flagged factorial Schur
  $Q$ notes to `schubert.tex`, cyclic quasisymmetric functions to
  `standardQuasiSymmetricFunctions.tex`, quasisymmetric functions in
  superspace to `superSymmetricSchur.tex`, dual-immaculate polynomial lifts
  and the Young/reverse dichotomy to `qsymSchur.tex`, Eulerian
  gamma-positivity to `gammaPositivity.tex`, colored fundamental
  quasisymmetric functions to `eulerianSymmetric.tex`, the asymmetric
  function survey to `assaf.tex`, and orthogonal/symplectic orbit-closure
  $K$-theory formulas to `schurKP.tex`.

- `tex-source/todo-list.tex:340--358`, arXiv:2505.09275,
  2504.21395, 2504.20975, 2504.19205, 2504.18825, 2506.09421,
  2504.17734, 2504.12583, 2504.15234, and 2504.05123.
  Accessible.  Added notes on Robbins-polynomial Littlewood identities,
  magic positivity of Ehrhart polynomials under dilation, poset symmetric
  functions from a Hopf algebra, spin Hall--Littlewood structure constants
  via lattice models and generalized honeycombs, a cyclotomic Hecke
  Murnaghan--Nakayama rule, Graham positivity in triple Schubert calculus,
  signed puzzles for Schubert coefficients, total positivity for Hadamard
  products of Jacobi--Trudi matrices, equivariant quasisymmetry and double
  forest/fundamental polynomials, and order polytopes of crown posets.  Used
  the published entry for arXiv:2504.05123 and custom keys for the two
  generated-key collisions.

- `tex-source/todo-list.tex:386--435`, arXiv:2502.02841,
  2501.18520, 2501.14691, 2501.11304, 2501.15667, 2412.18984,
  2412.19721, 2112.09633, 2501.16640, 2010.10493, 2412.20615,
  2405.01166, 2501.04245, 2501.01947, 2501.00275, 2501.04432,
  2501.04200, 2412.10556, 2412.03971, 2412.03463, 2412.02932,
  2412.02064, 2506.13659, 2412.02051, 2411.19521, and
  2411.17619.
  Accessible.  Added notes on factorial Schur functions via the
  boson--fermion correspondence, root-of-unity character factorizations and
  plethysm, product stability for double Grothendieck polynomials, dual
  immaculate $0$-Hecke filtrations, quasi-immanants, conditional positivity
  and GRH-dependent vanishing tests for Schubert coefficients, flagged-hive
  branching models, a super Littlewood--Richardson rule, normal square root
  crystals for Grothendieck positivity, Hawkes' double Grothendieck
  combinatorics, vexillary double Edelman--Greene coefficients,
  log-concavity of independence polynomials via chromatic symmetric
  functions, uniform LR symmetries, wreath-product character values, closed
  $k$-Schur Katalan functions, symmetry criteria for chromatic
  quasisymmetric functions, $P$-partitions extended by two-rowed plane
  partitions, zero-forcing characterizations of claw-free graphs, Schubert
  support bounds via pattern occurrences, Lorentzian Postnikov--Stanley
  polynomials and antiferromagnetic graph homomorphism inequalities, the
  matroid $\omega$-invariant, and the shifted plactic monoid.  The
  cycle-chord $e$-positivity item arXiv:2405.01166 was already present under
  the published key `Wang2025`.

- `tex-source/todo-list.tex:360--384`, arXiv:2504.01623,
  2503.19344, 2510.11322, 2503.19621, 2503.19694, 2503.17552,
  2503.09240, 2503.06051, 2503.03903, 2502.15586, 2502.08738,
  2507.00766, 2504.08187, and 2502.09072.
  Accessible.  Added notes on Lorentzian characters of parabolic Verma
  modules and restricted Kostant partition functions, valuative invariants and
  Ehrhart positivity for Catalan matroids, equivariant inverse
  Kazhdan--Lusztig polynomials of thagomizer matroids, contingency-table
  quotient rings and orbit harmonics, character evaluations on partial
  permutations, permuted-basement atom times Schur product rules, single-SEM
  Schubert polynomials, skew odd orthogonal characters and interpolating
  Schur polynomials, multi-symmetric Schur functions, $q$-rook numbers and
  $q$-Whittaker expansions of unicellular LLT functions, ribbon-Schur
  expansions for two-headed melting lollipop LLTs, and noncommutative
  chromatic quasisymmetric/Macdonald polynomials.  The gluing-at-one-vertex
  chromatic symmetric function paper was already present with its published
  DOI under key `TomVailaya2025x`; the permuted-basement Macdonald fillings
  paper arXiv:2503.06051 was already represented on `macdonaldEperm.tex`.

- `tex-source/todo-list.tex:1287--1324`, arXiv:1909.09520,
  1907.09681, 1909.00327, 1911.08732, 1911.07152, 1911.07799,
  1911.06732, 1910.08302, 1910.05848, 1909.00081, 1908.11224,
  1908.10934, 1812.01864, ALCO DOI `10.5802/alco.150`, EJC DOI
  `10.37236/11136`, arXiv:1907.06985, ALCO DOI `10.5802/alco.102`,
  ALCO DOI `10.5802/alco.178`, and EJC DOI `10.37236/10939`.
  Accessible.  Added notes on Kac--Moody Demazure keys, product monomial
  crystals, alcove paths and Gelfand--Tsetlin patterns, $0$-Hecke crystals
  for decreasing factorizations, quotient bases for symmetric polynomials,
  Hecke insertion for stack polyominoes, intrinsic hyperplane arrangements in
  irreducible symmetric-group representations, level-two Demazure modules and
  Macdonald polynomials, complete-homogeneous nonnegativity counterexamples,
  edge-labeled tableaux in equivariant Schubert calculus, divided
  symmetrization and quasisymmetric functions, Wronskian Appell polynomials,
  plethysms and $\mathrm{SL}_2(\mathbb C)$, spanning configurations and
  representation stability, positive specializations of symmetric
  Grothendieck polynomials, set-partition tableaux for diagram algebras,
  affine Demazure crystals for specialized nonsymmetric Macdonald
  polynomials, and signed-chromatic-polynomial categorification.  The
  symplectic Kostka--Foulkes row-case item was already present on
  `kostkaFoulkes.tex` with key `DolegaGerberTorres2020`.

- `tex-source/todo-list.tex:1246--1284`, DOI
  `10.1023/A:1008662732304`, arXiv:2004.00285, 1911.10703,
  2001.01449, 2008.03025, 2010.13930, 2102.09982, 2006.01568,
  2002.04810, 2001.00743, FPSAC 2019 article 96, arXiv:2001.04607,
  1912.12692, 1912.12721, 1912.04477, and 1911.10430.
  Accessible.  Added notes on Doran's plethysm formula for
  `p_mu[s_(a)]`, caracol flow polytopes, roots of Poupard and Kreweras
  polynomials, crystal and Macdonald cyclic sieving phenomena,
  rectangular `delta`-semistandard tableaux, Hopkins' poset-dynamics
  conjectures, rowmotion on trapezoid posets, Rush's global-basis proof of
  Rhoades' CSP, Stucky's necklaces/bracelets and double-coset CSP,
  periodic Macdonald processes, symmetric Gelfand--Tsetlin patterns,
  Hopf algebras of signed permutations and weak quasisymmetric functions,
  degrees of symmetric Grothendieck polynomials, and domino/bi-tableau
  generating functions.  The shifted-tableau cactus-group source
  arXiv:2004.00285 was already represented on `crystals.tex` by
  `Rodrigues2023`.

- `tex-source/todo-list.tex:1216--1244`, arXiv:2007.06261,
  2007.06362, 2007.05381, 2006.02089, 2005.12194, 2005.08329,
  2003.14236, 2003.00062, 2002.11999, 2001.11599, 2001.00654,
  and 2001.08763.
  Accessible.  Added notes on Macdonald polynomials and the extended
  Gelfand--Tsetlin graph, symplectic PBW tableaux, shifted double-staircase
  plane partitions, noncommutative probability Hopf algebras, principal
  specializations and differential operators for Schubert polynomials,
  weighted lozenge tilings, Schurifications of parking-function formulas,
  Lusztig and FFLV polytopes, zonal-polynomial computation, and two
  plethysm items.  The Woit Weyl-character note in this range is general
  expository background and was not promoted to page text.

- `tex-source/todo-list.tex:1183--1214`, arXiv:2108.10202,
  2010.08074, 2010.04241, 2009.14037, 2009.07344, 2401.02502,
  2008.06830, 2008.07034, 2007.11721, 2007.11042, 2007.09229,
  1701.01182, 2007.09238, q-alg/9512027, and 2007.07078.
  Accessible.  Added notes on back stable $K$-theory Schubert calculus,
  Jack Pieri formulas, intermediate symplectic characters, cuspidal ribbon
  tableaux, extended Schur functions and $0$-Hecke modules, skew Schubert
  tableaux formulas, perforated tableaux and type $A$ crystals,
  multiplicity-free key polynomials, flagged Schur determinant row bounds,
  Kostka polynomials in solvable lattice models, and cactus-group actions on
  shifted tableau crystals.  The orbit-harmonics CSP item was already covered
  in `cyclic-sieving.tex`, and the vertex-weighted Tutte item was already
  covered in `weightedChromatic.tex` and `tutteSymmetric.tex`.

- `tex-source/todo-list.tex:1161--1181`, arXiv:2012.01885,
  2012.01627, 2012.06402, 2101.02600, 2012.02376, 2011.15080,
  2011.13855, 2109.10299, 2109.06373, 2109.00639, 2011.12493, and
  2011.08374.
  Accessible.  Added `schurPositivity.tex` on type $B$ Schur positivity via
  domino tableaux, `diagonalHarmonics.tex` notes on the nabla formula, Theta
  identities, fermionic set-partition modules, the generalized valley Delta
  conjecture, and Delta Springer fibers at $t=0$, `grothendieck.tex` on the
  orthodontia formula for Grothendieck polynomials, `schubert.tex` on
  saturated Newton polytopes for double Schubert polynomials,
  `borderStripTableaux.tex` on set-valued domino tableaux, and
  `representationTheory.tex` on Springer representations and symmetric
  functions.  The LLT vertex-model entry was already covered in `llt.tex` and
  its bibliography entry was upgraded to the published IMRN version.  The LLT
  cumulants item was already covered in `unicellular-llt.tex`.

- `tex-source/todo-list.tex:1138--1157`, arXiv:2101.08907,
  2012.15011, 2012.14986, 2012.14975, 2012.12568, 2012.08076,
  2012.08741, EJC DOI `10.37236/1560`, arXiv:2012.06412,
  2407.05362, and 2011.06117.
  Accessible.  Added `key.tex` on type $B/C$ Demazure atom and character
  lattice models, upgraded the refined dual stable Grothendieck vertex-model
  citation to the published Selecta Mathematica version, added
  `gtpatterns.tex` on skew Schur Gelfand--Tsetlin-type weight bases,
  `grothendieck.tex` on hook-valued-tableau uncrowding,
  `cspMisc.tex` on $q$-Kreweras numbers for coincidental Coxeter groups,
  `schur.tex` on Bazin determinant identities and bijective Schur determinant
  identities, `permutationGeneralizations.tex` on Schur positivity for fully
  commutative type $B$ elements, and Macdonald multiline-queue notes in
  `macdonaldE.tex` and `macdonaldH.tex`.  The Young row-strict
  quasisymmetric Schur $0$-Hecke module item was already covered in
  `qsymSchur.tex`.

- `tex-source/todo-list.tex:1012--1035`, arXiv:2205.07322,
  arXiv:2205.06375, arXiv:2202.05706, arXiv:2205.03796,
  arXiv:2204.06059, arXiv:2204.03386, DOI
  `10.1007/s00026-021-00563-2`, arXiv:math/0612679,
  arXiv:2510.25106, arXiv:2204.04566, DOI `10.4153/CMB-2011-105-7`,
  arXiv:2203.15942, and arXiv:2203.16461.
  Accessible.  Added notes on symplectic/orthogonal hook-content formulae and
  hook/content partition identities, the Dyck-path zeta map, tiered trees and
  Theta operators, fermionic diagonal coinvariants, Rhoades' Delta-operator
  survey, positivity among $P$-partition generating functions, generalized
  cluster-complex CSP, orbit harmonics for two orbits and rook-placement
  loci, triangular partitions, and hook formulae from Segre--MacPherson
  classes.  The chain-polynomial real-rootedness item was already present and
  its bibliography entry was upgraded to published data.

- `tex-source/todo-list.tex:991--1010`, arXiv:2206.03054,
  arXiv:2105.09964, arXiv:2206.05177, arXiv:2311.12625,
  arXiv:2311.12216, arXiv:2206.02065, arXiv:2206.00131,
  arXiv:2206.00075, arXiv:2205.13949, arXiv:2205.11813, and
  arXiv:math/0703479.
  Accessible.  The Chaput--Ressayre LR item and Barcelo--Reiner--Stanton
  flag-major/bimahonian CSP item were already present.  Added `ncSchur.tex`
  on Schur functions in noncommuting variables, `macdonaldP.tex` on
  $m$-symmetric and partially symmetric Macdonald polynomials,
  `standardQuasiSymmetricFunctions.tex` on WQSym self-duality and
  anticommuting quasisymmetric harmonics, `diagonalHarmonics.tex` on
  rectangular shuffle/Delta conjectures and torus-link symmetric functions,
  and `nonCommutativeFunctions.tex` on noncommutative symmetric functions in
  superspace.  The related Fishel--Gatica--Lapointe--Pinto superspace
  quasisymmetric item was already present in `superSymmetricSchur.tex`.

- `tex-source/todo-list.tex:971--989`, arXiv:2206.14351,
  arXiv:2207.00523, arXiv:2206.13409, arXiv:2112.13333,
  arXiv:2206.11406, arXiv:2206.10017, arXiv:2206.08993, SLC B86a,
  arXiv:2206.07728, and arXiv:2206.06567.
  Accessible.  Added `schubert.tex` notes on bumpless-pipe-dream RSK/growth
  diagrams, the Gao--Huang bijection via bumpless pipe dreams, and pattern
  bounds for principal specializations of Schubert and Grothendieck
  polynomials; added `cyclic-sieving.tex` on FindStat homomesies,
  `representationTheory.tex` on free left-regular-band invariant theory,
  `schur.tex` on Jacobi--Trudi formulas and determinantal varieties,
  `murnaghanNakayama.tex` on path power sums, and `rsk.tex` on reverses with
  the same Robinson--Schensted recording tableau.  The Lazzeroni qsym/NCQSym
  power-sum item and Pan--Yu $K$-Kohnert item were already present; the
  Huang--Pylyavskyy later Knuth-move citation was upgraded to published DOI
  data.

- `tex-source/todo-list.tex:954--968`, arXiv:1108.2007,
  arXiv:2208.11156, arXiv:2208.10464, arXiv:2208.07258,
  arXiv:2207.05903, arXiv:2207.02905, and arXiv:2207.03354.
  Accessible.  The Jack vertex-operator item was already cited by published
  key `CaiJing2013`; added a fuller `jack.tex` note.  Added `cspCatalan.tex`
  and `cspMisc.tex` notes on rational Tamari/biCambrian rowmotion and
  noncommutative birational rowmotion, `plethysm.tex` detail on the s-perp
  computation method, `nonCommutativeFunctions.tex` on the noncommutative
  inverse Kostka matrix, `grothendieck.tex` on type ABCD skew Grothendieck
  tableau formulas, and `symplecticQ.tex` on intermediate symplectic
  $Q$-functions.  Upgraded the existing plethysm bibliography entry to its
  published PSPUM data.

- `tex-source/todo-list.tex:937--952`, arXiv:2209.06142,
  arXiv:2209.04413, arXiv:2209.03503, arXiv:2209.03551,
  DOI `10.1006/jabr.1994.1064`, arXiv:2208.04521, arXiv:2208.05526,
  arXiv:2209.00767, and arXiv:2209.00687.
  Accessible.  Added `resources.tex` on Pak's combinatorial-interpretation
  survey, `stablePolynomials.tex` on stability of spanning-tree degree
  enumerators, `hallLittlewood.tex` on Delta-Springer varieties and
  Hall--Littlewood polynomials, `schurKP.tex` on shifted dual stable
  Grothendieck functions, `grothendieck.tex` on Grothendieck degree/rajcode,
  `schurMisc.tex` on Proctor's classical-group Gelfand patterns and on
  skew/universal symplectic and orthogonal Schur functions, and
  `gtpatterns.tex` on combinatorial mutations of GT, FFLV, and matching-field
  polytopes.  The duplicate `tex-source/todo-list.tex:950` is covered by the
  same Jing--Li--Wang entry as line 947.

- `tex-source/todo-list.tex:222`, arXiv:2601.04409.
  Accessible.  Added bibliography key `MandelshtamNiergarthSingh2026x`.
  The source proves that permuted-basement Macdonald polynomials
  `E_alpha^sigma(X;q,0)` have Demazure-atom expansions with coefficients in
  `NN[q]` in Corollary 4.7.  Added `PositiveIn & atom` metadata to
  `macdonaldEperm` and `macdonaldEspec`.

- `tex-source/todo-list.tex:590`, arXiv:2406.01166.
  Accessible.  Added bibliography key `GrinbergVassilieva2024x` and a short
  `hallLittlewood.tex` subsection on Hall--Littlewood `S`-functions, enriched
  `P`-partitions, and the q-fundamental quasisymmetric expansion.

- `tex-source/todo-list.tex:328`, arXiv:2506.09015.
  Accessible.  Added bibliography key `BlasiakHaimanMorsePunSeelinger2025x`
  and a short `llt.tex` subsection on flagged LLT polynomials, nonsymmetric
  plethysm, and the conjectural Demazure-atom positivity statement.

- `tex-source/todo-list.tex:524`, arXiv:2408.17375.
  Accessible.  Added bibliography key `Kundu2024x` and a short
  `grothendieck.tex` paragraph on the key expansion of flagged refined skew
  stable Grothendieck polynomials.  This was not added as graph metadata
  because the displayed expansion has K-theoretic signs.

- `tex-source/todo-list.tex:787`, arXiv:2306.10939.
  Accessible.  Added bibliography key `NadeauTewari2023x`, a forest polynomial
  family node in `assaf.tex`, the forest-to-slide relation, and the Schubert
  to forest positive-expansion relation.

- `tex-source/todo-list.tex:796`, arXiv:2305.03241.
  Accessible.  Added bibliography key `Ehrhard2023x`, a complete flagged
  homogeneous family node in `key.tex`, its stable limit to `completeH`, its
  key/atom positivity, and the signed expansion of keys in this basis.

- `tex-source/todo-list.tex:463`, arXiv:2411.03117.
  Accessible.  Added bibliography key `FeiginKhoroshkinMakedonskyi2024x` and a
  short Cauchy-kernel paragraph in `key.tex` on staircase-shaped matrix
  identities involving keys and Demazure atoms.

- `tex-source/todo-list.tex:798`, DOI `10.1016/j.ejc.2023.103688`.
  Accessible.  Existing bibliography key `AliniaeifardWangWilligenburg2023`
  was used for a short `pPartitions.tex` paragraph on combinatorial power sum
  bases from weighted labeled $P$-partitions.

- `tex-source/todo-list.tex:1037--1085`, arXiv:2203.14422, 2203.12492,
  2203.10342, 2202.11185, 2202.04170, 2202.03066, 2202.02897, 2201.12432,
  2201.13142, FPSAC 2021 entries 58 and 37, arXiv:2201.00240, 2112.13909,
  2112.09800, 2112.09799, 2112.10604, 2112.09228, 2112.07063, 2112.07070,
  2112.06843, 2112.03780, 2112.02848, 2112.02147, 2112.00479, and
  2112.00524.
  Accessible.  Added short page-local notes for root-of-unity monomial
  specializations, balanced shifted tableaux, Delta/Theta expansions,
  fermionic Theta coinvariants, inverse Grassmannian LR rules, Kronecker
  square splittings, Grothendieck Mobius inversion, vexillary Grothendieck
  pipe dreams, plane-partition symmetric functions, enriched monomial QSym,
  descent-refined Murnaghan--Nakayama, iterated plethysm symmetries,
  party-algebra plethysm, Bergeron Macdonald/Catalan notes, wreath Macdonald
  characters at `q=t`, toric promotion, RSK/box-ball systems, Schur-Q
  crystals, Hall--Littlewood boundaries, set-partition profile polynomials,
  and geometric RSK.  Upgraded the existing increasing-tableaux CSP and the
  two Loehr--Warrington companion-paper bibliography entries to published DOI
  metadata.  The line 1069 increasing-tableaux item was already present on
  `cspTableau.tex`; only its bibliography metadata was upgraded.

- `tex-source/todo-list.tex:1087--1119`, arXiv:2111.14657, 2110.10273,
  2109.14597, 2108.08657, 2108.08370, 2108.11438, 2108.03188, 2107.10205,
  2106.16189, 2107.00453, EJC DOI `10.37236/9621`, arXiv:2109.06718,
  2106.12557, 2106.06872, and 2106.03828.
  Accessible.  Added short notes for orthosymplectic Cauchy identities,
  supersymmetric LLT vertex models, RSK reverse-recording tableaux, bumpless
  pipe-dream Groebner geometry, the canonical pipe-dream/bumpless-pipe-dream
  bijection, chromatic/Tutte plethysms, shifted Schur quantum immanants,
  multivariate Eulerian/Stirling e-positivity, Schur and symmetric
  Grothendieck Newton polytopes, free-fermion six-vertex Schur variants, spin
  Hall--Littlewood identities, generalized Grothendieck Cauchy formulas, and
  the q-Klyachko algebra.  The Hardt lattice-model item was already cited on
  `latticeModel.tex`; the skew-Jack item was already cited on `jack.tex`, and
  its bibliography entry was upgraded to published DOI metadata.

- `tex-source/todo-list.tex:1121--1135`, arXiv:2106.02564, 2106.02534,
  2104.10101, 2104.01415, 2104.00710, 2103.14195, 2102.11179, and
  arXiv:math/0608446.
  Accessible.  Upgraded the existing Patimo charge bibliography entry to
  published DOI metadata, and added short notes for cyclic pattern avoidance,
  Levi-spherical Schubert varieties and key polynomials, inhomogeneous spin
  q-Whittaker polynomials, nonsymmetric Macdonald superpolynomial evaluations,
  Kronecker powers of harmonics, inclusion--exclusion formulas for Schubert
  polynomials, and skew diagrams with identical skew Schur functions.

- `tex-source/todo-list.tex:921`, arXiv:2210.10236.
  Accessible.  Added published bibliography key `AssafDranowskiGonzalez2023`
  and a short `crystals.tex` paragraph on the tensor-product criterion for
  Demazure crystals, including the warning that this is not a general
  key-product positivity theorem.

- `tex-source/todo-list.tex:717--722`, arXiv:2401.07481, arXiv:2309.06401,
  arXiv:2106.11913, arXiv:2106.11922, arXiv:2204.06166, and
  arXiv:2109.12908.
  Accessible.  Added a `whittaker.tex` subsection on $q$-Whittaker Cauchy
  identities, skew RSK dynamics, type A Whittaker formula compression, spin
  $q$-Whittaker interpolation models, and bijections with modified
  Hall--Littlewood formulas.  Also added a diagonal-operator paragraph using
  published key `RamSchlosser2026`.

- `tex-source/todo-list.tex:32` and `tex-source/todo-list.tex:586`,
  arXiv:2405.05867 and arXiv:2406.12751.
  Accessible.  Added `qSchurQ` and `peakYqSchur` family nodes to
  `qsymSchur.tex`, with published bibliography keys for the definition and
  positivity results.  Added positive-expansion metadata from quasisymmetric
  Schur $Q$-functions to peak Young quasisymmetric Schur functions.

- `tex-source/todo-list.tex:592--593`, arXiv:2406.01510 and
  arXiv:2406.02420.
  Accessible.  Added short `assaf.tex` and `hivert.tex` paragraphs on
  quasisymmetric divided differences, forest polynomials, Hivert operators,
  fundamental slide polynomials, and the fundamental particle basis.

- `tex-source/todo-list.tex:754`, arXiv:2308.10456.
  Accessible.  Added a `standardQuasiSymmetricFunctions.tex` paragraph on
  poset modules for $0$-Hecke algebras and quasisymmetric power-sum
  expansions of dual immaculate and extended Schur functions, with published
  bibliography key `ChoiKimOh2024`.

- `tex-source/todo-list.tex:751--752`, `tex-source/todo-list.tex:756`,
  `tex-source/todo-list.tex:758`, `tex-source/todo-list.tex:762--763`,
  `tex-source/todo-list.tex:765`, and `tex-source/todo-list.tex:767`,
  arXiv:2303.09605, arXiv:2212.13588, arXiv:2308.10469, arXiv:2307.02385,
  arXiv:2312.00355, arXiv:2304.06889, arXiv:2304.06629, and arXiv:2303.15694.
  Accessible.  Added notes on symplectic-tableaux CSP, promotion on $r$-fans
  of Dyck paths, dual flagged Weyl character upper bounds, bisymmetric
  Macdonald polynomials, Schubert RSK and growth diagrams, Jack derangements,
  and higher-rank Hikita/rational Catalan polynomials.  The neighboring
  qsym power-sum item at `tex-source/todo-list.tex:754` was already processed
  above.

- `tex-source/todo-list.tex:771--775`, arXiv:2402.04219,
  arXiv:2309.08518, and arXiv:2307.06517.
  Accessible.  Added `qsymSchur.tex` notes on nonzero skew immaculate
  functions and colored dual immaculate functions, and a `macdonaldH.tex` note
  on the Blasiak--Haiman--Morse--Pun--Seelinger raising-operator formula for
  modified Macdonald polynomials.  Used published bibliography entries for the
  two immaculate papers.

- `tex-source/todo-list.tex:778--785`, arXiv:2403.10817, arXiv:2307.06678,
  arXiv:2212.07343, arXiv:2212.12477, and arXiv:2307.00767.
  Accessible.  Added notes on Schur functions at primitive roots of unity,
  Mitchell Lee's Frobenius transform and Lyndon factorizations, root-of-unity
  twists of universal and classical characters, and ribbon tilings of strips.
  The repeated twisted-character item at `tex-source/todo-list.tex:782` is
  covered by the same Albion entry as `tex-source/todo-list.tex:780`.

- `tex-source/todo-list.tex:790--794`, arXiv:2306.00304,
  arXiv:2306.00336, and arXiv:2305.07620.
  Accessible.  Added notes on flagged skew Grothendieck polynomials, crystals
  for shifted $P$- and $Q$-key polynomials, and cyclotomic generating
  functions.  Used the published bibliography entry for the shifted-key
  crystals paper.

- `tex-source/todo-list.tex:800--814`, arXiv:2304.11508, arXiv:2102.00935,
  arXiv:2304.07439, arXiv:2303.10664, arXiv:2210.10158, arXiv:2303.11392,
  arXiv:2303.09019, arXiv:2303.00241, arXiv:2303.00576, and arXiv:2303.00560.
  Accessible.  Added notes on double monomial quasisymmetric functions, the
  Kostka semigroup and cone, $Q$-Kostka/spin Green/spin Kostka polynomials,
  degrees of stretched Kostka quasi-polynomials, Rothe-diagram
  characterizations, back stable quasisymmetric functions from flagged
  $P$-partitions, nonsymmetric $q$-Cauchy identities, Cauchy-type generating
  functions for classical Lie group characters, and the super nabla operator.
  Used published bibliography entries where available.

- `tex-source/todo-list.tex:818--838`, arXiv:2302.09454, arXiv:2302.08211,
  arXiv:2302.08279, arXiv:2302.07694, arXiv:2302.07239, arXiv:2302.05903,
  arXiv:2302.04164, arXiv:2312.16824, arXiv:2312.03956, arXiv:2302.04136,
  arXiv:2206.11760, and arXiv:2302.03761.
  Accessible.  Added notes on realizable combinatorial sequences, stable-limit
  nonsymmetric Macdonald functions, left and right keys, quasicrystals,
  Jacobi--Trudi determinants over finite fields, averaging Cauchy identities,
  $(-1)$-enumerations of arrowed Gelfand--Tsetlin patterns, nabla of monomial
  symmetric functions, Delta conjecture specializations, and weighted
  $q$-enumeration of lattice points.  Reused existing keys `MaasGariepy2023x`
  and `DAdderioIraci2023`.

- `tex-source/todo-list.tex:841--859`, FPSAC 2021 article 52,
  arXiv:2301.12110, arXiv:2301.12741, DOI 10.1016/j.jalgebra.2020.05.030,
  arXiv:2301.09260, arXiv:2301.06500, EJC v30i1p5, and SIGMA 2020/130.
  Accessible.  Added `littlewoodRichardson.tex` on refined
  Littlewood--Richardson coefficients from key polynomials and saturation,
  `superSymmetricSchur.tex` on free fermionic Schur functions,
  `schurKP.tex` on the boson--fermion correspondence for dual
  $K$-theoretic $P$- and $Q$-functions, `kostkaFoulkes.tex` on symplectic
  Kostka--Foulkes polynomials, `latticeModel.tex` on stochastic six-vertex
  models and Hall--Littlewood positivity, and `macdonaldP.tex` on Macdonald
  Littlewood--Richardson coefficient factorization.  The flagged Schur
  polynomial duality and plane-partition CSP items were already covered in
  `schurFlagged.tex`, `lgv-lemma.tex`, `cspTableau.tex`, and `cspMisc.tex`.

- `tex-source/todo-list.tex:862--870`, arXiv:2301.02203,
  arXiv:2301.00175, arXiv:2301.00225, arXiv:2301.00309, and
  arXiv:2212.13241.
  Accessible.  Added `murnaghanNakayama.tex` notes on divisibility of
  symmetric-group character values and generalized characters for wreath
  products, `schur.tex` on bounded Littlewood identities related to
  alternating sign matrices, `key.tex` on geometric mitosis for Kogan faces,
  and `peakQuasisymmetric.tex` on the algebra of extended peaks.  Used
  published entries for arXiv:2301.02203, arXiv:2301.00175, and
  arXiv:2301.00225.

- `tex-source/todo-list.tex:873--893`, arXiv:2212.09419,
  arXiv:2212.06885, arXiv:2212.05665, arXiv:2212.04932,
  arXiv:2211.06575, DOI 10.37236/10941, arXiv:2404.02483,
  arXiv:2211.05002, arXiv:2211.03851, and arXiv:2211.03499.
  Accessible.  Added `macdonaldH.tex` on Butler's conjecture for modified
  Macdonald polynomials, `polytopes.tex` on generalized parking-function
  polytopes, `jack.tex` on 3-Jack polynomials, `qsymSchur.tex` on 0-Hecke
  modules for genomic Schur functions, `grothendieck.tex` on refined canonical
  stable Grothendieck polynomials and their free-fermion presentation,
  `macdonaldP.tex` on wreath Macdonald operators, and `gtpatterns.tex` on
  chain-order polytopes and toric degenerations.  The Wachs-permutation item
  was already covered in `permutationFamilies.tex`; its bibliography entry was
  upgraded to the published European Journal of Combinatorics version.  The
  skew Schur CSP item was already covered in `cspTableau.tex`,
  `schurFlagged.tex`, and `q-analogs.tex`.

- `tex-source/todo-list.tex:897--913`, arXiv:1204.2484,
  arXiv:2211.01578, arXiv:2211.00699, arXiv:2210.17476,
  arXiv:2207.05119, arXiv:2209.09277, arXiv:2206.15451,
  arXiv:2204.05259, arXiv:2204.06751, arXiv:2210.14839, and
  arXiv:2210.14668.
  Accessible.  Added `littlewoodRichardson.tex` on positivity testing for
  Littlewood--Richardson coefficients, `grothendieck.tex` on the Pieri rule
  for quantum Grothendieck polynomials, `weightedChromatic.tex` on
  chromatic symmetric homology for vertex-weighted graphs,
  `standardQuasiSymmetricFunctions.tex` on Lazzeroni's powersum basis,
  `rsk.tex` on Boolean permutations, box-ball systems, super RSK, and Burge
  correspondence variants, `q-analogs.tex` on cyclic descent extensions, and
  `schur.tex` on reduced Kronecker coefficient conjectures.  Used published
  entries where available and upgraded `BloomSaracino2022x` to the published
  European Journal of Combinatorics version.

- `tex-source/todo-list.tex:915--929`, arXiv:2210.14464,
  arXiv:2210.13862, arXiv:2210.11286, arXiv:2210.10236,
  arXiv:1903.08275, arXiv:2209.14942, and arXiv:2209.13317.
  Accessible.  Added `macdonaldP.tex` on arbitrary-type Macdonald polynomial
  path models, `schurMisc.tex` on 2-reduced Schur functions and Schur
  $Q$-functions, `macdonaldH.tex` on bijective coinversion identities for the
  multiline-queue formula, `gtpatterns.tex` on the marked order/flow-polytope
  viewpoint on GT-polytopes, `plethysm.tex` on 3-plethysms, and
  `standardQuasiSymmetricFunctions.tex` on new qsym bases from deformed
  quasi-shuffles.  The Demazure-crystal tensor-product item at
  `tex-source/todo-list.tex:921` was already processed earlier in this status
  file; `LiuMeszarosDizier2019flow` was upgraded to the published SIAM
  Journal on Discrete Mathematics entry.

- `tex-source/todo-list.tex:931--935`, arXiv:2209.12632,
  arXiv:2209.10075, and arXiv:2209.09859.
  Accessible.  Added `schur.tex` on Jacobi--Trudi identities via BGG category
  $\mathcal{O}$, `resources.tex` on the Goulden--Jackson survey, and
  `macdonaldH.tex` on the multispecies zero-range process and the modified
  Macdonald partition function.  Used published entries for the
  Goulden--Jackson survey and the zero-range process paper.

- `tex-source/todo-list.tex:494--501`, arXiv:2410.08038,
  arXiv:2410.03916, arXiv:2211.02993, arXiv:2302.04226,
  arXiv:2306.04159, arXiv:2302.03643, arXiv:2312.01647, and
  arXiv:2312.01417.
  Accessible.  Added a `grothendieck -> lascoux` positive-expansion relation,
  a `lascoux.tex` cluster on $K$-Kohnert diagrams, top Lascoux polynomials,
  Lascoux times stable Grothendieck products, double orthodontia positivity,
  Gelfand--Zetlin subdivisions, and shifted orbit-closure analogues.  Added a
  short `schubert.tex` cross-reference for top Lascoux/Schubert structure
  constants.  Published bibliography entries were used where available; the
  product and double-orthodontia papers remain arXiv entries.

- `tex-source/todo-list.tex:555--557`, `tex-source/todo-list.tex:659`, and
  `tex-source/todo-list.tex:704`, arXiv:2508.17682, arXiv:2502.21285,
  arXiv:2408.01395, arXiv:2312.16474, and arXiv:2301.02177.
  Accessible.  Updated `kromaticSymmetric.tex` with Marberg's kromatic
  quasisymmetric functions, Pierson's power-sum and Lyndon-heap expansions,
  Pierson--Samanta's counterexamples to graph-distinguishing by the kromatic
  symmetric function, and the published source for the original definition.

- `tex-source/todo-list.tex:569--570`, `tex-source/todo-list.tex:697`,
  `tex-source/todo-list.tex:701`, and `tex-source/todo-list.tex:703`,
  arXiv:2410.22813, arXiv:2407.06965, arXiv:2208.08458,
  arXiv:2011.06063, and arXiv:2208.12282.
  Accessible.  Added notes to `weightedChromatic.tex` on universal
  graph-series/vertex-weighted chromatic functions, generalized chromatic
  functions of edge-coloured digraphs, and $H$-chromatic symmetric functions.
  Added `chromaticQuasisymmetric.tex` notes on $\alpha$-chromatic symmetric
  functions and generalized Hessenberg varieties.

- `tex-source/todo-list.tex:685` and `tex-source/todo-list.tex:710--715`,
  arXiv:2311.09685, arXiv:2211.06981, arXiv:2205.14835,
  arXiv:2307.01130, arXiv:2112.12676, arXiv:2309.05970, and
  arXiv:2110.07984.
  Accessible.  Added notes to `chromaticQuasisymmetric.tex` on increasing
  spanning forests, interval-graph LLT quasisymmetric functions, and Gagnon's
  unipotent realization of chromatic quasisymmetric functions.  Added
  `unicellular-llt.tex` notes on the Kiem--Lee twin-manifold proof and the
  vertical-strip LLT character interpretation.  Added compact `llt.tex` notes
  on Hecke-character geometry, horizontal-strip LLT weighted graphs, and
  LLT asymptotic corner processes.  Upgraded `DolegaKowalski2021x` to its
  published Electronic Journal of Combinatorics entry.

- `tex-source/todo-list.tex:458--459` and `tex-source/todo-list.tex:480`,
  `tex-source/todo-list.tex:482--483`, arXiv:2507.05614,
  arXiv:2411.05096, arXiv:2503.23597, arXiv:2410.12231, and
  arXiv:2410.08366.
  Accessible.  Added `dot-action.tex` notes on Guay-Paquet's divided
  difference decomposition of Hessenberg GKM modules, Kato's affine
  Grassmannian realization of chromatic symmetric functions, and Salois's
  higher Specht/permutation bases for special Hessenberg cohomology rings.
  Added `chromaticQuasisymmetric.tex` notes on Abreu--Nigro--Ram finite-field
  point-counting formulas for Hessenberg varieties.  Added
  `chromaticEexpansion.tex` notes on Hikita's $(q,t)$-chromatic symmetric
  functions.

- `tex-source/todo-list.tex:476--477` and `tex-source/todo-list.tex:481`,
  arXiv:2504.09123, arXiv:2504.06936, and arXiv:2410.12758.
  Already covered in `chromaticEexpansion.tex` by the Hikita theorem and the
  post-Hikita refinement paragraph using keys `Hikita2024x`,
  `HuhHwangKimKimOh2025x`, and `GriffinMellitRomeroWeiglWen2025x`.

- `tex-source/todo-list.tex:478--479`, arXiv:2410.13642 and
  arXiv:2410.19189.
  Accessible.  Inspected but left without TeX edits in this pass: the first is
  primarily about stable-limit partially symmetric Macdonald functions and
  parabolic flag Hilbert schemes, and the second is a machine-learning-guided
  conjectural counting formula for Stanley coefficients.

- `tex-source/todo-list.tex:438--440`, arXiv:2412.09929,
  arXiv:2412.00116, and arXiv:2411.16485.
  Accessible.  Added `whittaker.tex` notes on inv/quinv formulas for
  $q$-Whittaker and modified Hall--Littlewood functions, bases and branching
  for $q$-Whittaker local Weyl modules, and the power-sum expansion/simple
  operator subspace-counting interpretation.

- `tex-source/todo-list.tex:442`, `tex-source/todo-list.tex:448`,
  `tex-source/todo-list.tex:450--452`, and `tex-source/todo-list.tex:456`,
  arXiv:2411.16654, arXiv:2411.10933, arXiv:2506.07306,
  arXiv:2411.11208, arXiv:2409.20389, and arXiv:2411.08465.
  Accessible.  Added `matroids.tex` notes on $M$-convex Newton polytopes of
  dual Schubert polynomials, `schubert.tex` notes on flagged Weyl zero-one
  characters, generic pipe dreams, bumpless pipe dream change-of-basis
  formulas, and back stable Schubert/Heisenberg algebra, plus a `key.tex` note
  on key-polynomial generating series.

- `tex-source/todo-list.tex:444`, `tex-source/todo-list.tex:446`, and
  `tex-source/todo-list.tex:454`, arXiv:2411.13371, arXiv:2411.13411, and
  arXiv:2411.11447.
  Accessible.  Added a `superSymmetricSchur.tex` note on fundamental
  quasisymmetric functions in superspace, a `chromaticQuasisymmetric.tex`
  note on computing chromatic symmetric functions in forest bases, and
  `murnaghanNakayama.tex`/`schurMisc.tex` notes on Murnaghan--Nakayama rules
  for symplectic, orthogonal, and orthosymplectic Schur functions.  Used
  published entries for arXiv:2411.13371 and arXiv:2411.11447.

- `tex-source/todo-list.tex:461`, `tex-source/todo-list.tex:465`, and
  `tex-source/todo-list.tex:467`, arXiv:2411.04123, arXiv:2411.02897, and
  arXiv:2506.06951.
  Accessible.  Added a `realRooted.tex` note on the equivalence between
  totally positive formal power series and rank-generating functions of
  Schur-positive upho posets, a `realRootedWords.tex` example on the
  generalized Sturm sequence for multi-dimensional permutations, and an
  `rsk.tex` note on type $C$ RSK for King tableaux via Berele insertion.  Used
  published entries for arXiv:2411.02897 and arXiv:2506.06951.

- `tex-source/todo-list.tex:471`, `tex-source/todo-list.tex:473`,
  `tex-source/todo-list.tex:485`, and `tex-source/todo-list.tex:487`,
  arXiv:2410.18343, arXiv:2410.15739, arXiv:2410.08075, and
  arXiv:2410.07960.
  Accessible.  Added `grothendieck.tex` notes on hook-valued-tableau
  uncrowding/tableau switching for refined canonical stable Grothendieck
  polynomials and on Kirillov's Hecke--Grothendieck positivity via solvable
  lattice models, a `schurKP.tex` note on special values of $K$-theoretic
  Schur $P$- and $Q$-functions, and a `hallLittlewood.tex` subsection on
  Hall--Littlewood--Schubert series.  Used published entries for
  arXiv:2410.18343 and arXiv:2410.07960.

- `tex-source/todo-list.tex:489`, `tex-source/todo-list.tex:505`, and
  `tex-source/todo-list.tex:506`, arXiv:2410.04669, arXiv:2505.07623, and
  arXiv:2410.03245.
  Accessible.  Added a `nonCommutativeFunctions.tex` note on Campbell's
  $\mathrm{NSym}$ lift of chromatic symmetric functions, and
  `gammaPositivity.tex` notes on equivariant gamma-effectiveness for order
  polytopes of graded posets and on canon permutation posets.

- `tex-source/todo-list.tex:510`, `tex-source/todo-list.tex:512`,
  `tex-source/todo-list.tex:514`, `tex-source/todo-list.tex:516`,
  `tex-source/todo-list.tex:518`, `tex-source/todo-list.tex:520`,
  `tex-source/todo-list.tex:522`, and `tex-source/todo-list.tex:526`,
  arXiv:2409.20478, arXiv:2409.17842, arXiv:2409.16648,
  arXiv:2409.09643, arXiv:2409.04621, arXiv:2409.06175,
  arXiv:2408.16694, and arXiv:2408.15111.
  Accessible.  Added notes on Kneser chromatic functions
  (`chromaticQuasisymmetric.tex`), skew hook-length formulas via contour
  integrals and vertex models (`schur.tex`), Artin symmetric functions
  (`standardSymmetricFunctions.tex`), asymptotics of Macdonald and Jack
  polynomials (`macdonaldP.tex`), involution matrix loci and orbit harmonics
  (`representationTheory.tex`), Schubert-module filtrations and the
  Nadeau--Spink--Tewari recursion (`schubert.tex`), and big descents in
  pattern-avoiding permutations (`realRootedWords.tex`).  The
  magic-positive Ehrhart item was already covered by the Stasheff and
  symmetric-edge polytope example in `polytopes.tex`.  Used published entries
  for arXiv:2409.20478, arXiv:2409.17842, arXiv:2409.04621,
  arXiv:2409.06175, and arXiv:2408.15111.

- `tex-source/todo-list.tex:582`, `tex-source/todo-list.tex:584`, and
  `tex-source/todo-list.tex:588`, arXiv:2406.13902, arXiv:2406.13728, and
  arXiv:2406.05311.
  Accessible.  Added a `standardSymmetricFunctions.tex` note on signed
  combinatorial interpretations, a `nonCommutativeFunctions.tex` note on
  concrete $\mathrm{NSym}$ change-of-basis formulas, and
  `murnaghanNakayama.tex`/`schubert.tex` notes replacing the stale quantum
  Murnaghan--Nakayama placeholder with the published flag-manifold result.
  The items at `tex-source/todo-list.tex:586` and `tex-source/todo-list.tex:590`
  were already processed earlier in this batch.

- `tex-source/todo-list.tex:595`, `tex-source/todo-list.tex:597`,
  `tex-source/todo-list.tex:599`, `tex-source/todo-list.tex:601`,
  `tex-source/todo-list.tex:603`, and `tex-source/todo-list.tex:605`,
  arXiv:2405.13137, arXiv:2405.01049, arXiv:2404.06320,
  arXiv:2404.04512, arXiv:2404.04961, and arXiv:2404.03904.
  Accessible.  Added `schurMisc.tex` notes on the Pfaffian formulation of
  Schur $Q$-functions and type-$B$ shifted domino/$Q$ analogues, an
  `almostSymmetricSchur` family node in `key.tex`, a
  `littlewoodRichardson.tex` note on polygonal Schubert puzzles, a
  `schurPositivity.tex` note on the quasi-Kostka method for extracting Schur
  expansions from fundamental quasisymmetric expansions, and a
  `macdonaldP.tex` note on creation operators and Macdonald characters.  Used
  published entries for arXiv:2405.13137 and arXiv:2404.04512.

- `tex-source/todo-list.tex:607--608`, `tex-source/todo-list.tex:610`,
  `tex-source/todo-list.tex:612`, `tex-source/todo-list.tex:614`,
  `tex-source/todo-list.tex:616`, and `tex-source/todo-list.tex:618`,
  arXiv:2510.11054, arXiv:2404.04014, arXiv:2404.03142,
  arXiv:2404.03649, arXiv:2404.01971, arXiv:2404.01450, and
  arXiv:2403.19573.
  Accessible.  Added `schur.tex` notes on bounded and growth-diagram
  Littlewood identities, `matroids.tex` notes on matricubes, superspace
  Tutte polynomials, and affine Demazure weight polytopes, a
  `cyclic-sieving.tex` note on toric promotion with reflections/refractions,
  and a `chromaticQuasisymmetric.tex` note on $q$-chromatic polynomials.

- `tex-source/todo-list.tex:621`, `tex-source/todo-list.tex:623`,
  `tex-source/todo-list.tex:625`, `tex-source/todo-list.tex:627`,
  `tex-source/todo-list.tex:629`, and `tex-source/todo-list.tex:631`,
  arXiv:2403.15058, arXiv:2403.14538, arXiv:2403.06468,
  arXiv:2403.04101, arXiv:2403.01843, and arXiv:2403.02490.
  Accessible.  Added notes to `realRootedCatalan.tex` on stable multivariate
  Narayana polynomials, `grothendieck.tex` on the Grothendieck K-Kohnert
  counterexample/revised rule, `standardSymmetricFunctions.tex` on criteria
  for algebraically independent generating families, `schur.tex` on derived
  Schur polynomials and thickened-ribbon skew Schur equivalence classes, and
  `jackF.tex` on interpolation-polynomial binomial and
  Littlewood--Richardson coefficients.

- `tex-source/todo-list.tex:529`, `tex-source/todo-list.tex:530`,
  `tex-source/todo-list.tex:532`, `tex-source/todo-list.tex:534`,
  `tex-source/todo-list.tex:536`, `tex-source/todo-list.tex:537`,
  `tex-source/todo-list.tex:539`, `tex-source/todo-list.tex:541`, and
  `tex-source/todo-list.tex:543`, arXiv:2510.03116, arXiv:2408.15074,
  arXiv:2408.13127, arXiv:2408.12092, arXiv:2509.24040,
  arXiv:2508.20935, arXiv:2408.12543, arXiv:2504.02290, and
  arXiv:2408.10956.
  Accessible.  Added `chromaticQuasisymmetric.tex` notes on strong niceness,
  claw-free graphs, and non-Schur-positive distributive lattices; a
  `latticeModel.tex` note on the strange five-vertex model for multispecies
  ASEP; `diagonalHarmonics.tex` notes on the nonsymmetric shuffle theorem,
  Schur-skewing from Rational Shuffle to Rise Delta, and the fall-decorated
  rational shuffle theorem; a `grothendieck.tex` note on Kundu's
  contratableau model for $K$-theoretic Littlewood--Richardson coefficients;
  and a `kschur.tex` note on $K$-theoretic double $k$-Schur functions.

- `tex-source/todo-list.tex:546`, `tex-source/todo-list.tex:547`,
  `tex-source/todo-list.tex:549`, `tex-source/todo-list.tex:551`, and
  `tex-source/todo-list.tex:553`, arXiv:2508.12521, arXiv:2408.10640,
  arXiv:2408.09152, arXiv:2408.07863, and arXiv:2408.00745.
  Accessible.  Added `diagonalHarmonics.tex` notes on Jiang's basis for the
  alternating diagonal coinvariants and on decorated square paths at $q=-1$;
  a `realRootedGraphs.tex` note on ultra-log-concavity and real-rootedness of
  dependence polynomials; a `littlewoodRichardson.tex` note on interlacing
  triangular arrays, Schubert puzzles, and structure constants; and a
  `gammaPositivity.tex` note on equivariant gamma-positivity for matroid Chow
  rings.  Used the published entry for arXiv:2408.07863.

- `tex-source/todo-list.tex:559`, `tex-source/todo-list.tex:561`, and
  `tex-source/todo-list.tex:563`, arXiv:2408.01390, arXiv:2408.01385, and
  arXiv:2407.12076.
  Accessible.  Added a `lascoux.tex` note on Pierson's proof of the
  Monical--Pechenik--Searles K-theoretic polynomial conjecture and a
  `realRootedWords.tex` note on colored multiset Eulerian polynomials.  The
  e-expansion paper arXiv:2408.01385 was already covered in
  `chromaticEexpansion.tex` with bibliography key `TangWang2024x`.  Used the
  published entry for arXiv:2408.01390.

- `tex-source/todo-list.tex:565`, `tex-source/todo-list.tex:566`,
  `tex-source/todo-list.tex:572`, `tex-source/todo-list.tex:574`, and
  `tex-source/todo-list.tex:580`, arXiv:2505.24027, arXiv:2407.10792,
  arXiv:2407.06511, arXiv:2407.04810, and arXiv:2406.19715.
  Accessible.  Added `diagonalHarmonics.tex` notes on the Fields conjectures,
  two-row Delta Springer varieties, and Lentfer's conjectural
  $(1,2)$-bosonic--fermionic coinvariant basis; a `polytopes.tex` note on
  graded Ehrhart theory; and a `superSymmetricSchur.tex` note on
  super-Macdonald polynomials.  Used published entries for arXiv:2407.10792
  and arXiv:2407.04810.

- `tex-source/todo-list.tex:576--578`, arXiv:2410.22329, arXiv:2410.07581,
  and arXiv:2407.06155.
  Already covered in `chromaticEexpansion.tex` by the 2024--2026 chronology
  and ordinary-family list, using keys `TomVailaya2025x`, `ChenHeWang2026`,
  and `Wang2025`.

- `tex-source/todo-list.tex:633`, `tex-source/todo-list.tex:635`,
  `tex-source/todo-list.tex:637`, `tex-source/todo-list.tex:639`,
  `tex-source/todo-list.tex:641`, `tex-source/todo-list.tex:643`,
  `tex-source/todo-list.tex:644`, `tex-source/todo-list.tex:646`, and
  `tex-source/todo-list.tex:648`, arXiv:2402.18716, arXiv:2402.16251,
  arXiv:2402.14217, arXiv:2402.11328, arXiv:2402.11994,
  arXiv:2505.07098, arXiv:2402.05221, arXiv:2401.17223, and
  arXiv:2401.11060.
  Accessible.  Added `crystals.tex` on Temperley--Lieb crystals,
  `cyclic-sieving.tex` on permutation CSP searches from FindStat, `schur.tex`
  on the diagonal derivative of skew Schur polynomials, `polytopes.tex` on
  weight-lifted lattice-point enumeration, `specht-modules.tex` on web bases
  and higher Specht polynomials, `macdonaldP.tex` on Mandelshtam's compact
  Macdonald $P$ formula, and `schubert.tex` on Samuel's Molev--Sagan type
  formula for double Schubert polynomials.  Used the published entry for
  arXiv:2401.11060.

- `tex-source/todo-list.tex:651`, `tex-source/todo-list.tex:653`,
  `tex-source/todo-list.tex:655`, `tex-source/todo-list.tex:657`,
  `tex-source/todo-list.tex:659`, `tex-source/todo-list.tex:662`,
  `tex-source/todo-list.tex:663`, `tex-source/todo-list.tex:665`,
  `tex-source/todo-list.tex:666`, `tex-source/todo-list.tex:667`,
  `tex-source/todo-list.tex:669`, and `tex-source/todo-list.tex:671`,
  arXiv:2401.07492, arXiv:2401.01723, DOI 10.1017/fmp.2023.23,
  arXiv:2312.17469, arXiv:2312.16474, arXiv:2312.15409,
  arXiv:2312.16776, arXiv:2312.13675, arXiv:2312.02958,
  arXiv:2212.08412, arXiv:2312.13681, and arXiv:2312.14348.
  Accessible.  Added `polytopes.tex` on Stricker's Ehrhart formula for
  marked order polytopes, `schurMisc.tex` on Kumari's determinant for
  orthosymplectic Schur functions, `macdonaldP.tex` on Koornwinder/type
  $\tilde C$ Macdonald formulas, `crystals.tex` on shifted set-valued and
  queer crystals, `murnaghanNakayama.tex` on plethystic/spin/q-rook
  Murnaghan--Nakayama results, and `latticeModel.tex` on half-space
  six-vertex symmetric functions.  The skew RSK dynamics item was already
  covered in `whittaker.tex`, and its bibliography entry was upgraded to the
  published Forum of Mathematics, Pi version.  The Kromatic quasisymmetric
  item was already covered in `kromaticSymmetric.tex`.

- `tex-source/todo-list.tex:675`, `tex-source/todo-list.tex:676`,
  `tex-source/todo-list.tex:678`, `tex-source/todo-list.tex:681`,
  `tex-source/todo-list.tex:683`, `tex-source/todo-list.tex:685`,
  `tex-source/todo-list.tex:689`, and `tex-source/todo-list.tex:690`,
  arXiv:2312.02830, arXiv:2312.02383, arXiv:2312.01250,
  arXiv:2311.18099, arXiv:2311.16979, arXiv:2311.09685,
  arXiv:2311.10276, and arXiv:2311.10659.
  Accessible.  Added `realRootedCatalan.tex` on context-free grammars for
  Narayana and related polynomial families, `cyclic-sieving.tex` on
  permutation homomesy from toggling actions, `grothendieck.tex` on maximal
  pipe dreams for double Grothendieck polynomials, `schubert.tex` on dual
  Schubert polynomials via a Cauchy identity, `matroids.tex` on
  Mirković--Vilonen polytopes and Kronecker saturated Newton polytopes, and
  `tableauOperators.tex` on type $B$ and type $C$ Bender--Knuth
  involutions.  The LLT/chromatic powersum item was already covered in
  `chromaticQuasisymmetric.tex`.

- `tex-source/todo-list.tex:695`, `tex-source/todo-list.tex:697`,
  `tex-source/todo-list.tex:699--704`,
  `tex-source/todo-list.tex:706--708`, and
  `tex-source/todo-list.tex:710--722`, arXiv:2310.16235,
  arXiv:2208.08458, arXiv:2209.14176, arXiv:2108.04850,
  arXiv:2011.06063, arXiv:2208.12282, arXiv:2301.02177,
  arXiv:2211.03953, arXiv:2212.13497, arXiv:2304.05285,
  arXiv:2211.06981, arXiv:2205.14835, arXiv:2110.07984,
  arXiv:2307.01130, arXiv:2112.12676, arXiv:2309.05970,
  arXiv:2401.07481, arXiv:2309.06401, arXiv:2106.11913,
  arXiv:2106.11922, arXiv:2204.06166, and arXiv:2109.12908.
  Accessible.  Added `dot-action.tex` on GKM proofs of the modular law,
  `chromaticQuasisymmetric.tex` on chromatic multisymmetric functions,
  centered chromatic symmetric functions, and parabolic Lusztig varieties,
  `cylindricSchur.tex` on cylindric $P$-tableaux, and
  `chromaticEexpansion.tex` on hook-shape immanant characters.  The
  generalized/H/set-valued/kromatic chromatic items, the LLT/chromatic block,
  and the q-Whittaker block had already been covered in earlier passes.

- `tex-source/todo-list.tex:725`, `tex-source/todo-list.tex:726`,
  `tex-source/todo-list.tex:728`, and `tex-source/todo-list.tex:730`,
  arXiv:2403.10485, arXiv:2311.12673, arXiv:2310.17756, and
  arXiv:2310.18275.
  Accessible.  Added `macdonaldE.tex` notes on inhomogeneous
  $t$-PushTASEP/Macdonald polynomials and parasymmetric Macdonald
  polynomials, `jack.tex` on power-sum/map expansions of Jack polynomials,
  and `combinatorialObjects.tex` on the Pak--Postnikov and Naruse skew
  hook-length formulas.

- `tex-source/todo-list.tex:732`, `tex-source/todo-list.tex:734`,
  `tex-source/todo-list.tex:736--738`,
  `tex-source/todo-list.tex:740`, `tex-source/todo-list.tex:742`,
  `tex-source/todo-list.tex:744`, `tex-source/todo-list.tex:746`, and
  `tex-source/todo-list.tex:748`, arXiv:2310.14584, arXiv:2310.09371,
  arXiv:2307.10852, arXiv:2303.09614, arXiv:1711.09962,
  arXiv:2310.15730, arXiv:2310.17362, arXiv:2310.01786,
  arXiv:2309.11203, and arXiv:2309.05903.
  Accessible.  Added `key.tex` on extremal subsets and atom-positivity,
  `standardQuasiSymmetricFunctions.tex` on shuffle bases and quasisymmetric
  power sums, `polytopes.tex` on weighted Ehrhart theory and Fu Liu's
  Ehrhart-positivity survey, `murnaghanNakayama.tex` on the Macdonald
  Murnaghan--Nakayama rule, `macdonaldP.tex` on intermediate Macdonald
  polynomials, `booleanProductPolynomials.tex` on special Chern plethysm
  cases, and `schurPositivity.tex` on transitive/Gallai colorings.  The
  Ferroni--Higashitani magic-positivity implication and the Dyck-path Sturm
  sequence were already covered in `polytopes.tex` and
  `realRootedCatalan.tex`, respectively.

- `tex-source/todo-list.tex:105--120`, arXiv:2407.05904,
  arXiv:2403.12186, arXiv:2010.10493, arXiv:2009.00592,
  arXiv:1906.01286, arXiv:1907.11415, arXiv:2003.00540,
  arXiv:2008.12000, arXiv:2406.14800, arXiv:1905.00047, and
  arXiv:2009.14120.
  Accessible.  Added `schubert.tex` notes on bumpless pipe dreams as Bruhat
  chains, weighted Bruhat-chain enumeration, and pipe dreams for Schubert
  polynomials of classical groups.  Added `grothendieck.tex` notes on inverse
  fireworks permutations, symplectic Grothendieck polynomials,
  higher-dimensional analogues of dual Grothendieck polynomials, and refined
  dual stable Jacobi--Trudi formulas.  Added `standardQuasiSymmetricFunctions.tex`
  on multi-quasisymmetric functions with semigroup exponents.  Hawkes's double
  Grothendieck paper was already covered, and the Hawkes--Scrimshaw crystal
  citation was upgraded to its published form.  Non-arXiv lines 118--119 are
  still open for clarification about the intended theorem statements.

- `tex-source/todo-list.tex:122--134`, FPSAC 2019 article 159,
  arXiv:1403.0607, Stanley's `pubfiles/98.pdf`, arXiv:2007.10886, and
  arXiv:2010.03363.
  Accessible.  Enriched `schurPositivity.tex` with the type $B$
  q-Cauchy/Chow-quasisymmetric content of Mayorova--Vassilieva, expanded the
  noncommutative Murnaghan--Nakayama note in `nonCommutativeFunctions.tex`,
  added Stanley's flag-symmetric poset functions to `pPartitions.tex`, added
  Petrov's refined Cauchy identity for spin Hall--Littlewood rational functions
  to `hallLittlewood.tex`, and added Fel's numerical-semigroup symmetric
  polynomials to `standardSymmetricFunctions.tex`.

- `tex-source/todo-list.tex:144--154`, arXiv:2111.09359,
  arXiv:2106.12176, arXiv:2104.13512, arXiv:2010.15333,
  arXiv:2010.14332, and arXiv:2010.14312.
  Accessible.  Added Goltsblat's type $A$--$D$ ninth-variation characters to
  `superSymmetricSchur.tex`, Ding--Zhu's stability survey/applications to
  `stablePolynomials.tex`, Marciniak's Goulden--Rattan character-polynomial
  result to `characterSymmetricFunctions.tex`, Tetreault's Foulkes-related
  partition order to `plethysm.tex`, and St.~Dizier--Yong's generalized
  permutahedra/Schubert-vanishing criteria to `schubert.tex`.  The twinning
  counterexample to preservation of $e$-positivity was already covered in
  `chromaticEexpansion.tex`.

- `tex-source/todo-list.tex:156--164`, arXiv:2508.13709,
  arXiv:2506.14996, arXiv:2010.13930, arXiv:2508.13988,
  arXiv:2010.13918, arXiv:2509.22648, and arXiv:1909.00081.
  Accessible.  Added Deb's continued-fraction approach to CSPs to
  `cyclic-sieving.tex`, Krattenthaler--Stump positive $m$-divisible
  non-crossing partitions to `cspCatalan.tex`, Nguyen--Vulakh--Woodruff and
  Singh RSK variants to `rsk.tex`, and Gutierrez--Krattenthaler's Schur
  log-concavity results to `schur.tex`.  Enriched the existing
  Akhmejanov--Elek rectangular $\delta$-semistandard tableaux note in
  `cspTableau.tex`.  The Heaton--Shankar symmetric-function inequality
  counterexample was already covered in `standardSymmetricFunctions.tex`.

- `tex-source/todo-list.tex:168--183`, arXiv:1907.03881,
  arXiv:1907.10691, arXiv:1701.01182, Wheeler's Cauchy/Littlewood identity
  slides, arXiv:2003.01211, and arXiv:2003.13719.
  Accessible.  Added Krishnan--Neville's Kostka/LIS connections to
  `kostkaFoulkes.tex`, Lewis--Marberg enriched set-valued $P$-partitions to
  `pPartitions.tex`, Proctor--Willis row-bound refinements to
  `schurFlagged.tex`, resource links for OEIS, FindStat, DOI/arXiv BibTeX
  tools, \LaTeX{} tips, and Viennot videos to `resources.tex`, refined the
  Betea--Wheeler Cauchy/Littlewood identity note in `schur.tex`, added
  Assaf's bijective proof of Kohnert's rule to `kohnert.tex`, and added
  Hamaker--Pechenik--Weigandt's Groebner geometry through ice to
  `schubert.tex`.  Vague lines 166 and 185 are still open for clarification.

- `tex-source/todo-list.tex:198--214`, arXiv:2602.09365,
  arXiv:2602.04036, arXiv:2602.04767, arXiv:2602.02448,
  arXiv:2601.22926, arXiv:2601.23170, arXiv:2601.19998,
  arXiv:2601.17603, and arXiv:2601.13497.
  Accessible.  Added Paten--Woodruff key positivity for Temperley--Lieb
  immanants and flagged skew Schur products to `key.tex`, Guo--Woodruff's
  forest-polynomial pattern-avoidance criterion to `assaf.tex`, Menon--Singh
  descent-restricted subsequences and Kobayashi--Matsumura--Sugimoto
  semistandard oscillating tableaux to `rsk.tex`, Hafner's
  Castelnuovo--Mumford support results to `grothendieck.tex`, Kim--Searles
  type $B$ 0-Hecke poset modules to `gessel.tex`, Colmenarejo--Klein total
  chromatic quasisymmetric functions to `chromaticQuasisymmetric.tex`,
  Diaz--Mainar total positivity via Schur functions to `schur.tex`, and
  Chen--Lu--Ruan double Hall--Littlewood functions to `hallLittlewood.tex`.

- `tex-source/todo-list.tex:216--224`, arXiv:2601.03293,
  arXiv:2601.05471, arXiv:2601.05007, arXiv:2601.04409, and
  arXiv:2601.04182.
  Accessible.  Added Pandey's generalized Petersen graph independence-polynomial
  real-rootedness conjecture to `realRootedGraphs.tex`, Shimazaki's staircase
  hook-length and Jacobi-special-value identities to `combinatorialObjects.tex`,
  Speyer's proof of the Lam--Postnikov--Pylyavskyy conjecture and skeps model
  to `littlewoodRichardson.tex`, Mandelshtam--Niergarth--Singh's $t=0$
  permuted-basement Macdonald atom-positivity result to `macdonaldEperm.tex`,
  and Pak--Robichaux's failure of Schubert coefficient saturation to
  `schubert.tex`.

- `tex-source/todo-list.tex:226--232`, arXiv:2512.20442,
  arXiv:2512.19814, arXiv:2512.18656, and arXiv:2512.19045.
  Accessible.  Added Kahane's zig-zag-poset Ehrhart proof of the
  Watanabe--Yoshida conjecture to `gammaPositivity.tex`, Assaf--Gonzalez's
  local characterization of unions of Demazure crystals to `crystals.tex`,
  Bousquet-Melou--Krattenthaler's CSPs for rooted plane trees and tree-rooted
  maps to `cyclic-sieving.tex`, and Marberg's classical double Grothendieck
  transition equations and $K$-Stanley positivity to `grothendieck.tex` and
  `schurKP.tex`.

- `tex-source/todo-list.tex:234--244`, published DOI `10.1090/mcom/4166`,
  arXiv:2512.04078, arXiv:2512.02267, arXiv:2511.20966,
  arXiv:2511.18156, and arXiv:2511.17034.
  Accessible.  Upgraded the FindStat cyclic-sieving citation in
  `cyclic-sieving.tex` to its published Math. Comp. entry, and added
  permutation flows to `polytopes.tex`, free-boundary $q$-Whittaker and
  Hall--Littlewood processes to `whittaker.tex`, dual affine Schur
  $P$-functions to `stanleySymmetric.tex`, the Allen--Celano--Mason proof of
  the inverse Kostka formula to `kostkaFoulkes.tex`, and Warnaar's affine
  Jacobi--Trudi formulas for Hall--Littlewood rectangles to
  `hallLittlewood.tex`.

- `tex-source/todo-list.tex:246--259`, arXiv:2511.15920,
  arXiv:2511.15094, arXiv:2511.08665, arXiv:2511.02649,
  arXiv:2511.02312, arXiv:2511.01711, arXiv:2511.01114, and
  arXiv:2511.00830.
  Accessible.  Added Schubert polynomial factorizations into elementary
  symmetric products to `schubert.tex`, Richardson tableaux from RSK insertion
  tableaux of noncrossing partial matchings to `rsk.tex`, $H$-chromatic
  distinguishability and basis results to `weightedChromatic.tex`, two recent
  plethysm-coefficient approaches to `plethysm.tex`, matroid Chow classes and
  lattice path matroid volume formulas to `lgv-lemma.tex`, Graf's
  Bernstein-operator deformation to `hallLittlewood.tex`, and Kundu's
  canonical stable Grothendieck Murnaghan--Nakayama rule to
  `grothendieck.tex` and `murnaghanNakayama.tex`.

- `tex-source/todo-list.tex:262--291`, arXiv:2511.00713,
  arXiv:2511.00009, arXiv:2510.27209, arXiv:2510.12723,
  arXiv:2510.10377, arXiv:2510.02587, arXiv:2509.17312,
  arXiv:2508.20337, arXiv:2508.20200, arXiv:2508.15538,
  arXiv:2508.13810, arXiv:2508.12467, arXiv:2508.11879, and
  arXiv:2508.09107.
  Accessible.  Added lexical-tableau quasisymmetric bases to `qsymSchur.tex`,
  LIS asymptotics/RSK survey context to `rsk.tex`, the tableaux algebra and
  Gelfand--Tsetlin semigroup-ring connection to `gtpatterns.tex`,
  polysymmetric-function transition and stack-partition notes to
  `standardSymmetricFunctions.tex`, interpolation Macdonald multiline queues
  to `macdonaldPinterpolation.tex`, double Whittaker lattice models to
  `whittaker.tex`, the permuted-basement identity to `macdonaldEperm.tex`,
  signed chromatic quasisymmetric functions to
  `chromaticQuasisymmetric.tex`, Chow and chain-polynomial real-rootedness
  results to `realRootedGraphs.tex`, super-recurrence log-concavity to
  `realRootedWords.tex`, padded Schubert differential-operator positivity to
  `schubert.tex`, and fireworks Grothendieck support/Newton-polytope results
  to `grothendieck.tex` and `permutationFamilies.tex`.
  The Combinatorial Theory issue link at line 273 is a broad collection link
  and needs selected target papers before promotion.  The arXiv:2105.09964
  todo at line 275 is already covered elsewhere as Schur functions in
  noncommuting variables; the todo wording mentions Rosas--Sagan and should be
  clarified before adding anything further.

- `tex-source/todo-list.tex:293--315`, arXiv:2508.05759,
  arXiv:2508.06188, arXiv:2508.03568, arXiv:2508.00157,
  arXiv:2507.23222, arXiv:2508.00336, arXiv:2507.22528,
  arXiv:2507.18959, arXiv:2507.11516, arXiv:2507.09304,
  arXiv:2507.08560, and arXiv:2507.08083.
  Accessible.  Added generalized Jack-binomial monotonicity and positivity to
  `jack.tex`, CJT-refined Fock-space/Jucys--Murphy theory to
  `standardSymmetricFunctions.tex`, the plethystic chain rule to
  `plethysm.tex`, chromatic MacMahon symmetric functions to
  `weightedChromatic.tex`, weighted $K$-$k$-Schur functions to `kschur.tex`,
  nonsymmetric Macdonald saturated Newton polytopes to `macdonaldE.tex`,
  supersymmetric Schur saturated Newton polytopes to
  `superSymmetricSchur.tex`, higher-order Stirling triangle real-rootedness
  questions to `realRootedWords.tex`, inversion tableaux to `schubert.tex`,
  Cayley permutations to `permutationGeneralizations.tex`, Schur generating
  functions for random Aztec-diamond tilings to `schur.tex`, and symmetry
  classifications for quasisymmetric Schur-like functions to `qsymSchur.tex`.

- `tex-source/todo-list.tex:318--333`, arXiv:2508.11587,
  arXiv:2507.07243, arXiv:2507.00433, arXiv:2507.00580,
  arXiv:2506.21052, arXiv:2506.20792, DOI:10.5070/C65365563,
  arXiv:2506.09015, arXiv:2506.07727, and arXiv:2506.00349.
  Accessible.  Added inversion and interval statistics for parking functions
  to `parking-functions.tex`, Stanton's Rogers--Ramanujan proof via the
  Schur Cauchy identity to `schur.tex`, lacunary RSK/Cauchy identities and
  Richardson tableaux from Springer geometry to `rsk.tex`, Grothendieck
  Cauchy identities and pipe-dream rectification to `grothendieck.tex`,
  Keating's LLT lattice-path equivalences to `llt.tex`, Weising's wreath
  generalization of Littlewood reciprocity to `plethysm.tex`, and
  shuffle/peelable-tableau Littlewood--Richardson rules to
  `littlewoodRichardson.tex`.  The flagged LLT/nonsymmetric Macdonald item
  arXiv:2506.09015 was already covered in `llt.tex` with existing citation
  `BlasiakHaimanMorsePunSeelinger2025x`.

- `tex-source/todo-list.tex:334--354`, arXiv:2505.18504,
  arXiv:2505.19072, arXiv:2505.14885, arXiv:2505.09275,
  arXiv:2504.21395, arXiv:2504.20975, arXiv:2504.19205,
  arXiv:2504.18825, arXiv:2506.09421, arXiv:2504.17734,
  arXiv:2504.12583, and arXiv:2504.15234.
  Accessible.  Added higher-order Bell symmetric functions to
  `standardSymmetricFunctions.tex`, hybrid Grothendieck polynomials to
  `grothendieck.tex`, and diagonal supersymmetry for coinvariant rings to
  `superSymmetricSchur.tex`.  The Robbins/Littlewood identity, magic-positive
  Ehrhart dilation, poset symmetric-function, spin Hall--Littlewood structure
  constant, cyclotomic Hecke Murnaghan--Nakayama, triple Schubert positivity,
  signed-puzzle Schubert-coefficient, and equivariant quasisymmetry items were
  already covered in the relevant pages.  Updated the Hadamard-product note in
  `realRooted.tex` to record the arXiv caveat that Sokal's conjecture remains
  open.

- `tex-source/todo-list.tex:356--380`, arXiv:2504.15234,
  arXiv:2504.05123, arXiv:2504.01623, arXiv:2503.19344,
  arXiv:2510.11322, arXiv:2503.19621, arXiv:2503.19694,
  arXiv:2503.17552, arXiv:2503.09240, arXiv:2503.06051,
  arXiv:2503.03903, arXiv:2502.15586, and arXiv:2502.08738.
  Accessible and already covered.  These appear respectively on
  `standardQuasiSymmetricFunctions.tex`, `polytopes.tex`,
  `lorentzianPolynomials.tex`, `chromaticEexpansion.tex`, `matroids.tex`,
  `lattice-path-matroids.tex`, `representationTheory.tex`,
  `murnaghanNakayama.tex`, `key.tex`, `macdonaldEperm.tex`, `schubert.tex`,
  `schurMisc.tex`, and `standardSymmetricFunctions.tex`.

- `tex-source/todo-list.tex:382--390`, arXiv:2507.00766,
  arXiv:2504.08187, arXiv:2502.09072, arXiv:2502.02841,
  arXiv:2501.18520, and arXiv:2501.14691.
  Accessible and already covered.  These appear respectively on
  `whittaker.tex`, `unicellular-llt.tex`, `nonCommutativeFunctions.tex`,
  `schurShifted.tex`, `schurMisc.tex`, and `grothendieck.tex`.

- `tex-source/todo-list.tex:392--420`, arXiv:2501.11304,
  arXiv:2501.15667, arXiv:2412.18984, arXiv:2412.19721,
  arXiv:2112.09633, arXiv:2501.16640, arXiv:2010.10493,
  arXiv:2412.20615, arXiv:2405.01166, arXiv:2501.04245,
  arXiv:2501.01947, arXiv:2501.00275, arXiv:2501.04432,
  arXiv:2501.04200, and arXiv:2412.10556.
  Accessible and already covered.  These appear respectively on
  `qsymSchur.tex`, `standardQuasiSymmetricFunctions.tex`, `schubert.tex`,
  `schurMisc.tex`, `rsk.tex`, `grothendieck.tex`, `grothendieck.tex`,
  `grothendieck.tex`, `chromaticEexpansion.tex`, `realRooted.tex`,
  `littlewoodRichardson.tex`, `schurMisc.tex`, `schurMisc.tex`,
  `kschur.tex`, and `chromaticQuasisymmetric.tex`.

- `tex-source/todo-list.tex:491`, arXiv:2410.04644.
  Accessible.  Added a `murnaghanNakayama.tex` note on Westrem's alternating
  power-sum identity over $\operatorname{Ev}(\lambda)$ and its application to
  vanishing sums of irreducible symmetric-group characters.

## Access Needed

None from this pass.
