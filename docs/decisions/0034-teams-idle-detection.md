# 0034: Teams gets the Idle Detection API through a Brave policy

- **Status:** Accepted, 2026-10-09
- **Issue:** #108
- **PR:** None yet

## Context

Teams on the web turned Away whenever its tab stopped getting input, even
while we worked in other windows. Teams can follow the system idle state
through the Idle Detection API, but Brave blocks that API on every site by
default.

## Decision

Brave's managed policy sets `IdleDetectionAllowedForUrls` to the Teams
origins (`teams.microsoft.com`, `teams.cloud.microsoft`), in `brave.nix`.

## Consequences

- Teams can read system idle once its "active outside of Teams" setting is
  turned on. No other site can.
- The permission is declared, and survives a lost or reset Brave profile.
- Brave can't tell when the session is locked (Noctalia's
  `org.freedesktop.ScreenSaver` lacks `GetActive`), so Teams goes Away on
  its idle threshold rather than on lock.

## Alternatives considered

- **Allow the permission by hand in Brave's site settings:** works, but
  isn't declared and is lost with the profile.
- **A separate `teams` feature adding the URLs through a new `brave`
  option:** more structure than one policy entry needs while Teams has
  nothing else to configure.
- **`teams-for-linux`:** a separate app with its own idle handling, to
  replace a browser tab that only lacked one permission.
- **Allow idle detection for every site (`DefaultIdleDetectionSetting`):**
  any site could then see when we're at the machine.
