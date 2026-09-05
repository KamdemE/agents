#!/bin/sh
# check-dashes — fail if any tracked .tex file contains an em-dash (---)
# outside of comment lines (%...). Usage: sh scripts/check-dashes.sh
# (MANDATORY in every KπX TeX-family project's `make check`, first position —
# never build on a dashes failure. See k-tex; symlinked into k-presentation.)
set -eu
fail=0
for f in $(git ls-files '*.tex'); do
	hits=$(grep -v '^[[:space:]]*%' "$f" | grep -n -- '---' || true)
	if [ -n "$hits" ]; then
		while IFS= read -r hit; do
			echo "$f:$hit"
		done <<EOF
$hits
EOF
		fail=1
	fi
done
if [ "$fail" = 1 ]; then
	echo "check-dashes FAILED: em-dash (---) found above — use -- instead" >&2
	exit 1
else
	echo "check-dashes OK: no em-dash in .tex files"
fi
