# 0024: Fixed terminal hues, blended with the wallpaper

- **Status:** Accepted, 2026-10-07
- **Issue:** #72

## Context

kitty's ANSI colours came from Noctalia's built-in kitty template, which
fills green, yellow, blue, magenta and cyan with the palette's accent
colours (`primary`, `secondary`, `tertiary` and two dimmed variants). Every
scheme Noctalia offers goes through the same mapping. With the default
wallpaper and `m3-content`, those five were pinkish greys of similar
lightness: green matched magenta, yellow matched cyan, and every bright
colour matched its normal one. The candidates were compared side by side,
with palettes Noctalia generated from both wallpapers.

## Decision

The [theme](../features/theme.md) feature declares six fixed hues as
Noctalia custom colours, with `blend` on, and renders kitty's colours from
its own template. ANSI 1–6 use each colour's main role, and 9–14 its
lighter on-container role. Everything else in the template matches the
built-in one.

## Consequences

- The six colours are distinct on every wallpaper, and lightness is
  managed by Noctalia for the dark background.
- Blending turns each hue up to 15° towards the wallpaper. On the default
  wallpaper red leans pink, and red and magenta are the closest pair.
- The module now maintains a copy of Noctalia's kitty template. If a
  Noctalia update changes the built-in one (new keys, renamed tokens), the
  copy has to be updated by hand.
- The 85% background opacity is unchanged.

## Alternatives considered

- **A different scheme** (`vibrant`, `faithful`): more saturated accents,
  but still only one or two hues, with no real yellow or magenta. It would
  also recolour the whole desktop.
- **The same hues without blending:** identical on every wallpaper, but not
  tinted towards it.
- **Fixed colours written straight into kitty's config:** simplest, but
  their lightness wouldn't follow the theme, and they'd ignore the
  wallpaper entirely.
- **Raising the background opacity:** improves contrast but doesn't make
  the colours any more distinct.
