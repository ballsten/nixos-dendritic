# Impermanence

Every host wipes its root, including `/home`, on every boot. Only paths
declared under `/persist` survive. This is the `impermanence` feature
(`modules/features/impermanence.nix`), which every host gets via
`workstation`.

| | |
|---|---|
| Module | `modules/features/impermanence.nix` |
| Aspects | `nixos.impermanence` |
| Hosts | All, through `workstation` |
| Inputs | `impermanence`, `disko` |
| Persists | `/var/log`, `/var/lib/nixos`, `/var/lib/systemd/coredump`, `/var/lib/systemd/timers`, `/etc/machine-id` |
| Secrets | None |

## How it works

Each host has one LUKS-encrypted btrfs filesystem, declared with disko in
`modules/hosts/<host>/disk.nix`:

| Subvolume | Mounted at | On boot |
|---|---|---|
| `@root` | `/` | Replaced with an empty subvolume |
| `@nix` | `/nix` | Kept |
| `@persist` | `/persist` | Kept |
| `@swap` | `/swap` | Kept (swapfile, used for hibernate) |

On every boot, a service in the initrd (`rollback-root`) runs after the LUKS
unlock and after any resume from hibernate. It moves `@root` to
`/old_roots/<time>`, deletes old roots older than 30 days and creates an
empty `@root`. NixOS activation then rebuilds `/etc`, and impermanence
bind-mounts the persisted paths from `/persist` into place.

## Keys read from /persist

Keys needed during activation are read straight from `/persist`, not from
bind mounts, because activation can run before the bind mounts exist: the
SSH host key ([ssh](ssh.md)), the admin age key ([secrets](secrets.md)) and
the Secure Boot keys ([secure-boot](secure-boot.md)).

## Guides

- [Persist state](../howto/persist-state.md): declare a path, find what a
  program writes, and get files back after a reboot.
- [Install or reinstall a host](../howto/install-host.md).
