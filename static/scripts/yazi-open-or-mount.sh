#!/usr/bin/env bash
# DISPATCHER: Triggered by Yazi. Evaluates environment and routes the request.
set -euo pipefail

# --- NIX ENVIRONMENT SETUP ---
if [ -f /etc/profile.d/nix.sh ]; then
  . /etc/profile.d/nix.sh
elif [ -f "$HOME/.nix-profile/etc/profile.d/nix.sh" ]; then
  . "$HOME/.nix-profile/etc/profile.d/nix.sh"
fi
export PATH="$HOME/.nix-profile/bin:/run/current-system/sw/bin:/etc/profiles/per-user/$USER/bin:$PATH"

# Yazi only passes the file path ($1)
abs="$(realpath -- "$1")"

# --- LOCAL EXECUTION ---
# If SSH_CONNECTION is empty, we are sitting physically at this machine. Open natively.
if [[ -z "${SSH_CONNECTION:-}" ]]; then
  ext="${abs##*.}"
  ext="${ext,,}"
  case "$ext" in
  pdf) exec zathura "$abs" ;;
  png | jpg | jpeg | gif | webp | svg | tiff | bmp | heic) exec swayimg "$abs" ;;
  mp4 | mkv | webm | avi | mov | flv | m4a | mp3 | flac | wav | ogg | opus)
    exec mpv --profile=pseudo-gui --force-window=yes --terminal=no "$abs" </dev/null >/dev/null 2>&1
    ;;
  *) exec xdg-open "$abs" ;;
  esac
fi

# --- REMOTE DISPATCH ---
# We are inside an SSH session. Dial back to the client IP.
client_ip="${SSH_CONNECTION%% *}"
safe_abs=$(printf %q "$abs")

# Fire and forget. -T strips the TTY requirement.
ssh -T -o BatchMode=yes \
  -o StrictHostKeyChecking=accept-new \
  -o UserKnownHostsFile=/dev/null \
  "$client_ip" \
  "$HOME/.scripts/yazi-open-from-remote.sh '$(whoami)@$(hostname)' $safe_abs"
