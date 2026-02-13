# Loreduck

Loreduck is:

- A command line environment 
- A collection of [agent skills]

Loreduck turns your agent into a creative muse who derives lore and setting concepts from you [TTRPG] lore. Loreduck is intended to be paired with lore that is created and curated primarily by a human.

To make best use of Loreduck, pair it with an [Obsidian] vault (or similar Markdown-based hypergraph) that contains your campaign lore. 

## Getting started

These skills must be used from within the Nix devshell environment defined in this repository.

So, first [install Nix] and drop into the shell:

```sh
nix develop github:cdata/agent-skills/main
```

Then, you can launch your agent. **Don't forget to set your Gemini API key!**

```sh
export GEMINI_API_KEY="..."
claude
```

## Available Commands

| Command | Description | Example Usage |
|---------|-------------|---------------|
| `/loreduck:roll` | Roll dice using standard polyhedral notation. | `/loreduck:roll 2d6`, `/loreduck:roll 1d20+5`, `/loreduck:roll 2d20K1` |
| `/loreduck:image` | Generate, edit, and compose images using Google Gemini's image models. | `/loreduck:image a treasure chest overflowing with gold coins, isometric, fantasy RPG style` |
| `/loreduck:lore` | Creates NPCs, items, locations, and other lore notes as linked Markdown | `/loreduck:lore create an NPC named Vasha, a tiefling alchemist in the Ash Quarter` |
| `/loreduck:dungeon` | Generate a "5 Room Dungeon" using dice-drop generator tables | `/loreduck:dungeon a forgotten dwarven forge beneath the city` |

[agent skills]: https://agentskills.io/
[install Nix]: https://github.com/mschwaig/howto-install-nix-with-flake-support/blob/main/README.md
[TTRPG]: https://en.wikipedia.org/wiki/Tabletop_role-playing_game
[Obsidian]: https://obsidian.md/
