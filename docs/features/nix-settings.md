# nix-settings

Nix daemon settings, and automatic garbage collection and store
optimisation.

| | |
|---|---|
| Module | `modules/features/nix-settings.nix` |
| Aspects | `nixos.nix-settings` |
| Hosts | All, through `workstation` |
| Inputs | None |
| Persists | Nothing (timer state is persisted by [impermanence](impermanence.md)) |
| Secrets | None |

## Settings

- Flakes and the `nix` command are enabled.
- `root` and `@wheel` are trusted users.
- The only substituter is cache.nixos.org.
- `keep-going`: one failed build doesn't stop the others.
- `warn-dirty = false`: no warning for an uncommitted git tree.

## Garbage collection and optimisation

- `nix.gc` runs weekly and deletes generations older than 30 days, the same
  as impermanence keeps old roots.
- `nix.optimise` hard-links identical store files weekly. A timer is used
  rather than `auto-optimise-store`, which slows down every build.

Both timers catch up after the machine was off or asleep, because
`/var/lib/systemd/timers` is persisted.

Boot menu entries are limited separately, by `configurationLimit` in
[secure-boot](secure-boot.md).
