# 0051: Mouse wheel left-clicks in Path of Exile, through input-remapper

- **Status:** Accepted, 2026-11-13

## Context

On Windows, PoE players use XMouseButtonControl to make the mouse wheel
left-click while the game has focus: holding Ctrl and rolling the wheel
over the inventory moves items one per notch, with far less clicking.
tiki-rig runs the game through Proton under Umbriel, on Wayland.

Two parts are needed: turning wheel notches into clicks, and doing it only
while the game has focus, so the wheel scrolls everywhere else.

Umbriel's keybinds can bind the wheel, but only to compositor actions or
commands; it can't synthesise a click.

## Decision

The [poe-wheel-click](../features/poe-wheel-click.md) feature runs
input-remapper's daemon with a preset that maps the wheel to `BTN_LEFT`.
A user service follows Umbriel's window event stream and starts the preset
while Path of Exile has keyboard focus and stops it otherwise. tiki-rig
imports the feature directly and names its mouse with
`poeWheelClick.device`.

## Consequences

- The remap is at the evdev level, so the game sees an ordinary click.
- Switching into the game turns it on after `input-remapper-control`
  runs, a fraction of a second.
- input-remapper holds the wheel as a pressed button until it stops
  turning, so each notch is its own click only while notches are further
  apart than `release_timeout` (10 ms) plus a check interval.
- The input-remapper daemon accepts commands over D-Bus from any local
  user.

## Alternatives considered

- **evsieve or a small python-evdev script:** could emit an exact
  press and release per notch, but means writing and maintaining the
  grabbing, toggling and pass-through that input-remapper already has.
- **keyd:** remaps keys and mouse buttons, but not the wheel.
- **A keybind toggling the remap by hand:** simpler, but easy to leave on
  and lose scrolling elsewhere.
- **A remap that's always on:** the wheel would never scroll.
