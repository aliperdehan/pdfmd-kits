# csl: citation styles

A kit with no class and no filter: each mode only sets `csl:`. It works with every output format, so
`pdfmd paper -t docx --kit csl:chicago` gives a Word file in Chicago style.

| Mode | Style |
|---|---|
| `apa` (default) | APA 7th edition |
| `mla` | MLA Handbook 9th edition |
| `chicago` (`chicago-author-date`) | Chicago 18th edition, author-date |
| `chicago-notes` (`notes`) | Chicago 18th edition, notes and bibliography (footnotes) |
| `harvard` | Cite Them Right 12th edition (Harvard) |
| `vancouver` (`nlm`) | NLM/Vancouver, numbered |
| `nature` | Nature |
| `ieee` | IEEE |
| `acs` | ACS Guide, 2026 revision |
| `rsc` | Royal Society of Chemistry |

```sh
pdfmd paper --kit csl:harvard
```

The styles are the unchanged files of the [CSL project](https://github.com/citation-style-language/styles), each pinned to the
commit it was taken from (CC BY-SA 3.0; see `../THIRD_PARTY.md`). Another style is one file: copy it into this folder, add
a mode to `csl.kit` and an entry to `SOURCES.yaml` (see `../docs/WRITING-A-KIT.md`).
