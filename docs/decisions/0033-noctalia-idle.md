# 0033: Noctalia handles idle lock and screen-off

- **Status:** Accepted, 2026-10-09
- **Issue:** #102
- **PR:** None yet

## Context

The desktop had no idle handling, so an unattended machine stayed
unlocked. We want it to lock after 5 minutes idle and the monitors to turn
off later, on both hosts. Video and games shouldn't trigger either. The
lock must be Noctalia's own lock screen, the one
<kbd>Mod</kbd>+<kbd>Shift</kbd>+<kbd>L</kbd> shows.

## Decision

Use Noctalia's built-in idle behaviours (`idle.behavior` in
`programs.noctalia.settings`): `lock` at 5 minutes, and `screen-off` 5
minutes after any lock (`locked_timeout`). Lock-before-suspend stays on
Noctalia's default (`lockscreen.lock_before_suspend`).

## Consequences

- No extra daemon or user service. Idle settings sit in the `desktop`
  feature next to the rest of Noctalia's.
- Noctalia already serves `org.freedesktop.ScreenSaver` and respects
  Wayland idle inhibitors, so apps that inhibit idle hold both behaviours
  off.
- Idle handling stops whenever the Noctalia service isn't running, for
  example while it restarts on a rebuild.
- Timeouts depend on Noctalia's timer semantics: it restarts its timers
  on lock, which is why `screen-off` uses `locked_timeout`.

## Alternatives considered

- **swayidle or hypridle calling `noctalia msg session lock`:** a second
  idle client on the same protocol. It adds a package and a user service,
  and its inhibitor handling would have to match Noctalia's.
- **Lock only, screen-off later:** leaves the monitors on all night;
  screen-off is a one-entry addition.
- **Bind `Mod+L` to lock (as the issue first proposed):** replaces the
  packaged vim-style focus-right key. `Mod+Shift+L` was unused.
