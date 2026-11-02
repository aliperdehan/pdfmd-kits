# revtex: APS and AIP journals

`pdfmd paper --kit revtex` builds `paper.md` with the revtex4-2 class and the APS (or AIP) citation style.

| Mode | Journal | Layout |
|---|---|---|
| `prl` (default; `aps`, `letters`) | Physical Review Letters | two columns (`reprint`) |
| `prb`, `pra`, `pre` | Physical Review B, A, E | two columns |
| `jcp` (`aip`) | Journal of Chemical Physics (AIP) | two columns, AIP citation style |
| `preprint` | APS | one column, double-spaced |

## Front matter

```yaml
title: "A Demonstration of the revtex Kit"
author:
  - name: Ada Example
    email: ada@example.org
    affiliation: 1
  - name: Jane Roe
    affiliation: [1, 2]               # one \affiliation per entry; numbered with superscriptaddress
affiliation:
  - Department of Physics, Example University, Example City
  - Institute of Optics, Other University, Other City
date: March 3, 2026                   # printed as "(Dated: ..)"; nothing is printed without it
abstract: |
  One paragraph.
keywords: [kits, pdfmd]
bibliography: refs.bib
```

An example is in [`example/`](example/).

## Known limits

- Tested with lualatex, xelatex and Tectonic; not with pdflatex.
- Section headings follow the journal's own style (small capitals, centred), not Pandoc's.
