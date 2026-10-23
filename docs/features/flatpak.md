# flatpak

Flatpak with the Flathub remote, for apps that are only published there.
Apps are declared in Nix, not installed by hand.

| | |
|---|---|
| Module | `modules/features/flatpak.nix` |
| Aspects | `nixos.flatpak` |
| Hosts | `surface-laptop`, `tiki-rig`, for [roblox](roblox.md) |
| Inputs | `nix-flatpak` |
| Persists | `/var/lib/flatpak` (installed apps and runtimes) |
| Secrets | None |

Prefer a package from nixpkgs. Use Flatpak only for an app that isn't in
nixpkgs and can't reasonably be packaged, such as Sober.

## Declaring apps

[nix-flatpak](https://github.com/gmodena/nix-flatpak) adds options under
`services.flatpak`. A feature that needs a Flatpak app adds its ID to
`services.flatpak.packages`, as [roblox](roblox.md) does. The host imports
`flatpak` as well as that feature.

Apps are installed system-wide, into `/var/lib/flatpak`, by the
`flatpak-managed-install` service. That service runs at boot and after
each rebuild, not during the build, so:

- `nix build` doesn't download apps, and an app ID typo only fails at
  runtime. Check with `systemctl status flatpak-managed-install`.
- The first install needs network access and can take a few minutes
  while the runtimes download.

`uninstallUnmanaged` is on: anything installed with `flatpak install` by
hand is removed on the next run. This is the same rule as Wi-Fi
networks ([0007](../decisions/0007-declarative-wifi.md)): what's on the
machine is what's declared.

## Updates

Apps aren't pinned by `flake.lock`. A weekly timer
(`flatpak-managed-install-timer`) updates them from Flathub. To update
now:

```sh
flatpak update
```

## Persistence

`/var/lib/flatpak` is persisted, so apps and runtimes survive the boot
wipe. App data lives in each user's `~/.var/app/<app-id>`, which the
feature that adds the app persists.

See [0040](../decisions/0040-roblox-sober-flatpak.md) for why Flatpak and
nix-flatpak.
