#!/usr/bin/env bash

# Dependency checks
for cmd in git curl jq; do
  if ! command -v $cmd &>/dev/null; then
    echo "Error: Required command '$cmd' not found in PATH." >&2
    exit 1
  fi
done

# Ensure the API key is present
if [ -f "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh" ]; then
  source "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh"
elif [ -f "$HOME/.zshrc" ]; then
  source "$HOME/.zshrc"
fi
if [ -z "$GEMINI_API_KEY" ]; then
  echo "Error: GEMINI_API_KEY environment variable is not set." >&2
  exit 1
fi

# Capture the staged git diff
DIFF=$(git diff --cached)

# Exit cleanly if nothing is staged
if [ -z "$DIFF" ]; then
  echo "No staged changes to commit."
  exit 0
fi

# Updated System Prompt for 3.1 Pro's reasoning capabilities
SYSTEM_PROMPT="You are a senior developer. Analyze the following git diff.
Generate exactly 4 distinct, high-quality Conventional Commit titles (e.g., feat:, fix:, refactor:).
Focus on the 'why' and 'what' of the change.
Output ONLY the titles, one per line. No markdown, no numbers, no bullets."

# Safely construct the JSON payload with thinkingConfig
JSON_PAYLOAD=$(jq -n \
  --arg prompt "$SYSTEM_PROMPT" \
  --arg diff "$DIFF" \
  '{
    contents: [{
      parts: [{
        text: ($prompt + "\n\nDiff:\n" + $diff)
      }]
    }],
    generationConfig: {
      thinkingConfig: {
        thinkingLevel: "low"
      }
    }
  }')

# Make the API call using the Gemini 3.1 Pro Preview endpoint and headers
RESPONSE=$(curl -s -w "\n%{http_code}" \
  -H "x-goog-api-key: $GEMINI_API_KEY" \
  -H 'Content-Type: application/json' \
  -X POST \
  -d "$JSON_PAYLOAD" \
  "https://generativelanguage.googleapis.com/v1beta/models/gemini-3.1-flash-lite-preview:generateContent")

# Extract Status and Body
HTTP_STATUS=$(echo "$RESPONSE" | tail -n1)
BODY=$(echo "$RESPONSE" | sed '$d')

# Handle API errors
if [ "$HTTP_STATUS" -ne 200 ]; then
  echo "API Error (HTTP $HTTP_STATUS):" >&2
  # Try to extract a clean error message from Gemini's JSON response
  ERR_MSG=$(echo "$BODY" | jq -r '.error.message // "Unknown error"')
  echo "$ERR_MSG" >&2
  exit 1
fi

# Parse and output the titles
echo "$BODY" | jq -r '.candidates[0].content.parts[0].text' | sed '/^$/d'
