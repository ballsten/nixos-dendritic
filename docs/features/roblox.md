# roblox

Roblox, through [Sober](https://sober.vinegarhq.org), which runs Roblox's
Android client natively on Linux.

| | |
|---|---|
| Module | `modules/features/roblox.nix` |
| Aspects | `nixos.roblox`, `homeManager.roblox` |
| Hosts | `surface-laptop`, `tiki-rig` |
| Inputs | None (needs [flatpak](flatpak.md)) |
| Persists | `~/.var/app/org.vinegarhq.Sober` (login, settings and the downloaded Roblox client) |
| Secrets | None |

Sober is only published on Flathub (`org.vinegarhq.Sober`). It isn't in
nixpkgs, so this feature adds it to `services.flatpak.packages`. A host
that imports `roblox` must also import `flatpak`; without it, evaluation
fails because `services.flatpak.packages` doesn't exist.

It's separate from [gaming](gaming.md), which brings Steam and needs a
`/games` subvolume, so it can go on a host that doesn't game otherwise.

## First run

After the rebuild, `flatpak-managed-install` downloads Sober and its
runtimes in the background. Sober then appears in the launcher. On first
start it downloads the Roblox client itself, then asks you to log in.

## Caveats

- Sober is closed source, made by the Vinegar team, and isn't affiliated
  with Roblox. Roblox currently allows it, but that could change.
- Roblox Studio isn't included. It runs under Wine with Vinegar
  (`pkgs.vinegar`) if it's ever needed.
- On tiki-rig, Flatpak apps reach the NVIDIA GPU through the
  `org.freedesktop.Platform.GL.nvidia-<driver version>` extension, which
  Flatpak installs to match the running driver. After a driver update,
  Sober falls back to software rendering until the matching extension is
  installed: the next `flatpak-managed-install` run does it, or
  `flatpak update` does it now.

See [0040](../decisions/0040-roblox-sober-flatpak.md) for the
alternatives.
