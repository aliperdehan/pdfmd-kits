# moderncv: curricula vitae

`pdfmd cv --kit moderncv` builds `cv.md` as a moderncv CV. A heading is a `\section`; two fenced-div classes are the CV's own
blocks.

| Mode | Style |
|---|---|
| `casual` (default) | casual |
| `classic`, `banking`, `oldstyle`, `fancy`, `contemporary` | the other moderncv styles |

## Front matter

```yaml
name: Ada Example                     # the last word is the family name; or firstname: / lastname:
title: Research Chemist
address: [1 Example Street, 010000 Example City, Country]   # street, "postcode city", country
phone: {mobile: "+1 234 567 890"}     # or a text; mobile, fixed, fax
email: ada@example.org
homepage: www.example.org/ada
social: {github: adaexample, orcid: 0000-0000-0000-0000}    # the services moderncv knows
photo: me.jpg                         # photoheight: 64pt
quote: A line under the header
cvcolor: blue                         # black, blue, burgundy, green, grey, orange, purple, red, cerulean ...
```

## In the text

```markdown
# Education

::: {.cventry years="2020--2024" title="BSc Chemistry" institution="Example University" city="Example City" grade="GPA 3.9"}
Thesis on the titration of calcium with EDTA. A short list is fine too.
:::

# Skills

::: {.cvitem label="Languages"}
English, Russian, Kazakh
:::
```

`years`, `title`, `institution`, `city`, `grade` are the arguments of `\cventry`; the content of the div is its description.
`--` in an attribute is an en dash. An example is in [`example/`](example/).

## Known limits

- **Tectonic does not work with the current moderncv (2.6.1)**: its icon sets need `fontawesome6`, which Tectonic's
  bundle does not have. Use xelatex or lualatex.
- `\cvdoubleitem`, `\cvitemwithcomment`, `\cvlistitem`, the skill matrix and the publication list (biblatex) are not
  generated; write them as raw LaTeX inside the document.
