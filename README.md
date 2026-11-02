# kits

Ready-made [pdfmd](https://github.com/aliperdehan/pdfmd) kits: a LaTeX class or package, its Lua filter, default
metadata and citation style in one folder, so that `pdfmd paper --kit apa7` produces a paper in that house style
from a plain Markdown file. Each kit carries what it needs, so it works with a full TeX Live, with
[Tectonic](https://tectonic-typesetting.github.io/) or with a minimal TeX installation.

| Kit | Style | Modes |
|---|---|---|
| [`apa7`](apa7/) | APA 7th edition (apa7 class, `apa.csl`) | `stu` (default), `man`, `doc`, `jou` |

## Use

```sh
git clone https://github.com/aliperdehan/kits ~/kits
```

Name the folder once in pdfmd's config (`kits:` in `~/.config/pdfmd/config.yaml`, or the *Folders of kits* row of
`pdfmd --setup`), then:

```sh
pdfmd paper --kit apa7          # the student-paper mode
pdfmd paper --kit apa7:man      # a professional manuscript
pdfmd --kits                    # lists the kits pdfmd can see
```

or choose it in the paper's front matter, `pdfmd-options: {kit: apa7:man}`. A `kits/` folder beside the document
is found without any configuration.

## apa7 front matter

```yaml
---
title: "Sleep Deprivation and Working Memory"
shorttitle: "Sleep and Working Memory"     # the running head; the title when left out
author:
  - name: Ali Perdekhan
    affiliation: 1
  - name: Jane Roe
    affiliation: [1, 2]
affiliation:
  - Department of Chemistry, Example University
  - School of Humanities, Example University
course: "SOC 203: Research Methods"        # student paper
professor: Dr. A. Instructor               # student paper
duedate: November 3, 2026                  # student paper (date: is used when there is none)
abstract: |
  One paragraph.
keywords: [sleep, working memory]
authornote: ...                            # manuscript
bibliography: refs.bib                     # citations are [@key] and `apa.csl` formats them
---
```

`# References` starts a page of its own in the `stu` and `man` modes.

## Tectonic

Tectonic does not read `TEXINPUTS`, so a kit's own copy of a class is only used when its folder is given with
`-Zsearch-path` (without it Tectonic quietly builds with the class from its own bundle):

```sh
pdfmd paper --kit apa7 -e tectonic --pdf-engine-opt=-Zsearch-path="$HOME/kits/apa7/tex"
```

## Licenses

The kit files are MIT. The files copied from elsewhere (the apa7 class, `apa.csl`) keep their own licenses and are
listed with their source, authors and checksums in [`THIRD_PARTY.md`](THIRD_PARTY.md); the license texts are in
[`LICENSES/`](LICENSES/). This repository is not affiliated with the American Psychological Association or with any
publisher.
