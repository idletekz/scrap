# Loop through allowed keys and validate file existence and version matching
for key in "${ALLOWED_KEYS[@]}"; do
    # Extract filepath and expected version from YAML; use 'empty' as fallback
    filepath=$(yq e ".${key}.filepath // empty" "$YAML_FILE")
    expected_version=$(yq e ".${key}.version // empty" "$YAML_FILE")
    # Only process if a filepath is defined
    if [ -n "$filepath" ]; then
        if [ ! -e "$filepath" ]; then
            ERRORS+=("File for key '${key}' not found: ${filepath}")
        else
            # Only check version if an expected version is specified
            if [ -n "$expected_version" ]; then
                # Read the versionLabel from the file
                file_version=$(yq e '.versionLabel // empty' "$filepath")
                if [ "$file_version" != "$expected_version" ]; then
                    ERRORS+=("Version mismatch for '${filepath}': expected '${expected_version}', found '${file_version}'")
                fi
            fi
        fi
    fi
done
