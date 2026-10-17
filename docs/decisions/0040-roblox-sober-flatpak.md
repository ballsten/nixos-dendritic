# 0040: Roblox through Sober, installed with nix-flatpak

- **Status:** Accepted, 2026-10-17

## Context

Roblox should run on `surface-laptop`. Roblox's Windows client has refused
to run under Wine since its Hyperion anti-cheat arrived in 2023. Sober
runs the Android client natively and works, but it's closed source and
only distributed on Flathub. It isn't in nixpkgs.

Every host is impermanent ([0016](0016-impermanence.md)), and the rest of
the system is declared in Nix.

## Decision

Two features:

- [flatpak](../features/flatpak.md) enables Flatpak through
  [nix-flatpak](https://github.com/gmodena/nix-flatpak). It adds the
  Flathub remote, installs the apps features declare, removes undeclared
  apps, updates weekly, and persists `/var/lib/flatpak`.
- [roblox](../features/roblox.md) declares `org.vinegarhq.Sober` and
  persists its data in home.

`surface-laptop` imports both.

## Consequences

- Flatpak apps aren't pinned by `flake.lock`. They update from Flathub on
  a timer, so a rollback doesn't roll them back.
- Installation happens in a service after activation, so `nix build` and
  `nix flake check` don't catch a bad app ID.
- Other Flathub-only apps can be added from their own feature without
  touching `flatpak`.

## Alternatives considered

- **Plain `services.flatpak.enable` and a manual install:** no new input,
  but the app list isn't declared, and it would drift between hosts.
- **Packaging Sober in Nix:** it's closed source and only distributed as
  a Flatpak; a repackage would break with its frequent updates.
- **Wine or Proton (Grapejuice, Vinegar for the player):** blocked by
  Hyperion.
- **Waydroid with the Play Store build:** a full Android container, much
  heavier on a laptop where battery life matters.
- **Inside `gaming`:** `gaming` brings Steam and requires a `/games`
  subvolume, and `surface-laptop` imports neither.
