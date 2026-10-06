# 0021: Desktop styling with Noctalia, coloured from the wallpaper

- **Status:** Accepted, 2026-10-06
- **Issue:** #61

## Context

The desktop ([0014](0014-noctalia-desktop.md)) used Noctalia's default
colours, with nothing applied to Umbriel or other apps. Styling should be
declared in the repo like everything else.

## Decision

The [theme](../features/theme.md) feature styles the desktop with
Noctalia's own theming:

- **Colours come from the wallpaper**, in dark mode.
- **Noctalia's built-in templates** apply them to other apps, starting
  with Umbriel. Each app's include for its generated colours is declared
  in home-manager, so the template hooks never edit a read-only config.
- **Wallpapers are kept in the repo** (`assets/wallpapers/`) and picked
  by hand in Noctalia. A choice lasts until reboot.

## Consequences

- No new flake input.
- The exact colours are computed at runtime from the image, so they aren't
  written down anywhere in the repo, but the same image always gives the
  same palette.
- Each further app is one template ID plus one declared include.
- Images in a public repo must be ones that may be published, and they
  make the repo bigger.

## Alternatives considered

- **Stylix:** broader home-manager coverage from one base16 scheme, but it
  has no support for Umbriel, and it would compete with Noctalia's
  templates for the same files.
- **A fixed palette** (a named scheme or one defined in the repo): fully
  written down, but the desktop wouldn't follow the wallpaper.
- **Automatic rotation** (`wallpaper.automation`): possible later; manual
  picking was preferred.
- **Wallpapers outside the repo** under `/persist`: no size cost, but not
  reproducible from the repo.
