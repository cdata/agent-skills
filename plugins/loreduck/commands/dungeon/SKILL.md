---
name: dungeon
description: Generate a 5 Room Dungeon using the dice-drop generator tables from the vault. Rolls polyhedral dice, gathers context from the Obsidian vault, and produces a complete five-room dungeon outline with narrative prompts tied to the campaign world.
---

# Dungeon — 5 Room Dungeon Generator

Generates a 5 Room Dungeon by rolling against the generator tables below, gathering campaign context from the vault, and weaving the results into a cohesive dungeon outline.

## 5 Room Dungeons

A lightweight adventure design framework that maps mythic story structure onto five "rooms" (which need not be literal rooms). It works for any genre, setting, or system — the rooms are narrative beats, not floor plans.

| Room | Beat                | Purpose                                                                                     |
| ---- | ------------------- | ------------------------------------------------------------------------------------------- |
| 1    | **Entrance**        | A guardian, barrier, or puzzle that explains why this place hasn't been cleared out already |
| 2    | **Puzzle**          | A non-combat challenge — spotlights different skills and characters than Room 1             |
| 3    | **Trick / Setback** | A complication that raises the stakes — betrayal, false victory, collapsing terrain         |
| 4    | **Climax**          | The big confrontation — interesting terrain, tactical depth, emotional weight               |
| 5    | **Revelation**      | The payoff — treasure, plot twist, new hook, or campaign-altering information               |

## Ground Rules

- **ALWAYS write output into the `loreduck/` folder.**
- **NEVER create or modify notes outside the `loreduck/` folder.**
- Use `[[wiki links]]` to connect the dungeon to existing vault lore.
- Keep prose concise — evocative, not exhaustive. Write for a GM who will improvise the details.

## Step 1: Roll the Dice

Roll all five dice using the `/loreduck:roll` skill. Each die maps to one room:

| Die  | Room       |
| ---- | ---------- |
| d4   | Entrance   |
| d6   | Puzzle     |
| d8   | Trick      |
| d10  | Climax     |
| d12  | Revelation |

Execute a single roll:

```
/loreduck:roll 1d4 1d6 1d8 1d10 1d12
```

Record each result and look up the corresponding concept from the tables below.

### Lookup Tables

**d4 — Entrance** *(Why has this dungeon not been explored before?)*

| Face | Concept      | Idea                                   |
| ---- | ------------ | -------------------------------------- |
| 1    | **Shroud**   | It is hidden, concealed, or forgotten  |
| 2    | **Trap**     | The entrance itself is trapped         |
| 3    | **Guardian** | Something guards the door              |
| 4    | **Posse**    | A faction or tribe inhabits this place |

**d6 — Puzzle** *(What non-combat challenge blocks the way?)*

| Face | Concept     | Idea                                        |
| ---- | ----------- | ------------------------------------------- |
| 1    | **Riddle**  | Logic, wordplay, a sphinx-like test         |
| 2    | **Bargain** | Negotiate, make a deal, social leverage     |
| 3    | **Maze**    | Navigation, spatial reasoning, dead ends    |
| 4    | **Ritual**  | Perform a sequence, ceremony, or rite       |
| 5    | **Cipher**  | Decode, translate, interpret symbols        |
| 6    | **Trial**   | Judged or tested by some authority or force |

**d8 — Trick / Setback** *(What complication raises the stakes?)*

| Face | Concept      | Idea                                          |
| ---- | ------------ | --------------------------------------------- |
| 1    | **Betrayal** | An ally turns, or the info was wrong          |
| 2    | **Collapse** | The environment becomes unstable or hostile   |
| 3    | **Reversal** | The goal flips — hunter becomes hunted        |
| 4    | **Curse**    | A supernatural affliction takes hold          |
| 5    | **Ambush**   | Enemies strike from an unexpected angle       |
| 6    | **Illusion** | Things aren't what they seem                  |
| 7    | **Drain**    | Resources are stolen, depleted, or sealed off |
| 8    | **Schism**   | The party is split or forced to choose sides  |

**d10 — Climax** *(What is the nature of the big confrontation?)*

| Face | Concept         | Idea                                         |
| ---- | --------------- | -------------------------------------------- |
| 1    | **Horde**       | Overwhelmed by sheer numbers                 |
| 2    | **Duel**        | Single powerful foe, one-on-one worthy       |
| 3    | **Siege**       | Defend or breach a fortified position        |
| 4    | **Hunt**        | Predator and prey, tracking or being tracked |
| 5    | **Summoning**   | Interrupt a dark rite before it completes    |
| 6    | **Colossus**    | Something enormous and imposing              |
| 7    | **Arena**       | Forced combat under constraints or rules     |
| 8    | **Tyrant**      | A cunning leader commanding minions          |
| 9    | **Abomination** | Something unnatural, wrong, horrifying       |
| 10   | **Gauntlet**    | A deadly escalating series of challenges     |

**d12 — Revelation** *(What is discovered at the end?)*

| Face | Concept      | Idea                                               |
| ---- | ------------ | -------------------------------------------------- |
| 1    | **Treasure** | Material wealth, a hoard                           |
| 2    | **Ally**     | A new friend, faction, or patron                   |
| 3    | **Portal**   | Access to somewhere else entirely                  |
| 4    | **Prophecy** | Knowledge of what's coming                         |
| 5    | **Relic**    | A powerful artifact                                |
| 6    | **Prisoner** | Someone held captive here                          |
| 7    | **Map**      | Knowledge of a new location or path                |
| 8    | **Traitor**  | Someone trusted is revealed as false               |
| 9    | **Origin**   | The truth about how something began                |
| 10   | **Plague**   | A spreading threat uncovered                       |
| 11   | **Heir**     | A lineage, succession, or birthright revealed      |
| 12   | **Void**     | Absence — what was here is gone, or was never real |

## Step 2: Gather Context

Interpret `$ARGUMENTS` as a creative prompt. It may reference locations, NPCs, factions, themes, or situations from the campaign.

1. **Search the vault** for notes related to the prompt — use Grep and Glob to find relevant NPCs, locations, items, and lore.
2. **Read** the most relevant notes (aim for 3-6 notes) to absorb setting details, active conflicts, and established facts.
3. **Follow wiki links** from those notes one level deep to pick up additional context.

If `$ARGUMENTS` is empty or very generic (e.g., "a dungeon"), search broadly for recent or prominent campaign elements and use them as seeds.

## Step 3: Generate the Dungeon

Combine the rolled concepts with the gathered context to produce a dungeon note. The dungeon should feel like it belongs in the campaign world — grounded in existing lore, featuring known (or plausibly connected) factions, creatures, and locations.

### Output Format

Create a new note at `loreduck/{Dungeon Name}.md` with this structure:

```markdown
*{One-sentence evocative summary of the dungeon's premise.}*

- **Theme**: {A few words capturing the dungeon's mood or motif}
- **Location**: [[{Where the dungeon may be found}]]

## Entrance: {Concept}

_{Idea}_

{2-4 sentences. What do the PCs encounter? Why hasn't this place been cleared? Use the rolled concept as the seed.}

## Puzzle: {Concept}

_{Idea}_

{2-4 sentences. What non-combat challenge do the PCs face? What skills or approaches might help?}

## Trick / Setback: {Concept}

_{Idea}_

{2-4 sentences. What goes wrong? How do the stakes escalate?}

## Climax: {Concept}

_{Idea}_

{2-4 sentences. What is the big fight or confrontation? Include terrain, tactics, or emotional stakes.}

## Revelation: {Concept}

_{Idea}_

{2-4 sentences. What do the PCs discover? How does it connect back to the wider campaign?}

## Hooks

- {1-3 bullet points: loose threads, future adventure seeds, or connections to existing campaign arcs}

#dungeon
```

### Writing Guidelines

- Each room description should be **2-4 sentences** — enough to run from, not a script.
- Use `[[wiki links]]` generously to tie into existing vault lore.
- Invent freely where the vault has gaps, but stay consistent with established facts.
- The dungeon name should be evocative and specific (e.g., "The Ember Vaults of Khorash", not "Fire Dungeon").
- Include a **Hooks** section with threads that connect the dungeon back to the campaign.
- Record the raw dice results in a **Dice** section at the bottom for reference.
- End the note with `#dungeon` on its own line.

## How to Use This Skill

When the user invokes `/loreduck:dungeon`, interpret `$ARGUMENTS` as a creative prompt or theme for the dungeon. Execute the three steps in order: roll dice, gather context, generate the dungeon. Present the dice results and the generated note to the user.

