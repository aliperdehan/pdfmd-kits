# elsarticle: Elsevier journals

`pdfmd paper --kit elsarticle` builds `paper.md` with the elsarticle class: a `frontmatter` block (title, authors with
affiliation labels, corresponding author, abstract, keywords) and an Elsevier citation style.

| Mode | Layout | Citations |
|---|---|---|
| `preprint` (default) | preprint, 12 pt | author-year (Elsevier Harvard) |
| `numbered` | preprint, 12 pt | numbered (Elsevier, with titles) |
| `review` | double-spaced review | author-year |
| `3p` | journal, one column | author-year |
| `5p` | journal, two columns | author-year |

## Front matter

```yaml
title: "A Demonstration of the elsarticle Kit"
author:
  - name: Ada Example
    email: ada@example.org
    corresponding: true               # \corref and \cortext
    affiliation: 1
  - name: Jane Roe
    affiliation: [1, 2]
affiliation:
  - Department of Chemistry, Example University, Example City, Country
  - Institute of Materials, Other University, Other City, Country
journal: Journal of Examples          # \journal{..}
abstract: |
  One paragraph.
keywords: [kits, pdfmd]
bibliography: refs.bib
```

An example is in [`example/`](example/). An affiliation is written as `organization={..}`.

## Known limits

- Tested with lualatex, xelatex and Tectonic; not with pdflatex.
- The whole block is written into the document through `include-before`, so a `title:` etc. in the front matter is read by the
  kit and not by Pandoc's template.
- Citations are plain text from the citation style, without links.
