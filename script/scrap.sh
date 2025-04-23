#!/usr/bin/env bash
set -euo pipefail

# Returns the filename (in $1) closest to today among files matching
# YYYY-MM-DD-CHG*.yml in the given directory.
# Usage: get_closest_file [search_dir]
get_closest_file() {
  local dir="${1:-.}"
  local pattern='[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]-CHG*.yml'
  local today now_sec file_date date_sec diff
  today=$(date +%s)
  local closest_file="" min_diff=

  shopt -s nullglob
  for now in "$dir"/$pattern; do
    # strip everything after the date
    file_date=${now##*/}       # remove path
    file_date=${file_date%%-CHG*}

    # convert to epoch seconds (on macOS replace `date -d` with `gdate -d`)
    date_sec=$(date -d "$file_date" +%s)

    # absolute difference
    diff=$(( date_sec>today ? date_sec-today : today-date_sec ))

    # record if first or better match
    if [[ -z $min_diff || diff -lt min_diff ]]; then
      min_diff=$diff
      closest_file=$now
    fi
  done
  shopt -u nullglob

  if [[ -n $closest_file ]]; then
    printf '%s' "$closest_file"
    return 0
  else
    return 1
  fi
}

# ---- example usage ----

if closest=$(get_closest_file "/path/to/dir"); then
  echo "Closest file is: $closest"
else
  echo "No matching files found." >&2
  exit 1
fi
