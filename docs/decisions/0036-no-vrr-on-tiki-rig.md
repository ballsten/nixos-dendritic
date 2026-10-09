# 0036: No variable refresh rate on tiki-rig

- **Status:** Accepted, 2026-10-09
- **Issue:** None
- **PR:** None yet

## Context

`tiki-rig` turned variable refresh rate (VRR) on through an Umbriel window
rule for windows with the `game` content type. Umbriel applies the rule to
the output while the game has focus, so VRR switched on and off every time
focus moved into or out of the game: alt-tab, clicking a window on the
other monitor, or opening the Noctalia launcher.

The LG 27GL850 goes black for a moment each time VRR switches. While
playing Path of Exile, Umbriel's log showed a switch on DP-2 every few
seconds to minutes, each within milliseconds of a focus change, and a
blackout lined up with one of them.

## Decision

Remove the window rule. VRR stays off on both monitors, for games and the
desktop alike.

## Consequences

- No blackouts from VRR switching.
- Games run at a fixed 144 Hz. Frames that miss a refresh show judder or
  tearing that VRR would have smoothed out. At 144 Hz this is minor for the
  games played here.

## Alternatives considered

- **VRR always on for DP-2 (`output.DP-2.vrr = "always"`):** no switching,
  but the desktop panels flicker at low frame rates with VRR on, which is
  why the rule was limited to games in the first place.
- **The `fullscreen` VRR mode in the rule:** VRR would only apply to a
  fullscreen game, but it still switches whenever focus leaves the game,
  so the blackouts would remain.
