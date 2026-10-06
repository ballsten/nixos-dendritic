# 0025: The login screen's look is declared, from the default wallpaper

- **Status:** Accepted, 2026-10-07
- **Issue:** #71

## Context

noctalia-greeter showed its own built-in colours and background, so the
login screen didn't match the desktop. Only the cursor was shared
([0023](0023-cursor.md)).

Noctalia can sync its current wallpaper and colours to the greeter at
runtime, through a helper run as root by polkit. The synced files go in
`/var/lib/noctalia-greeter`, which is wiped on boot
([0016](0016-impermanence.md)). A wallpaper picked on the desktop also
lasts only until reboot ([0021](0021-noctalia-theming.md)), when the
default comes back.

The greeter's `greeter.toml`, which NixOS generates, can hold the same
wallpaper and palette itself, and takes precedence over anything synced.

## Decision

The [theme](../features/theme.md) feature declares the greeter's look in
`greeter.toml`:

- **The default wallpaper**, the one the desktop shows at boot.
- **A palette generated at build time** by running `noctalia theme` on
  that wallpaper with the desktop's scheme. Nix reads the result back
  through import-from-derivation and maps it to the greeter's 16 colours
  the way Noctalia's own sync does.
- **The `Synced` scheme, with the scheme picker hidden**, so the login
  screen always uses those colours.

The runtime sync stays off, and no polkit rule allows it without a
password.

## Consequences

- The login screen matches the desktop as it looks after a reboot, and
  every boot shows the same thing.
- A wallpaper picked at runtime isn't shown on the login screen.
- Nothing new is persisted, and no polkit rule is added.
- Evaluating a host now builds a small derivation (import-from-derivation)
  that runs Noctalia, the first use of it in this repo. Noctalia comes
  from the binary cache, and generating takes about a second.
- If Noctalia changes how its sync maps colours to the greeter, the
  mapping in the module needs updating by hand.

## Alternatives considered

- **Runtime sync**, with `ballsten` in `passwordlessSyncUsers` and
  `/var/lib/noctalia-greeter` persisted: follows the last wallpaper picked,
  which after a reboot is no longer the desktop's.
- **Both**, a declared default with runtime sync on top: not possible
  through `greeter.toml`, which always wins over synced values. It would
  need the default written into the greeter's mutable `sync.toml` instead.
- **A palette written into the repo**: no import-from-derivation, but it
  would go stale whenever the default wallpaper or scheme changed.
- **Generating all of `greeter.toml` in a derivation**: also avoids
  import-from-derivation, but means overriding the nixpkgs module's
  tmpfiles entry rather than using its `settings` option.
