#!/usr/bin/env bash
# Build the example of every kit with pdfmd and each engine that is installed, and say what failed.
#   scripts/check-examples.sh                 all kits, all engines found
#   scripts/check-examples.sh apa7            one kit
#   ENGINES="xelatex tectonic" scripts/check-examples.sh
#   PDFMD="python3 $HOME/dev/py/pdfmd/pdfmd.py" scripts/check-examples.sh      # a checkout of pdfmd
# Each build goes to a temporary folder, never into the kit.
set -u
root=$(cd "$(dirname "$0")/.." && pwd)
engines=${ENGINES:-"lualatex xelatex tectonic"}
only=${1:-}
read -ra pdfmd_cmd <<<"${PDFMD:-pdfmd}"      # PDFMD="python3 ~/dev/py/pdfmd/pdfmd.py" runs a checkout
work=$(mktemp -d)
trap 'rm -r "$work"' EXIT
fail=0
for example in "$root"/*/example/*.md; do
  [ -e "$example" ] || continue
  kit=$(basename "$(dirname "$(dirname "$example")")")
  [ -z "$only" ] || [ "$only" = "$kit" ] || continue
  # the front matter of an example may say which modes to try: `# check-modes: stu man`
  modes=$(sed -n 's/^# check-modes: //p' "$example" | head -1)
  # `# check-engines: lualatex xelatex` limits the engines for an example (a class the other engines cannot run)
  only_engines=$(sed -n 's/^# check-engines: //p' "$example" | head -1)
  for mode in ${modes:-""}; do
    for engine in ${only_engines:-$engines}; do
      command -v "$engine" >/dev/null 2>&1 || { echo "skip  $kit${mode:+:$mode} $engine (not installed)"; continue; }
      dir="$work/$kit-${mode:-default}-$engine"
      mkdir -p "$dir"
      cp "$(dirname "$example")"/* "$dir"/
      name=$(basename "$example" .md)
      if (cd "$dir" && "${pdfmd_cmd[@]}" "$name" --kit "$kit${mode:+:$mode}" -e "$engine" -o "$name.pdf" >log.txt 2>&1) \
         && [ -s "$dir/$name.pdf" ]; then
        echo "ok    $kit${mode:+:$mode} $engine ($(pdfinfo "$dir/$name.pdf" 2>/dev/null | awk '/^Pages:/{print $2}') pages)"
      else
        echo "FAIL  $kit${mode:+:$mode} $engine: $(grep -m1 -E '^!|error|Error' "$dir/log.txt" | cut -c1-120)"
        fail=1
      fi
    done
  done
done
exit $fail
