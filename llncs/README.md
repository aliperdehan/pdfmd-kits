# llncs: Springer Lecture Notes in Computer Science

`pdfmd paper --kit llncs` builds `paper.md` with Springer's llncs class and the LNCS citation style (`[1]`).

| Mode | Layout |
|---|---|
| `proceedings` (default; `lncs`, `runningheads`) | with running heads: `\titlerunning` is the title, `\authorrunning` "Surname et al." |
| `plain` | without running heads |

## Front matter

```yaml
title: "A Demonstration of the llncs Kit"
author:
  - name: Ada Example
    email: ada@example.org            # printed under the author's first institute
    affiliation: 1
  - name: Jane Roe
    affiliation: [1, 2]               # \inst{1,2}
affiliation:
  - Department of Computer Science, Example University, Example City
  - Institute of Logic, Other University, Other City
abstract: |
  One paragraph.
keywords: [kits, pdfmd, LNCS]         # written inside the abstract, separated by \and
bibliography: refs.bib
```

An example is in [`example/`](example/). The paper size is A4 (the class's own).

## Known limits

- `\orcidID` and an `\email` outside the institute block are not generated; write them as raw LaTeX.
- Tested with lualatex, xelatex and Tectonic; not with pdflatex.
