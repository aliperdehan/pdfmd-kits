# Third-party files

Every file in this repository that is not the author's own is listed here with where it comes from, who wrote it
and the license that lets it be copied. Nothing below was edited: each file is byte-identical to upstream, and the
SHA-256 of what was copied is recorded so that a change can be seen.

The author's own files (`*.kit`, `metadata.yaml`, `*.lua`, the README files) are MIT (see `LICENSE`).
The files below keep their own licenses; the texts are in `LICENSES/`.

None of these files is endorsed by, or affiliated with, the American Psychological Association or any
publisher. The apa7 class says so itself (`apa7/tex/upstream/README.txt`).

## apa7

| Files | What | From | Authors | License |
|---|---|---|---|---|
| `apa7/tex/apa7.cls`, `apa7/tex/config/*` | the apa7 class v2.16 (2022/07/25) and its language files, in the form TeX Live 2026 installs them (generated from `apa7.dtx` by `apa7.ins`) | [CTAN `apa7`](https://ctan.org/pkg/apa7), via TeX Live 2026 | Daniel A. Weiss (2022); the class continues the apa6 class of Brian D. Beitzel (2011-2017) and the contributors credited in `apa7.dtx` | LPPL 1.3c (`LICENSES/LPPL-1.3c.txt`) |
| `apa7/tex/upstream/*` | the complete CTAN distribution of apa7 v2.16: the `.dtx` and `.ins` sources, the manual, the README and the samples | <https://mirrors.ctan.org/macros/latex/contrib/apa7.zip> | Daniel A. Weiss | LPPL 1.3c |
| `apa7/apa.csl` | "American Psychological Association 7th edition", updated 2026-02-07 | [citation-style-language/styles](https://github.com/citation-style-language/styles) at commit `3c6698d791a83016d699f50cbbea857f6ee3d2f8` | Brenton M. Wiernik, Andrew Dunning, Jay Pfaffman | CC BY-SA 3.0 (`LICENSES/CC-BY-SA-3.0.txt`) |

SHA-256 of the copied files:

```
3917def5fc951b104d64216c3373096042368b9704ba269ca83c14ebaba889fc  apa7/apa.csl
9150e4e81c2ee99f4e64d153e64f0294286eaf54461bcea8c42d30b47bbe06e5  apa7/tex/apa7.cls
e52580e6baacec397e9f7b3b5b65178fc2edb74ee0fe734dceff7a4d371d960d  apa7/tex/upstream/apa7.dtx
e7a5166271e2060ba175ddae01fddc13a54c1a3b9b921fbb497e221b8b06e4c7  apa7/tex/upstream/apa7.ins
77fba528784b7b275ae9a918440ae49278d4f9dbaee82161352e4eb8b304967e  apa7/tex/upstream/README.txt
6fc04b97ef6b0386fdd38b64214405b332fdb814b965d7fe8349808a9a55ee21  apa7/tex/upstream/apa7.pdf
a63d4141b08f85d9133c5df7c4df1fc8ca86f3b9a22c63b5472c510b08b834e2  apa7.zip (the CTAN archive the upstream/ files come from)
```

### What the licenses ask of you

- **LPPL 1.3c** (apa7 class): a copy may be distributed unmodified, with the license text. A changed copy must be
  given another name (the license's condition on renaming). That is why the class is vendored as it is and the glue
  lives in `apa7.lua`, `apa7.kit` and `metadata.yaml`, which have their own names. The class files `apa7.cls`
  and `config/*` were copied from the TeX Live tree, not regenerated from the `.dtx` here.
- **CC BY-SA 3.0** (`apa.csl`): keep the credit above, say if you changed it, and share a changed copy under the same
  license. The file's own `<rights>` and author list are intact.
