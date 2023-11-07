import git
import logging

class GitRepo:
    def __init__(self, repo_url, token, dst_dir):
        self._repo_url = repo_url
        self._dst_dir = dst_dir
        self._logger = logging.getLogger(self.__class__.__name__)
        self._token = token
        self._repo = None

    @property
    def repo(self) -> git.Repo:
        if not self._repo:
            raise ValueError("Repo has not been cloned or initialized: {self._repo_url}")
        return self._repo

    def _validate_url(self, url: str) -> str:
        if "https://" not in url:
            return f"only https url are supported for token-based auth: {url}"
        return None

    def _add_token(self, url: str) -> str:
        return f"https://x-access-token:{self._token}@{url.removeprefix('https://')}"
    
    def has_changes(self) -> bool:
        return self.repo.is_dirty(untracked_files=True)

    def checkout_branch(self, branch: str) -> str:
        try:
            self.repo.git.checkout(branch)
            return None
        except git.exc.GitCommandError as e:
            return f"failed to check branch '{branch}': {e}"
    
    def clone_repo(self) -> str:
        err = self._validate_url(self._repo_url)
        if err:
            return err
        try:
            self._logger.info(f"cloning repository from {self._repo_url} into {self._dst_dir}")
            git.Repo.clone_from(self._add_token(self._repo_url), self._dst_dir, depth=1)
            self._repo = git.Repo(self._dst_dir)
            return None
        except git.exc.GitCommandError as e:
            return f"failed to clone repository: {e}"

    def add_and_commit(self, commit_message: str) -> str:
        if not self.has_changes():
            self._logger.info("No changes to commit")
            return None
        try:
            self.repo.git.add('--all')
            status_output = self.repo.git.status()
            self._logger.info(status_output)
            self.repo.index.commit(commit_message)
            self._logger.info(f"committed changes with message: '{commit_message}'")
            return None
        except git.exc.GitCommandError as e:
            return f"failed to commit changes: {e}"

    def push(self) -> str:
        try:
            origin = self.repo.remote(name='origin')
            origin.push()
            self._logger.info("Pushed changes to the remote repository")
            return None
        except git.exc.GitCommandError as e:
            return f"failed to push changes to remote repo: {e}"



import pytest
from git_repo import GitRepo
from unittest.mock import Mock, MagicMock, patch, PropertyMock
import git

@pytest.fixture
def git_repo():
    # Dummy values for initialization
    return GitRepo(repo_url='https://example.com/repo.git', token='dummy_token', dst_dir='/dummy/dir')

def test_validate_url(git_repo):
    # Test for a valid HTTPS URL
    assert git_repo._validate_url('https://example.com/repo.git') is None
    
    # Test for a non-HTTPS URL
    want = "only https url are supported for token-based auth: http://example.com/repo.git"
    got = git_repo._validate_url('http://example.com/repo.git')
    assert got == want

def test_add_token(git_repo):
    want = git_repo._add_token('https://example.com/repo.git')
    got = 'https://x-access-token:dummy_token@example.com/repo.git'
    assert got == got

def test_has_changes_with_no_changes(git_repo):
    # Mock the repo's is_dirty method to return False
    git_repo._repo = MagicMock()
    git_repo._repo.is_dirty.return_value = False
    
    assert git_repo.has_changes() is False

def test_has_changes_with_changes(git_repo):
    # Mock the repo's is_dirty method to return True
    git_repo._repo = MagicMock()
    git_repo._repo.is_dirty.return_value = True
    
    assert git_repo.has_changes() is True

def test_checkout_branch_success(git_repo):
    # Setup the repo mock with a successful checkout
    git_repo._repo = MagicMock()
    git_repo._repo.git.checkout.return_value = None  # Simulate successful checkout

    # Perform the checkout
    error_message = git_repo.checkout_branch('main')
    
    # Assert no error message is returned on success
    assert error_message is None

@patch('git.Repo')
def test_checkout_branch_failure(mock_git_repo, git_repo):
    # Create a mock GitCommandError
    mock_git_command_error = git.exc.GitCommandError('checkout', 'error message')
    
    # Setup the repo mock to raise a GitCommandError on checkout
    git_repo._repo = mock_git_repo
    git_repo._repo.git.checkout.side_effect = mock_git_command_error

    # Perform the checkout
    want = "failed to check branch 'main': " + str(mock_git_command_error)
    got = git_repo.checkout_branch('main')
    assert got == want

@patch('git.Repo.clone_from')
@patch('git.Repo')
def test_clone_repo_success(mock_repo_class, mock_clone_from, git_repo):
    mock_clone_from.return_value = Mock()
    mock_repo_class.return_value = Mock()
    # Perform the clone
    got = git_repo.clone_repo()
    assert got is None

@patch('git.Repo.clone_from')
def test_clone_repo_failure(mock_clone_from, git_repo):
    mock_git_command_error = git.exc.GitCommandError("clone", "failed to clone repository")
    mock_clone_from.side_effect = mock_git_command_error
    want = f"failed to clone repository: {str(mock_git_command_error)}"
    got = git_repo.clone_repo()
    assert got == want

@patch.object(GitRepo, 'repo', new_callable=PropertyMock)
def test_add_and_commit_with_changes(mock_repo_property, git_repo):
    # Set up the mock Repo object and configure it to return the expected values
    mock_repo = Mock()
    mock_repo.is_dirty.return_value = True
    mock_repo.git.add.return_value = None
    mock_repo.git.status.return_value = "status output"
    mock_repo.index.commit.return_value = None
    mock_repo_property.return_value = mock_repo

    commit_message = "Test commit"
    # Perform the add and commit
    error_message = git_repo.add_and_commit(commit_message)
    
    # Assert no error message is returned on success
    assert error_message is None
    mock_repo.git.add.assert_called_with('--all')
    mock_repo.index.commit.assert_called_with(commit_message)

@patch.object(GitRepo, 'repo', new_callable=PropertyMock)
def test_add_and_commit_failure(mock_repo_property, git_repo):
    mock_repo = Mock()
    mock_repo.is_dirty.return_value = True
    mock_git_command_error = git.exc.GitCommandError('add', 'error message')
    mock_repo.git.add.side_effect = mock_git_command_error
    mock_repo_property.return_value = mock_repo

    commit_message = "Test commit"
    want = f"failed to commit changes: {str(mock_git_command_error)}"
    # Perform the add and commit, which should fail
    got = git_repo.add_and_commit(commit_message)
    
    # Assert the error message is correctly formatted
    assert got == want

@patch.object(GitRepo, 'repo', new_callable=PropertyMock)
def test_push_success(mock_repo_property, git_repo):
    mock_repo = Mock()
    mock_origin = Mock()
    mock_repo.remote.return_value = mock_origin
    mock_repo_property.return_value = mock_repo

    mock_origin.push.return_value = None

    got = git_repo.push()

    # Assert no error message is returned on success
    assert got is None
    mock_origin.push.assert_called_once()

@patch.object(GitRepo, 'repo', new_callable=PropertyMock)
def test_push_failure(mock_repo_property, git_repo):
    mock_repo = Mock()
    mock_origin = Mock()
    mock_repo.remote.return_value = mock_origin
    mock_repo_property.return_value = mock_repo

    mock_git_command_error = git.exc.GitCommandError('push', 'error message')
    mock_origin.push.side_effect = mock_git_command_error

    want = f"failed to push changes to remote repo: {str(mock_git_command_error)}"
    got = git_repo.push()

    assert got == want
