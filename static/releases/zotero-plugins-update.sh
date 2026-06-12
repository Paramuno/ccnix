#!/usr/bin/env bash

# Go to the directory where the script is located, then up one level to the static dir
cd "$(dirname "$0")/.." || exit

echo "Fetching latest release data from GitHub..."

# Hit the GitHub API to get the latest release data for Better BibTeX
LATEST_JSON=$(curl -s "https://api.github.com/repos/retorquere/zotero-better-bibtex/releases/latest")

# Use jq to extract the version tag and the download URL for the .xpi file
VERSION=$(echo "$LATEST_JSON" | jq -r '.tag_name' | sed 's/^v//')
URL=$(echo "$LATEST_JSON" | jq -r '.assets[] | select(.name | endswith(".xpi")) | .browser_download_url')

if [ -z "$URL" ] || [ "$URL" == "null" ]; then
  echo "Error: Could not find .xpi URL in the latest release."
  exit 1
fi

echo "Found Better BibTeX version: $VERSION"
echo "Calculating Nix hash (this may take a few seconds)..."

# Ask Nix to download the file into the store and calculate the required SRI hash
HASH=$(nix store prefetch-file "$URL" --json | jq -r '.hash')

# Safely write the new values back to the JSON file
cat <<EOF >zotero-plugins.json
{
  "better-bibtex": {
    "version": "$VERSION",
    "url": "$URL",
    "hash": "$HASH"
  }
}
EOF

echo "Successfully updated zotero-plugins.json!"
