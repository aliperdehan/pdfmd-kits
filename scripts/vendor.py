#!/usr/bin/env python3
"""Vendor a LaTeX package into a kit, unmodified, and print the rows for THIRD_PARTY.md.

    scripts/vendor.py [--prefer-archive] KIT ARCHIVE.zip TEXLIVE_DIR [TEXLIVE_DIR ...]

KIT           the kit folder (apa7, achemso, ...)
ARCHIVE.zip   the package's complete distribution from CTAN (https://mirrors.ctan.org/macros/latex/contrib/NAME.zip)
TEXLIVE_DIR   folder(s) of the installed form under texmf-dist/tex/latex (revtex, achemso ...); its files go to KIT/tex/

The archive is unpacked with Python's zipfile (no code in it is run) into KIT/tex/upstream/, without its top folder.
The installed files are copied from TeX Live byte for byte; with --prefer-archive a file the archive ships too (a class that
needs no .ins run) is taken from the archive when TeX Live's copy is older. Nothing is edited: LPPL asks that a changed copy be renamed,
so a kit keeps its own glue in files of its own (KIT.kit, metadata.yaml, KIT.lua).
"""

from __future__ import annotations

import hashlib
import shutil
import sys
import zipfile
from pathlib import Path

TEXLIVE = next(iter(sorted(Path("/usr/local/texlive").glob("*/texmf-dist/tex/latex"))[::-1]), None)


def sha256(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def unpack(archive: Path, target: Path) -> list[Path]:
    """Unpack `archive` into `target`, dropping a single top folder; refuses names that leave `target`."""
    written: list[Path] = []
    with zipfile.ZipFile(archive) as zf:
        names = [info for info in zf.infolist() if not info.filename.startswith("__MACOSX")]
        tops = {info.filename.split("/", 1)[0] for info in names}
        strip = len(tops) == 1 and any("/" in info.filename for info in names)
        for info in names:
            parts = Path(info.filename).parts[1:] if strip else Path(info.filename).parts
            if not parts:
                continue
            destination = target.joinpath(*parts).resolve()
            if target.resolve() not in destination.parents and destination != target.resolve():
                sys.exit(f"refusing {info.filename}: it leaves {target}")
            if info.is_dir():
                destination.mkdir(parents=True, exist_ok=True)
                continue
            destination.parent.mkdir(parents=True, exist_ok=True)
            destination.write_bytes(zf.read(info))
            written.append(destination)
    return written


def main(argv: list[str]) -> int:
    prefer_archive = "--prefer-archive" in argv
    argv = [item for item in argv if item != "--prefer-archive"]
    if len(argv) < 4 or TEXLIVE is None:
        print(__doc__)
        return 2
    kit, archive, sources = argv[1], Path(argv[2]), argv[3:]
    tex = Path(kit) / "tex"
    upstream = tex / "upstream"
    if upstream.exists():
        sys.exit(f"{upstream} exists: remove it yourself (this script never deletes) and run again")
    unpack(archive, upstream)
    installed: list[Path] = []
    for name in sources:
        source = TEXLIVE / name
        if not source.is_dir():
            sys.exit(f"{source} is not a folder")
        for path in sorted(source.rglob("*")):
            if path.is_file():
                destination = tex / path.relative_to(source)
                destination.parent.mkdir(parents=True, exist_ok=True)
                shutil.copy2(path, destination)
                installed.append(destination)
    if prefer_archive:
        # TeX Live may be behind CTAN: where the archive ships the same file ready to use, the archive's copy is the one kept
        for path in installed:
            twin = upstream / path.name
            if twin.is_file() and twin.read_bytes() != path.read_bytes():
                shutil.copy2(twin, path)
                print(f"  {path.relative_to(kit)}: the archive's copy replaces TeX Live's")
    print(f"archive  {archive.name}  sha256 {sha256(archive)}")
    print(f"installed {len(installed)} files from {', '.join(sources)}; upstream: {sum(1 for p in upstream.rglob('*') if p.is_file())} files")
    for path in installed:
        twin = upstream / path.name
        same = twin.is_file() and twin.read_bytes() == path.read_bytes()
        print(f"  {path.relative_to(kit)}  {sha256(path)}{'  (= upstream file)' if same else ''}")
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
