# 0049: LibreWolf bookmarks sync through floccus to Google Drive

- **Status:** Accepted, 2026-11-10
- **Issue:** #142

## Context

Each host keeps its own LibreWolf bookmarks in `places.sqlite`, and they
never sync. We wanted them shared between tiki-rig and surface-laptop by
the most private method that works. Neither host is always on, and there's
no home server.

Declaring bookmarks in Nix doesn't work: the repo is public, and the
option replaces bookmarks with a fixed list. Syncing `places.sqlite`
itself isn't safe, because the browser holds it open in WAL mode.

## Decision

- [librewolf](../features/librewolf.md) force-installs
  [floccus](https://floccus.org/), which syncs bookmarks to one file in
  Google Drive, encrypted with a passphrase.
- floccus is set up by hand once per host, like the Bitwarden login. The
  passphrase lives in Bitwarden, not in sops.
- Only bookmarks sync. The first sync starts from an empty set on both
  hosts.

## Consequences

- No server, flake input or secret to maintain; the Nix change is one
  extension.
- Google sees one encrypted file, its size and when it changes, plus the
  account signing in. It doesn't see the bookmarks.
- Losing the passphrase means losing the remote copy; each host still has
  its own bookmarks.
- A new host, or a wiped profile, needs the floccus setup again.
- The existing bookmarks on both hosts were dropped.

## Alternatives considered

- **floccus with a private GitHub repo**, like the Obsidian vault: no
  server and full history, but floccus' Git backend can't encrypt, so
  GitHub would hold the bookmarks in plaintext.
- **floccus with Dropbox or an S3 bucket**: the same encryption, but
  another account to keep. Dropbox is the fallback if Google's sign-in
  doesn't work in LibreWolf.
- **floccus with WebDAV on tiki-rig**: nothing leaves our machines, but it
  only syncs while tiki-rig is on, the laptop would need Tailscale or
  WireGuard away from home, and it's a new server to run.
- **Self-hosted Firefox Sync** (`services.firefox-syncserver`): still needs
  a Mozilla account unless the accounts server is self-hosted too, and has
  the same always-on problem.
- **Firefox Sync with Mozilla's servers**: end-to-end encrypted, but
  Mozilla sees account and usage metadata.
- **An exported bookmark file over Syncthing**: no server, but manual, and
  not two-way sync.
- **Preconfiguring floccus from sops-nix**: floccus documents no
  managed-storage or policy settings, so there's nothing to write the
  account into.
