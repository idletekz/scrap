import requests

def check_files_in_docs_directory(files_url, headers):
    response = requests.get(files_url, headers=headers)
    files = response.json()
    return all(file['filename'].startswith('docs/') for file in files)

def approve_pull_request(repo_owner, repo_name, pr_number, github_token):
    # Define the URL for the pull request files and the review endpoint
    files_url = f"https://api.github.com/repos/{repo_owner}/{repo_name}/pulls/{pr_number}/files"
    review_url = f"https://api.github.com/repos/{repo_owner}/{repo_name}/pulls/{pr_number}/reviews"

    # Set up headers for Authorization
    headers = {
        'Authorization': f'token {github_token}',
        'Accept': 'application/vnd.github.v3+json'
    }

    # Check if all files are within the docs directory
    if check_files_in_docs_directory(files_url, headers):
        # Data for approving the pull request
        data = {
            'event': 'APPROVE',
            'body': 'Auto-approved since changes are confined to docs directory.'
        }
        response = requests.post(review_url, headers=headers, json=data)
        if response.status_code == 201:
            print("Pull request approved.")
        else:
            print("Failed to approve pull request:", response.json())
    else:
        print("Pull request contains changes outside the 'docs' directory.")

# Variables you need to set
repo_owner = 'your_repo_owner'
repo_name = 'your_repo_name'
pr_number = 1  # Pull request number
github_token = 'your_github_token'

approve_pull_request(repo_owner, repo_name, pr_number, github_token)
