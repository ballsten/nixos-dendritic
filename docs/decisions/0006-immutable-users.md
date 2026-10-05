# 0006: Declarative users, with passwords from sops

- **Status:** Accepted, 2026-10-02
- **Issue:** #11
- **PR:** #17

## Context

Until #17, `users.mutableUsers` was the default (`true`) and the login
password was set with `passwd`. That state lives in `/etc/shadow`, which
impermanence ([0016](0016-impermanence.md)) would wipe.

## Decision

- `users.mutableUsers = false` ([immutable-users](../features/immutable-users.md)).
- Each user's password hash is a sops secret with `neededForUsers`, set
  with `just set-password`.
- Root has no password.

## Consequences

- `passwd` changes don't survive a rebuild; passwords change through
  `just set-password` and a rebuild.
- A host that can't decrypt its secrets has no login password, so a
  mistake here can lock you out. #17's testing used `nixos-rebuild test`
  with a root shell kept open.
- `uid 1000` for ballsten is pinned (#42), so files on `/persist` keep
  their owner without depending on `/var/lib/nixos`.

## Alternatives considered

- **Keep `mutableUsers = true`:** simpler, but incompatible with a wiped
  root.
