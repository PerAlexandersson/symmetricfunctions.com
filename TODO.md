# TeX source cleanup TODO

Updated 2026-05-07 after applying the mechanical text, hyperlink, name,
label, and citation-key fixes from the original 2026-04-21 cleanup plan.

Only remaining items below need metadata/source judgment or additional content
writing.

## Citation and raw-link cleanup

These are not currently broken, but they should be converted to proper
`bibliography.bib` entries or existing citation keys after verifying metadata.

| File:line | Current text | Remaining work |
|---|---|---|
| `tex-source/grothendieck.tex:305` | `\href{https://arxiv.org/pdf/math/0601514.pdf}{this paper}` | Replace generic link with a proper citation key following the site convention. |
| `tex-source/grothendieck.tex:307` | `\url{https://arxiv.org/pdf/1701.03561.pdf}` | Add or locate a bib entry and cite it instead of using a raw URL. |
| `tex-source/grothendieck.tex:308` | `\url{https://arxiv.org/pdf/1711.09544.pdf}` | Add or locate a bib entry and cite it instead of using a raw URL. |
| `tex-source/macdonaldH.tex:267` | `\todo{cite preprint properly.}` | Resolve by adding or using a bib entry. |
| `tex-source/macdonaldH.tex:268` | `\href{https://www.newton.ac.uk/files/preprints/ni01035.pdf}{this preprint}` | Replace with a proper citation after metadata check. |
| `tex-source/cspWord.tex:95` | `In this preprint, \url{https://arxiv.org/pdf/2005.14031.pdf}` | Replace with a proper citation. |
| `tex-source/whittaker.tex:21` | Lam intro raw arXiv URL | Add or locate a bib entry and cite it. |
| `tex-source/whittaker.tex:23` | Iwahori Whittaker raw arXiv URL | Add or locate a bib entry and cite it. |
| `tex-source/whittaker.tex:25` | Spin q-Whittaker raw arXiv URL | Add or locate a bib entry and cite it. |
| `tex-source/whittaker.tex:27` | `(p,q)-Whittaker` raw arXiv URL | Add or locate a bib entry and cite it. |
| `tex-source/whittaker.tex:29` | Metaplectic Whittaker raw arXiv URL | Add or locate a bib entry and cite it. |
| `tex-source/lattice-path-matroids.tex:27` | Bonin lecture notes linked directly | Add a lecture-notes bib entry or keep the direct link. Existing `Bonin2010` appears to be a different article. |

## Content additions

| File:line | Remaining work |
|---|---|
| `tex-source/realRooted.tex:101` | The `AthanasiadisWagner2024` citation for Veronese sections is already present. Expand this section if you want an explicit explanation of how the k-Veronese framework gives interlacing polynomial families. |
