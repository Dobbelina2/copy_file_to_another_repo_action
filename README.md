# copy_file_to_another_repo_action
This GitHub Action copies files or folders from the current repository to a location in another repository
 ```diff
   Improved version from @dmnemec
 + Uses rsync exclusively with full access to it's switches,
 + using the rsync_option: [optional] makes it very versatile
 + with lots of configuration settings, see RSYNC.MD that gives
 + a short tutorial + examples.
 + If rsync_option: is not used it defaults to '-avrh' 
 
 + Multiple source files/directories separated by comma
 + "file1.txt,file2.txt" or '"file 1.txt","file 2.txt"'
 + if there are spaces in the file/folder name(s)
 
 + Use ${{ github.event.head_commit.message }} to 
 + preserve the original commit message.
 
 + git-lfs support.
 ```
# Example Workflow
```yml
name: Push Files

on: push

jobs:
  copy-files:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v3

      - name: Push test folder & 1 file
        uses: dobbelina/copy_file_to_another_repo_action@main
        env:
          API_TOKEN_GITHUB: ${{ secrets.API_TOKEN_GITHUB }}
        with:
          source_file: "My_Folder/,Another_Folder/test.txt"
          destination_repo: "dmnemec/release-test"
          destination_folder: "test-dir"
          user_email: "example@email.com"
          user_name: "dmnemec"
          commit_message: ${{ github.event.head_commit.message }}
          rsync_option: "-avrh --delete" # Deletes any files in the 
                                         # destination that is not
                                         # present in the source 
 ```
# Variables

The `API_TOKEN_GITHUB` needs to be set in the `Secrets` section of your repository options. You can retrieve the `API_TOKEN_GITHUB` [here](https://github.com/settings/tokens) (set the `repo` permissions).

* source_file: The file(s) or directory/directories to be moved. Uses the same syntax as the `rsync` command. Include the path for any files not in the repositories root directory. Multiple source files/directories separated by comma 
`"file1.txt,file2.txt"` or `'"file 1.txt","file 2.txt"'` if there are spaces in the file/folder name(s)
* destination_repo: The repository to place the file or directory in.
* destination_folder: [optional] The folder in the destination repository to place the file in, if not the root directory.
* user_email: The GitHub user email associated with the API token secret.
* user_name: The GitHub username associated with the API token secret.
* destination_branch: [optional] The branch of the source repo to update, if not "main" branch is used.
* destination_branch_create: [optional] A branch to be created with this commit, defaults to commiting in `destination_branch`
* commit_message: [optional] A custom commit message for the commit. Defaults to `Update from https://github.com/${GITHUB_REPOSITORY}/commit/${GITHUB_SHA}` 
 use `${{ github.event.head_commit.message }}` to preserve the original commit message.
* rsync_option: [optional] Full access to rsync's switches, if not used it defaults to '-avrh'
* retry_attempts: [optional] Retry attempts if pushing commit failed, if not used it defaults to 10
* git_server: [optional] Git server host, default github.com

# Behavior Notes
The action will create any destination paths if they don't exist. It will also overwrite existing files if they already exist in the locations being copied to. It will not delete the entire destination repository.
