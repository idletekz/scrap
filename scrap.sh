#!/bin/bash

# Function to clone a GitHub PR into a new temporary directory, with support for private repositories
clone_github_pr() {
  # Check if the correct number of arguments is passed
  if [ "$#" -ne 3 ]; then
    echo "Usage: clone_github_pr <repo_url> <pr_number> <pat_token>"
    return 1
  fi

  # Extract arguments
  local repo_url="$1"
  local pr_number="$2"
  local pat_token="$3"

  # Create a new temporary directory
  local tmp_dir=$(mktemp -d -t pr-clone-XXXXXX)
  echo "Created temporary directory $tmp_dir"

  # Navigate to the temporary directory
  cd "$tmp_dir"

  # Initialize a new git repository
  git init &> /dev/null

  # Modify the repository URL to include the PAT for authentication
  local auth_repo_url=$(echo "$repo_url" | sed "s://:://$pat_token@:")

  # Add the original repository as a remote with authentication
  git remote add origin "$auth_repo_url"

  # Fetch the PR
  git fetch origin pull/"$pr_number"/head:pr-"$pr_number" &> /dev/null

  # Checkout the PR
  git checkout pr-"$pr_number" &> /dev/null

  echo "PR #$pr_number from $repo_url has been cloned into $tmp_dir"
}

# Example usage (Do not hardcode your PAT in the script or use it directly in the command line to avoid exposure)
# clone_github_pr https://github.com/example/repo.git 123 your_pat_token_here
