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

## Styleguide Integration

Styleguides live in `loreduck/styles/` and are created via the
`loreduck:styleguide` skill. The **default styleguide** is a symlink at
`loreduck/styles/default`.

### When to use a styleguide

Use the default styleguide for token generation **unless**:

- The user explicitly requests a different style
- The user references a specific named styleguide — look for it in
  `loreduck/styles/<name>/`
- No default styleguide exists (`loreduck/styles/default` is missing)

### How to apply a styleguide

When a styleguide applies:

1. **Read the prose guide** (`textual-guide.md`) and extract the **Prompt
   Fragment** from the bottom of the file.
2. Incorporate the prompt fragment into the token generation prompt so the
   frame's rendering style (color palette, brushwork, lighting) matches the
   established visual identity.

When no styleguide is available, rely on the character context alone to guide
the frame's visual treatment.

## Procedure

1. **Craft the prompt.** Build a detailed prompt for the framed token. The
   prompt must address four concerns:

   **Circular containment** — The most critical constraint. The generated image
   must be a clean, unbroken circle with absolutely nothing extending beyond its
   boundary. State this explicitly and emphatically in the prompt:

   - All elements — the frame, its ornamentation, and the character — must be
     strictly contained within the circular boundary.
   - No flourishes, tendrils, weapons, wings, or decorative details may extend
     past the edge of the circle.
   - The frame must have a clean, continuous circular silhouette.
   - The background outside the circle must be solid, uniform, dark black with
     no texture, variation, or stray details.

   **Character-informed frame design** — The frame should not be generic. Its
   material, motifs, and ornamentation should incorporate or complement the
   character's narrative identity. Draw on:

   - Race, ancestry, or creature type
   - Class, profession, or role
   - Faction or cultural affiliation
   - Signature equipment, abilities, or themes
   - Environment or homeland

   The frame should feel like it *belongs* to the character — an artifact of
   their world, not a stock border. For example:

   - A fungal leshy druid → a ring of twisted living wood with sprouting leaves
     and bioluminescent fungi woven into the grain
   - An infernal warlock → wrought iron with glowing infernal runes and
     smoldering chain links riveted into the band
   - A dwarven smith → hammered bronze with interlocking gear teeth and anvil
     engravings around the bezel
   - An elven ranger → pale silver-wood vine with tiny carved leaves and a
     crescent moon inset at the crown

   **Character composition** — The character must be pleasingly framed within
   the circle. The prompt should specify:

   - The character's head, face, and shoulders must be fully visible — nothing
     cropped or cut off, especially the top of the head.
   - The character should be centered within the circular frame with comfortable
     breathing room between them and the inner edge of the frame.
   - The framing is a head-and-shoulders portrait: close enough to read the
     character's expression, but not so tight that features are clipped.

   **Styleguide alignment** — If a styleguide applies (see [Styleguide
   Integration](#styleguide-integration)), incorporate its prompt fragment so
   the frame's rendering style is consistent with the established visual
   identity.

2. **Generate the framed token.** Use `modify_image` with the character's
   existing portrait as the source image, a 1:1 aspect ratio, and the prompt
   crafted above:

   ```bash
   modify_image "<portrait>" \
     "<prompt>" \
     "<output>" "1:1"
   ```

   The prompt should follow this structure:

   ```
   Transform this portrait into a circular token icon. Frame the character's
   head and shoulders inside an ornate circular frame. The character must be
   pleasingly composed within the frame — their full head, face, and shoulders
   must be visible with comfortable space between them and the inner edge of
   the frame. Do not crop or cut off any part of the character, especially
   the top of the head. Center the character naturally within the circle.

   CRITICAL: The circular frame must have a perfectly clean, unbroken circular
   silhouette. ALL elements — frame ornamentation, decorative flourishes, and
   the character itself — must be strictly contained within the circle. Nothing
   may extend beyond the circular boundary. No flourishes, tendrils, weapons,
   wings, horns, or other details may break out of or protrude past the frame
   edge. The outer edge of the frame must form a smooth, continuous circle.

   Frame design: [character-specific frame description — describe the frame's
   material, motifs, and ornamentation as narrative elements drawn from the
   character's race, class, faction, signature themes, and environment. The
   frame should feel like an artifact of the character's world.]

   [Styleguide prompt fragment, if applicable]

   The background outside the circular frame must be solid, uniform, dark black
   with absolutely no texture, variation, or stray marks.
   ```

   Check for an existing file at `<output>` and version if needed (see
   [File Versioning](#file-versioning)).

3. **Cut out the background.** Run `circle-crop` to detect the frame boundary
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
2. Context about the character (name, race, class, traits, etc.) to personalize
   the frame

If character context is sparse, read the character's note (if it exists in the
vault) to gather additional narrative details for frame personalization.

Generate the token icon following the [Procedure](#procedure) above, using the
character context to craft a richly personalized frame description.
