#!/usr/bin/env bash

# Pure bash URL encoding function
urlencode() {
  local length="${#1}"
  for ((i = 0; i < length; i++)); do
    local c="${1:i:1}"
    case $c in
    [a-zA-Z0-9.~_-]) printf "%s" "$c" ;;
    *) printf '%%%02X' "'$c" ;;
    esac
  done
}

# 1. Prompt the user for input.
PROMPT=$(rofi -dmenu -p "Gemini:" -theme-str 'window {width: 60%;} listview {lines: 0;}')

# 2. Exit immediately if the user presses Escape or submits an empty string.
if [ -z "$PROMPT" ]; then
  exit 0
fi

# 3. URL-encode the prompt using the native bash function.
ENCODED_PROMPT=$(urlencode "$PROMPT")

# 4. Pass the final URL to the default browser.
xdg-open "https://gemini.google.com/app?prompt=$ENCODED_PROMPT"
