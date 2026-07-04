#!/usr/bin/env bash
# Print a short project label for a directory path.
# Used as the tab-name prefix and the reorder grouping key.
# Edit the normalization rules below to taste.
set -euo pipefail
path="${1:-$PWD}"
label="$(basename "$path")"
# Normalization rules (extend as needed):
label="${label%-omnitend}"                                     # strip customer suffix
label="$(printf '%s' "$label" | sed -E 's/^[0-9]{4}-[0-9]{2}-[0-9]{2}-//')"  # strip ISO date prefix
printf '%s' "$label"
