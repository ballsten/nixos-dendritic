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
- `programs.noctalia` runs the shell as a systemd user service. Apps
  started from its launcher, dock or taskbar run as their own transient
  units (`shell.launch_apps_as_systemd_services`), named
  `app-<desktop-id>@<uuid>.service`. Without that they'd share
  `noctalia.service`'s cgroup, and a rebuild that restarts the service
  would kill them. Brave, for example, crashed on every rebuild: its main
  process moves to its own scope, but helper processes left behind were
  killed.
- kitty is configured with `programs.kitty`, because the packaged Umbriel
  config binds <kbd>Mod</kbd>+<kbd>Return</kbd> to it. It is slightly
  transparent (`background_opacity = 0.85`) with a little padding; its
  colours come from the [theme](theme.md) feature.

## Media keys

The packaged Umbriel config binds no `XF86*` keys, so this feature adds
them to `programs.umbriel.settings.keybinds`. Umbriel merges tables from
included files by key, so these sit alongside the packaged keybinds rather
than replacing them.

| Keys | Command |
|---|---|
| Volume up / down | `noctalia msg volume-up 5` / `volume-down 5` |
| Mute, mic mute | `noctalia msg volume-mute`, `mic-mute` |
| Brightness up / down | `noctalia msg brightness-up 5` / `brightness-down 5` |
| Play, Pause | `noctalia msg media toggle` |
| Stop, Next, Previous | `noctalia msg media stop`, `next`, `previous` |

Each key runs a Noctalia command rather than `wpctl`, `brightnessctl` or
`playerctl`, so Noctalia shows its on-screen display and no extra packages
are needed. Noctalia sets the backlight through logind's `SetBrightness`,
which works for the session's user without the `video` group.

Volume and brightness repeat while held; the others fire once. All of them
work on the lock screen (`allow_when_locked`). The bindings are generic, so
they apply to any keyboard on any host.

## Night light

Noctalia's night light warms the screen to 5000 K from sunset to sunrise,
and returns to 6500 K (neutral) during the day. It fades over an hour around
each change. It uses Umbriel's gamma control (`wlr-gamma-control`).

Sunset and sunrise are worked out from the location, which Noctalia looks
up from the IP address through noctalia.dev (`location.auto_locate`). This
keeps where we live out of this public repo, and surface-laptop follows
when travelling. The lookup needs a network connection; until it succeeds,
night light has no schedule to follow.

The control centre's Night Light button, or `noctalia msg
nightlight-toggle`, turns it off for the session. `nightlight-force-toggle`
holds the night temperature regardless of the time. Changes made in
Noctalia's settings aren't kept across reboots; the declared settings
apply again.

The old config used hyprsunset, which only works with Hyprland
([#88](https://github.com/ballsten/nixos-dendritic/issues/88)).

## Per-host settings

Display outputs and scaling are hardware-specific, so each host sets them in
its own `display.nix` through `home-manager.sharedModules`, for example
`programs.umbriel.settings.output.eDP-1.scale` on
[surface-laptop](../hosts/surface-laptop.md).
