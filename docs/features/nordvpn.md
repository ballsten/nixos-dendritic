# nordvpn

NordVPN over WireGuard (NordLynx), as NetworkManager connections for
Australia, New Zealand, the UK and the US.

| | |
|---|---|
| Module | `modules/features/nordvpn.nix`, servers in `modules/features/_nordvpn-servers.json` |
| Aspects | `nixos.nordvpn` |
| Hosts | All, through `workstation` |
| Inputs | None |
| Persists | Nothing |
| Secrets | `nordvpn/private-key` |
| Recipes | `just set-nordvpn`, `just nordvpn-servers` |

## Connecting

Each country is a NetworkManager connection named `nordvpn-<country>`
(`nordvpn-au`, `nordvpn-nz`, `nordvpn-uk`, `nordvpn-us`). None starts on
its own:

```sh
nmcli connection up nordvpn-au
nmcli connection down nordvpn-au
```

While a tunnel is up, all IPv4 traffic and DNS go through it.

## IPv6

NordVPN has no IPv6 on any of its servers, so IPv6 can't go through the
tunnel. On a network with IPv6 it would otherwise leave through the normal
connection from the real address, which streaming services see as the wrong
country. Instead, each connection routes all IPv6 into the tunnel too, where
NordVPN's server drops it, so IPv6 is blocked while the VPN is up.

The tunnel gets a unique-local address, `fd3f:da6f:2206::2`. It is the
source address for that traffic, and because it isn't a public address,
programs prefer IPv4 for public destinations and seldom try IPv6 at all. Any
that do fall back to IPv4 when it fails. IPv6 works normally again once the
connection is down. See [0038](../decisions/0038-nordvpn-block-ipv6.md).

## The private key

NordLynx uses one WireGuard private key per account, the same for every
server. It isn't shown in Nord Account, only returned by NordVPN's API:

1. In Nord Account, open NordVPN's manual setup page and
   generate an access token.
2. Run `just set-nordvpn` and paste the token. The recipe fetches the
   NordLynx private key with it and stores only the key in sops, as
   `nordvpn/private-key`.
3. Rebuild. A sops template, `nordvpn.env`, holds the key, and
   `ensureProfiles` substitutes it into the connections at boot, as the
   [wifi](wifi.md) feature does.

The access token can be revoked afterwards; the key keeps working.

## Servers

Each connection points at one server, kept with its WireGuard public key
in `_nordvpn-servers.json`. The `_` keeps import-tree from loading it as a
module. `just nordvpn-servers` asks NordVPN's API for the currently
recommended server in each country and rewrites the file; run it when a
server stops answering or is overloaded, then rebuild. To change the
countries, edit the list in that recipe and run it.

Recommendations depend on where the request comes from, so run it from
home, not through the VPN.

## Firewall

The tunnel takes the default route through NetworkManager's policy routing,
which the NixOS firewall's strict reverse-path filter reads as spoofed
traffic and drops replies. The feature sets
`networking.firewall.checkReversePath = "loose"` on every host.

See [0037](../decisions/0037-nordvpn-wireguard.md) for why this isn't the
official client or OpenVPN.
