# 0047: LibreWolf as the browser, with a Chromium only for Teams

- **Status:** Accepted, 2026-11-07
- **Issue:** #139
- **Supersedes:** [0034](0034-teams-idle-detection.md), and the Brave
  option in [0031](0031-prun-feature.md)

## Context

nixpkgs dropped Brave on 2026-11-03 (NixOS/nixpkgs#582838, backported to
26.05), because none of its maintainers were committers who could merge
security updates promptly. The next input update would have failed to
evaluate. Brave held our extensions (Bitwarden, the [prun](../features/prun.md)
extensions) and Teams, whose presence needs the Idle Detection API
(0034, [0046](0046-lock-status.md)).

What we wanted from the replacement, in order: privacy, then keeping Teams
presence working. Those pull apart. Firefox-based browsers are the more
private and still run Manifest V2 extensions, so the full uBlock Origin.
Only Chromium-based browsers have the Idle Detection API.

## Decision

- [librewolf](../features/librewolf.md) is the main browser and the
  default for links. Extensions are force-installed from addons.mozilla.org
  through a `librewolf.extensions` option, which replaces
  `brave.extensions` (Chrome Web Store IDs) for other features. It keeps
  LibreWolf's defaults, except that cookies are kept between restarts, and
  `resistFingerprinting` is swapped for Fingerprinting Protection with
  every target but the colour scheme, so sites can follow the dark theme.
- [teams](../features/teams.md) runs Teams in a Chromium app window. Its
  policies block every site except Teams, the Microsoft sign-in and
  Microsoft 365, turn off Google's background services and extensions,
  and allow Idle Detection for the Teams origins only. Chromium isn't on
  `PATH`, and Teams has a `Work` workspace on `Mod+Alt+W`.

## Consequences

- Everyday browsing gets LibreWolf's privacy settings and the full uBlock
  Origin.
- Teams presence works as before: the same Idle Detection policy as
  0034, now in Chromium, and the lock reporting from 0046.
- Two browsers to maintain, each with its own profile.
- A link in Teams to a site outside the allowlist is blocked rather than
  opened elsewhere; it has to be copied into LibreWolf. Chromium's
  `BrowserSwitcher` policies, which could hand it over, are only
  documented for Windows and macOS.
- The Microsoft allowlist is a guess at what Teams needs. A Microsoft page
  that turns up blocked means adding its domain.
- Brave's profile isn't carried over: bookmarks and logins are moved by
  hand, or started fresh.

## Alternatives considered

- **Chromium for everything:** keeps one browser and Teams presence, but
  Chromium contacts Google more than LibreWolf even with policies, and
  has only uBlock Origin Lite.
- **LibreWolf or Firefox for everything:** most private and simplest, but
  Teams would go Away whenever its tab lost input, the problem 0034
  solved.
- **Brave from a community flake:** fewest changes, but a third-party
  input for the security updates that nixpkgs dropped it over.
- **ungoogled-chromium for Teams:** removes more Google traffic in the
  code, but has thinner nixpkgs maintenance. With every other site blocked,
  the policies already leave Google little to see.
- **LibreWolf's full defaults (clear cookies on exit):** most private, but
  every site signs out on each restart.
- **Bitwarden in the Teams Chromium:** easier Microsoft sign-in, but an
  extension in a browser kept free of them; sign-in is rare once the
  profile is persisted.
