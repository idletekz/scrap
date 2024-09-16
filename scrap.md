```bash
gh-app-token() {
  if [[ "${GITHUB_APP_ID}" != "" ]] && [[ -e "${GITHUB_APP_SECRET_PATH}" ]] ; then
    # Create a temporary JWT for API access
    GITHUB_JWT=$(jwt encode --secret "@${GITHUB_APP_SECRET_PATH}" -i "${GITHUB_APP_ID}" -e "10 minutes" --alg RS256 )
    # Request installation information; note that this assumes there's just one installation (this is a private GitHub app);
    # if you have multiple installations you'll have to customize this to pick out the installation you are interested in    
    APP_TOKEN_URL=$( curl -s -H "Authorization: Bearer ${GITHUB_JWT}" -H "Accept: application/vnd.github.v3+json" https://api.github.com/app/installations | yq -r '.[0].access_tokens_url' )
    # Now POST to the installation token URL to generate a new access token we can use to with with the gh and hub command lines
    export GITHUB_TOKEN=$( curl -s -X POST -H "Authorization: Bearer ${GITHUB_JWT}" -H "Accept: application/vnd.github.v3+json" ${APP_TOKEN_URL} | yq -r '.token' )
  fi
}
```


```powershell
function clonePR {
    param (
        [Parameter(Mandatory=$true)]
        [int]$prNumber,

        [Parameter(Mandatory=$false)]
        [string]$remoteRepoName = "upstream"
    )

    $branchName = "pr-$prNumber"
    $remoteRef = "refs/pull/$prNumber/head"

    Write-Host "fetching pull request #$prNumber from remote '$remoteRepoName'..."
    git fetch $remoteRepoName $remoteRef

    Write-Host "checking out the pull request to branch '$branchName'..."
    git checkout -b $branchName FETCH_HEAD
}
```

```bash
function clonePR() {
    if [ $# -lt 1 ]; then
        echo "Usage: clonePR <prNumber> [remoteRepoName]"
        return 1
    fi

    prNumber="$1"
    remoteRepoName="${2:-upstream}"

    branch_name="pr-$prNumber"
    remote_ref="refs/pull/$prNumber/head"

    echo "fetching pull request #$prNumber from remote '$remoteRepoName'..."
    git fetch "$remoteRepoName" "$remote_ref"

    echo "checking out the pull request to branch '$branch_name'..."
    git checkout -b "$branch_name" FETCH_HEAD
}
```
