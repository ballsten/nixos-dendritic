# desktop

The graphical session: the Umbriel compositor, the Noctalia shell and the
noctalia-greeter login screen, with PipeWire for audio.

| | |
|---|---|
| Module | `modules/features/desktop.nix` |
| Aspects | `nixos.desktop`, `homeManager.desktop` |
| Hosts | All, through `workstation` |
| Inputs | `umbriel` (home-manager module only) |
| Persists | `/var/lib/bluetooth` |
| Secrets | None |

## System side

- `programs.umbriel` installs the compositor from nixpkgs. Umbriel runs as a
  systemd user session that pulls in `graphical-session.target`, which
  starts the Noctalia user service.
- `programs.noctalia` with `recommendedServices` enables the services
  Noctalia's widgets use: NetworkManager, Bluetooth, UPower and
  power-profiles-daemon.
- `services.displayManager.noctalia-greeter` is the login screen.
- PipeWire with ALSA and PulseAudio compatibility, and rtkit.
- The default font packages.

Bluetooth pairings are kept in `/var/lib/bluetooth`, which is persisted.

## User side

Every home-manager user on the host gets `homeManager.desktop` through
`home-manager.sharedModules`.

- `programs.umbriel` (from the `umbriel` flake's home-manager module)
  writes `~/.config/umbriel/config.toml`. `package = null` uses the
  compositor from nixpkgs, because the flake's own build isn't in the
  binary cache. The generated config includes the packaged default config
  first, so its keybinds and rules are kept and settings here override
  them.
- `programs.noctalia` runs the shell as a systemd user service.
- kitty is configured with `programs.kitty`, because the packaged Umbriel
  config binds <kbd>Mod</kbd>+<kbd>Return</kbd> to it. It is slightly
  transparent (`background_opacity = 0.9`) with a little padding; its
  colours come from the [theme](theme.md) feature.

## Per-host settings

Display outputs and scaling are hardware-specific, so each host sets them in
its own `display.nix` through `home-manager.sharedModules`, for example
`programs.umbriel.settings.output.eDP-1.scale` on
[surface-laptop](../hosts/surface-laptop.md).
