#!/usr/bin/env bash

ACTION="$1"
MSG="$2"

# Ensure git is in PATH
if ! command -v git &>/dev/null; then
  echo "Error: git is not in PATH."
  exit 1
fi

# Dynamically find the absolute path to the .git directory
GIT_DIR=$(git rev-parse --absolute-git-dir 2>/dev/null)

if [ -z "$GIT_DIR" ]; then
  echo "Error: Not inside a git repository."
  exit 1
fi

# Fallback to standard editor variables, default to nvim, then vi
EDITOR_CMD="${VISUAL:-${EDITOR:-nvim}}"

if [ "$ACTION" = "edit" ]; then
  echo "$MSG" >"$GIT_DIR/COMMIT_EDITMSG"

  # Execute the editor
  $EDITOR_CMD "$GIT_DIR/COMMIT_EDITMSG"

  # Check if the file is not empty (-s) after the user closes the editor
  if [ -s "$GIT_DIR/COMMIT_EDITMSG" ]; then
    git commit -F "$GIT_DIR/COMMIT_EDITMSG"
  else
    echo "Aborted: Empty commit message."
  fi
else
  # Direct commit
  git commit -m "$MSG" >/dev/null 2>&1
fi

exit 0
