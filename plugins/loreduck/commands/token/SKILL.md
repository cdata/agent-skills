---
name: token
description: Generate a circular framed token icon with alpha transparency from a character portrait, suitable for VTTs and Obsidian embeds.
---

# Token Icon Generator

Generate circular framed token icons with alpha-transparent backgrounds from
existing character portraits. Suitable for VTTs and Obsidian embeds.

## Shell Environment

Before proceeding, invoke `/loreduck:shell-environment` to learn about the shell
commands available in this skill and the environment they run in.

## File Versioning

Before writing ANY file to `loreduck/` — images or other assets — check whether
a file with the intended name already exists. If it does, append a version
suffix before the extension:

- `Penguin Mage (Token Icon).webp` already exists → save as `Penguin Mage (Token Icon) v2.webp`
- `Penguin Mage (Token Icon) v2.webp` already exists → save as `Penguin Mage (Token Icon) v3.webp`

Use `ls loreduck/` or Glob to check before writing.

## Procedure

1. **Generate the framed token.** Use `modify_image` with the character's
   existing portrait as the source image. Request a 1:1 circular token with an
   ornate decorative frame and a dark background outside the frame. The frame
   should be **personalized to the character** — derive its material, motifs,
   and ornamentation from the character's race, class, faction, environment, or
   other defining traits. For example:

   - A fungal leshy druid → twisted living wood with sprouting leaves and bioluminescent fungi
   - An infernal warlock → wrought iron with glowing runes and smoldering chain links
   - A dwarven smith → hammered bronze with gear teeth and anvil engravings

   ```bash
   modify_image "<portrait>" \
     "Transform this portrait into a circular token icon. Frame the character's
      head and shoulders inside an ornate circular frame. The frame's material,
      motifs, and ornamentation should reflect the character's identity —
      [brief character-specific frame description]. The background outside the
      circular frame must be solid dark black with no texture or variation." \
     "<output>" "1:1"
   ```

   Replace the bracketed placeholder with details drawn from the character's
   appearance and context.

   Check for an existing file at `<output>` and version if needed (see
   [File Versioning](#file-versioning)).

2. **Cut out the background.** Run `circle-crop` to detect the frame boundary
   and replace the dark background with alpha transparency:

   ```bash
   circle-crop "<output>" "<output>"
   ```

## Naming and Embedding

- Name: `{Name} (Token Icon).webp`, saved to `loreduck/`
- Embed: `![[{Name} (Token Icon).webp|256]]`

## How to Use This Skill

When the user invokes `/loreduck:token`, interpret `$ARGUMENTS` as containing:

1. The path to a source portrait image
2. Context about the character (name, race, class, traits, etc.) to personalize the frame

Generate the token icon following the [Procedure](#procedure) above, using the
character context to craft a personalized frame description.
