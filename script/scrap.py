import requests

# Replace these with your actual values
token = 'YOUR_GITHUB_TOKEN'
owner = 'OWNER'
repo = 'REPO'
pr_number = 'PR_NUMBER'

url = f'https://api.github.com/repos/{owner}/{repo}/pulls/{pr_number}/reviews'
headers = {
    'Accept': 'application/vnd.github.v3+json',
    'Authorization': f'token {token}',
}

response = requests.get(url, headers=headers)
reviews = response.json()

approved_reviews = [review for review in reviews if review['state'] == 'APPROVED']

if approved_reviews:
    print(f'The pull request #{pr_number} has been approved.')
else:
    print(f'The pull request #{pr_number} has not been approved.')

--- 
# rebase
import requests

# Replace these with your actual values
token = 'YOUR_GITHUB_TOKEN'
owner = 'OWNER'
repo = 'REPO'
pr_number = 'PR_NUMBER'

# GitHub API URL for merging a pull request
merge_url = f'https://api.github.com/repos/{owner}/{repo}/pulls/{pr_number}/merge'

headers = {
    'Accept': 'application/vnd.github.v3+json',
    'Authorization': f'token {token}',
}

# Payload for the merge request
payload = {
    'merge_method': 'rebase'
}

# Make the request to merge the pull request
response = requests.put(merge_url, headers=headers, json=payload)

if response.status_code == 200:
    print(f'Successfully rebased and merged PR #{pr_number}')
else:
    print(f'Failed to rebase and merge PR #{pr_number}: {response.json()}')
