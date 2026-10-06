# theme

Desktop styling with Noctalia's own theming: dark colours generated from the
wallpaper, applied to the shell and, through Noctalia's templates, to other
apps.

| | |
|---|---|
| Module | `modules/features/theme.nix` |
| Aspects | `nixos.theme`, `homeManager.theme` |
| Hosts | All, through `workstation` |
| Inputs | None |
| Persists | Nothing (see below) |
| Secrets | None |

Every home-manager user on the host gets it through
`home-manager.sharedModules`. It sets options from the
[desktop](desktop.md) feature's `programs.noctalia` and `programs.umbriel`.
Why Noctalia rather than Stylix is in
[0021](../decisions/0021-noctalia-theming.md).

## Wallpapers

Wallpapers live in `assets/wallpapers/` and are copied into the store. Pick
one from Noctalia's wallpaper picker; the colours are regenerated from it.

To add one, commit the image to that folder. The repo is public, so only
add images that may be published. `wallpaper.default.path` in the module
sets the one shown at boot, currently `astronaut-and-robot.jpg`.

## Colours

`theme.source = "wallpaper"` generates a palette from the current wallpaper,
in dark mode. `theme.wallpaper_scheme` controls how; it's set to
`m3-content`, Noctalia's default. Others include `m3-tonal-spot`,
`vibrant` and `muted`. To preview a scheme without changing anything:

```sh
noctalia theme <image> --dark --scheme vibrant
```

## Templates

Noctalia renders a template per app into a colours file, then a hook adds
an include for it to the app's main config. home-manager links those
configs read-only, so each include is declared in the module instead, and
the hook finds it already present.

| App | Generated file | Include declared in |
|---|---|---|
| Umbriel | `~/.config/umbriel/noctalia.toml` | `programs.umbriel.settings.include.optional` |
| kitty | `~/.config/kitty/themes/noctalia.conf` | `programs.kitty.extraConfig` |
| GTK 3 | `~/.config/gtk-3.0/noctalia.css` | `gtk.gtk3.extraCss` |
| GTK 4 | `~/.config/gtk-4.0/noctalia.css` | `gtk.gtk4.extraCss` |

To add an app, add its ID to `theme.templates.builtin_ids` and declare its
include. `noctalia theme --list-templates` lists the built-in templates.

## GTK

GTK apps are dark, with the theme `adw-gtk3-dark` (from `adw-gtk3`) and
`color-scheme` set to `prefer-dark`. adw-gtk3 makes GTK 3 apps look like
libadwaita ones and uses the same named colours, so one `noctalia.css` per
GTK version restyles both. GTK 4 gets no theme of its own; libadwaita apps
pick up the colours from `noctalia.css` directly.

The GTK templates' hook also writes `gtk-theme` and `color-scheme` to dconf.
It sets the same values home-manager does, so nothing changes. Running GTK
apps may need restarting to show new colours after the wallpaper changes.

## Fonts and icons

| Role | Choice | Set through |
|---|---|---|
| UI | Inter | fontconfig `sansSerif`, `gtk.font` (Inter 11) |
| Monospace | FiraCode Nerd Font | fontconfig `monospace`, `programs.kitty.font` |
| App icons | Tela-dark | `gtk.iconTheme` |

Noctalia has no font setting; it asks fontconfig for the default
sans-serif, so the fontconfig default sets its font. GTK reads its font
and icon theme from dconf and `settings.ini` instead, so those are set
separately. Noctalia's launcher and dock take the icon theme from the same
place. Noctalia's own bar and panel icons are bundled with it and don't
change.

The `tela-icon-theme` package installs all 15 colour variants (about
2.7 GB), so the module overrides its install step to build only the
standard colour: Tela, Tela-dark and Tela-light. Why these three were
chosen is in [0022](../decisions/0022-fonts-and-icons.md).

## Changes made at runtime

Choices made in Noctalia's settings, including the wallpaper picker, are
saved over the declared config and last until reboot. `/home` is wiped on
boot, so the declared settings come back. Nothing here is persisted on
purpose; to keep a change, set it in the module.
