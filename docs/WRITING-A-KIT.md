# Writing a kit

A **kit** is a folder that turns a plain Markdown file into a document in a house style: a journal's LaTeX class, a university's
rules, a citation style, a CV. pdfmd reads the folder's `.kit` file and does the rest: it puts the kit's files where the build
finds them, applies its defaults and its Lua filter, and picks a *mode* (a named variant) when you ask for one.

```sh
pdfmd paper --kit apa7:man
```

This guide is for people who want to make one, for a journal, a course or a company, and share it. Read the first two sections
and you can make a citation-style kit in five minutes; the rest is what building the ten kits of this repository taught. The
format itself (every key of the `.kit` file, how kits are found and stacked) is in pdfmd's README, section *Kits*; this guide
does not repeat it.

- [1. Anatomy](#1-anatomy)
- [2. Your first kit, in five minutes (a citation style)](#2-your-first-kit-in-five-minutes-a-citation-style)
- [3. A kit for a LaTeX class](#3-a-kit-for-a-latex-class)
- [4. The Lua filter: front matter to the class's commands](#4-the-lua-filter-front-matter-to-the-classs-commands)
- [5. What Pandoc's template does to your class (a checklist)](#5-what-pandocs-template-does-to-your-class-a-checklist)
- [6. Testing](#6-testing)
- [7. Licenses and attribution](#7-licenses-and-attribution)
- [8. Versions, a changelog, publishing](#8-versions-a-changelog-publishing)
- [9. A checklist before you publish](#9-a-checklist-before-you-publish)

## 1. Anatomy

```
mykit/
  mykit.kit          the kit file (or just `.kit`): name, version, modes, what to load
  metadata.yaml      the defaults every mode gets: documentclass, csl, fonts ...
  mykit.lua          the Lua filter: front matter -> the class's commands (optional)
  tex/               the class and its files, exactly as upstream ships them (optional)
  some-style.csl     citation styles (optional)
  example/           a paper that builds with the kit: it is also its test
  README.md          the front-matter keys, the modes, the known limits
  SOURCES.yaml       what you did not write: source, authors, license (see section 7)
```

Only the `.kit` file is required. Everything it names lives inside the kit's folder: a path that is absolute or leaves the folder
is refused. Nothing else about the layout is fixed; `tex/` is this repository's name for LaTeX parts, and a kit could as well
hold other kinds of parts (a Word reference document, CSS) when pdfmd learns to use them.

A repository can hold **one kit at its root** (the shape of a package that has its own repository) or **many kits, one per
folder** (this repository). `pdfmd --install kit:owner/repo` finds both: it looks at the root, then at every folder down to three
levels, and a folder with a `.kit` or `NAME.kit` file is a kit. A kit's own sub-folders belong to it and are not searched.

## 2. Your first kit, in five minutes (a citation style)

Pick a style from the [CSL project](https://github.com/citation-style-language/styles) and make a folder:

```
my-style/
  my-style.kit
  the-style.csl
```

```yaml
# my-style.kit
kit-format: 1
name: my-style
version: 0.1.0
description: the citation style of my department
default-mode: paper
carry: [the-style.csl]
modes:
  paper:
    description: author-date citations
    metadata: {csl: the-style.csl}
```

That is a complete kit. Try it:

```sh
pdfmd --kits ./my-style                   # shows it and checks the file
pdfmd paper --kit ./my-style              # a path works without installing anything
```

`metadata:` of a mode is front matter that a document can override; `carry:` lists what travels when someone attaches a source or
bundles a document. Several styles in one kit are several modes (see `csl/`).

## 3. A kit for a LaTeX class

1. **Get the class, whole and unchanged.** Download the package's archive from CTAN. `scripts/vendor.py` unpacks it safely into
   `tex/upstream/` and copies the installed form from your TeX Live into `tex/`:

   ```sh
   curl -L -o /tmp/pkg.zip https://mirrors.ctan.org/macros/latex/contrib/PKG.zip
   scripts/vendor.py mykit /tmp/pkg.zip PKGDIR            # PKGDIR: the folder under texmf-dist/tex/latex
   scripts/vendor.py --prefer-archive mykit /tmp/pkg.zip PKGDIR    # when TeX Live's copy is older than CTAN's
   ```

   If the package needs `latex pkg.ins` to produce its `.cls`, take the files from TeX Live (the script does); never run code
   from a downloaded archive to make them. **Do not edit a vendored file** (section 7).

2. **Write `mykit.kit` and `metadata.yaml`.** The class is `documentclass:` in the metadata; the class options of a mode are
   `classoption:` in the mode's `metadata:`. A kit does not need a `package:` (that key writes `\usepackage`): a class is chosen
   through the metadata.

   ```yaml
   # metadata.yaml
   documentclass: apa7
   papersize: letter
   lang: en-US
   indent: true               # Pandoc removes paragraph indents unless told otherwise
   csl: apa.csl
   colorlinks: false
   mainfont: TeX Gyre Termes  # a font with a real bold (section 5)
   geometry: " "              # or the class's own options (section 5)
   ```

   ```yaml
   # mykit.kit (the parts that matter)
   lua: [apa7.lua]
   defaults: metadata.yaml
   carry: [tex/, apa.csl]       # a `tex/` here is put on TEXINPUTS, searched recursively; with Tectonic pdfmd 3.32.6+ also
                                # passes every folder below it as -Zsearch-path
   modes:
     stu: {metadata: {classoption: [stu]}}
     man: {metadata: {classoption: [man]}}
   ```

3. **Write the filter** (section 4) and **an example** (section 6).
4. **Say where everything came from** (section 7) and run `scripts/third-party.py`.

A kit needs no installation into TeX: the folders it `carry:`s are on `TEXINPUTS`, so a class that exists nowhere else on the
machine is found. The class's own helper packages (`fancyhdr`, `endfloat`, ...) still come from the TeX installation, or from
Tectonic's bundle.

## 4. The Lua filter: front matter to the class's commands

pdfmd's `latex-keys:` can only write `\renewcommand{\Macro}{value}`, which suits a package that has such macros (nulabreport).
Most journal classes have *setter commands* with arguments (`\affiliation{..}`, `\keywords{..}`, `\author[..]{..}`), so a kit
usually has a Lua filter that reads the front matter and writes those commands.

The pattern, used by every kit here, is a filter with one `Meta` function (see [`template/NAME.lua.txt`](template/NAME.lua.txt)):

```lua
return {
  { Meta = function(meta)
      if not FORMAT:match('latex') then return nil end                  -- only for LaTeX output
      if pandoc.utils.stringify(meta.documentclass) ~= 'mycls' then return nil end   -- only for this class
      -- read meta.title, meta.author, meta.affiliation, meta.abstract ...
      -- write raw LaTeX into meta['header-includes'] (the preamble) and/or meta['include-before'] (right after \begin{document})
      -- remove what Pandoc's template would write wrongly: meta.title, meta.author, meta.abstract = nil
      return meta
    end },
}
```

Where to write each thing:

| Where | What goes there |
|---|---|
| `header-includes` | the preamble: `\journal{..}`, `\institute{..}`, `\keywords{..}`, fixes for Pandoc's template |
| `include-before` | text right after `\begin{document}`: a `frontmatter` environment, or `\title`, `\author`, the abstract and `\maketitle` in the order the class wants |
| remove `title`, `author`, `abstract` | when you write them yourself, so Pandoc's template does not write them again and `\maketitle` is not run twice |
| `title-meta`, `author-meta` | set these to plain text when you removed `title` and `author`: they are what the PDF's own metadata uses |

Classes differ in how they take authors: achemso, revtex, acmart and elsarticle want one `\author{..}` per author, each followed
by its affiliation; IEEEtran and llncs want one `\author{..}` with every name (a second `\author` replaces the first). Read the
class's own sample before you write the loop.

Keep the front-matter names the same across kits, so that a document moves from one class to another by changing the kit line:
`title`, `author` (a name, a list, or maps with `name`, `email`, `affiliation`), `affiliation` (one, or a list that authors
point at by number), `abstract`, `keywords`, `date`. Add class-specific keys as you need them (`course`, `professor`, `journal`).

**A Lua filter is code.** It runs on the machine of everyone who builds with your kit. Keep it to reading metadata and writing
text: no `os.execute`, no `io.popen`, no network, no writing files. pdfmd shows a note the first time a filter is new or has
changed, and `pdfmd --install` says which kits carry one. Write the filter so that a stranger can read it in five minutes.

## 5. What Pandoc's template does to your class (a checklist)

Pandoc's own LaTeX template writes a lot before your class gets a say. These are the things that went wrong while building the
kits here, in the order you will meet them. Each one shows up as a LaTeX error; the fix is in the kit, never in the class.

1. **`Option clash for package geometry`.** The class loads `geometry` itself; pdfmd (and Pandoc) load it again with
   `margin=1in`. Set `geometry:` in the kit's metadata to the class's own option list (`margin=2.54cm`), or, for a class that
   sets the page itself, to a single space (`geometry: " "`), which switches off pdfmd's automatic margin and loads nothing.
2. **`Option clash for package babel`.** The class loads `babel`; `lang: en-US` makes Pandoc load it too. Leave `lang:` out of
   the kit's metadata (the CSL's locale defaults to US English anyway).
3. **An empty `\author{}` and `\date{}` in the preamble.** Pandoc always writes them. Some classes keep an empty first author
   (a stray comma before the names) or print `(Dated: )`, or stop with an undefined control sequence. Disarm them in
   `header-includes` and give back the real commands when the document begins, where your own authors are written:

   ```latex
   \let\pdfmdauthor\author
   \renewcommand{\author}[2][]{}
   \AtBeginDocument{\let\author\pdfmdauthor}
   ```
4. **Citations print garbage (`1code`) or `\bibitem` fails.** Pandoc's citeproc output goes through `\cite` and
   `\bibitem[label]`; a class that redefines them breaks it. The citation style has already made the text, so make a citation
   that text and a bibliography item an `\item`. Use `\Declare...`, not `\Renew...`: `\citeproc` does not exist in a document
   without citations.

   ```latex
   \AtBeginDocument{\DeclareDocumentCommand\citeproc{mm}{#2}\renewcommand{\bibitem}[2][]{\item}}
   ```
5. **No bold anywhere.** pdfmd's automatic font (STIX Two Text) is a variable font and has no bold for XeTeX and LuaTeX. Set
   `mainfont:` to a font with real bold and italic that is in TeX Live *and* in Tectonic's bundle (TeX Gyre Termes, TeX Gyre
   Heros, Libertinus Serif).
6. **The abstract in the wrong place.** Pandoc writes the abstract after `\maketitle`; some classes (revtex, acmart) want it
   before, or inside the title block. Write the title block yourself through `include-before` and remove Pandoc's abstract.
7. **First-line indents are gone.** Pandoc removes them; set `indent: true` in the kit's metadata if the style wants them.
8. **A class option that Pandoc adds.** Pandoc passes `lang`, `papersize` and `fontsize` as class options (`american,
   letterpaper,12pt`). Most classes accept them; if yours does not, leave the key out of the kit's metadata.
9. **`latex-keys:` cannot call a setter.** It writes `\renewcommand{\Macro}{value}`; for `\affiliation{..}` use a filter.
10. **Tectonic.** Tectonic does not read `TEXINPUTS`; pdfmd 3.32.6+ gives it the kit's folders as `-Zsearch-path`. Its bundle is
    older than a current TeX Live: a class that needs a newer package (moderncv 2.6.1 needs `fontawesome6`) fails there, and a
    class that loads `biblatex` with `biber` (mla) meets a `biber` that does not match. Say so in the kit's README, and limit
    the example's engines (section 6).

When a build fails, read the *last* error of the log: `pdfmd paper --kit mykit -v` prints the exact Pandoc command, and the failed
build's full log path.

## 6. Testing

The `example/` folder is both the documentation and the test: a small paper that uses every front-matter key of the kit. Two
comment lines in its front matter drive `scripts/check-examples.sh`:

```yaml
---
# check-modes: stu man doc jou          # build every mode
# check-engines: lualatex xelatex       # optional: the engines that can run this class (default: lualatex xelatex tectonic)
title: ...
---
```

```sh
scripts/check-examples.sh                  # every kit, every engine installed
scripts/check-examples.sh mykit            # one kit
PDFMD="python3 ~/dev/py/pdfmd/pdfmd.py" scripts/check-examples.sh mykit     # a checkout of pdfmd
```

A passing build is not a correct one. **Look at the PDF** (`pdftoppm -r 70 -png out.pdf page`): is the title block where the
class puts it, are the affiliations and the corresponding author right, are the citations and the reference list in the style?

**Prove the kit's own class is the one that loaded.** If the class also exists in the TeX installation, a build can succeed with
that copy and tell you nothing. Copy the kit to a scratch folder, add `\ClassError{mycls}{VENDORED-COPY-LOADED}{}` as the first
line of the *copy's* class, and build with `--kit /path/to/the/copy`: the build must stop with that message, for every engine
you support (Tectonic is the one that fails silently without pdfmd 3.32.6).

## 7. Licenses and attribution

Vendoring a file means copying someone else's work, so say whose, keep their license, and do not change it.

- **LPPL** (almost every LaTeX class and package). A package may be redistributed whole and unmodified; a changed copy must be
  renamed. So the class stays exactly as upstream ships it, together with the complete CTAN archive (`tex/upstream/`), and your
  own glue lives in files with names of their own (`mykit.lua`, `mykit.kit`, `metadata.yaml`). If a class needs a patch, make a
  new class that loads the old one, with another name, and say so.
- **CC BY-SA 3.0** (the CSL citation styles). Keep the file as it is (it carries its authors and license), credit it, and
  anything derived from it stays CC BY-SA. Take the style from the CSL repository at a named commit, not from a website.
- **Anything else**: read the license. If it does not allow redistribution, do not vendor it: tell the user where to get it.
  Fonts are the usual case; do not bundle them, name a font that TeX Live ships.
- **Names are trademarks.** A kit is not affiliated with APA, ACS, IEEE, Elsevier, ACM or anyone else; say so.

Declare every third-party file in `SOURCES.yaml` and let the scripts do the bookkeeping:

```yaml
- what: the apa7 class package, installed form
  version: "v2.16 (2022-07-25)"
  files: [tex]
  except: [tex/upstream]
  from: TeX Live 2026 (texmf-dist/tex/latex)
  authors: Daniel A. Weiss (2022); the class continues the apa6 class of Brian D. Beitzel (2011-2017)
  license: LPPL-1.3c
- what: the complete CTAN distribution of apa7
  files: [tex/upstream]
  from: https://mirrors.ctan.org/macros/latex/contrib/apa7.zip
  authors: Daniel A. Weiss
  license: LPPL-1.3c
  archive-sha256: a63d4141...
- what: citation style
  files: [apa.csl]
  commit: 3c6698d791a83016d699f50cbbea857f6ee3d2f8   # its title, date, authors and license are read from the file
  license: CC-BY-SA-3.0
```

```sh
scripts/fetch-csl.py apa mykit            # fetches a style pinned to the commit that last changed it and prints its credits
scripts/third-party.py                    # writes THIRD_PARTY.md and every kit's SHA256SUMS
scripts/third-party.py --check            # fails if a vendored file changed, or a file in tex/ or a .csl has no entry
```

Take the authors and the version from the files themselves (`\ProvidesClass`, the copyright lines, the README), not from
memory. Put the license text under `LICENSES/` if it is not there yet.

## 8. Versions, a changelog, publishing

- **The kit's version** is `version:` in the `.kit` file: yours, not the class's (the class's is in `SOURCES.yaml`). Raise it
  when the kit changes: a new front-matter key or mode is a minor bump, a fix is a patch, a changed meaning of an old key is
  a major one.
- **The repository** has a `CHANGELOG.md` (newest first) and git tags `vX.Y.Z`. Say in the changelog which kit changed and how.
- **Publishing**: push the repository to GitHub, add the topic **`pdfmd-kit`** so that others can find it, and tag a release.
  Anyone can then run `pdfmd --install kit:owner/repo` (or `kit:owner/repo@v1.2#name` for one kit at a tag): pdfmd fetches the
  repository, finds the kits, checks each one and copies it to `kits/` beside its config file. A repository that is one kit
  (a `.kit` in its root) and one that holds many both work.
- **Requirements**: pdfmd 3.31.34 or later reads kits; 3.32.6 or later is needed for the kit's class to be loaded under Tectonic;
  3.32.7 or later has `--install kit`.

## 9. A checklist before you publish

- [ ] `pdfmd --kits ./mykit` prints no WARN and lists the modes you meant.
- [ ] `example/` builds in every mode with every engine you claim, and you looked at the PDFs.
- [ ] The kit's own class is the one that loads (the marker test), also with Tectonic if you claim it.
- [ ] No vendored file was edited; `scripts/third-party.py --check` passes.
- [ ] The Lua filter reads and writes text only, and fits on a screen or two.
- [ ] The README lists the front-matter keys, the modes and the **known limits** (what does not work, which engines).
- [ ] `CHANGELOG.md` has the entry, the `.kit` has the version, the tag is made.
- [ ] A fresh `pdfmd --install kit:./path` (a throw-away `PDFMD_CONFIG`) installs it and a build with the installed copy works.
