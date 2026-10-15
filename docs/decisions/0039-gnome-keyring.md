# 0039: gnome-keyring as the Secret Service

- **Status:** Accepted, 2026-10-15
- **Issue:** #82
- **PR:** None yet

## Context

Element keeps the key to its local message database in the system keyring.
No keyring ran in the session, so Element would show a "System unsupported"
dialog on first start and offer weaker encryption (a key built into
Electron) or none. Other apps that use the Secret Service API had nowhere
to store secrets either.

## Decision

Run gnome-keyring as the Secret Service on every host, through
`workstation`. PAM unlocks the `login` keyring with the password typed at
the greeter, and `~/.local/share/keyrings` is persisted. Its SSH agent is
turned off. Apps that should use it are started with
`--password-store=gnome-libsecret`, because Chromium and Electron don't
recognise Umbriel and would otherwise use their built-in key.

## Consequences

- Keys stored by apps are encrypted with the login password, not a key
  every Electron install shares.
- The keyring password doesn't follow `just set-password`; it has to be
  changed in seahorse afterwards.
- Each app has to be given the `--password-store` flag in its own feature.
- seahorse, gcr and gnome-keyring add about 17 MiB.

## Alternatives considered

- **Electron's basic store (`--password-store=basic`):** no new feature,
  but the key is only obscured, so its protection is the LUKS disk
  encryption alone.
- **Leave Element's dialog:** the same result as the basic store, chosen
  by hand on each host.
- **KeePassXC's Secret Service:** needs KeePassXC open and unlocked, and
  a database to manage, with Bitwarden already used for passwords.
- **KWallet:** pulls in KDE frameworks for a non-KDE desktop.
