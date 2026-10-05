# 0014: Umbriel and Noctalia from nixpkgs

- **Status:** Accepted, 2026-10-03
- **Issue:** #22
- **PRs:** #36, #37

## Context

Hosts booted to a TTY. The previous configuration used Hyprland with
waybar and wofi.

## Decision

The [desktop](../features/desktop.md) feature uses the Noctalia stack: the
Umbriel compositor, Noctalia Shell and noctalia-greeter. All three come
from nixpkgs, with their NixOS and home-manager modules (decided
2026-10-02). It goes in `workstation`, so every host gets it.

The `umbriel` flake was added later (#37), only for its home-manager
module to write `~/.config/umbriel/config.toml`. The compositor still comes
from nixpkgs (`package = null`), because the flake's build isn't in the
binary cache.

## Consequences

- Noctalia's widgets need NetworkManager, Bluetooth, UPower and
  power-profiles-daemon, enabled through `recommendedServices`.
- Started with no settings; Umbriel's config is now declarative, including
  the packaged defaults so their keybinds are kept.
- Per-host display scaling lives in each host's `display.nix`.

## Alternatives considered

- **Upstream flakes for all three:** newer versions, but builds outside the
  binary cache.
