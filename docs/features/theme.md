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
add images that may be published. Set `wallpaper.default.path` in the
module to one of them to make it the default; until then the default is
the wallpaper that ships with Noctalia.

## Colours

`theme.source = "wallpaper"` generates a palette from the current wallpaper,
in dark mode. `theme.wallpaper_scheme` (unset, so Noctalia's default)
controls how: `m3-tonal-spot`, `vibrant`, `muted` and others. To preview a
scheme without changing anything:

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

To add an app, add its ID to `theme.templates.builtin_ids` and declare its
include. `noctalia theme --list-templates` lists the built-in templates.

## Changes made at runtime

Choices made in Noctalia's settings, including the wallpaper picker, are
saved over the declared config and last until reboot. `/home` is wiped on
boot, so the declared settings come back. Nothing here is persisted on
purpose; to keep a change, set it in the module.
