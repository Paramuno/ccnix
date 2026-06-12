#!/usr/bin/env bash

# Exit on any unexpected error
set -e

REPO_ROOT=$(git rev-parse --show-toplevel)
README="$REPO_ROOT/README.md"

# 1. Dependency Check
if ! command -v fd &>/dev/null || ! command -v as-tree &>/dev/null; then
  echo "Error: fd or as-tree missing from PATH."
  exit 1
fi

echo "Generating complete README.md..."

# 2. Generate the Tree
# Excluding .git, the Nix result symlink, and the contents of static folders
TREE_CONTENT=$(fd --exclude ".git" --exclude "result" --exclude "static/*" | as-tree)

# 3. Overwrite the file entirely
# The single '>' operator destroys the old README and creates a new one.
# Everything between 'cat <<EOF' and 'EOF' is written exactly as formatted.
cat <<EOF >"$README"
# Architecture

\`\`\`text
$TREE_CONTENT
\`\`\`
EOF

echo "README.md has been successfully overwritten with the new tree."
