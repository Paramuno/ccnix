#!/usr/bin/env bash

# 1. Grab the exact file path passed by Yazi
TARGET="$1"

# 2. Strict safety check: Abort immediately if it is not a .zip file
if [[ "${TARGET##*.}" != "zip" ]]; then
    exit 1
fi

# 3. Define the destination directory by stripping the .zip extension
# (e.g., "/Downloads/iconnn.zip" becomes "/Downloads/iconnn")
DIR="${TARGET%.*}"

# 4. Extract the archive directly into the new directory
# The -d flag automatically creates the folder if it doesn't exist
unzip "$TARGET" -d "$DIR"

# 5. Ping your desktop notification daemon so you know it finished
notify-send "Yazi" "Extraction complete: $(basename "$TARGET")"
