# 0038: Block IPv6 while NordVPN is up

- **Status:** Accepted, 2026-10-15
- **Issue:** #89
- **PR:** None yet

## Context

NordVPN has no IPv6 on any of its servers: its API lists IPv6 protocols,
but no server offers them, and no WireGuard server has an IPv6 address.
The connections from [0037](0037-nordvpn-wireguard.md) only routed IPv4, so
on a network with IPv6, IPv6 traffic left through the normal connection
from the real address. Streaming services then see the wrong country.

## Decision

Each `nordvpn-*` connection also routes `::/0` into the tunnel, where
NordVPN's server drops it. The tunnel gets a unique-local address,
`fd3f:da6f:2206::2/128`, from a random prefix, as the source for that
traffic.

## Consequences

- IPv6 can't leave from the real address while the VPN is up.
- Programs prefer IPv4 for public destinations, because the only IPv6
  source they'd use isn't public. Those that try IPv6 fall back to IPv4
  when it fails.
- IPv6-only destinations are unreachable while the VPN is up.
- Nothing changes on networks without IPv6, such as home.

## Alternatives considered

- **Leave IPv6 alone:** simplest, but leaks the real address on networks
  with IPv6.
- **Turn off IPv6 on the other connections while the VPN is up:** the same
  result, but needs a NetworkManager dispatcher script to switch it off and
  back on, and changes connections that aren't the VPN's.
- **OpenVPN or IKEv2 servers with IPv6:** NordVPN lists the protocols, but
  no server offers them.
