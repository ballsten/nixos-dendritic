# 0037: NordVPN over WireGuard in NetworkManager

- **Status:** Accepted, 2026-10-15
- **Issue:** #89
- **PR:** None yet

## Context

The old configuration had four NordVPN OpenVPN connections, created by hand
in NetworkManager, so their credentials only lived in
`/etc/NetworkManager/system-connections`. With a wiped root
([0016](0016-impermanence.md)) and networks declared rather than saved
([0007](0007-declarative-wifi.md)), the VPN has to be declared too.

## Decision

Declare one WireGuard (NordLynx) connection per country with
`ensureProfiles`. The account's NordLynx private key is in sops, fetched once
from NordVPN's API with `just set-nordvpn`. Server hostnames and public
keys are public and pinned in `_nordvpn-servers.json`, refreshed with
`just nordvpn-servers`. The reverse-path filter is loosened so replies
through the tunnel aren't dropped.

## Consequences

- No daemon, no unfree package and nothing to persist.
- Servers are pinned. One that's retired or busy has to be refreshed by
  hand; the connections don't pick the best server when they start.
- NordVPN has no IPv6, so IPv6 is routed into the tunnel and dropped
  rather than leaking past it. IPv6-only destinations are unreachable
  while the VPN is up.
- The reverse-path filter is loose on every host, not only while the VPN
  is up.

## Alternatives considered

- **OpenVPN in NetworkManager:** the old setup, with service credentials in
  sops and the `.ovpn` settings declared. Slower, and needs the
  `networkmanager-openvpn` plugin.
- **The official client (`services.nordvpn`):** picks the best server
  itself and has a kill switch and Meshnet, but it's unfree, runs a root
  daemon, needs `/var/lib/nordvpn` persisted and a login token in sops.
- **`wgnord`:** a script that fetches a server and writes a `wg-quick`
  config at connect time. Not declarative, and was disabled in the old
  config.
