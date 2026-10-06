# 0023: graphite-dark cursor at size 24

- **Status:** Accepted, 2026-10-07
- **Issue:** #63

## Context

No cursor theme was configured or installed. Umbriel fell back to wlroots'
built-in cursor, which only exists at 24 device pixels and can't be loaded
at the 48 that scale 2.0 needs, so on `surface-laptop` the cursor was about
a quarter of the intended area. The candidate themes were compared side by
side, using their real frames at the size they'd have on the Surface.

## Decision

The [theme](../features/theme.md) feature sets **graphite-dark** at
**size 24** for the login screen, Umbriel and GTK, from one value in the
module.

## Consequences

- The cursor is the size intended for 24 at scale 2.0, rather than the
  built-in fallback.
- graphite-dark has nothing larger than 48px, so it looks sharp up to size
  24 at scale 2.0, but anything larger is scaled up and soft. A bigger
  cursor later would mean a theme with larger images (Bibata and phinger
  go to 96px).
- Umbriel's setting decides `XCURSOR_THEME` and `XCURSOR_SIZE` for apps, so
  it and `home.pointerCursor` must stay in step; both read the same value.

## Alternatives considered

- **Adwaita** (GNOME's default): fixes the size problem with no new
  package, but keeps the stock look.
- **Bibata** (Modern or Original, Classic or Ice) and **phinger**: images
  up to 96px, so they'd stay sharp at larger sizes.
- **capitaine**, **Volantes** and **Simp1e**: other styles, with largest
  images of 72px or less.
- **Size 32 or 48**: larger, but graphite-dark would be scaled up.
