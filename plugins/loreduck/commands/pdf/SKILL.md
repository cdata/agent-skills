---
name: pdf
description: Convert a PDF to a refined, reusable Markdown document. Extracts text via pdf_to_markdown, then performs multi-pass cleanup to fix spacing, unicode artifacts, linebreak issues, and other extraction anomalies. Results are cached by content hash.
user-invocable: true
---

# PDF to Markdown

Convert a PDF file into a clean, reusable Markdown document. The raw extraction
is analyzed for anomalies and refined through multiple targeted passes, then
cached so repeated requests for the same file are instant.

## Shell Environment

Before proceeding, invoke `/loreduck:shell-environment` to learn about the shell
commands available in this skill and the environment they run in.

## Workflow

When the user provides a PDF file, follow these steps in order:

### 1. Resolve the input file

Interpret `$ARGUMENTS` as the path to a PDF file. If the path is relative,
resolve it against the current working directory. Confirm the file exists before
continuing.

### 2. Check the cache

Compute the SHA-256 hash of the input file:

```bash
sha256sum <input>.pdf
```

The first field of the output is the hex digest. Use it to build the artifact
path:

```
loreduck/.cache/pdf_text/<hash>.md
```

If this file already exists, the extraction and cleanup can be skipped. However,
the filename-derived symlink may not exist yet (e.g., the same PDF was previously
processed under a different filename). Create the symlink if it is missing (see
[step 6](#6-write-the-artifact) for symlink details), then tell the user where
to find the artifact and stop.

### 3. Extract raw text

Run the extraction command, writing to a temporary location:

```bash
pdf_to_markdown <input>.pdf /tmp/claude/<hash>_raw.md
```

Read the resulting file. This is the raw extraction and will contain various
artifacts from the PDF-to-text conversion process.

### 4. Analyze the raw text

Read through the extracted text carefully and catalog every category of anomaly
you find. Common categories include (but are not limited to):

- **Broken paragraphs** — sentences split across lines with hard linebreaks
  where the original PDF had soft-wrapped text within a single paragraph
- **Spurious whitespace** — extra spaces mid-word, inconsistent indentation,
  trailing whitespace, or multiple consecutive blank lines
- **Unicode artifacts** — mojibake, replacement characters (`�`), smart quotes
  decoded as multi-byte garbage, ligatures expanded incorrectly (e.g., `ﬁ` → `fi`)
- **Header/footer residue** — repeated page numbers, running headers, or
  watermark text scattered throughout the body
- **Broken tables** — tabular data that lost its structure and became ragged
  plain text
- **Malformed lists** — numbered or bulleted lists whose markers were stripped
  or mangled
- **Inline formatting loss** — bold, italic, or code spans that were flattened
  to plain text but still have residual marker characters

After cataloging, briefly note each category you found and the rough scope
(how pervasive it is) before proceeding.

### 5. Multi-pass cleanup

For **each** category identified in step 4, make a dedicated pass over the
document and fix all instances of that category. Work through the categories one
at a time so that fixes from earlier passes don't conflict with later ones.

**Ordering guidance** — process structural issues before cosmetic ones:

1. Header/footer residue (remove before anything else so they don't pollute
   paragraph joining)
2. Broken paragraphs (rejoin lines into proper paragraphs)
3. Broken tables and malformed lists (restore structure)
4. Unicode artifacts (normalize characters)
5. Spurious whitespace (clean up spacing)
6. Inline formatting (restore emphasis markers if evidence supports it)

After all passes, do a final read-through to catch any regressions or edge
cases introduced by the cleanup.

### 6. Write the artifact

Ensure the cache directory exists:

```bash
mkdir -p loreduck/.cache/pdf_text
```

Write the cleaned Markdown to:

```
loreduck/.cache/pdf_text/<hash>.md
```

Then create a human-friendly symlink derived from the input filename. Strip the
`.pdf` extension and append `.md`:

```bash
ln -sf <hash>.md loreduck/.cache/pdf_text/<basename>.md
```

For example, if the input is `Monster Manual.pdf` and the hash is `a1b2c3…`,
the cache directory will contain:

```
loreduck/.cache/pdf_text/a1b2c3….md          ← the actual artifact
loreduck/.cache/pdf_text/Monster Manual.md    ← symlink → a1b2c3….md
```

The symlink target is a **relative** path (just the hash filename, not a full
path) so the link stays valid if the repository is moved.

If a symlink with that name already exists (e.g., a previous version of the PDF
was cached under the same filename), overwrite it — the `-f` flag handles this.
The old hash-named file can be left in place; it does no harm and may still be
referenced elsewhere.

Tell the user the path to the finished artifact (the symlink path is usually
the more useful one to mention).

## Ground Rules

- **Never modify the original PDF.**
- **Do not hallucinate content.** The cleanup must be conservative — fix
  formatting issues, but never add, remove, or rephrase substantive text. If
  something is ambiguous, leave it as-is rather than guessing.
- **Preserve document structure.** Headings, lists, block quotes, and tables
  from the original should survive into the output. When in doubt, prefer the
  structure suggested by the raw extraction.
- **Cache is content-addressed.** Two different PDFs with different content will
  always produce different hashes. The same PDF will always hit cache on the
  second request regardless of filename.

## How to Use This Skill

When the user invokes `/loreduck:pdf`, interpret `$ARGUMENTS` as the path to a PDF file. Follow the [Workflow](#workflow) above from step 1. If the artifact is already cached, report its path immediately. Otherwise, extract, analyze, clean, and cache the result, then report its path.
