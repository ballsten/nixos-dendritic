# 0031: Path of Exile runs in gamescope

- **Status:** Accepted, 2026-10-08
- **Issues:** #98, #99
- **PR:** #100

## Context

Path of Exile runs through Proton as an X11 window on Umbriel's Xwayland.
Umbriel's X11 window manager supports little of EWMH: no minimise
(`_NET_WM_STATE_HIDDEN`) and no "keep above" (`_NET_WM_STATE_ABOVE`). When
the game minimises itself on losing focus, Wine withdraws its window and
Umbriel can't show it again (#98).

Awakened PoE Trade, the price-check overlay, only works on X11. Its
hotkeys use XRecord and XTest, and its overlay finds the game window by
title and attaches to it through X11. Under Umbriel the overlay ends up
below the game or covers it, and its fight with the game over focus made
the game's window disappear again (#99).

## Decision

The [gaming](../features/gaming.md) feature enables `programs.gamescope`
and adds a `with-awakened-poe-trade` wrapper. Path of Exile's Steam launch
options run the game and the overlay together in gamescope, which has its
own Xwayland and window manager, so neither depends on Umbriel's.

The size and refresh rate are passed in the launch options, not set in the
feature, because they depend on the host's monitors.

## Consequences

- The overlay runs only while the game does, inside gamescope. A copy
  already running outside gamescope stops the wrapper's copy from starting.
- Gamescope adds a nested compositor. It may cost some latency, and it
  hasn't been proven on tiki-rig's NVIDIA driver under Umbriel.
- If Umbriel's X11 support improves, the game can go back to plain
  `%command%`.

## Alternatives considered

- **Native Wayland (`PROTON_ENABLE_WAYLAND=1`):** the window stays put,
  but Awakened PoE Trade can't see a Wayland window, so no price checks.
- **Plain Xwayland with Wine's `UseTakeFocus=N`:** stops most focus
  changes from withdrawing the window, but the overlay still doesn't work.
- **Pinning the overlay with an Umbriel window rule:** tried live. The
  overlay covered the game and the game window was withdrawn.
