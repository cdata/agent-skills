#!/usr/bin/env bash
# nb_extract.sh — Safely extract image and text from a Gemini API response.
#
# Usage:
#   nb_extract.sh <response.json> <output.png>
#
# The Gemini response JSON can be multi-megabyte and may contain unescaped
# control characters. This script handles both issues by:
#   1. Sanitizing control chars with tr
#   2. Writing base64 to an intermediate file (avoids pipe-buffer hangs)
#   3. Decoding to the final image separately
#   4. Handling both camelCase (inlineData) and snake_case (inline_data) fields

set -euo pipefail

RESP="${1:?Usage: nb_extract.sh <response.json> <output.png>}"
OUT="${2:?Usage: nb_extract.sh <response.json> <output.png>}"

TMPB64=$(mktemp /tmp/nb_b64.XXXXXX)
trap 'rm -f "$TMPB64"' EXIT

# Check for API errors first
ERROR=$(tr -d '\000-\010\013\014\016-\037' < "$RESP" \
  | jq -r '.error.message // empty' 2>/dev/null)
if [[ -n "$ERROR" ]]; then
  echo "API error: $ERROR" >&2
  exit 1
fi

# Extract base64 image data to intermediate file
tr -d '\000-\010\013\014\016-\037' < "$RESP" \
  | jq -r '[.candidates[0].content.parts[]
    | select(has("inlineData") or has("inline_data"))]
    | .[0] | (.inlineData // .inline_data).data' \
  > "$TMPB64"

if [[ ! -s "$TMPB64" ]]; then
  echo "No image data found in response." >&2
  echo "Response structure:" >&2
  tr -d '\000-\010\013\014\016-\037' < "$RESP" \
    | jq 'del(.. | .data? // empty)' >&2
  exit 1
fi

# Decode to output file
base64 -d "$TMPB64" > "$OUT"

echo "Saved $(wc -c < "$OUT") bytes to $OUT"

# Print text commentary if present
TEXT=$(tr -d '\000-\010\013\014\016-\037' < "$RESP" \
  | jq -r '.candidates[0].content.parts[] | select(has("text")) | .text' 2>/dev/null)
if [[ -n "$TEXT" ]]; then
  echo "---"
  echo "$TEXT"
fi
