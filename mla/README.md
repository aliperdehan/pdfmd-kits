# mla: MLA-style papers

`pdfmd paper --kit mla` builds `paper.md` with the mlacls class (the heading block, a running head, double spacing) and the
MLA citation style (`(Skoog et al. 12)`).

```yaml
title: "A Demonstration of the mla Kit"
author: Ada Example
professor: Dr. A. Instructor          # or instructor:
course: ENG 101
date: 3 November 2026                 # today's date in MLA form when left out
bibliography: refs.bib
```

Cite with `[@key, p. 12]`; a final `# Works Cited` heading receives the list. An example is in [`example/`](example/).

## Known limits

- **Tectonic does not work with this class.** The class loads biblatex with the biber back end, and Tectonic then runs the
  system's biber, which does not match the biblatex of Tectonic's own bundle ("expected version 3.11"). Use xelatex or
  lualatex.
- One author only (several are joined with commas on the heading line).
- No `lang:` is set: the class loads `babel[american]` itself.
