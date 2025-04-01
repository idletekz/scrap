# Initialize an array to track errors
ERRORS=()

# Loop through allowed keys and validate each file entry
for key in "${ALLOWED_KEYS[@]}"; do
    # Determine the number of entries in the array for this key
    count=$(yq e ".${key} | length" "$YAML_FILE")
    
    # Skip if the key is empty or not an array
    if [ "$count" = "0" ] || [ -z "$count" ]; then
        continue
    fi

    for (( i=0; i<count; i++ )); do
        # Extract filepath and expected version for this entry
        filepath=$(yq e ".${key}[${i}].filepath // \"\"" "$YAML_FILE")
        expected_version=$(yq e ".${key}[${i}].version // \"\"" "$YAML_FILE")

        if [ -z "$filepath" ]; then
            ERRORS+=("Entry $i in '${key}' does not have a 'filepath' defined.")
            continue
        fi

        if [ ! -e "$filepath" ]; then
            ERRORS+=("File not found for '${key}' entry $i: ${filepath}")
        else
            # If an expected version is provided, check the file's versionLabel
            if [ -n "$expected_version" ]; then
                file_version=$(yq e '.versionLabel // ""' "$filepath")
                if [ "$file_version" != "$expected_version" ]; then
                    ERRORS+=("Version mismatch for '${filepath}' in '${key}' entry $i: expected '${expected_version}', found '${file_version}'")
                fi
            fi
        fi
    done
done

# Output errors if any were found
if [ ${#ERRORS[@]} -gt 0 ]; then
    echo "Errors detected:"
    for error in "${ERRORS[@]}"; do
        echo "- $error"
    done
    exit 1
else
    echo "All file paths exist and version labels match."
fi
