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
- **Fira Code** as the monospace font, for kitty and the default
  monospace.
- **Tela-dark** as the icon theme, built with only its standard colour.

## Consequences

- Fira Code has no Nerd Font glyphs, so prompts or TUIs that use them
  show boxes or fall back to another font. None do yet.
- Tela-dark adds about 220 MiB, including the Adwaita and Breeze themes it
  falls back to. Building every colour variant would be about 2.7 GB.
- The Tela override copies the package's install step, so it needs
  checking if the package's install step changes.

## Alternatives considered

- **UI font:** Adwaita Sans (GNOME's default, based on Inter), Noto Sans
  (widest script coverage), or keeping DejaVu Sans.
- **Monospace:** JetBrains Mono, with or without Nerd Font glyphs; Adwaita
  Mono; or keeping DejaVu Sans Mono.
- **Icons:** Papirus-Dark (widest coverage), MoreWaita (Adwaita style for
  more apps), or keeping Adwaita.
