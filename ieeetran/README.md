# ieeetran: IEEE papers

`pdfmd paper --kit ieeetran` builds `paper.md` with the IEEEtran class and the IEEE citation style (`[1]`).

| Mode | Paper |
|---|---|
| `conference` (default; `conf`) | conference paper, author blocks side by side |
| `journal` (`jrnl`, `transactions`) | journal paper: names in the title, affiliations in a footnote |

## Front matter

```yaml
title: "A Demonstration of the IEEEtran Kit"
author:
  - name: Ada Example
    email: ada@example.org
    affiliation: 1
  - name: Jane Roe
    email: jane@example.org
    affiliation: 2
affiliation:
  - Department of Electrical Engineering, Example University, Example City
  - Institute of Signals, Other University, Other City
abstract: |
  One paragraph.
keywords: [kits, pdfmd]               # IEEEkeywords ("Index Terms")
bibliography: refs.bib
```

An example is in [`example/`](example/).

## Known limits

- The conference mode puts each author in an `\IEEEauthorblockN`/`\IEEEauthorblockA` block with the affiliation and e-mail
  on separate lines; `\IEEEmembership`, `\thanks` and the special journal front pages are not generated (write them as raw
  LaTeX in the text).
- Tested with lualatex, xelatex and Tectonic; not with pdflatex.
