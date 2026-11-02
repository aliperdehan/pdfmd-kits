#!/usr/bin/env python3
"""Write THIRD_PARTY.md and the SHA256SUMS of every kit from the kits' SOURCES.yaml files, or check them.

    scripts/third-party.py            write THIRD_PARTY.md and KIT/SHA256SUMS
    scripts/third-party.py --check    verify the checksums and that no third-party file is undeclared (exit 1 if not)

Each kit declares what it did not write in KIT/SOURCES.yaml, a list of entries:

    - what: the apa7 class and its language files        # shown in the table
      files: [tex/apa7.cls, tex/config]                  # files or folders of the kit (a folder: every file under it)
      except: [tex/upstream]                             # optional: left out of `files`
      from: https://ctan.org/pkg/apa7                    # where it was taken from
      version: "2.16 (2022-07-25)"                       # optional
      authors: Daniel A. Weiss                           # who wrote it (not needed for a CSL style: read from the file)
      license: LPPL-1.3c                                 # SPDX id, with the text in LICENSES/
      archive-sha256: ...                                # optional: the downloaded archive, for the record
      commit: 3c6698d7...                                # a CSL style: the commit of the styles repository it is from
      notes: ...                                         # optional

A CSL style (`*.csl`) needs only `files`, `commit` and `license`: its title, date and authors are read from the file.
Every file under a kit's `tex/` folder and every `.csl` file must be covered by an entry; --check says which is not.
"""

from __future__ import annotations

import hashlib
import re
import sys
from pathlib import Path

import yaml

ROOT = Path(__file__).resolve().parent.parent
GENERATED_NOTE = "<!-- written by scripts/third-party.py from the kits' SOURCES.yaml: edit those, not this file -->"


def sha256(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def expand(kit: Path, names: list[str], excluded: list[str]) -> list[Path]:
    skip = [(kit / name).resolve() for name in excluded]
    found: list[Path] = []
    for name in names:
        top = kit / name
        if not top.exists():
            sys.exit(f"{kit.name}/SOURCES.yaml: {name} does not exist")
        paths = [top] if top.is_file() else sorted(p for p in top.rglob("*") if p.is_file())
        found += [p for p in paths if not any(s == p.resolve() or s in p.resolve().parents for s in skip)]
    return found


def csl_facts(path: Path) -> dict[str, str]:
    text = path.read_text(encoding="utf-8")
    info = re.search(r"<info>.*?</info>", text, re.S)
    block = info.group(0) if info else ""
    title = re.search(r"<title>([^<]*)</title>", block)
    updated = re.search(r"<updated>([^<]*)</updated>", block)
    rights = re.search(r"<rights[^>]*>([^<]*)</rights>", block)
    return {
        "title": title.group(1) if title else path.stem,
        "updated": updated.group(1)[:10] if updated else "",
        "authors": ", ".join(re.findall(r"<name>([^<]*)</name>", block)),
        "rights": rights.group(1) if rights else "",
    }


def kits() -> list[Path]:
    return sorted(p.parent for p in ROOT.glob("*/SOURCES.yaml"))


def cell(text: str) -> str:
    return " ".join(str(text).split()).replace("|", "\\|")


def main(argv: list[str]) -> int:
    check = "--check" in argv
    problems: list[str] = []
    lines = [
        "# Third-party files",
        "",
        GENERATED_NOTE,
        "",
        "Every file in this repository that is not the author's own is listed here with where it comes from, who wrote it and the",
        "license that lets it be copied. Nothing below was edited: each file is byte-identical to upstream, and `KIT/SHA256SUMS`",
        "records the SHA-256 of every one (`cd KIT && shasum -a 256 -c SHA256SUMS`).",
        "",
        "The author's own files (`*.kit`, `metadata.yaml`, `*.lua`, the README files, the examples, the scripts) are MIT, see",
        "`LICENSE`. The files below keep their own licenses; the texts are in `LICENSES/` (a package that allows \"LPPL 1.3 or later\"",
        "is used here under 1.3c). None of them is endorsed by, or affiliated with, any publisher or society named here; the",
        "classes are community or publisher-supplied templates and the names are trademarks of their owners.",
        "",
        "LPPL asks that a copy of a package is distributed whole and unmodified, or renamed when changed: that is why each class is",
        "kept as it was (with the complete CTAN archive beside it in `tex/upstream/`) and all glue lives in files with names of their",
        "own. CC BY-SA 3.0 (the citation styles) asks for credit and that a changed copy keeps the license.",
        "",
    ]
    for kit in kits():
        entries = yaml.safe_load((kit / "SOURCES.yaml").read_text(encoding="utf-8")) or []
        covered: set[Path] = set()
        sums: list[str] = []
        lines += [f"## {kit.name}", "", "| What | Files | From | Authors | License |", "|---|---|---|---|---|"]
        for entry in entries:
            files = expand(kit, entry.get("files", []), entry.get("except", []))
            covered.update(p.resolve() for p in files)
            sums += [f"{sha256(p)}  {p.relative_to(kit).as_posix()}" for p in files]
            names = ", ".join(f"`{kit.name}/{n}`" for n in entry["files"])
            what = entry["what"] + (f", {entry['version']}" if entry.get("version") else "")
            source = entry.get("from", "")
            authors, license_ = entry.get("authors", ""), entry.get("license", "")
            if entry.get("commit"):
                csl = [p for p in files if p.suffix == ".csl"]
                if len(csl) == 1:
                    facts = csl_facts(csl[0])
                    what = f"\"{facts['title']}\" (CSL style, updated {facts['updated']})"
                    authors = authors or facts["authors"]
                    if "ShareAlike" not in facts["rights"] and license_ != "CC-BY-SA-3.0":
                        problems.append(f"{kit.name}: {csl[0].name} states other rights: {facts['rights']}")
                source = source or (f"https://github.com/citation-style-language/styles/blob/{entry['commit']}/{csl[0].name}"
                                    if len(csl) == 1 else "")
            if not authors or not license_ or not source:
                problems.append(f"{kit.name}: entry \"{entry['what']}\" needs from, authors and license")
            if entry.get("notes"):
                what += f". {entry['notes']}"
            if entry.get("archive-sha256"):
                what += f". Archive SHA-256 {entry['archive-sha256']}"
            lines.append(f"| {cell(what)} | {cell(names)} | {cell(source)} | {cell(authors)} | {cell(license_)} |")
        lines.append("")
        # what would be third-party but is not declared
        owned = {"SOURCES.yaml", "SHA256SUMS"}
        for path in sorted(kit.rglob("*")):
            if path.is_file() and path.resolve() not in covered and path.name not in owned:
                relative = path.relative_to(kit)
                if relative.parts[0] == "tex" or path.suffix == ".csl":
                    problems.append(f"{kit.name}/{relative.as_posix()} is in tex/ or a .csl style but no SOURCES.yaml entry covers it")
        text = "\n".join(sorted(sums)) + "\n"
        target = kit / "SHA256SUMS"
        if check:
            if not target.is_file() or target.read_text(encoding="utf-8") != text:
                problems.append(f"{kit.name}/SHA256SUMS is out of date (a vendored file changed, or a new one is not listed)")
        else:
            target.write_text(text, encoding="utf-8")
    text = "\n".join(lines).rstrip() + "\n"
    if check:
        current = (ROOT / "THIRD_PARTY.md")
        if not current.is_file() or current.read_text(encoding="utf-8") != text:
            problems.append("THIRD_PARTY.md is out of date: run scripts/third-party.py")
    else:
        (ROOT / "THIRD_PARTY.md").write_text(text, encoding="utf-8")
    for problem in problems:
        print(f"PROBLEM  {problem}", file=sys.stderr)
    if not check and not problems:
        print(f"wrote THIRD_PARTY.md and {len(kits())} SHA256SUMS")
    return 1 if problems else 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
