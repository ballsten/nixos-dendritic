# 0030: The installer stick's `KEYS` partition is FAT32

- **Status:** Accepted, 2026-10-08
- **Issue:** #9
- **Supersedes:** the `KEYS` filesystem in
  [0029](0029-host-keys-before-install.md)

## Context

[0029](0029-host-keys-before-install.md) put a `KEYS` partition after the
installer ISO on the USB stick, and made it ext4 so the `/persist` backup
could be one tar file larger than 4 GiB. The stick used to install
tiki-rig had a FAT32 `KEYS` partition instead, and the install worked: a
new host only needs its SSH key and the admin key from the stick.

## Decision

- `KEYS` is FAT32 (`mkfs.vfat -F 32`, MBR type `c`).
- The `/persist` backup for a reinstall is piped through `split` into
  parts under 4 GiB, and joined with `cat` when restoring. tar records
  ownership and permissions, so FAT32 not keeping them doesn't matter.

## Consequences

- Any machine can read and write the stick, including Windows on tiki-rig
  and a machine without NixOS.
- udisks mounts it as the desktop user, so copying to it needs no `sudo`.
- The backup is several files rather than one. The surface-laptop binary
  cache was already many files, each well under 4 GiB.
- Files on the stick have no Unix permissions; anyone who mounts it can
  read the keys. That was already true of anyone holding the stick, and
  the keys are deleted from it after the first boot.

## Alternatives considered

- **ext4** ([0029](0029-host-keys-before-install.md)): one backup file and
  real permissions, but only Linux reads it, and it needs `root_owner` to
  be writable without `sudo`.
- **exFAT:** no 4 GiB limit, but older firmware and tools support it less
  well than FAT32, and nothing on the stick needs files that large once
  the backup is split.
