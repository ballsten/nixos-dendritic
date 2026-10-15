_: {
  # NordVPN over WireGuard (NordLynx): one NetworkManager connection per
  # country, nordvpn-<country>, none started automatically. The servers come
  # from _nordvpn-servers.json (just nordvpn-servers); the private key, the
  # same for every server, from sops (just set-nordvpn).
  flake.modules.nixos.nordvpn =
    { config, lib, ... }:
    let
      servers = lib.importJSON ./_nordvpn-servers.json;
    in
    {
      sops = {
        secrets."nordvpn/private-key" = { };
        templates."nordvpn.env".content = ''
          NORDVPN_PRIVATE_KEY=${config.sops.placeholder."nordvpn/private-key"}
        '';
      };

      networking = {
        networkmanager.ensureProfiles = {
          environmentFiles = [ config.sops.templates."nordvpn.env".path ];
          profiles = lib.mapAttrs' (
            country: server:
            lib.nameValuePair "nordvpn-${country}" {
              connection = {
                id = "nordvpn-${country}";
                type = "wireguard";
                interface-name = "nordvpn-${country}";
                autoconnect = false;
              };
              wireguard.private-key = "$NORDVPN_PRIVATE_KEY";
              "wireguard-peer.${server.publicKey}" = {
                endpoint = "${server.hostname}:51820";
                allowed-ips = "0.0.0.0/0;::/0;";
              };
              # NordLynx gives every client this address. Its DNS servers,
              # with a negative priority so no other connection's DNS is used
              # while the tunnel is up.
              ipv4 = {
                method = "manual";
                address1 = "10.5.0.2/32";
                dns = "103.86.96.100;103.86.99.100;";
                dns-priority = -50;
              };
              # NordLynx carries no IPv6, so IPv6 is routed into the tunnel,
              # where the server drops it, rather than leaving through the
              # normal connection from our real address. The unique-local
              # address (a random prefix of our own) is the source for it,
              # and makes programs prefer IPv4 for public addresses.
              ipv6 = {
                method = "manual";
                address1 = "fd3f:da6f:2206::2/128";
              };
            }
          ) servers;
        };

        # The tunnel takes over the default route through policy routing,
        # which the strict reverse-path check reads as spoofed: replies from
        # the server are dropped. Loose still drops packets from addresses
        # with no route at all.
        firewall.checkReversePath = "loose";
      };
    };
}
