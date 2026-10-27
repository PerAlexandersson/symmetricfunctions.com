# Polynomial relations

Families of polynomials are linked by relation rows in their `polydata`
blocks. This file records the relation vocabulary, what the build already does
with it, and what is still open. The row syntax is in `CONVENTIONS.md`.

## Current implementation

- `relation_registry.lua` is the single registry of relation types: TeX keys
  and aliases, labels, transitivity, poset type and allowed attributes.
- `gather.lua` parses both the legacy rows (`target | Key`, `target [Key]`,
  semicolon-separated targets) and the structured grammar
  `target | Key[,Key...] | attr=value; ...`.
- `merge_meta.lua` checks relation types, targets, statuses, attributes and
  bibliography keys. Unknown targets or keys, a missing key, invalid statuses
  and unexpected attributes are all errors.
- `relation_graph.lua` writes `www/polynomial-relations.json` and the page
  `www/polynomial-relations.htm`, linked as **Relations** in the top navigation.
  `assets/relation-graph.js` draws one or more selected relation types as a
  layered graph, with search and a details panel listing the references.
  Strongly connected components share a layer and layers follow longest paths;
  all asserted edges are drawn.
- Edges with `status=question` or `include=false` are kept in the data but not
  drawn.

The legacy seed data (`polynomialData.m` and the `tikzdata*` files) has been
migrated. As of 2026-10-27, 134 of 179 families have relations: 326 edges, all
with bibliography keys, of which 3 are conjectures.

## Conventions

Arrows point from the more general, structured or source family to the more
specific family obtained from it:

```text
key -> schur          Generalizes
schubert -> schur     Contains
macdonaldE -> key     SpecializesTo
llt -> schur          PositiveIn
```

- Each family page owns the outgoing relation rows of its `polydata` entries.
  Generated JSON and graph views are derived from these rows; build code may
  normalize and validate them but never adds mathematical assertions.
- A relation stated in prose should also appear as a structured row once its
  type is supported.
- Every edge cites at least one bibliography key. An unproved edge is marked
  `status=conjecture` and cites where the conjecture is stated. Edges without
  a source stay in notes rather than in `polydata`.

## Relation types

| TeX key | Reading | Transitive | Poset |
| --- | --- | :---: | :---: |
| `PositiveIn` | source expands positively in target | yes | yes |
| `Generalizes` | source generalizes target | yes | yes |
| `Contains` | target is a subfamily or special case of source | yes | yes |
| `SpecializesTo` | parameter value, limit or substitution gives target | yes | yes |
| `DegeneratesTo` | source degenerates or limits to target | yes | yes |
| `StableLimit` | target is the stable limit of source | yes | no |
| `RefinedBy` | target refines source | yes | no |
| `SignedIn` | expansion in target with a predictable sign rule | no | no |
| `KTheoreticAnalogueOf` | source is a K-theoretic analogue of target | no | no |
| `TransformsTo` | a named transform relates source and target | no | no |
| `DualTo` | dual under a specified pairing or involution | no | no |
| `NSymQSymDual` | dual under the NSym/QSym pairing | no | no |

Legacy aliases such as `ExpandsPositiveIn` and `SupersetOf` remain accepted;
see the registry for the full list.

## Attributes

Valid on every relation:

| Attribute | Meaning |
| --- | --- |
| `status=theorem` | proved relation (default) |
| `status=conjecture` | conjectural relation |
| `status=question` | open question; kept in the data, not drawn |
| `scope=...` | hypotheses or indexing restrictions, such as `Grassmannian` |
| `note=...` | short note |
| `include=false` | kept in the data, not drawn |

Relation-specific (the registry lists which relations accept which):

| Attribute | Meaning |
| --- | --- |
| `map=...` | specialization, limit or transform, such as `q=0` or `omega` |
| `parameter=...` | relevant deformation parameter |
| `semiring=...` | coefficient semiring, such as `NN[q,t]` |
| `sign_rule=...` | sign convention for a signed expansion |
| `combinatorial_rule=known` / `none_known` | whether a positive combinatorial rule is known |
| `pairing=...` | pairing or involution defining a duality |
| `proof=...` | proof style: `combinatorial`, `geometric` or `algebraic` |

`status` records truth status only; use `combinatorial_rule=none_known` rather
than a status for "no combinatorial rule is known".

## Open items

- Report cycles in poset-type relations at build time. The browser currently
  places a cycle in a single layer without comment.
- Add a Hasse view: transitive reduction per poset-type relation, keeping the
  references of every asserted edge and never citing inferred edges.
- Warn about duplicate edges with different references.
- Optionally embed per-family relation neighbourhoods or static diagrams in
  family pages.
