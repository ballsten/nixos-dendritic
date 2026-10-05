# 0019: Weekly garbage collection and store optimisation

- **Status:** Accepted, 2026-10-05
- **Issue:** #44
- **PR:** #49

## Context

The store and boot menu grew without limit. The previous configuration
used `auto-optimise-store`.

## Decision

In [nix-settings](../features/nix-settings.md) and
[secure-boot](../features/secure-boot.md):

- `nix.gc` weekly, deleting generations older than 30 days, the same as
  impermanence keeps old roots.
- `nix.optimise` weekly, rather than `auto-optimise-store`, which
  hard-links during every build and slows builds. The space saved is the
  same.
- At most 10 boot menu entries, and no command-line editor in the boot
  menu.

## Consequences

- Both timers are persistent, and `/var/lib/systemd/timers` is persisted,
  so runs missed while the machine was off happen on the next boot.
- Generations older than 30 days can't be rolled back to.

## Alternatives considered

- **`auto-optimise-store`:** as before; slower builds.
