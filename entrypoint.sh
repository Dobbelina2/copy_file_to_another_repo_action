#!/bin/sh

set -e
set -x

if [ -z "$INPUT_SOURCE_FILE" ]; then
  echo "Source file(s) must be defined"
  return 1
fi

if [ -z "$INPUT_GIT_SERVER" ]; then
  INPUT_GIT_SERVER="github.com"
fi

if [ -z "$INPUT_DESTINATION_BRANCH" ]; then
  INPUT_DESTINATION_BRANCH=main
fi
OUTPUT_BRANCH="$INPUT_DESTINATION_BRANCH"

CLONE_DIR=$(mktemp -d)

echo "Cloning destination git repository"
git config --global user.email "$INPUT_USER_EMAIL"
git config --global user.name "$INPUT_USER_NAME"
git clone --single-branch --branch $INPUT_DESTINATION_BRANCH "https://x-access-token:$API_TOKEN_GITHUB@$INPUT_GIT_SERVER/$INPUT_DESTINATION_REPO.git" "$CLONE_DIR"

if [ -z "$INPUT_DESTINATION_FOLDER" ]; then
  DEST_COPY="$CLONE_DIR"
else
  DEST_COPY="$CLONE_DIR/$INPUT_DESTINATION_FOLDER"
fi

echo "Copying contents to git repo"
if [ "$INPUT_DELETE_EXISTING" = "true" ]; then
  echo "Deleting existing files"
  rm -rf "$DEST_COPY"
fi

mkdir -p "$DEST_COPY"

if [ "$INPUT_USE_RSYNC" = "true" ]; then
  COPY_COMMAND="rsync -avrh"
else
  COPY_COMMAND="cp -R"
fi

IFS=','
for SOURCE_FILE in $INPUT_SOURCE_FILE; do
  if [ -d "$SOURCE_FILE" ]; then
    find "$SOURCE_FILE" -type f -exec sh -c "$COPY_COMMAND {} \"$DEST_COPY/\"" \;
  else
    FILENAME=$(basename "$SOURCE_FILE")
    sh -c "$COPY_COMMAND \"$SOURCE_FILE\" \"$DEST_COPY/$FILENAME\""
  fi
done

cd "$CLONE_DIR"

if [ ! -z "$INPUT_DESTINATION_BRANCH_CREATE" ]; then
  echo "Creating new branch: ${INPUT_DESTINATION_BRANCH_CREATE}"
  git checkout -b "$INPUT_DESTINATION_BRANCH_CREATE"
  OUTPUT_BRANCH="$INPUT_DESTINATION_BRANCH_CREATE"
fi

if [ -z "$INPUT_COMMIT_MESSAGE" ]; then
  INPUT_COMMIT_MESSAGE="Update from https://$INPUT_GIT_SERVER/${GITHUB_REPOSITORY}/commit/${GITHUB_SHA}"
fi

echo "Adding git commit"
cd "$CLONE_DIR"  # Move to the root of the cloned repository
git add .
if git status | grep -q "Changes to be committed"; then
  git commit --message "$INPUT_COMMIT_MESSAGE"
  echo "Pushing git commit"
  git push -u origin HEAD:"$OUTPUT_BRANCH"
else
  echo "No changes detected"
fi
