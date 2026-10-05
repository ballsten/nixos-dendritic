# 0007: Wi-Fi networks are declared, not saved

- **Status:** Accepted, 2026-10-02
- **Issues:** #6, #11
- **PRs:** #17, #42

## Context

NetworkManager saves networks added in its UI under
`/etc/NetworkManager/system-connections`. With a wiped root
([0016](0016-impermanence.md)), that directory would need persisting.

## Decision

Wi-Fi networks are NetworkManager profiles declared with `ensureProfiles`
in the [wifi](../features/wifi.md) feature, with their SSID and key in sops.
`/etc/NetworkManager/system-connections` isn't persisted: ad-hoc
connections were left out of the impermanence scope on purpose (#42).

## Consequences

- Keys never sit unencrypted on disk outside `/run`.
- A network added by hand in the UI works until the next reboot.
- Adding a network needs `just set-wifi <name>` and a profile in
  `wifi.nix`. If there are many, the profiles could be generated from a
  list.
- A VPN would follow the same pattern: the NetworkManager plugin and a
  declared profile with its secrets in sops (#44).

## Alternatives considered

- **Persist `system-connections`:** networks added in the UI would
  survive, but with their keys in plain text on `/persist`, outside the
  config.
