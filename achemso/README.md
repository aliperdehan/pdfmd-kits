# achemso: American Chemical Society journals

`pdfmd paper --kit achemso` builds `paper.md` with the achemso class and the ACS citation style: the title block with
authors, affiliations and corresponding-author e-mails, the abstract, `# References` in ACS form, numbered citations.

| Mode | Manuscript type (class option `manuscript=`) |
|---|---|
| `article` (default; `paper`) | full paper |
| `communication` (`comm`) | communication |
| `letter` | letter |
| `note` | note |
| `review` | review article |

The target journal is `journal:` in the front matter (a class option, `jacsat` by default; the codes are in
`tex/upstream/achemso.pdf`).

## Front matter

```yaml
title: "A Demonstration of the achemso Kit"
author:
  - name: Ada Example
    email: ada@example.org            # a corresponding author
    affiliation: 1
  - name: Jane Roe
    affiliation: [1, 2]               # a second affiliation becomes \alsoaffiliation
affiliation:
  - Department of Chemistry, Example University, Example City
  - Institute of Materials, Other University, Other City
journal: jacsat
abstract: |
  One paragraph.
keywords: [kits, pdfmd]               # printed by journals that ask for them
abbreviations: [IR, NMR, UV]
bibliography: refs.bib
```

An example is in [`example/`](example/). Consecutive authors with the same affiliations are one group (achemso applies an
`\affiliation` to all authors before it). `phone:` and `fax:` per author are passed on.

## Known limits

- Tested with lualatex, xelatex and Tectonic; not with pdflatex.
- Pandoc's citeproc output (`\cite` and `\bibitem[label]`) does not survive achemso's own redefinitions, so citations are
  plain numbers from the citation style, without links.
- `\SectionNumbersOn`, `tocentry` and the supporting-information environments are not set; write them as raw LaTeX.
