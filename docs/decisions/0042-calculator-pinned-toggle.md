# 0042: A pinned calculator, opened and closed with Mod+C

- **Status:** Accepted, 2026-10-27

## Context

A simple GUI calculator should be one key away and float above other
windows (#129). On `tiki-rig` it should sit in the bottom-right corner of
the left monitor.

Umbriel offers two ways to keep a window above the others:

- **Pinned windows** (`default_pinned`) float above the others on every
  workspace of their output. A window rule can also choose the output
  (`default_output`) and corner (`default_position`).
- **Scratchpads** hide and show a window with one key, and can start the
  app when empty (`spawn_when_empty`). But a scratchpad appears on the
  monitor under the pointer, and Umbriel clears pinning when a window
  enters one. Defining a named scratchpad also removes the implicit
  `default` one that the packaged `Mod+Space` bindings use.

Umbriel has no minimise.

## Decision

GNOME Calculator, opened pinned in the bottom-right corner by a window rule.
`Mod+C` runs a small script that closes the calculator if Umbriel lists it,
and starts it otherwise. `tiki-rig` adds a rule that opens it on DP-3.

## Consequences

- The calculator is always above other windows and always on the same
  monitor, wherever the pointer is.
- Closing it clears the number on screen. Settings stay until reboot.
- The packaged scratchpad bindings are untouched.
- The script matches on the app ID `org.gnome.Calculator`; if it changes,
  `Mod+C` only ever opens the calculator.

## Alternatives considered

- **A named scratchpad on `Mod+C`:** keeps the number on screen between
  toggles, but can't be pinned or kept on the left monitor, and needs the
  packaged `Mod+Space` bindings moved to a named scratchpad.
- **Qalculate (`qalculate-gtk`):** far more capable, but busier than a
  simple calculator.
- **KCalc:** brings in KDE libraries that nothing else here uses.
