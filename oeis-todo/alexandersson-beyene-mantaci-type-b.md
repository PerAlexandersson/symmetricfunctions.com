# OEIS follow-up for type B set partitions and flattened signed permutations

Source: Per Alexandersson, Fufa Beyene, and Roberto Mantaci, “Some Families
of Type B Set Partitions Counted by the Dowling Numbers,”
[arXiv:2601.17174v3](https://arxiv.org/abs/2601.17174v3), 2 September 2026.

Audit date: 10 September 2026.  No OEIS edits have been submitted.  The rows
below were generated exactly from the recurrences in the paper and checked by
exact-term and description searches against the live OEIS.  “New” means that
no exact OEIS entry was found; it should still receive a final Superseeker
check when submitted.

## Existing entries needing the paper or a stronger comment

| OEIS | Match in the paper | Suggested action |
|---|---|---|
| [A075497](https://oeis.org/A075497) | $w_{n,k}=2^{n-k}S(n,k)$, the coefficients of $T_n(x)$, Proposition 7, pp. 4–5 | Add the paper and the interpretation as type B set partitions without a zero block, counted by blocks. |
| [A039755](https://oeis.org/A039755) | $S_B(n,k)$, equation (1), p. 4 | Add the paper; these are type B set partitions counted by nonzero blocks. |
| [A124324](https://oeis.org/A124324) | $a_{n+1,k+1}=T(n,k)$, pp. 10–12 | Add the paper and the interpretation as type A merging-free partitions of $[n+1]$ with $k+1$ blocks. |
| [A217924](https://oeis.org/A217924) | $A217924(n)=\sum_k\widetilde b_{n+1,k}$, pp. 11–12 | Add the paper and the new interpretation as the total number of the restricted type B merging-free partitions defined before Example 25. |
| [A000110](https://oeis.org/A000110) | $B_{n-1}$ is the number of valley-hopping orbits on $R^B_n$, Proposition 56, pp. 22–23 | Add the paper and this orbit interpretation. |
| [A004211](https://oeis.org/A004211) | Already cited for type B partitions without a zero block; also $\sum_k u_{n+1,k}=A004211(n)$, pp. 14–16 | Keep the existing link but extend its page locator and add the merging-free separated interpretation. |
| [A007405](https://oeis.org/A007405) | Already cited for Dowling numbers; $A007405(n-1)$ also counts type B merging-free partitions and the flattened signed permutations $R^B_n$, pp. 10 and 19–24 | Keep the existing link but add these interpretations and page locators. |

[A008299](https://oeis.org/A008299) already links to the paper and points to
p. 16, where Corollary 42 gives the type A merging-free separated
interpretation.  [A123125](https://oeis.org/A123125) also already links to the
paper; it is used only as background for ordinary Eulerian numbers.  No change
is needed for either entry.

### Ready-to-paste link

Use this link line for the entries above, changing only the final page/theorem
locator:

> Per Alexandersson, Fufa Beyene, and Roberto Mantaci, [Some Families of Type B Set Partitions Counted by the Dowling Numbers](https://arxiv.org/abs/2601.17174), arXiv:2601.17174 [math.CO], 2026.

## New coefficient-triangle candidates

### 1. Type B merging-free partitions by blocks

High priority.  Let $b_{n,k}$ count type B merging-free partitions without a
zero block over ⟨n⟩ with $k$ blocks.  Proposition 24 gives

\[
b_{n,k}=2k b_{n-1,k}+2(n-2)b_{n-2,k-1},
\qquad b_{0,0}=b_{1,1}=1.
\]

Rows $n\geq1$, with zero trailing entries omitted:

```text
1;
2;
4, 2;
8, 16;
16, 88, 12;
32, 416, 200;
64, 1824, 2080, 120;
128, 7680, 17472, 3360;
256, 31616, 130368, 56000, 1680;
512, 128512, 905088, 727552, 70560.
```

Formula: $b_{n,k}=2^{n-k}a_{n,k}$, where
$a_{n,k}=A124324(n-1,k-1)$.  Row sums are
$A007405(n-1)$.  The row polynomials are real-rooted and consecutive rows
interlace by Proposition 27 and Corollary 28.

### 2. Restricted type B merging-free partitions by blocks

High priority because this is also the gamma triangle in Theorem 59.  The
numbers $\widetilde b_{n,k}$ count the restricted family defined immediately
before Example 25 and satisfy

\[
\widetilde b_{n,k}=k\widetilde b_{n-1,k}
 +2(n-2)\widetilde b_{n-2,k-1},
\qquad \widetilde b_{0,0}=\widetilde b_{1,1}=1.
\]

Rows $n\geq1$:

```text
1;
1;
1, 2;
1, 8;
1, 22, 12;
1, 52, 100;
1, 114, 520, 120;
1, 240, 2184, 1680;
1, 494, 8148, 14000, 1680;
1, 1004, 28284, 90944, 35280.
```

Formula: $\widetilde b_{n,k}=2^{k-1}a_{n,k}$.  The row sums, beginning
at $n=1$, are [A217924](https://oeis.org/A217924).  The row polynomials
are real-rooted and consecutive rows interlace.  These entries are the gamma
coefficients of the flattened signed-permutation descent polynomials.

### 3. Type B merging-free separated partitions by blocks

High priority.  Let $u_{n,k}$ count type B partitions without a zero block
that are both merging-free and separated.  Theorem 33 gives

\[
u_{n,k}=(2k-1)u_{n-1,k}+2(n-2)u_{n-2,k-1},
\qquad u_{0,0}=u_{1,1}=1.
\]

Rows $n\geq1$:

```text
1;
1;
1, 2;
1, 10;
1, 36, 12;
1, 116, 140;
1, 358, 1060, 120;
1, 1086, 6692, 2520;
1, 3272, 38472, 32480, 1680;
1, 9832, 209736, 334432, 55440.
```

The row sums are $A004211(n-1)$.  The row polynomials are real-rooted by
Theorem 33.  Corollary 41 also identifies $u_{n,k}$ with type B partitions
without a zero block over ⟨n−1⟩ having $k-1$ nonsingleton blocks.

### 4. Descents on flattened signed permutations

High priority.  Let

\[
d_{n,k}=\#\{\sigma\in R^B_n:\operatorname{des}(\sigma)=k\}.
\]

Rows $n\geq1$:

```text
1;
1, 1;
1, 4, 1;
1, 11, 11, 1;
1, 26, 62, 26, 1;
1, 57, 266, 266, 57, 1;
1, 120, 991, 1864, 991, 120, 1;
1, 247, 3405, 10667, 10667, 3405, 247, 1;
1, 502, 11140, 54058, 88518, 54058, 11140, 502, 1;
1, 1013, 35348, 253532, 626218, 626218, 253532, 35348, 1013, 1.
```

Theorem 59 gives the gamma expansion

\[
\sum_k d_{n,k}x^k
=\sum_i \widetilde b_{n,i+1}x^i(1+x)^{n-1-2i}.
\]

The row sums are $A007405(n-1)$; Corollary 60 proves real-rootedness.
This is **not** [A085852](https://oeis.org/A085852): the arrays first differ
in the $n=6$ row, where A085852 has $258$ in place of the second $266$,
and A085852 is not symmetric from that row onward.

### 5. Successions or merging blocks on type B partitions without a zero block

Medium priority.  Let $c_{n,r}$ count type B set partitions without a zero
block over ⟨n⟩ having $r$ successions.  Theorem 14 gives the same
numbers for $r$ merging blocks.  Equation (10) implies

\[
c_{n,r}=\binom{n-1}{r}A007405(n-r-1).
\]

Rows $n\geq1$:

```text
1;
2, 1;
6, 4, 1;
24, 18, 6, 1;
116, 96, 36, 8, 1;
648, 580, 240, 60, 10, 1;
4088, 3888, 1740, 480, 90, 12, 1;
28640, 28616, 13608, 4060, 840, 126, 14, 1;
219920, 229120, 114464, 36288, 8120, 1344, 168, 16, 1;
1832224, 1979280, 1031040, 343392, 81648, 14616, 2016, 216, 18, 1.
```

This is the type B analogue of [A056857](https://oeis.org/A056857).  Row sums
are A004211.  The finer three-index numbers $w_k(n,s)$ need not be a separate
OEIS submission: equation (10) reduces their block polynomials to the
$s=0$ family by

\[
Q_{n,s}(x)=\binom{n-1}{s}Q_{n-s,0}(x).
\]

## Search disposition

- A075497 was found only after removing the extra $n=0$ row from the term
  query; its terms and recurrence agree exactly with Proposition 7.
- Exact flattened-row searches, reversed-row searches, distinctive later-term
  searches, and description searches found no entry for candidates 1–5.
- All scalar row-sum matches were checked separately.  In particular, the
  apparently new totals $1,1,3,9,35,153,\ldots$ of
  $\widetilde b_{n,k}$ are A217924, so they should not be submitted as a new
  scalar sequence.
- The two-parameter $Q_{n,s}(x)$ family and the gamma coefficients introduce
  no additional independent arrays beyond the candidates recorded above.
