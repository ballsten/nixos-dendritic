# 0051: LibreWolf tells every site the real time zone

- **Status:** Accepted, 2026-11-16

## Context

LibreWolf's Fingerprinting Protection has every target switched on
except `CSSPrefersColorScheme`. One of those targets, `JSDateTimeUTC`,
tells pages the time zone is UTC. Sites that show times in the user's
own zone, such as Prosperous Universe (PrUn), then show them in UTC.

## Decision

`privacy.fingerprintingProtection.overrides` also turns off
`JSDateTimeUTC`, for every site. The other fingerprinting protections
stay on.

## Consequences

- PrUn and other sites show local times, as in Firefox.
- Every site can read the time zone. That makes the browser a little
  easier to fingerprint, since it narrows down where the user is.

## Alternatives considered

- **Only for PrUn:** `privacy.fingerprintingProtection.granularOverrides`
  can turn the target off for one domain, which the prun feature could
  add. Every other site would still see UTC, but each site that needs the
  time zone would need adding. The real time zone everywhere was
  preferred.
- **`resistFingerprinting` back on:** it always reports UTC, so it
  doesn't help.
