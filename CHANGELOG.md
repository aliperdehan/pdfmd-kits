# Changelog

Newest first. The repository is tagged `vX.Y.Z`; each kit's own version is `version:` in its `.kit` file. A new kit or mode, or a
new front-matter key, is a minor bump of the repository; a fix is a patch; a changed meaning of an existing key is a major one.

## Unreleased

- apa7: `coverpage:` puts a cover page in front of the title page: `true` a plain one (title, authors, course, professor, due date),
  a file name that PDF's pages (pdfpages). It has no running head or page number and is not counted: the title page stays page
  1, as APA 7 numbers it. `example/options.md` has the plain cover, the new `example/coverfile.md` a PDF one.
- apa7: `abstractname:` is the abstract's heading (`Executive Summary`) in every mode; without it the heading stays *Abstract*
  (and `jou` keeps its abstract without a heading). `example/options.md` uses it.
- apa7: `titleoffset:` sets how far down the title page the title starts, in lines (`6`) or as a length (`2in`, `5cm`); without it
  the class's own space is kept (4 lines in `stu` and `man`). Any other value stops the build with a message naming the key.
  New example `example/options.md`.
- apa7: a figure's caption is above the image in every mode (APA 7: `Figure 1` in bold, the title in italics, the image, a
  note), and a `*Note.*` paragraph right after a figure goes into it, below the image. In `stu` and `man` the figures that the
  class holds back to the end are put out before the first appendix, and an appendix's own figures stay in it (Figure A1).
  New example `example/figure.md`.
- apa7 (`stu`, `man`): the 0.5 in first-line indent no longer depends on `\maketitle`, so a partial build (`pdfmd parts/20-methods.md`,
  `report#methods`) is indented like the full one; the reference list hangs by 0.5 in (Pandoc's CSL list used 1.5em = 18 pt); an
  `# Appendix X: Title` heading starts a new page and restarts the table and figure counters (Table A1, B1, C1); a paragraph that
  starts with `*Note.*` is flush left. `example/appendix.md` has an appendix with a captioned table and a note.
- docs: the guide mentions `no-auto:` of pdfmd 3.32.8 (the kits themselves do not use it yet).
- apa7: a partial build (`pdfmd report#methods`) drops the title page, as nulabreport does; `partial-title: true` keeps it. It needs
  pdfmd 3.32.30: before it, any header file of pdfmd's replaced the kit's `header-includes` and `\maketitle` stopped with "There's no
  line here to end".
- acmart: removed the two preamble entries that neutralised `\author` and `\date`. They did nothing before pdfmd 3.32.30 and, once
  `header-includes` is honoured, swallowed the author names.

## v0.1.0 (2026-11-03)

First version. Ten kits, each with an example that builds in every mode (85 builds with lualatex, xelatex and Tectonic):

- **apa7** 0.1.0: APA 7th edition papers; modes `stu`, `man`, `doc`, `jou`; title page with affiliations, course, professor and due
  date; the reference list on its own page. Class v2.16, APA style.
- **achemso** 0.1.0: ACS journals; modes `article`, `communication`, `letter`, `note`, `review`; authors grouped by affiliation,
  corresponding-author e-mails, `journal:`. Class v3.14, ACS Guide 2026.
- **revtex** 0.1.0: APS and AIP journals with revtex4-2; modes `prl`, `prb`, `pra`, `pre`, `jcp`, `preprint`.
- **elsarticle** 0.1.0: Elsevier journals; modes `preprint`, `numbered`, `review`, `3p`, `5p`; the `frontmatter` block with labelled
  affiliations and a corresponding author.
- **ieeetran** 0.1.0: IEEE; modes `conference` (author blocks) and `journal` (names and a footnote).
- **acmart** 0.1.0: ACM; modes `sigconf`, `sigplan`, `manuscript`; affiliations as text or as a map, venue optional.
- **llncs** 0.1.0: Springer LNCS; modes `proceedings` (running heads) and `plain`; `\inst` marks, institutes with e-mails.
- **mla** 0.1.0: MLA papers (not under Tectonic: biblatex and biber of its bundle disagree).
- **moderncv** 0.1.0: CVs; six styles; `cventry` and `cvitem` fenced divs (not under Tectonic: its icon sets need fontawesome6).
- **csl** 0.1.0: ten citation styles as modes, for any output format.
- `docs/WRITING-A-KIT.md` and `docs/template/`: how to write a kit.
- `scripts/`: `check-examples.sh`, `vendor.py`, `fetch-csl.py`, `third-party.py` (provenance: `THIRD_PARTY.md` and a `SHA256SUMS` per kit
  from each kit's `SOURCES.yaml`, `--check` for a drift or an undeclared file).
- Needs pdfmd 3.32.6 (Tectonic: kit folders as `-Zsearch-path`) and 3.32.7 (`pdfmd --install kit:SOURCE`).
