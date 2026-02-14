---
name: image
description: Generate, edit, and compose images using Google's Gemini image models via cURL and the REST API. Use this skill when the user asks to create images, generate visuals, edit photos, compose multiple images, create logos, thumbnails, infographics, product shots, or any image generation task. Supports text-to-image, image editing, multi-image composition, iterative refinement, and aspect ratio control. No Python required — uses only cURL, jq, and base64.
---

# Nano Banana (cURL Edition)

Image generation skill powered by Google's Gemini image models via the REST API. Uses only cURL, `jq`, and `base64` — no Python or SDK dependencies.

## Requirements

- `GEMINI_API_KEY` environment variable set
- `curl`, `jq`, and `base64` available on PATH (standard on most Linux/macOS systems)

## Task Workflows

All workflows use the same REST endpoint. The difference is in the request body.

### Text-to-Image Generation

Use the `create_image` command to generate an image from a text prompt. It handles the API call, response extraction, and WebP conversion in one step.

```bash
create_image <prompt> <output_image> [aspect_ratio] [image_size]
```

Examples:

```bash
# Basic generation
create_image "A cat wearing a wizard hat" output.webp

# With aspect ratio
create_image "Futuristic motorcycle on Mars" output.webp "16:9"

# With aspect ratio and resolution
create_image "Futuristic motorcycle on Mars" output.webp "16:9" "4K"
```

The default image size is `2K`. See [Generation Options](#generation-options) for available aspect ratios and resolutions.

### Edit an Existing Image

Use the `modify_image` command to edit an existing image. It handles encoding, API calls, response extraction, and WebP conversion in one step.

```bash
modify_image <source_image> <prompt> <output_image> [aspect_ratio]
```

Examples:

```bash
# Basic edit
modify_image input.png "Add a sunset to the background" output.webp

# Edit with aspect ratio
modify_image input.png "Add a sunset to the background" output.webp "16:9"
```

Supports PNG, WebP, and JPEG source images (MIME type is detected automatically from the file extension).

### Compose Multiple Images

Use the `compose_image` command to combine multiple source images into a new image. Supports up to 14 reference images in PNG, WebP, or JPEG format (MIME type is detected automatically from file extensions).

```bash
compose_image <prompt> <output_image> <source_image>...
```

Examples:

```bash
# Combine two portraits into a group scene
compose_image "Create a group photo in an office setting" output.webp person1.png person2.png

# Merge elements from multiple references
compose_image "Combine these into a collage" collage.webp photo1.jpg photo2.png photo3.webp
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

Common issues:

- **Missing API key**: Ensure `GEMINI_API_KEY` is exported in your shell environment
- **Empty output file**: The model may have refused the prompt (safety filters) — check the JSON response for `blockReason` or `finishReason`
- **Large images for editing**: Very large source images may exceed request size limits — resize before encoding
- **`jq` parse errors**: The `tr` sanitization step in `extract_image` handles this, but if running manually, always sanitize first
- **Quota errors (429)**: Free-tier quotas for `gemini-3-pro-image` may be 0 — a billing-enabled API key is required

## How to Use This Skill

When the user invokes `/loreduck:image`, interpret `$ARGUMENTS` as the image generation task. Determine the appropriate workflow based on the request and use the corresponding command: `create_image` for text-to-image generation, `modify_image` for editing an existing image, or `compose_image` for combining multiple images. Always save output images to the current working directory unless the user specifies a different path.
