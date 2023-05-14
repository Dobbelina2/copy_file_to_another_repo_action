# copy_file_to_another_repo_action
This GitHub Action copies files or folders from the current repository to a location in another repository

# Example Workflow
    name: Push File

    on: push

    jobs:
      copy-file:
        runs-on: ubuntu-latest
        steps:
        - name: Checkout
          uses: actions/checkout@v3

        - name: Pushes test file
          uses: dobbelina/copy_file_to_another_repo_action@main
          env:
            API_TOKEN_GITHUB: ${{ secrets.API_TOKEN_GITHUB }}
          with:
            source_file: 'test2.md'
            destination_repo: 'dmnemec/release-test'
            destination_folder: 'test-dir'
            user_email: 'example@email.com'
            user_name: 'dmnemec'
            commit_message: 'A custom message for the commit'
            delete_existing: true

# Variables

The `API_TOKEN_GITHUB` needs to be set in the `Secrets` section of your repository options. You can retrieve the `API_TOKEN_GITHUB` [here](https://github.com/settings/tokens) (set the `repo` permissions).

* source_file: The file(s) or directory/directories to be moved. Uses the same syntax as the `rsync` command. Include the path for any files not in the repositories root directory. Multiple source files/directories separated by space `"file1.txt file2.txt"`
* destination_repo: The repository to place the file or directory in.
* destination_folder: [optional] The folder in the destination repository to place the file in, if not the root directory.
* user_email: The GitHub user email associated with the API token secret.
* user_name: The GitHub username associated with the API token secret.
* destination_branch: [optional] The branch of the source repo to update, if not "main" branch is used.
* destination_branch_create: [optional] A branch to be created with this commit, defaults to commiting in `destination_branch`
* commit_message: [optional] A custom commit message for the commit. Defaults to `Update from https://github.com/${GITHUB_REPOSITORY}/commit/${GITHUB_SHA}` 
 use `${{ github.event.head_commit.message }}` to preserve the original commit message.
* delete_existing: [optional] Delete all the existing files in the `destination_folder` before copying over the new files.

# Behavior Notes
The action will create any destination paths if they don't exist. It will also overwrite existing files if they already exist in the locations being copied to. It will not delete the entire destination repository.
