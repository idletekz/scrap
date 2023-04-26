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
