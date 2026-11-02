#!/usr/bin/env python3
"""Fetch a citation style from the CSL repository, pinned to the commit that last changed it.

    scripts/fetch-csl.py STYLE KIT [SAVE_AS]

STYLE     the file in https://github.com/citation-style-language/styles (american-chemical-society, apa, ieee ...)
KIT       the kit folder; the style is written to KIT/SAVE_AS (default STYLE.csl), unchanged
SAVE_AS   the name to save it under

Prints what THIRD_PARTY.md needs: the commit, the title, the date, the authors, the license and the SHA-256.
Styles are CC BY-SA 3.0: they are kept as downloaded, with their own credits, and not edited.
Needs the GitHub CLI (`gh`) for the commit lookup.
"""

from __future__ import annotations

import hashlib
import json
import re
import subprocess
import sys
import urllib.request
from pathlib import Path

REPOSITORY = "citation-style-language/styles"


def main(argv: list[str]) -> int:
    if len(argv) < 3:
        print(__doc__)
        return 2
    style, kit = argv[1].removesuffix(".csl"), Path(argv[2])
    save_as = argv[3] if len(argv) > 3 else f"{style}.csl"
    commits = json.loads(subprocess.run(
        ["gh", "api", f"repos/{REPOSITORY}/commits?path={style}.csl&per_page=1"],
        capture_output=True, text=True, check=True).stdout)
    if not commits:
        sys.exit(f"{style}.csl is not in {REPOSITORY}")
    sha = commits[0]["sha"]
    url = f"https://raw.githubusercontent.com/{REPOSITORY}/{sha}/{style}.csl"
    with urllib.request.urlopen(url, timeout=60) as response:  # noqa: S310 (a fixed https host)
        data = response.read()
    text = data.decode("utf-8")
    kit.mkdir(parents=True, exist_ok=True)
    (kit / save_as).write_bytes(data)
    title = re.search(r"<title>([^<]*)</title>", text)
    updated = re.search(r"<updated>([^<]*)</updated>", text)
    rights = re.search(r"<rights[^>]*>([^<]*)</rights>", text)
    info = re.search(r"<info>.*?</info>", text, re.S)
    authors = re.findall(r"<name>([^<]*)</name>", info.group(0) if info else "")   # <author> and <contributor>
    print(f"file     {kit / save_as}")
    print(f"commit   {sha}")
    print(f"title    {title.group(1) if title else '?'}")
    print(f"updated  {updated.group(1)[:10] if updated else '?'}")
    print(f"authors  {', '.join(authors) or '(none listed)'}")
    print(f"rights   {rights.group(1) if rights else 'not stated in the file: CC BY-SA 3.0 by the repository'}")
    print(f"sha256   {hashlib.sha256(data).hexdigest()}")
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
