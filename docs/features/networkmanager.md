# networkmanager

Network configuration with NetworkManager.

| | |
|---|---|
| Module | `modules/features/networkmanager.nix` |
| Aspects | `nixos.networkmanager` |
| Hosts | All, through `workstation` |
| Inputs | None |
| Persists | Nothing |
| Secrets | None |

Enables `networking.networkmanager`. Users who should manage connections
need the `networkmanager` group. Saved Wi-Fi networks are declared by the
[wifi](wifi.md) feature rather than kept on disk, so
`/etc/NetworkManager/system-connections` isn't persisted: a network added
by hand in the UI is gone after a reboot.
