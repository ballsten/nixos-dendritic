# 0029: Host keys are generated before install, onto the installer stick

- **Status:** Accepted, 2026-10-08; the `KEYS` filesystem superseded by [0030](0030-keys-partition-fat32.md)
- **Issue:** #9

## Context

A host's SSH key is its sops recipient, and it must be enrolled before
the first boot: ballsten's password comes from sops, and root has none
([0006](0006-immutable-users.md)). Enrolling re-encrypts the secrets, which
needs the admin key, so it runs on a working machine.

[Add a host](../howto/add-host.md) used to generate the key in the
installer, after partitioning. The install then stopped halfway: copy the
age recipient to the working machine, enrol and push, `git pull` in the
installer, then install. That's two machines in use at once, and a long
`age1…` string copied between them by hand.

## Decision

- **Generate the host key on the working machine, before the install**,
  straight onto the installer stick, and enrol it from the `.pub` file
  there. The private key isn't written to the working machine's disk.
- **One USB stick.** The installer ISO is written to it, and a second
  partition after the ISO, labelled `KEYS`, carries the host key, the admin
  key and, for a reinstall, the `/persist` backup.
- In the installer, the steps run straight through: partition, copy the
  keys into `/persist`, install.

## Consequences

- The secrets are re-encrypted for the host, and the PR reviewed, before
  the machine is wiped.
- The stick holds the host's private key and the admin key until the host
  is installed. They're deleted from it after the first boot.
- `KEYS` is ext4, so the stick needs `sudo` to prepare, and the `/persist`
  tar isn't limited to FAT32's 4 GiB.

## Alternatives considered

- **Generate the key in the installer** (the previous guide): the key never
  leaves the new machine, but the install needs the working machine and a
  round trip partway through.
- **Enrol over SSH from the working machine** to the installer
  (`just enrol-host <host> <address>`): no copying by hand, but it needs a
  password for `nixos`, both machines on the same network, and trusting
  whatever answers `ssh-keyscan`.
- **A custom installer image with the keys built in:** anything in the
  image is in the Nix store, readable by every user.
- **A second USB stick for the files:** works, but one stick is less to
  carry, and the space after the ISO is otherwise unused.
