# apa7: APA 7th edition papers

`pdfmd paper --kit apa7` builds `paper.md` as an APA 7th edition paper: the apa7 class (title page, running head,
double spacing, headings, a reference list on its own page) and `apa.csl` (in-text citations and references from a
`.bib` file). Everything it needs is in this folder; see [`../THIRD_PARTY.md`](../THIRD_PARTY.md) for the sources.

| Mode | Paper | Notes |
|---|---|---|
| `stu` (default; `student`) | student paper | title page with `course`, `professor`, `duedate` |
| `man` (`manuscript`, `professional`) | professional manuscript | author note, running head |
| `doc` (`document`) | single-spaced document in APA style | |
| `jou` (`journal`) | journal-article layout | two columns, Times |

```sh
pdfmd paper --kit apa7           # stu
pdfmd paper --kit apa7:man
```

## Front matter

| Key | Meaning |
|---|---|
| `title`, `shorttitle` | the running head defaults to the title |
| `author` | a name, a list of names, or maps with `name:` and `affiliation:` (a number, a text, or a list of them) |
| `affiliation` | one affiliation or a list; authors point at it by position |
| `course`, `professor` (or `instructor`) | student title page |
| `duedate` (or `date`) | student title page |
| `abstract`, `keywords` | the abstract is on its own page; `keywords` may be a list |
| `abstractname` | the abstract's heading instead of *Abstract* (`Executive Summary`); in `jou`, where the class prints no heading, the abstract then starts with it, centred |
| `authornote` | manuscript author note |
| `titleoffset` | how far down the title page the title starts: a number of lines (`6`; the class's own is 4 in `stu` and `man`) or a length (`2in`, `5cm`, `40mm`, `72pt`, `3em`); every mode |
| `bibliography` | a `.bib` file; cite with `[@key]` or `[@key, p. 12]` |

A complete example is in [`example/`](example/): `cd example && pdfmd paper --kit apa7`.

## What it sets

`documentclass: apa7`, 12 pt, US Letter, first-line indents, black links, `lang: en-US`, TeX Gyre Termes as the
text font (a Times clone with real bold and italic; xelatex, lualatex and Tectonic; pdflatex ignores `mainfont`),
and `geometry` set to apa7's own margins. Set `papersize: a4` or `mainfont:` in your document to change them.
A `# References` heading starts a new page in `stu` and `man`.
In `stu` and `man` the body paragraphs have a 0.5 in first-line indent and the reference list a 0.5 in hanging indent (also in a
partial build, where the title page, and so the class's own indent, is left out); each `# Appendix A: Title` heading starts a new
page and restarts the table and figure counters, so that its tables are numbered A1, A2, ... (APA 7); a paragraph that starts with
`*Note.*` (a table or figure note) is flush left.
In every mode a figure's caption is set above the image, as APA 7 wants: `Figure 1` in bold on a line of its own, the
caption from `![Caption in Title Case](figure.pdf)` in italics below it, then the image; a `*Note.*` paragraph right after the
figure goes into the figure, below the image. Tables already have their caption above. In `stu` and `man` the class holds
figures back to the end of the paper (after the references); the body's figures are put out before the first
appendix, and an appendix's figures stay in it, numbered A1, A2 ... A complete example is `example/figure.md`.

## Known limits

- An author name with a comma in it loses the comma (apa7 reads the list at commas).
- The abstract is one block; apa7 does not lay out several paragraphs as APA asks.
- A figure of several images (subfigures, a `::: {#fig-x}` div of images) keeps Pandoc's layout, with its caption below.
- Tested with lualatex, xelatex and Tectonic. pdflatex is untested.
- Pandoc's own `\author`, `abstract` and `date` are replaced by apa7's commands by `apa7.lua`; raw LaTeX that
  calls `\author` yourself will do nothing.

## Credits

The apa7 class and its language files are by Daniel A. Weiss (LPPL 1.3c) and are kept here exactly as published; `apa.csl` is the
CSL project's APA style (CC BY-SA 3.0, credits in the file and in [`../THIRD_PARTY.md`](../THIRD_PARTY.md)). `apa7.kit`,
`metadata.yaml` and `apa7.lua` were written for the class: they ask for it and call its documented commands, and hold none of its
code. This kit is not affiliated with the American Psychological Association or with the class's author.
