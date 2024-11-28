curl -s https://api.github.com/repos/{owner}/{repo}/commits/{branch} | jq -r '.sha'
