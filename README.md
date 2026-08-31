# Only-Hero

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

- `/onlyhero` or `/lust` — run a check now
- `/onlyhero options` — open the options window

## Configuration

Options are available under **Esc → Options → AddOns → Only-Hero** (or via `/onlyhero options`):

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

This addon relies on the **Ace3** libraries. During development the libraries are loaded from your existing AddOns folder; for releases they are automatically embedded into `Libs/` by the [BigWigs packager](https://github.com/BigWigsMods/packager) (via the `.pkgmeta` file), so no manual installation is needed.

Required libraries (automatically embedded at build time):

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
2. Extract the `OnlyHero` folder into your `World of Warcraft/_retail_/Interface/AddOns/`.
3. Restart WoW (or reload your UI with `/reload`) and enable the addon.

## Building a release

Releases are built automatically by a GitHub Actions workflow (`.github/workflows/package.yml`) whenever you push an **annotated tag** (e.g. `git tag -a v1.0.1 -m "v1.0.1"`). The workflow:
- Embeds all Ace3 libraries into `Libs/` as configured in `.pkgmeta`.
- Packages the addon as `OnlyHero-<version>.zip`.
- Creates a GitHub Release with the packaged addon attached.

Releases are uploaded to services whose API keys you have configured as GitHub repository secrets (`CF_API_KEY`, `WOWI_API_TOKEN`, `WAGO_API_TOKEN`). The `GITHUB_TOKEN` secret must be set to read-write permissions in your repository settings.

## Notes

- Hunter detection is class-based because WoW does not expose which pet another hunter currently has out. Use the **Count Hunters** option to control whether hunters are treated as bloodlust-capable.
- Bloodlust effects share a 10-minute cooldown debuff (Sated / Exhaustion / Temporal Displacement) on all affected players.
