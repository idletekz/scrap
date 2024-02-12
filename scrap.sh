#!/bin/bash

# Usage: ./script.sh <GitHub URL> <Branch Name>

# Example: ./script.sh https://github.com/username/repo.git main

# Extracts the GitHub URL and Branch Name from the command line arguments
GITHUB_URL=$1
BRANCH_NAME=$2
PERSONAL_ACCESS_TOKEN="YOUR_TOKEN_HERE"
# Depth for a shallow clone
DEPTH=1

# Check if both arguments are provided
if [ -z "$GITHUB_URL" ] || [ -z "$BRANCH_NAME" ]; then
    echo "Usage: $0 <GitHub URL> <Branch Name>"
    exit 1
fi

# Replace https:// with https://<TOKEN>@ to include the PAT in the URL for cloning
CLONE_URL=$(echo $GITHUB_URL | sed "s/https:\/\//https:\/\/$PERSONAL_ACCESS_TOKEN@/g")

# Shallow clone the specific branch into the current working directory
git clone -b $BRANCH_NAME --depth $DEPTH $CLONE_URL .

echo "Repository cloned successfully into the current directory."


#!/bin/bash

# Full path to the file
FILE_PATH="/path/to/your/file.tar"

# Directory to search for files with the same base name
SEARCH_DIR="/path/to/directory"

# Extract the base name from the file path
BASE_NAME=$(basename "$FILE_PATH")

# Find files in the specified directory with the same base name
matching_files=$(find "$SEARCH_DIR" -maxdepth 1 -type f -name "$BASE_NAME")

# Count the number of matching files found
file_count=$(echo "$matching_files" | grep -v '^$' | wc -l)

# Check the number of matching files and act accordingly
if [ "$file_count" -eq 0 ]; then
  echo "No files found with base name $BASE_NAME in $SEARCH_DIR."
elif [ "$file_count" -eq 1 ]; then
  echo "Extracting file: $matching_files"
  tar -xf "$matching_files" -C .
  echo "Extraction completed."
else
  echo "Error: More than one file found with base name $BASE_NAME. Please ensure only one file with that base name is present."
  exit 1
fi
