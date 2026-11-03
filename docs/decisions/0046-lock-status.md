# 0046: Teams goes Away on lock, through our own `org.gnome.ScreenSaver`

- **Status:** Accepted, 2026-11-04
- **Issue:** #113
- **Supersedes:** the lock behaviour in
  [0034](0034-teams-idle-detection.md)

## Context

With the Idle Detection API allowed ([0034](0034-teams-idle-detection.md))
and Teams' "active outside of Teams" setting on, Teams in Brave never went
Away, even with nobody at the machine (#113).

Testing on `tiki-rig` with Brave 1.98.60 showed:

- Brave does get idle time from Umbriel's `ext-idle-notify-v1`. The Teams
  tab's `IdleDetector` reported `user=idle` about 60 s after the last
  input. (Brave 1.96, which #113 was written against, had no client for
  the protocol.)
- It never reported `screen=locked`. Chromium asks a ScreenSaver D-Bus
  service's `GetActive`, and Noctalia's `org.freedesktop.ScreenSaver`
  doesn't implement it.
- Given `idle` and `unlocked`, Teams stays Available for as long as that
  lasts. A prototype answering `GetActive` on `org.gnome.ScreenSaver` made
  the page report `screen=locked`, and Teams went Away.

0034 expected Teams to go Away on its own idle threshold and wanted it not
to change on lock. In practice that means it never goes Away.

## Decision

A `lock-status` feature runs a small user service that owns
`org.gnome.ScreenSaver`, answers `GetActive` and emits `ActiveChanged`
from logind's `LockedHint`. Teams goes Away when the screen locks: 5
minutes after the last input with Noctalia's idle lock, or at once on a
manual lock.

## Consequences

- Teams' status follows the lock screen, on every host.
- Any Chromium or Electron app that checks the lock gets the right
  answer, not only Teams.
- A small Python service of our own to maintain, until Noctalia
  implements `GetActive`.
- Brave has to start after the service, which it does when launched from
  the desktop.
- Other programs looking for `org.gnome.ScreenSaver` find a service that
  only has `GetActive` and `ActiveChanged`.

## Alternatives considered

- **Leave it, and document that Teams never goes Away:** no code, but
  Teams shows Available all night.
- **Wait for Noctalia to add `GetActive`:** the proper fix, with nothing of
  ours to maintain, but no date. The feature can go once it lands.
- **Noctalia's `ActiveChanged` signal as the source:** Noctalia already
  emits it on lock and unlock. It's a signal only, so a service started
  while locked couldn't know the state; `LockedHint` can be read at any
  time.
- **A Mutter `IdleMonitor` service** (an option in #113): only provides
  idle time, which Brave already has.
- **Turning off Teams' "active outside of Teams" setting:** Teams then goes
  Away whenever its tab loses input, the problem 0034 solved.
