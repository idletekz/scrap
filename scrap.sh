import requests

def find_comment_id(comments_url, identifier, headers):
    """
    Find the comment ID for the existing test results comment.

    :param comments_url: GitHub API URL for the pull request comments
    :param identifier: Unique identifier to search for in the comments
    :param headers: Headers to use for the GitHub API request
    :return: The ID of the found comment or None
    """
    response = requests.get(comments_url, headers=headers)
    if response.status_code == 200:
        comments = response.json()
        for comment in comments:
            if identifier in comment['body']:
                return comment['id']
    return None

def post_or_update_comment(repo, pr_id, report_file_path, github_token, identifier):
    """
    Post a new comment or update an existing one with pytest results.

    :param repo: Repository name in the format 'owner/repo'
    :param pr_id: Pull Request ID (number)
    :param report_file_path: Path to the file containing the pytest results
    :param github_token: GitHub Personal Access Token for authentication
    :param identifier: Unique identifier to mark the comment for later updates
    """
    comments_url = f"https://api.github.com/repos/{repo}/issues/{pr_id}/comments"
    headers = {'Authorization': f'token {github_token}'}
    
    comment_id = find_comment_id(comments_url, identifier, headers)
    
    with open(report_file_path, 'r') as file:
        report_content = file.read()
    
    comment_body = {
        "body": f"### Pytest Results\n```\n{report_content}\n```\n\n<!-- {identifier} -->"
    }
    
    if comment_id:
        # Update existing comment
        update_url = f"{comments_url}/{comment_id}"
        response = requests.patch(update_url, json=comment_body, headers=headers)
    else:
        # Post new comment
        response = requests.post(comments_url, json=comment_body, headers=headers)
    
    if response.status_code in [200, 201]:
        print("Comment posted or updated successfully.")
    else:
        print(f"Failed to post or update comment. Status code: {response.status_code}, Response: {response.text}")

# Usage
repo = 'your_username/your_repo'
pr_id = 'PR_NUMBER'
report_file_path = 'pytest_results.txt'
github_token = 'YOUR_GITHUB_TOKEN'
identifier = 'unique_test_results_identifier'  # This should be a unique phrase or keyword.

post_or_update_comment(repo, pr_id, report_file_path, github_token, identifier)
