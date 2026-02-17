---
name: styleguide
description: Generate reusable art style references from a set of input images. Produces a visual reference sheet and prose description that capture the shared style, enabling consistent visual identity across future image generation.
---

# Styleguide — Art Style Reference Generator

Generates a reusable art style reference from a set of input images. Produces both a visual reference sheet (via Gemini) and a prose style description, along with a manifest tracking the source material.

## Shell Environment

Before proceeding, invoke `/loreduck:shell-environment` to learn about the shell
commands available in this skill and the environment they run in.

## Ground Rules

- **ALWAYS write output into the `loreduck/styles/` folder.**
- **NEVER create or modify notes outside the `loreduck/` folder.**
- **ALWAYS use images paths that fall inside the project root** when relevant
  - All input images must exist as files within the current working directory (or be copied in during processing).

## Step 1: Parse the Request

Interpret `$ARGUMENTS` as a description of the desired styleguide. Extract two things:

1. **Style name** — derive a kebab-case name from the description (e.g., "character portrait styleguide" becomes `character-portrait`, "watercolor landscapes" becomes `watercolor-landscape`).
2. **Input images** — identify referenced images by name. Search the CWD recursively for files matching the referenced names (use Glob with patterns like `**/*Lark*`, `**/*Cawthorn*`). Confirm each match with the user if ambiguous.

## Step 2: Set Up Output Folder

Create the output directory if it doesn't exist:

```
loreduck/styles/<style-name>/
```

## Step 3: Generate the Visual Styleguide

Use `compose_image` with all input images to produce a style reference sheet:

```bash
compose_image "<prompt>" "loreduck/styles/<style-name>/visual-guide.webp" <input-image-1> <input-image-2> ...
```

The prompt should ask Gemini to create a **style reference sheet** — not a collage or composite, but an analytical breakdown. The prompt must instruct the model to extract and present:

- **Color palette** — dominant and accent colors as swatches
- **Rendering technique** — brushwork, line quality, texture handling
- **Lighting approach** — direction, intensity, color temperature
- **Common visual elements** — recurring motifs, compositional patterns
- **Medium** — what traditional or digital medium the style evokes

Example prompt structure:

```
Create an art style reference sheet analyzing these images. Extract and present:
the shared color palette as labeled swatches, the rendering technique and
brushwork style, the lighting approach, and any recurring compositional motifs.
Lay this out as a clean reference sheet an artist could use to reproduce the style.
```

## Step 4: Generate the Prose Styleguide

Read each input image directly (Claude is multimodal) and write a prose style description to:

```
loreduck/styles/<style-name>/textual-guide.md
```

The prose guide should describe the shared art style across these dimensions:

- **Medium** — what the style evokes (oil painting, watercolor, digital cel-shading, etc.)
- **Color palette** — dominant hues, saturation level, contrast patterns
- **Lighting** — direction, quality (hard/soft), color temperature, use of shadow
- **Rendering technique** — brushwork, level of detail, texture handling, line quality
- **Composition patterns** — framing, focal point placement, background treatment
- **Distinguishing characteristics** — anything else that makes this style recognizable

Write it as a concise, actionable reference — something that could be dropped into a future image generation prompt to reproduce the style.

## Step 5: Handle External Images

If any input image does **not** already exist somewhere within the CWD, copy it into `loreduck/styles/<style-name>/references/` so the styleguide is self-contained.

Use standard file operations (Bash `cp`) to bring external files in.

## Step 6: Create Manifest

Compute a SHA-256 hash for each input image and write a manifest to:

```
loreduck/styles/<style-name>/manifest.json
```

Schema:

```json
{
  "style": "<style-name>",
  "inputs": [
    {
      "source": "<path-relative-to-manifest>",
      "sha256": "<hex-digest>"
    }
  ],
  "outputs": {
    "visual": "visual-guide.webp",
    "prose": "textual-guide.md"
  }
}
```

Compute hashes using `sha256sum`:

```bash
sha256sum path/to/image.webp
```

The `source` path for each input should be **relative to the manifest file itself** (i.e., relative to `loreduck/styles/<style-name>/`). If an image was copied in during Step 5, use its **new path** (within the styleguide folder) as the source.

## Step 7: Manage the Default Styleguide

The default styleguide is tracked as a **relative symlink** at `loreduck/styles/default` pointing to the directory of a named styleguide (e.g., `default -> character-portrait`).

### After creating a new styleguide

Check whether `loreduck/styles/default` already exists:

- **If it does not exist** (this is the first styleguide), automatically set the new styleguide as the default:

  ```bash
  ln -s <style-name> loreduck/styles/default
  ```

- **If it already exists** (other styleguides are present), ask the user whether they'd like to make the new styleguide the default. If they agree, update the symlink:

  ```bash
  ln -snf <style-name> loreduck/styles/default
  ```

### Changing the default on request

If the user asks to change the default styleguide (via `/loreduck:styleguide` or otherwise):

1. List the available styleguides by scanning directories in `loreduck/styles/` (excluding the `default` symlink itself).
2. If the user specified a style name, resolve it directly. Otherwise, present the available options and let them choose.
3. Update the symlink:

   ```bash
   ln -snf <style-name> loreduck/styles/default
   ```

4. Confirm the change to the user.

## How to Use This Skill

When the user invokes `/loreduck:styleguide`, interpret `$ARGUMENTS` as a description of the style to capture or a request to manage styleguides. If the request is to **create** a new styleguide, execute Steps 1–7 in order: parse the request, set up the output folder, generate the visual reference sheet, write the prose guide, handle any external images, create the manifest, and manage the default symlink. If the request is to **change the default** styleguide, follow the "Changing the default on request" procedure in Step 7. Present the results to the user with paths to the generated files.
