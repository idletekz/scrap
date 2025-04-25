cleanup_old_files_by_sample() {
  local dir="${1:-.}"
  local filename="${2:-}"
  local cache="${3:-3}"

  # Validate input
  if [[ -z "$filename" ]]; then
    echo "[ERROR] Filename must be provided." >&2
    return 1
  fi

  if [[ ! -d "$dir" ]]; then
    echo "[ERROR] Directory '$dir' does not exist." >&2
    return 1
  fi

  if ! [[ "$cache" =~ ^[0-9]+$ ]]; then
    echo "[ERROR] Cache value must be a positive integer." >&2
    return 1
  fi

  if (( cache < 1 )); then
    echo "[WARN] Forcing minimum cache to 1."
    cache=1
  fi

  # Extract prefix from filename (up to first '-' or '.')
  local prefix="${filename%%[-.]*}"
  if [[ -z "$prefix" ]]; then
    echo "[ERROR] Failed to extract prefix from '$filename'" >&2
    return 1
  fi

  local pattern="${prefix}*"
  echo "[INFO] Matching files in '$dir' with pattern '$pattern' (prefix: '$prefix')"

  # Find and sort files by modified time (newest first)
  local file_list
  file_list=$(find "$dir" -maxdepth 1 -type f -name "$pattern" -printf "%T@ %p\n" 2>/dev/null | sort -nr)

  if [[ -z "$file_list" ]]; then
    echo "[INFO] No matching files found."
    return 0
  fi

  local total_files
  total_files=$(echo "$file_list" | wc -l)

  if (( total_files <= cache )); then
    echo "[INFO] $total_files file(s) found. Nothing to delete (cache: $cache)."
    return 0
  fi

  local files_to_delete
  files_to_delete=$(echo "$file_list" | tail -n +$((cache + 1)) | awk '{print $2}')

  echo "[INFO] Deleting $((total_files - cache)) old file(s):"
  echo "$files_to_delete"

  while IFS= read -r file; do
    if rm -f -- "$file"; then
      echo "[INFO] Deleted '$file'"
    else
      echo "[ERROR] Failed to delete '$file'" >&2
    fi
  done <<< "$files_to_delete"
}