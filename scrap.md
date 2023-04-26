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
