# 0016: Impermanence with a btrfs root rollback

- **Status:** Accepted, 2026-10-05 (surface-laptop reinstalled the same day)
- **Issue:** #6
- **PRs:** #41, #42

## Context

Andrew wanted impermanence to be a core part of the repo: only state the
configuration declares survives a reboot. Andrew chose each option below
while #6 was scoped on 2026-10-04.

## Decision

- **Layout:** one LUKS volume (`cryptroot`) holding btrfs with `@root`,
  `@nix`, `@persist` and `@swap`, declared per host with disko in
  `disk.nix`.
- **Rollback:** an initrd service moves `@root` to `/old_roots/<time>` and
  creates an empty one on every boot, after the LUKS unlock and after any
  hibernate resume. Old roots are kept for 30 days.
- **Scope:** `/` and `/home` are both wiped, on every host, through
  `workstation`.
- **Persisting:** each feature persists its own paths, with no central
  list. Directories, not single files.
- **Keys:** read from `/persist` directly rather than through bind mounts.
- **Swap:** a swapfile in `@swap`, inside LUKS, for hibernate.
- **Not persisted:** `~/Downloads`, `~/.cache`, ad-hoc NetworkManager
  connections ([0007](0007-declarative-wifi.md)), and apps the repo
  doesn't configure.

## Consequences

- Applying it needed a reinstall; switching a non-impermanent install
  breaks boot.
- New features must think about state. `CLAUDE_CONFIG_DIR` moves Claude
  Code's `.claude.json` into `~/.claude`, because a persisted single file
  breaks when a program saves it by renaming over it.
- Lost state can be recovered from `/old_roots` for 30 days.
- Every host needs a `disk.nix`, and users have pinned uids.
- Disk unlock was passphrase-only at first; TPM unlock followed
  ([0018](0018-tpm-unlock.md)).

## Alternatives considered

The scoping session recorded the choices, not the options turned down.
The previous install was a single ext4 partition with no encryption, which
can't be rolled back; the choices above replaced it. Other common
approaches, not recorded as weighed:

- **tmpfs root:** no old roots to recover from, and limited by RAM.
- **Wipe `/` only, keep `/home`:** less work per feature, but home state
  accumulates undeclared.
