# Only-Lust

A World of Warcraft addon that lets you know when you are the only member of your group who can cast a bloodlust effect (**Lust / Hero / Time Warp / Primal Rage / Fury of the Aspects**).

Created by Runningbird.

## Features

- **Popup window** appears when your group fills via the **Dungeon Finder** or an **LFG List (premade) group** acceptance, showing the bloodlust availability of the newly formed group.
- Detects bloodlust-capable classes:
  - **Shaman** — Bloodlust / Heroism
  - **Mage** — Time Warp
  - **Hunter** — Primal Rage (Ferocity pet)
  - **Evoker** — Fury of the Aspects
- Warns when **you are the only one** who can cast a bloodlust effect.
- Optionally warns when **nobody** in the group can.
- Color-coded class names, configurable minimum group-member level, and raid-chat announcement support.

## Usage

The addon is automatic — no setup required. When your group fills via group finder, a popup (or chat message) reports the bloodlust situation.

Manual commands:

- `/onlylust` or `/lust` — run a check now
- `/onlylust options` — open the options window

## Configuration

Options are available under **Esc → Options → AddOns → Only-Lust** (or via `/onlylust options`):

| Option | Default | Description |
| ------ | ------- | ----------- |
| Enabled | On | Enable the warning system |
| Popup window | On | Show a popup when the group forms; if off, print to chat |
| Warn if you are the only one | On | Warn when only you can cast a bloodlust effect |
| Warn if nobody can | Off | Warn when no one in the group can cast |
| Count Hunters | On | Count hunters as bloodlust-capable |
| Announce in raid chat | Off | Post the warning to raid chat instead of a popup |
| Min level | 10 | Minimum group member level to be considered |

## Dependencies

This addon relies on the **Ace3** libraries. During development the libraries are loaded from your existing AddOns folder; for a standalone release you should embed them into `Libs/` when packaging (e.g. via the [WoW Addon packager](https://github.com/BigWigsMods/packager)).

Required libraries:

- LibStub
- AceAddon-3.0
- AceConsole-3.0
- AceEvent-3.0
- AceTimer-3.0
- AceDB-3.0
- AceConfig-3.0
- AceConfigDialog-3.0
- AceGUI-3.0

## Installation

1. Download the latest release.
2. Extract the `OnlyLust` folder into your `World of Warcraft/_retail_/Interface/AddOns/`.
3. Restart WoW (or reload your UI with `/reload`) and enable the addon.

## Notes

- Hunter detection is class-based because WoW does not expose which pet another hunter currently has out. Use the **Count Hunters** option to control whether hunters are treated as bloodlust-capable.
- Bloodlust effects share a 10-minute cooldown debuff (Sated / Exhaustion / Temporal Displacement) on all affected players.
