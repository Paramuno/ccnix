#!/usr/bin/env bash

# Define the pattern you used in your kitty.conf
SOCKET_PREFIX="/tmp/kitty"
STATE_FILE="$HOME/.cache/kitty_opacity_state"

# Determine the toggle state
if [ ! -f "$STATE_FILE" ]; then echo "solid" >"$STATE_FILE"; fi
CURRENT_STATE=$(cat "$STATE_FILE")

if [ "$CURRENT_STATE" == "solid" ]; then
  TARGET_OPACITY="0.0"
  NEXT_STATE="transparent"
else
  TARGET_OPACITY="1.0"
  NEXT_STATE="solid"
fi

# Find the kitty executable in the environment
KITTY_EXEC=$(command -v kitty)

if [ -z "$KITTY_EXEC" ]; then
  echo "Error: kitty executable not found in PATH" >&2
  exit 1
fi

# Find and toggle ALL active Master sockets
# This avoids the PID-naming conflict by catching all variations
shopt -s nullglob
for socket in ${SOCKET_PREFIX}*; do
  if [ -S "$socket" ]; then
    # Use the explicit socket path to send the command
    "$KITTY_EXEC" @ --to "unix:$socket" set-background-opacity "$TARGET_OPACITY"
  fi
done

echo "$NEXT_STATE" >"$STATE_FILE"
