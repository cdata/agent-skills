---
name: image
description: Generate, edit, and compose images using Google's Gemini image models via cURL and the REST API. Use this skill when the user asks to create images, generate visuals, edit photos, compose multiple images, create logos, thumbnails, infographics, product shots, or any image generation task. Supports text-to-image, image editing, multi-image composition, iterative refinement, and aspect ratio control. No Python required — uses only cURL, jq, and base64.
---

# Nano Banana (cURL Edition)

Image generation skill powered by Google's Gemini image models via the REST API. Uses only cURL, `jq`, and `base64` — no Python or SDK dependencies.

## Requirements

- `GEMINI_API_KEY` environment variable set
- `curl`, `jq`, and `base64` available on PATH (standard on most Linux/macOS systems)

## Model

Always use `gemini-3-pro-image-preview` for all image generation tasks. This is the highest quality model available.

## API Endpoint

```
https://generativelanguage.googleapis.com/v1beta/models/gemini-3-pro-image-preview:generateContent
```

## Critical: Handling API Responses

The Gemini API response JSON can be very large (multi-megabyte base64 image data) and may contain unescaped control characters that break `jq`. **Never pipe the full extraction pipeline in one shot** — this can hang indefinitely on large responses.

**Always use the prescribed extraction command:**

```bash
curl -s -X POST "$ENDPOINT" ... -o /tmp/nb_resp.json
extract_nano_banana_image /tmp/nb_resp.json output.png
```

The command (`extract_nano_banana_image`) safely:
1. Sanitizes control characters with `tr`
2. Checks for API errors
3. Extracts base64 to an **intermediate temp file** (avoids pipe-buffer hangs)
4. Decodes to the final image in a separate step
5. Handles both `inlineData` (camelCase) and `inline_data` (snake_case) field names
6. Prints text commentary if present

### Then: convert to WebP!

```bash
convert_to_webp output.png output.webp
```

### What NOT to do

```bash
# WRONG: single pipeline hangs on large responses
curl ... | jq -r '...' | base64 -d > output.png

# WRONG: storing response in a shell variable (too large)
RESPONSE=$(curl -s ...)

# WRONG: only checking snake_case field names (API may return camelCase)
jq '.inline_data.data'
```

## Task Workflows

All workflows use the same REST endpoint. The difference is in the request body.

### Text-to-Image Generation

Generate an image from a text prompt and save it to a file.

```bash
curl -s -X POST \
  "https://generativelanguage.googleapis.com/v1beta/models/gemini-3-pro-image-preview:generateContent" \
  -H "x-goog-api-key: ${GEMINI_API_KEY}" \
  -H "Content-Type: application/json" \
  -o /tmp/nb_resp.json \
  -d '{
    "contents": [{"parts": [{"text": "A cat wearing a wizard hat"}]}],
    "generationConfig": {
      "responseModalities": ["TEXT", "IMAGE"]
    }
  }'

extract_nano_banana_response /tmp/nb_resp.json output.png
convert_to_webp output.png output.webp
```

### Text-to-Image with Aspect Ratio and Size

```bash
curl -s -X POST \
  "https://generativelanguage.googleapis.com/v1beta/models/gemini-3-pro-image-preview:generateContent" \
  -H "x-goog-api-key: ${GEMINI_API_KEY}" \
  -H "Content-Type: application/json" \
  -o /tmp/nb_resp.json \
  -d '{
    "contents": [{"parts": [{"text": "Futuristic motorcycle on Mars"}]}],
    "generationConfig": {
      "responseModalities": ["TEXT", "IMAGE"],
      "imageConfig": {
        "aspectRatio": "16:9",
        "imageSize": "4K"
      }
    }
  }'

extract_nano_banana_response /tmp/nb_resp.json output.png
convert_to_webp output.png output.webp
```

### Edit an Existing Image

Use `jq -Rs` (raw slurp from stdin) to build the request JSON with inline image data. This avoids shell variable size limits.

```bash
base64 -w0 input.png \
  | jq -Rs --arg prompt "Add a sunset to the background" '{
      "contents": [{"parts": [
        {"text": $prompt},
        {"inline_data": {"mime_type": "image/png", "data": .}}
      ]}],
      "generationConfig": {
        "responseModalities": ["TEXT", "IMAGE"]
      }
    }' \
  | curl -s -X POST \
      "https://generativelanguage.googleapis.com/v1beta/models/gemini-3-pro-image-preview:generateContent" \
      -H "x-goog-api-key: ${GEMINI_API_KEY}" \
      -H "Content-Type: application/json" \
      -d @- -o /tmp/nb_resp.json

extract_nano_banana_response /tmp/nb_resp.json output.png
convert_to_webp output.png output.webp
```

For JPEG source images, use `"mime_type": "image/jpeg"`. Match the mime type to the actual file format.

### Compose Multiple Images

Encode each image as a JSON part, slurp them into an array, then merge with the text prompt. Supports up to 14 reference images.

```bash
for img in person1.png person2.png; do
  base64 -w0 "$img" | jq -Rs '{"inline_data": {"mime_type": "image/png", "data": .}}'
done \
  | jq -s --arg prompt "Create a group photo in an office setting" '{
      "contents": [{"parts": ([{"text": $prompt}] + .)}],
      "generationConfig": {
        "responseModalities": ["TEXT", "IMAGE"]
      }
    }' \
  | curl -s -X POST \
      "https://generativelanguage.googleapis.com/v1beta/models/gemini-3-pro-image-preview:generateContent" \
      -H "x-goog-api-key: ${GEMINI_API_KEY}" \
      -H "Content-Type: application/json" \
      -d @- -o /tmp/nb_resp.json

extract_nano_banana_response /tmp/nb_resp.json output.png
convert_to_webp output.png output.webp
```

## Generation Options

### Aspect Ratios

`1:1`, `2:3`, `3:2`, `3:4`, `4:3`, `4:5`, `5:4`, `9:16`, `16:9`, `21:9`

### Resolutions

`1K` (1024px), `2K`, `4K`

Set these in the `generationConfig.imageConfig` object:

```json
"imageConfig": {
  "aspectRatio": "16:9",
  "imageSize": "2K"
}
```

## Prompting Tips

**Photorealistic**: Include camera settings, lighting, lens details
```
"Shot on 85mm lens, golden hour lighting, shallow depth of field"
```

**Logos**: Specify style, colors, typography
```
"Clean minimalist logo, sans-serif font, monochrome, vector style"
```

**Product shots**: Describe studio setup
```
"Studio-lit, 3-point softbox, polished surface, 45-degree angle"
```

**Stylized art**: Name the style explicitly
```
"Anime style, cel-shading, bold outlines, vibrant colors"
```

## Error Handling

The `extract_nano_banana_response` command checks for API errors and missing image data automatically. If you need to debug manually:

```bash
tr -d '\000-\010\013\014\016-\037' < /tmp/nb_resp.json | jq .
```

Common issues:
- **Missing API key**: Ensure `GEMINI_API_KEY` is exported in your shell environment
- **Empty output file**: The model may have refused the prompt (safety filters) — check the JSON response for `blockReason` or `finishReason`
- **Large images for editing**: Very large source images may exceed request size limits — resize before encoding
- **`jq` parse errors**: The `tr` sanitization step in `extract_nano_banana_response` handles this, but if running manually, always sanitize first
- **Quota errors (429)**: Free-tier quotas for `gemini-3-pro-image` may be 0 — a billing-enabled API key is required

## How to Use This Skill

When the user invokes `/loreduck:image`, interpret `$ARGUMENTS` as the image generation task. Determine the appropriate workflow (generate, edit, or compose) based on the request, construct the cURL command with the right parameters, execute it using `extract_nana_banana_response` for response processing, convert it to WebP using `convert_to_webp` and then present the result. Always save output images to the current working directory unless the user specifies a different path.
