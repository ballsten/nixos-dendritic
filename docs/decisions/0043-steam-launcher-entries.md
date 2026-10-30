# 0043: Launcher entries for Steam games are generated from the library

- **Status:** Accepted, 2026-10-27

## Context

Installed Steam games should be startable from Noctalia's launcher on
`tiki-rig` without opening Steam first (#107).

Steam writes a desktop entry to `~/.local/share/applications` and icons to
`~/.local/share/icons/hicolor` when it installs a game, and never again.
Impermanence wipes both on boot ([0016](0016-impermanence.md)), while the
library itself survives on `/games`. After the first reboot, no game has an
entry.

## Decision

A user service, `steam-launcher-entries`, writes one desktop entry per game
from each library's app manifests. It runs at login and from a path unit
whenever `steamapps` changes. It removes Steam's own entries so a game isn't
listed twice, and uses Steam's cached library icon by absolute path. Steam
tools that have manifests (Proton, runtimes, redistributables) are skipped
by name.

## Consequences

- Every installed game has an entry, including ones installed before this
  change, and nothing new is persisted.
- The entries follow the library: installing or removing a game updates
  them.
- Icons are 32x32, so they look soft at large sizes.
- The script depends on the manifest format and on where Steam caches
  icons (`appcache/librarycache/<appid>/`). If either changes, entries
  lose their icon or stop appearing.
- A new Steam tool with a manifest shows up as a game until its name is
  added to the list.

## Alternatives considered

- **Persist Steam's output:** persist `~/.local/share/applications` and
  the hicolor icons. Simpler, but those folders are shared with other
  apps, files can't be persisted one by one because their names depend on
  the game, and games installed before the change need "Add desktop
  shortcut" by hand.
- **`logo.png` as the icon:** 360x360 and sharp, but it's the game's title
  logo, often wide text on a transparent background.
- **Launching through `gamemoderun`:** left to each game's Steam launch
  options, as before.
