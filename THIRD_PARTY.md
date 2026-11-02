# Third-party files

<!-- written by scripts/third-party.py from the kits' SOURCES.yaml: edit those, not this file -->

Every file in this repository that is not the author's own is listed here with where it comes from, who wrote it and the
license that lets it be copied. Nothing below was edited: each file is byte-identical to upstream, and `KIT/SHA256SUMS`
records the SHA-256 of every one (`cd KIT && shasum -a 256 -c SHA256SUMS`).

The author's own files (`*.kit`, `metadata.yaml`, `*.lua`, the README files, the examples, the scripts) are MIT, see
`LICENSE`. The files below keep their own licenses; the texts are in `LICENSES/` (a package that allows "LPPL 1.3 or later"
is used here under 1.3c). None of them is endorsed by, or affiliated with, any publisher or society named here; the
classes are community or publisher-supplied templates and the names are trademarks of their owners.

LPPL asks that a copy of a package is distributed whole and unmodified, or renamed when changed: that is why each class is
kept as it was (with the complete CTAN archive beside it in `tex/upstream/`) and all glue lives in files with names of their
own. CC BY-SA 3.0 (the citation styles) asks for credit and that a changed copy keeps the license.

The kit's own glue (`*.kit`, `metadata.yaml`, the Lua filter) was written for these classes and contains none of their code:
it asks for a class and calls the commands its manual documents. It is not a part of any class, nor a modified copy of one.

## achemso

| What | Files | From | Authors | License |
|---|---|---|---|---|
| the achemso class package, installed form, v3.14 (2025-09-22) | `achemso/tex` | TeX Live 2026 (texmf-dist/tex/latex) | Joseph Wright (2008-2025) | LPPL-1.3c |
| the complete CTAN distribution of achemso class: sources, manual, samples. Archive SHA-256 0fd9e883a2ff3f074859be868e3b468935b89e2c7474e3a8b1dd62a220619b45 | `achemso/tex/upstream` | https://mirrors.ctan.org/macros/latex/contrib/achemso.zip | Joseph Wright (2008-2025) | LPPL-1.3c |
| "ACS Guide 2026 revision" (CSL style, updated 2026-08-25) | `achemso/american-chemical-society.csl` | https://github.com/citation-style-language/styles/blob/a81be93326fd9e0cdb23d345572141bd5ffbe154/american-chemical-society.csl | Julian Onions, Ivan Bushmarinov, Sebastian Karcher, Patrick O'Brien | CC-BY-SA-3.0 |

## acmart

| What | Files | From | Authors | License |
|---|---|---|---|---|
| the acmart class package, installed form, CTAN 2.21 | `acmart/tex` | TeX Live 2026 (texmf-dist/tex/latex) | Association for Computing Machinery (2016-2026) | LPPL-1.3 or later |
| the complete CTAN distribution of acmart class: sources, manual, samples. Archive SHA-256 81977a834f5cfd5302c37181ede34d2663eeea60604d1d89230e3c5e74b9a4bb | `acmart/tex/upstream` | https://mirrors.ctan.org/macros/latex/contrib/acmart.zip | Association for Computing Machinery (2016-2026) | LPPL-1.3 or later |
| "Association for Computing Machinery" (CSL style, updated 2024-01-24) | `acmart/association-for-computing-machinery.csl` | https://github.com/citation-style-language/styles/blob/c18c1a491dc6c5db555185e9858561c8357af943/association-for-computing-machinery.csl | Patrick O'Brien, Junliang Hu | CC-BY-SA-3.0 |

## apa7

| What | Files | From | Authors | License |
|---|---|---|---|---|
| the apa7 class package, installed form, v2.16 (2022-07-25) | `apa7/tex/apa7.cls`, `apa7/tex/config` | TeX Live 2026 (texmf-dist/tex/latex) | Daniel A. Weiss (2022); the class continues the apa6 class of Brian D. Beitzel (2011-2017) | LPPL-1.3c |
| the complete CTAN distribution of apa7 class: sources, manual, samples. Archive SHA-256 a63d4141b08f85d9133c5df7c4df1fc8ca86f3b9a22c63b5472c510b08b834e2 | `apa7/tex/upstream` | https://mirrors.ctan.org/macros/latex/contrib/apa7.zip | Daniel A. Weiss (2022); the class continues the apa6 class of Brian D. Beitzel (2011-2017) | LPPL-1.3c |
| "APA Style 7th edition" (CSL style, updated 2026-02-07) | `apa7/apa.csl` | https://github.com/citation-style-language/styles/blob/3c6698d791a83016d699f50cbbea857f6ee3d2f8/apa.csl | Brenton M. Wiernik, Andrew Dunning, Jay Pfaffman | CC-BY-SA-3.0 |

## csl

| What | Files | From | Authors | License |
|---|---|---|---|---|
| "APA Style 7th edition" (CSL style, updated 2026-02-07) | `csl/apa.csl` | https://github.com/citation-style-language/styles/blob/3c6698d791a83016d699f50cbbea857f6ee3d2f8/apa.csl | Brenton M. Wiernik, Andrew Dunning, Jay Pfaffman | CC-BY-SA-3.0 |
| "MLA Handbook 9th edition (in-text citations)" (CSL style, updated 2026-02-03) | `csl/modern-language-association.csl` | https://github.com/citation-style-language/styles/blob/c0c8fd69fb7222b81cfd068d3bccfdb17b833045/modern-language-association.csl | Sebastian Karcher, Andrew Dunning, Patrick O'Brien | CC-BY-SA-3.0 |
| "Chicago Manual of Style 18th edition (author-date)" (CSL style, updated 2025-02-09) | `csl/chicago-author-date.csl` | https://github.com/citation-style-language/styles/blob/1aaf551f864d50e875a617b4faf2bf5da30f3f15/chicago-author-date.csl | Andrew Dunning | CC-BY-SA-3.0 |
| "Chicago Manual of Style 18th edition (notes and bibliography)" (CSL style, updated 2025-02-09) | `csl/chicago-notes-bibliography.csl` | https://github.com/citation-style-language/styles/blob/1aaf551f864d50e875a617b4faf2bf5da30f3f15/chicago-notes-bibliography.csl | Andrew Dunning | CC-BY-SA-3.0 |
| "Cite Them Right 12th edition (author-date/Harvard)" (CSL style, updated 2026-02-12) | `csl/harvard-cite-them-right.csl` | https://github.com/citation-style-language/styles/blob/c4b23ac4ba0de5b165fde037cbdc1df52645f861/harvard-cite-them-right.csl | Patrick O'Brien | CC-BY-SA-3.0 |
| "NLM/Vancouver: Citing Medicine 2nd edition (citation-sequence)" (CSL style, updated 2026-01-07) | `csl/nlm-citation-sequence.csl` | https://github.com/citation-style-language/styles/blob/f25316f71c0006867950b25d6d2064f5d8dd591a/nlm-citation-sequence.csl | Michael Berkowitz, Andrew Dunning, Petr Hlustik, Sebastian Karcher, Charles Parnot, Sean Takats | CC-BY-SA-3.0 |
| "Nature" (CSL style, updated 2025-09-10) | `csl/nature.csl` | https://github.com/citation-style-language/styles/blob/e0aa3018cd24b7be9a0e2acf3f9d83a6a78d8f0f/nature.csl | Michael Berkowitz, Patrick O'Brien | CC-BY-SA-3.0 |
| "IEEE Reference Guide version 11.29.2023" (CSL style, updated 2024-03-27) | `csl/ieee.csl` | https://github.com/citation-style-language/styles/blob/1ccf4696be22ea0b55f83cc9163bde3061fddb0a/ieee.csl | Michael Berkowitz, Julian Onions, Rintze Zelle, Stephen Frank, Sebastian Karcher, Giuseppe Silano, Patrick O'Brien, Brenton M. Wiernik, Oliver Couch, Andrew Dunning | CC-BY-SA-3.0 |
| "ACS Guide 2026 revision" (CSL style, updated 2026-08-25) | `csl/american-chemical-society.csl` | https://github.com/citation-style-language/styles/blob/a81be93326fd9e0cdb23d345572141bd5ffbe154/american-chemical-society.csl | Julian Onions, Ivan Bushmarinov, Sebastian Karcher, Patrick O'Brien | CC-BY-SA-3.0 |
| "Royal Society of Chemistry" (CSL style, updated 2026-01-28) | `csl/royal-society-of-chemistry.csl` | https://github.com/citation-style-language/styles/blob/9e562bba7fbb36df7942a97a724fbb326bf76854/royal-society-of-chemistry.csl | Julian Onions, Ivan Bushmarinov, Steven R. Kirk, Patrick O'Brien | CC-BY-SA-3.0 |

## elsarticle

| What | Files | From | Authors | License |
|---|---|---|---|---|
| the elsarticle class package, installed form, CTAN 3.5 | `elsarticle/tex` | TeX Live 2026 (texmf-dist/tex/latex) | Elsevier Ltd (2007-2026) | LPPL-1.3 or later |
| the complete CTAN distribution of elsarticle class: sources, manual, samples. Archive SHA-256 f25a3e1b006e0f86abb091a02f3afa7c6d60491665c7aa89f70cc5609e14d9dc | `elsarticle/tex/upstream` | https://mirrors.ctan.org/macros/latex/contrib/elsarticle.zip | Elsevier Ltd (2007-2026) | LPPL-1.3 or later |
| "Elsevier (author-date/Harvard, with titles)" (CSL style, updated 2014-03-04) | `elsarticle/elsevier-harvard.csl` | https://github.com/citation-style-language/styles/blob/9b37385e700b67ed908ebf3ac60321c60405b7e0/elsevier-harvard.csl | David Kaplan, Simon Kornblith, Bruce D'Arcus, Curtis M. Humphrey, Richard Karnesky, Sebastian Karcher | CC-BY-SA-3.0 |
| "Elsevier (numeric, with titles)" (CSL style, updated 2019-10-15) | `elsarticle/elsevier-with-titles.csl` | https://github.com/citation-style-language/styles/blob/b7df21a2b28d7a747637041a875865ed1845ca7d/elsevier-with-titles.csl | Richard Karnesky, Rintze Zelle | CC-BY-SA-3.0 |

## ieeetran

| What | Files | From | Authors | License |
|---|---|---|---|---|
| the IEEEtran class package, installed form, V1.8b (2015-08-26) | `ieeetran/tex` | TeX Live 2026 (texmf-dist/tex/latex) | Gerry Murray, Silvano Balemi, Jon Dixon, Peter Nüchter, Juergen von Hagen (1993-2000); Michael Shell (2001-2015) | LPPL-1.3 or later |
| the complete CTAN distribution of IEEEtran class: sources, manual, samples. Archive SHA-256 e0cd4f5afbd42c8076092280e72b3e0a5111efe501d35de9f715cfb8da313cb4 | `ieeetran/tex/upstream` | https://mirrors.ctan.org/macros/latex/contrib/IEEEtran.zip | Gerry Murray, Silvano Balemi, Jon Dixon, Peter Nüchter, Juergen von Hagen (1993-2000); Michael Shell (2001-2015) | LPPL-1.3 or later |
| "IEEE Reference Guide version 11.29.2023" (CSL style, updated 2024-03-27) | `ieeetran/ieee.csl` | https://github.com/citation-style-language/styles/blob/1ccf4696be22ea0b55f83cc9163bde3061fddb0a/ieee.csl | Michael Berkowitz, Julian Onions, Rintze Zelle, Stephen Frank, Sebastian Karcher, Giuseppe Silano, Patrick O'Brien, Brenton M. Wiernik, Oliver Couch, Andrew Dunning | CC-BY-SA-3.0 |

## llncs

| What | Files | From | Authors | License |
|---|---|---|---|---|
| the llncs class package, installed form, v2.26 (2025-02-25) | `llncs/tex` | TeX Live 2026 (texmf-dist/tex/latex) | Springer (1996-2025) | CC-BY-4.0 (4.0 or later) |
| the complete CTAN distribution of llncs class: sources, manual, samples. Archive SHA-256 932940fb23574fbc8c61afe6094e2debe0955e1bc6f971f734f3cb4de5d1167a | `llncs/tex/upstream` | https://mirrors.ctan.org/macros/latex/contrib/llncs.zip | Springer (1996-2025) | CC-BY-4.0 (4.0 or later) |
| "Springer - Lecture Notes in Computer Science" (CSL style, updated 2019-09-25) | `llncs/springer-lecture-notes-in-computer-science.csl` | https://github.com/citation-style-language/styles/blob/6ead27bca765563a8b49c4a20b2900f57caeae29/springer-lecture-notes-in-computer-science.csl | Ammar Memari, Mikko Ronkko | CC-BY-SA-3.0 |

## mla

| What | Files | From | Authors | License |
|---|---|---|---|---|
| the mla class (mlacls) package, installed form, v1.1 (2024-09-13) | `mla/tex` | TeX Live 2026 (texmf-dist/tex/latex) | Seth M. Price (2019) | LPPL-1.3c |
| the complete CTAN distribution of mla class (mlacls): sources, manual, samples. Archive SHA-256 31406f3ca5344b745b1852643d9232b8b7340839a3e69ad3c93a7090f1036bb1 | `mla/tex/upstream` | https://mirrors.ctan.org/macros/latex/contrib/mlacls.zip | Seth M. Price (2019) | LPPL-1.3c |
| "MLA Handbook 9th edition (in-text citations)" (CSL style, updated 2026-02-03) | `mla/modern-language-association.csl` | https://github.com/citation-style-language/styles/blob/c0c8fd69fb7222b81cfd068d3bccfdb17b833045/modern-language-association.csl | Sebastian Karcher, Andrew Dunning, Patrick O'Brien | CC-BY-SA-3.0 |

## moderncv

| What | Files | From | Authors | License |
|---|---|---|---|---|
| the moderncv class package, installed form, v2.6.1 (2026-06-24) | `moderncv/tex` | the CTAN archive (newer than TeX Live 2026's v2.5.1: the archive's files replaced those of TeX Live) | Xavier Danaux (2006-2015); the moderncv maintainers (2020-2026) | LPPL-1.3c |
| the complete CTAN distribution of moderncv class: sources, manual, samples. Archive SHA-256 9b50ba5c8e7de1c55e1252eaa0126f498fea2cd2d18236aab146f9f21d01ad59 | `moderncv/tex/upstream` | https://mirrors.ctan.org/macros/latex/contrib/moderncv.zip | Xavier Danaux (2006-2015); the moderncv maintainers (2020-2026) | LPPL-1.3c |

## revtex

| What | Files | From | Authors | License |
|---|---|---|---|---|
| the revtex4-2 class package, installed form, CTAN 4.2f | `revtex/tex` | TeX Live 2026 (texmf-dist/tex/latex) | American Physical Society (1999-2022) | LPPL-1.3c or later |
| the complete CTAN distribution of revtex4-2 class: sources, manual, samples. Archive SHA-256 5a5ebc9831ae219b2bcf2f8b408dc07a55a9e244af1317f1f25ca187daa40d82 | `revtex/tex/upstream` | https://mirrors.ctan.org/macros/latex/contrib/revtex.zip | American Physical Society (1999-2022) | LPPL-1.3c or later |
| "American Physical Society" (CSL style, updated 2024-12-17) | `revtex/american-physics-society.csl` | https://github.com/citation-style-language/styles/blob/77c46c415385cd9d68525dbad3bdf86cb5e18260/american-physics-society.csl | Richard Karnesky, Brenton M. Wiernik, Anna C. Véron | CC-BY-SA-3.0 |
| "AIP Style Manual 4th edition" (CSL style, updated 2024-03-27) | `revtex/american-institute-of-physics.csl` | https://github.com/citation-style-language/styles/blob/72c96faed175645b7438054369376cb7eac688eb/american-institute-of-physics.csl | Richard Karnesky, Patrick O'Brien | CC-BY-SA-3.0 |
