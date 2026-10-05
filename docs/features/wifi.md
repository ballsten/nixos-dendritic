# wifi

Declares the Wi-Fi networks NetworkManager knows, with their SSIDs and keys
in sops.

| | |
|---|---|
| Module | `modules/features/wifi.nix` |
| Aspects | `nixos.wifi` |
| Hosts | All, through `workstation` |
| Inputs | None |
| Persists | Nothing |
| Secrets | `wifi/home/ssid`, `wifi/home/psk` |
| Recipes | `just set-wifi [network]` |

The secrets are written into a sops template, `wifi.env`, as
`HOME_SSID=…` and `HOME_PSK=…`. NetworkManager's `ensureProfiles` reads that
file as an environment file and substitutes `$HOME_SSID` and `$HOME_PSK`
into the `home` profile when it creates it at boot. The values never enter
the Nix store.

To add a network, run `just set-wifi <name>` and add a matching profile and
template lines in `modules/features/wifi.nix`. See
[secrets](secrets.md#wi-fi).
