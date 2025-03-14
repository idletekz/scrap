#!/bin/bash

DEPLOYMENTS_JSON_BASE64=$(yq eval -o=json '
  [ (.) | select(.kind == "Deployment") | 
  {"Deployment": .metadata.name, "Replicas": .spec.replicas} ]
' manifest.yaml | jq -s add | base64 -w 0)

echo "$DEPLOYMENTS_JSON_BASE64" | base64 -d | jq

# jq -c '.[]' extracts each object from the JSON array as a single-line JSON string
# while read -r deployment reads each JSON object one by one.
# The -r flag prevents backslash escapes (\) from being interpreted. This ensures JSON remains intact.

# Decode the Base64-encoded JSON and iterate over each deployment
echo "$DEPLOYMENTS_JSON_BASE64" | base64 -d | jq -c '.[]' | while read -r deployment; do
  name=$(echo "$deployment" | jq -r '.Deployment')
  replicas=$(echo "$deployment" | jq -r '.Replicas')
  echo "Deployment Name: $name, Replicas: $replicas"
done

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

# Find non-allowed keys
NON_ALLOWED_KEYS=()
for key in "${ROOT_KEYS[@]}"; do
    if [[ ! " ${ALLOWED_KEYS[*]} " =~ " $key " ]]; then
        NON_ALLOWED_KEYS+=("$key")
    fi
done

# Extract file paths from allowed keys
FILE_PATHS=$(yq e '.[] | select(has("filepath")) | .filepath' "$YAML_FILE")

# Check if file paths exist and collect missing ones
MISSING_FILES=()
while IFS= read -r filepath; do
    if [ ! -e "$filepath" ]; then
        MISSING_FILES+=("$filepath")
    fi
done <<< "$FILE_PATHS"

# Output results
if [ ${#NON_ALLOWED_KEYS[@]} -gt 0 ]; then
    echo "Non-allowed keys found in YAML:"
    for key in "${NON_ALLOWED_KEYS[@]}"; do
        echo "- $key
