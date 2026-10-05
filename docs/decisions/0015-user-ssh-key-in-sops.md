# 0015: The user's SSH key lives in sops

- **Status:** Accepted, 2026-10-05
- **Issue:** #6
- **PR:** #41

## Context

With home wiped on boot ([0016](0016-impermanence.md)), `~/.ssh` is
emptied. ballsten's SSH key is what `git push` uses.

## Decision

The private key is a home-manager sops secret, linked at
`~/.ssh/id_ed25519`. The public key is plain text in
`modules/users/ballsten/credentials.nix`, without the comment field so the
email address stays out of the repo. GitHub's host key is in the
system-wide known hosts ([ssh](../features/ssh.md)), so there is no
first-connection prompt after a wipe.

## Consequences

- `git push` works on a fresh boot without anything persisted in
  `~/.ssh`.
- The key has no passphrase, since sops gives it to `ssh` without a
  prompt; `just set-ssh-key` checks this.
- Every host with the admin key can decrypt it, the same trust as other
  home-manager secrets.
- Other SSH hosts prompt once per boot unless added to
  `programs.ssh.knownHosts`.

## Alternatives considered

- **Persist `~/.ssh`:** the key would sit unencrypted on `/persist`, and
  the known hosts file would be mutable state.
