# Changelog

Newest first. The repository is tagged `vX.Y.Z`; each kit's own version is `version:` in its `.kit` file. A new kit or mode, or a
new front-matter key, is a minor bump of the repository; a fix is a patch; a changed meaning of an existing key is a major one.

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
