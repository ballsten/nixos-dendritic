# 0035: Sidekick Web replaces Awakened PoE Trade

- **Status:** Accepted, 2026-10-09
- **Issue:** #101
- **PR:** None yet

## Context

Path of Exile runs as a native Wayland window (`PROTON_ENABLE_WAYLAND=1`),
because under Umbriel's Xwayland its window disappears on focus changes
(#98). Awakened PoE Trade's hotkeys and overlay only work with X11, so it
couldn't work with the game at all (#99). Running both in gamescope (#100)
was tried and dropped.

## Decision

Remove Awakened PoE Trade and use the web variant of Sidekick: a local
server with its UI in Brave, started from the launcher. Items are
price-checked by copying them in game and pasting them into Sidekick.
It runs as an on-demand systemd user service, with a launcher entry to
stop it.

## Consequences

- Price checks work with the game on Wayland, with no hotkeys, overlay or
  X11.
- Checking an item takes a copy, a window switch and a paste instead of a
  single hotkey.
- Sidekick isn't in nixpkgs, so the feature fetches its AppImage, and
  version updates are manual.
- Sidekick's links open in Brave outside the service, through a
  replacement `xdg-open` in its sandbox, so stopping Sidekick never
  closes the browser.

## Alternatives considered

- **Sidekick's desktop build:** uses SharpHook 7 (X11-only hooks) and an
  X11 overlay, so it has the same problems as Awakened PoE Trade.
- **Run the game on X11 again:** brings back #98.
- **Gamescope for the game and overlay (#100):** experimental on NVIDIA
  under Umbriel, and it was dropped.
- **The trade website alone:** needs the item's mods entered by hand.
- **Sidekick started straight from the launcher, without a service:**
  every launch starts another server on the next port, and there's no
  way to stop it short of logging out.
