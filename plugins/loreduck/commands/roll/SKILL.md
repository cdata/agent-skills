---
name: roll
description: Roll dice using standard dice notation
---

# Dice Roller

Roll polyhedral dice using standard dice notation via the `roll` utility.

## Shell Environment

Before proceeding, read [SHELL_ENVIRONMENT.md](../SHELL_ENVIRONMENT.md). It
documents the shell commands available in this skill and explains the environment
they run in.

## Notation

Standard dice notation is supported:

- `NdS` — Roll N dice with S sides and sum the results (e.g., `2d6`)
- `NdSKH` — Roll N dice with S sides, keep the H highest (e.g., `2d20K1`)
- `NdSkL` — Roll N dice with S sides, keep the L lowest (e.g., `2d20k1`)
- `NdS+M` — Roll N dice with S sides, sum the results and add M (e.g., `3d8+3`)
- `NdS-M` — Roll N dice with S sides, sum the results and subtract M

Multiple expressions can be rolled at once by separating them with spaces.

## How to Use This Skill

1. Parse the user's request from `$ARGUMENTS` and translate it into one or more
   dice expressions.
2. Run the `roll` command with the expressions as positional arguments:

```bash
roll 2d6
roll 2d20K1
roll 1d6 2d10 3d20
```

3. Report the results back to the user. Each expression produces one line of
   output. When multiple expressions are rolled, label each result so the user
   can tell which roll is which.

## Ground Rules

- Always use the `roll` shell command. Do not simulate dice rolls or generate
  random numbers any other way.
- If the user's request is ambiguous, ask for clarification before rolling.
- If `roll` exits with an error, show the error message to the user and suggest
  correcting the notation.
