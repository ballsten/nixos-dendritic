# 0031: Prosperous Universe extensions in their own feature, force-installed

- **Status:** Accepted, 2026-10-09
- **Issue:** #103
- **PR:** #105

## Context

Refined PrUn and the FIO Client are Brave extensions for one game,
Prosperous Universe. `brave` already force-installed Bitwarden by writing
the policy JSON directly, so no other module could add to it.

## Decision

`brave` defines a `brave.extensions` option (Chrome Web Store IDs) and
builds `ExtensionInstallForcelist` from it. A separate `prun` feature adds
the two PrUn extensions to it, and `workstation` imports `prun`, so both
hosts get them: the game runs in the browser, and the extensions bring in
nothing GPU- or Steam-related. They are force-installed, like Bitwarden.

## Consequences

- Game-specific extensions stay out of the general `brave` feature, and a
  host can drop them by not importing `prun`.
- Other features can add Brave extensions from their own file.
- The extensions can't be disabled or removed in the browser; turning them
  off means removing `prun` from the host.
- `prun` relies on `brave` being imported, as 0012 allows.

## Alternatives considered

- **IDs in `brave.nix` next to Bitwarden:** simplest, but puts one game's
  extensions in the general browser feature.
- **`ExtensionSettings` with `normal_installed`:** installed automatically
  but can be turned off in the browser. Rejected to match Bitwarden and
  keep the browser's state declared.
- **`prun` in `gaming`:** would keep it off `surface-laptop`, but `gaming`
  is about Steam and the GPU, and PrUn is played from the browser on both
  machines.
