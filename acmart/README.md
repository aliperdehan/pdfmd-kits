# acmart: ACM papers

`pdfmd paper --kit acmart` builds `paper.md` with the acmart class and the ACM citation style (`[1]`).

| Mode | Layout |
|---|---|
| `sigconf` (default; `conference`, `proceedings`) | conference proceedings, two columns |
| `sigplan` | SIGPLAN proceedings |
| `manuscript` (`review`) | one column, for review |

The ACM reference-format block and the copyright notice are switched off (a paper that is not yet accepted has neither).
Give the venue in the front matter to get them: `acmconference: [short, name, date, place]` or `acmjournal: TOMS`.

## Front matter

```yaml
title: "A Demonstration of the acmart Kit"
author:
  - name: Ada Example
    email: ada@example.org
    affiliation: 1
  - name: Jane Roe
    affiliation: 2
affiliation:                          # a text (the last comma part is taken as the country) ...
  - Department of Computer Science, Example University, Example City
  - institution: Other University     # ... or a map: institution, department, city, state, postcode, country
    city: Other City
    country: Country
abstract: |
  One paragraph.
keywords: [kits, pdfmd, ACM]
bibliography: refs.bib
```

An example is in [`example/`](example/). acmart insists on a country for every affiliation, hence the last-comma rule.

## Known limits

- CCS concepts (`CCSXML`, `\ccsdesc`), `\acmDOI`, `\acmISBN` and the other publication macros are not generated; write them as
  raw LaTeX.
- The text font is Libertinus Serif (the maintained successor of the Libertine of the class); set `mainfont:` to change it.
- Tested with lualatex, xelatex and Tectonic; not with pdflatex.
