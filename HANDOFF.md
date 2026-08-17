# Handoff

## Current scope

Add the August 2026 symmetric-function preprints selected by the user, with a
new page for the weighted-bond-poset symmetric function, a decision and likely
new page for Koornwinder polynomials, exact Rust-backed examples, and
cross-linked updates for Lorentzian skew Schur polynomials, Schubert
polynomials, Butler positivity, (m)-symmetric functions, and plethysm.

## Ownership

The main worker owns the relevant `tex-source/` pages, `bibliography.bib`, this
handoff, and any new Rust example/test explicitly recorded in the Rust project
handoff. No other worker should edit those files while this scope is active.

## Starting state

- The SymCat worktree was clean at the start.
- Local `master` was already three commits ahead of `origin/master`; those
  pre-existing commits must be preserved and not rewritten.
- No project `HANDOFF.md` existed before this task.
- No paper/PDF MCP servers are configured in this host session. The fallback is
  the live arXiv++ REST/BibTeX API, primary arXiv PDFs, and `pdf2txt.py`.

## Status

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
