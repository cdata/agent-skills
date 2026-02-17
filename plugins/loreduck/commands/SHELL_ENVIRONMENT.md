# Shell Environment

This plugin runs inside a shell environment that provides all commands listed below.
**These commands are guaranteed to be on PATH — do not check for their existence
or verify availability.** Just use them directly.

## Environment Requirements

- `GEMINI_API_KEY` must be set in the shell environment (required by the image
  generation commands)

## Commands

### `roll`

Roll polyhedral dice using standard dice notation.

```bash
roll <expression>...
```

Each positional argument is a dice expression (e.g., `2d6`, `2d20K1`, `1d8+3`).
Each expression produces one line of output.

### `create_image`

Generate an image from a text prompt.

```bash
create_image <prompt> <output_image> [aspect_ratio] [image_size]
```

- `output_image` is always WebP format
- `aspect_ratio` defaults to `1:1` — options: `1:1`, `2:3`, `3:2`, `3:4`, `4:3`, `4:5`, `5:4`, `9:16`, `16:9`, `21:9`
- `image_size` defaults to `2K` — options: `1K`, `2K`, `4K`

### `modify_image`

Edit an existing image using a text prompt.

```bash
modify_image <source_image> <prompt> <output_image> [aspect_ratio]
```

- `source_image` can be PNG, WebP, or JPEG (MIME type is auto-detected)
- `output_image` is always WebP format

### `compose_image`

Combine multiple source images into a new image guided by a text prompt.

```bash
compose_image <prompt> <output_image> <source_image>...
```

- Supports up to 14 source images in PNG, WebP, or JPEG format
- `output_image` is always WebP format

### `extract_image`

*Internal helper* — extracts a base64 image from a Gemini API JSON response and
writes it to a file. Called automatically by `create_image`, `modify_image`, and
`compose_image`. You do not need to invoke this directly.

```bash
extract_image <json_response_file> <output_file>
```

### `convert_to_webp`

*Internal helper* — converts a PNG file to WebP format. Called automatically by
`create_image`, `modify_image`, and `compose_image`. You do not need to invoke
this directly.

```bash
convert_to_webp <input_file> <output_file>
```

## Notes

- All image commands handle API calls, response extraction, and format conversion
  internally. Dependencies like `curl`, `jq`, `base64`, and `cwebp` are baked
  into each command's Nix wrapper as `runtimeInputs` — they do not need to be on
  your PATH separately.
- The `extract_image` and `convert_to_webp` helpers are listed here for
  completeness. They are invoked internally by the main image commands and should
  not need to be called directly.
