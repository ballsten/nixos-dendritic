# 0026: The Steam library on its own `/games` subvolume

- **Status:** Accepted, 2026-10-07
- **Issue:** #9

## Context

Every host is impermanent ([0016](0016-impermanence.md)): only what's
declared under `/persist` survives a reboot. On tiki-rig the Steam library
is 429G, against well under 10G for everything else in home. tiki-rig keeps
Windows on its second disk, so the library has to share the NixOS disk.

## Decision

The [gaming](../features/gaming.md) feature persists `~/.local/share/Steam`
under a second persistence root, `/games`, instead of `/persist`. A host
that imports `gaming` provides `/games` as its own btrfs subvolume
(`@games`) inside the same LUKS volume, and the feature asserts that it
exists.

## Consequences

- `@persist` stays small, so copying or snapshotting it for a reinstall
  (as [Install or reinstall a host](../howto/install-host.md) does) doesn't
  carry the game library.
- Each gaming host's `disk.nix` declares `@games`, mounted at `/games`
  with `neededForBoot`.
- The library can later move to its own disk by changing only the host's
  `/games` mount, not the feature.

## Alternatives considered

- **In `/persist`:** simplest, but makes `@persist` huge, and every backup
  or restore of it carries the games.
- **A separate disk:** tiki-rig's second disk holds Windows, which stays.
- **Not persisting it:** every boot would mean re-downloading the library.
