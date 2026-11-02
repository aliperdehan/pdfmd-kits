# pdfmd-kits

Ready-made **kits** for [pdfmd](https://github.com/aliperdehan/pdfmd): a journal's LaTeX class, a university's rules, a citation
style or a CV, packaged so that a plain Markdown file becomes a document in that style with one option:

```sh
pdfmd paper --kit apa7              # an APA 7th edition student paper
pdfmd paper --kit achemso           # a manuscript for an ACS journal
pdfmd paper --kit csl:harvard       # just the citation style, any output format
```

A kit is a folder pdfmd understands: the class (unchanged, with its license), the citation style, a small Lua filter that turns
front matter (`author`, `affiliation`, `abstract` ...) into the commands the class wants, and defaults. Everything the build needs
is in the folder, so it works with a full TeX Live and with [Tectonic](https://tectonic-typesetting.github.io/) alike. These
kits were made so that anyone can use them, read them, and make their own: see [`docs/WRITING-A-KIT.md`](docs/WRITING-A-KIT.md).

## The kits

| Kit | For | Modes | Tested with |
|---|---|---|---|
| [`apa7`](apa7/) | APA 7th edition papers (apa7 class, APA style) | `stu`, `man`, `doc`, `jou` | lualatex, xelatex, Tectonic |
| [`achemso`](achemso/) | American Chemical Society journals | `article`, `communication`, `letter`, `note`, `review` | lualatex, xelatex, Tectonic |
| [`revtex`](revtex/) | APS and AIP journals (revtex4-2) | `prl`, `prb`, `pra`, `pre`, `jcp`, `preprint` | lualatex, xelatex, Tectonic |
| [`elsarticle`](elsarticle/) | Elsevier journals | `preprint`, `numbered`, `review`, `3p`, `5p` | lualatex, xelatex, Tectonic |
| [`ieeetran`](ieeetran/) | IEEE conference and journal papers | `conference`, `journal` | lualatex, xelatex, Tectonic |
| [`acmart`](acmart/) | ACM papers | `sigconf`, `sigplan`, `manuscript` | lualatex, xelatex, Tectonic |
| [`llncs`](llncs/) | Springer Lecture Notes in Computer Science | `proceedings`, `plain` | lualatex, xelatex, Tectonic |
| [`mla`](mla/) | MLA-style papers | `paper` | lualatex, xelatex (not Tectonic, see its README) |
| [`moderncv`](moderncv/) | curricula vitae | `casual`, `classic`, `banking`, `oldstyle`, `fancy`, `contemporary` | lualatex, xelatex (not Tectonic, see its README) |
| [`csl`](csl/) | ten citation styles, nothing else: APA, MLA, Chicago (both), Harvard, Vancouver, Nature, IEEE, ACS, RSC | one per style | lualatex, Tectonic; any output format |

"Tested" means the kit's `example/` builds in every mode with those engines (85 builds in all, `scripts/check-examples.sh`) and
that the PDFs were looked at. pdflatex is not tested. Each kit's README lists its front-matter keys and its known limits.

## Install

You need [pdfmd](https://github.com/aliperdehan/pdfmd) **3.32.7 or later** (3.32.6 for Tectonic, 3.31.34 to read kits at all) and
a TeX engine: a full TeX Live, or Tectonic (`pdfmd --install core:tex`).

```sh
pdfmd --install kit:aliperdehan/pdfmd-kits        # every kit here, into kits/ beside pdfmd's config file
pdfmd --install kit:apa7                          # or one of them by name
pdfmd --install kit:aliperdehan/pdfmd-kits@v0.1.0#apa7      # one kit, at a tag
pdfmd --kits                                      # what pdfmd can see now
```

Without `--install`: clone the repository and name the folder once under `kits:` in `~/.config/pdfmd/config.yaml`
(or in `pdfmd --setup`):

```yaml
kits: [~/kits]
```

`pdfmd --install kit:...` fetches a snapshot, looks for kits in its root and its folders, checks each and copies it whole; it
runs nothing from the repository. A kit's Lua filter runs when you build with the kit: read it (they are short) before you use a
kit from somewhere else. The repository is about 35 MB because each class is kept with its complete upstream distribution (the
licenses ask for that, see below); `--install kit:NAME` keeps only the kit you name.

## Use

```sh
pdfmd paper --kit apa7              # the default mode of the kit
pdfmd paper --kit apa7:man          # a mode
pdfmd paper --kit moderncv:classic cv.md
```

or in the document's front matter, so that the file builds the same everywhere:

```yaml
---
pdfmd-options: {kit: apa7:man}
title: ...
---
```

The front-matter keys are the same across the class kits where the meaning is the same (`title`, `author` with `name`, `email`
and `affiliation`, `affiliation`, `abstract`, `keywords`, `date`), and each kit adds what its class needs (`course` and
`professor` for a student paper, `journal`, `acmconference`, `cvstyle`). Each kit's README and `example/` say which.

## What is in the repository

```
apa7/ achemso/ ...      one folder per kit: KIT.kit, metadata.yaml, KIT.lua, tex/ (the class), .csl files, example/, README.md
docs/WRITING-A-KIT.md   how to write a kit (and docs/template/ to start from)
scripts/                check-examples.sh (build every example), vendor.py, fetch-csl.py, third-party.py (provenance)
LICENSES/               the texts of the licenses of the files that are not the author's own
THIRD_PARTY.md          every third-party file: source, authors, license (written from each kit's SOURCES.yaml)
```

## Licenses

The kits' own files (`*.kit`, `metadata.yaml`, `*.lua`, the READMEs, the examples, the scripts) are **MIT** (`LICENSE`). The files
copied from elsewhere keep their own licenses and are listed in [`THIRD_PARTY.md`](THIRD_PARTY.md) with their source, their authors
and the SHA-256 of each (`cd KIT && shasum -a 256 -c SHA256SUMS`):

- the LaTeX classes are **LPPL** (apa7, achemso, mla, moderncv, revtex 1.3c; elsarticle, IEEEtran, acmart 1.3 or later) and
  llncs is **CC BY 4.0**. They are kept exactly as upstream ships them, with the complete CTAN archive beside them, because LPPL
  allows a package to be redistributed whole and unmodified; nothing is patched, the kits' own glue has names of its own.
- the citation styles are the unchanged files of the [CSL project](https://github.com/citation-style-language/styles),
  **CC BY-SA 3.0**, each pinned to the commit it was taken from.

This repository is not affiliated with, or endorsed by, the American Psychological Association, the American Chemical Society, the
American Physical Society, Elsevier, IEEE, the ACM, Springer, the MLA or any publisher; the classes are community or
publisher-supplied templates and the names are their owners'.

## Versions

The repository is versioned with git tags (`v0.1.0`, ...) and a [`CHANGELOG.md`](CHANGELOG.md); each kit has its own `version:`
in its `.kit` file, which is not the version of the class it carries (that is in `SOURCES.yaml`). Add the GitHub topic
**`pdfmd-kit`** to a repository of kits so that others can find it; any such repository installs the same way,
`pdfmd --install kit:owner/repo`.
