#!/usr/bin/env bash
# MOUNTER: Executes locally. Mounts SSHFS and injects Wayland displays.
set -euo pipefail

# --- NIX ENVIRONMENT SETUP ---
if [ -f /etc/profile.d/nix.sh ]; then
  . /etc/profile.d/nix.sh
elif [ -f "$HOME/.nix-profile/etc/profile.d/nix.sh" ]; then
  . "$HOME/.nix-profile/etc/profile.d/nix.sh"
fi
export PATH="$HOME/.nix-profile/bin:/run/current-system/sw/bin:/etc/profiles/per-user/$USER/bin:$PATH"

# This script expects exactly two arguments from the dispatcher
remote="$1" # user@host
abs="$2"    # absolute path on remote
host="${remote##*@}"
mnt="$HOME/mnt/$host"

# --- WAYLAND / HYPRLAND ENVIRONMENT INJECTION ---
export XDG_RUNTIME_DIR="/run/user/$(id -u)"
export WAYLAND_DISPLAY="$(ls "$XDG_RUNTIME_DIR" | grep -m1 '^wayland-[0-9]' || echo 'wayland-1')"
export DISPLAY=":0"
export DBUS_SESSION_BUS_ADDRESS="unix:path=${XDG_RUNTIME_DIR}/bus"

mkdir -p "$mnt"

# --- THE HIGH-PERFORMANCE MOUNT ---
if ! mountpoint -q "$mnt"; then
  ssh_opts="ssh -T -c aes128-gcm@openssh.com -o BatchMode=yes -o Compression=no"

  sshfs "$remote:/" "$mnt" \
    -o reconnect,ServerAliveInterval=15,ServerAliveCountMax=3,idmap=user \
    -o auto_cache,kernel_cache,large_read,transform_symlinks \
    -o ssh_command="$ssh_opts"
fi

# --- FAST POLLING ---
timeout 3 bash -c "until [[ -e '$mnt$abs' ]]; do sleep 0.05; done" || {
  echo "CRITICAL: FUSE mount timed out or file missing." >&2
  exit 1
}

# --- EXTENSION EXTRACTION & NORMALIZATION ---
ext="${abs##*.}"
ext="${ext,,}"

# --- DIRECT BINARY DISPATCH ---
case "$ext" in
pdf)
  exec zathura "$mnt$abs"
  ;;
png | jpg | jpeg | gif | webp | svg | tiff | bmp | heic)
  exec swayimg "$mnt$abs"
  ;;
mp4 | mkv | webm | avi | mov | flv | m4a | mp3 | flac | wav | ogg | opus)
  exec mpv --cache=yes --profile=pseudo-gui --force-window=yes terminal=no "$mnt$abs" </dev/null >/dev/null 2>&1
  ;;
*)
  exec xdg-open "$mnt$abs"
  ;;
esac
