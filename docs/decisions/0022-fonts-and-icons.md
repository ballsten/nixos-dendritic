# 0022: Inter, Fira Code and Tela-dark

- **Status:** Accepted, 2026-10-07
- **Issue:** #61

## Context

The desktop used NixOS's default fonts (DejaVu Sans and DejaVu Sans Mono)
and the Adwaita icons. Adwaita has icons for few apps beyond GNOME's own,
so most apps showed their own icons in mixed styles. The candidates were
compared side by side, rendered from the nixpkgs font files and icons.

## Decision

The [theme](../features/theme.md) feature sets:

- **Inter** as the UI font, for Noctalia, GTK apps and the default
  sans-serif.
- **Fira Code**, in its Nerd Font build (`FiraCode Nerd Font`), as the
  monospace font, for kitty and the default monospace. The Nerd Font build
  adds icon glyphs for prompts and TUIs.
- **Tela-dark** as the icon theme, built with only its standard colour.

## Consequences

- The Nerd Font build is about 47 MiB, against 0.3 MiB for plain Fira
  Code, since it ships its own copy of every weight in three spacing
  variants.
- Tela-dark adds about 220 MiB, including the Adwaita and Breeze themes it
  falls back to. Building every colour variant would be about 2.7 GB.
- The Tela override copies the package's install step, so it needs
  checking if the package's install step changes.

## Alternatives considered

- **UI font:** Adwaita Sans (GNOME's default, based on Inter), Noto Sans
  (widest script coverage), or keeping DejaVu Sans.
- **Monospace:** plain Fira Code (no icon glyphs); JetBrains Mono, with
  or without Nerd Font glyphs; Adwaita Mono; or keeping DejaVu Sans Mono.
- **Icons:** Papirus-Dark (widest coverage), MoreWaita (Adwaita style for
  more apps), or keeping Adwaita.
