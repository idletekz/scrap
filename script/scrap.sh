#!/bin/bash

# Ensure a PR number is provided
if [ -z "$1" ]; then
    echo "Usage: $0 <PR_NUMBER>"
    exit 1
fi

# Get the directory where the script resides
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Construct YAML filename from PR number
PR_NUMBER="$1"
YAML_FILE="$SCRIPT_DIR/${PR_NUMBER}.yml"

# Allowed root keys
ALLOWED_KEYS=("filestore_folder_root" "filestore_folder_sub1" "filestore_folder_sub2" "filestore_file")

# Check if YAML file exists
if [ ! -f "$YAML_FILE" ]; then
    echo "Error: YAML file '$YAML_FILE' not found."
    exit 1
fi

# Check if yq (a YAML processor) is installed
if ! command -v yq &> /dev/null; then
    echo "Error: 'yq' is required but not installed. Install it from https://github.com/mikefarah/yq."
    exit 1
fi

# Extract root keys from YAML
ROOT_KEYS=($(yq e 'keys | .[]' "$YAML_FILE"))

# Check if there are any unexpected keys
for key in "${ROOT_KEYS[@]}"; do
    if [[ ! " ${ALLOWED_KEYS[*]} " =~ " $key " ]]; then
        echo "Error: Invalid key '$key' found in YAML. Allowed keys are: ${ALLOWED_KEYS[*]}"
        exit 1
    fi
done

# Extract file paths from the allowed keys
FILE_PATHS=$(yq e '.[] | select(has("filepath")) | .filepath' "$YAML_FILE")

# Check if file paths exist and print only missing ones
MISSING_FILES=()
while IFS= read -r filepath; do
    if [ ! -e "$filepath" ]; then
        MISSING_FILES+=("$filepath")
    fi
done <<< "$FILE_PATHS"

# Print only missing file paths
if [ ${#MISSING_FILES[@]} -eq 0 ]; then
    echo "All files exist."
else
    echo "Missing file paths:"
    for file in "${MISSING_FILES[@]}"; do
        echo "$file"
    done
fi
