# 0013: Passwordless sudo for ballsten

- **Status:** Accepted, 2026-10-03
- **PR:** #34

## Context

Typing the password for every `sudo` on personal machines was friction
(#16 todo).

## Decision

A `security.sudo.extraRules` entry in the `ballsten` user aspect lets
ballsten run anything with `sudo` without a password. It applies to that
user, not the whole `wheel` group.

## Consequences

- Anything running as ballsten can get root without a prompt.
- The sops password is still needed to log in.
- Claude Code is denied `sudo` by its own settings and `CLAUDE.md`, not by
  a password prompt.

## Alternatives considered

- **`security.sudo.wheelNeedsPassword = false`:** the same for every
  `wheel` member.
- **Keep the prompt.**
