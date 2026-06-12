#!/usr/bin/env bash
#  _                          _   _
# | |__  _   _ _ __  _ __ ___| |_| |
# | '_ \| | | | '_ \| '__/ __| __| |
# | | | | |_| | |_) | | | (__| |_| |
# |_| |_|\__, | .__/|_|  \___|\__|_|
#        |___/|_|
#
# Execute this file in the hyprland.conf with exec-always
sleep 3

# Define the absolute path directly instead of resolving Nix store symlinks
path="$HOME/.config/hypr"

if [ ! -f "$path/hyprctl.json" ]; then
  echo ":: ERROR: hyprctl.json not found in $path"
  exit 1
fi

jq -c '.[]' "$path/hyprctl.json" | while read -r i; do
  _val() {
    echo "$1" | jq -r '.value'
  }
  _key() {
    echo "$1" | jq -r '.key'
  }
  key=$(_key "$i")
  val=$(_val "$i")
  echo ":: Execute: hyprctl keyword $key $val"
  hyprctl keyword $key "$val"
done
