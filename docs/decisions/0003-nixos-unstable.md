# 0003: Follow nixos-unstable

- **Status:** Accepted, 2026-10-02
- **PR:** #4

## Context

nixpkgs can be followed on a stable release branch (such as `nixos-25.11`)
or on `nixos-unstable`.

## Decision

Follow `github:nixos/nixpkgs/nixos-unstable`, declared once in
`modules/flake/nixpkgs.nix`, to have current packages on personal
machines. home-manager follows its master branch to match.

## Consequences

- Recent packages, such as the Umbriel and Noctalia desktop, are available
  from nixpkgs without extra inputs.
- Updates can bring breaking option changes, so the release notes are
  worth checking in each `chore/update-inputs` PR
  ([Update flake inputs](../howto/update-inputs.md)).
- A nixpkgs update usually changes the linux-surface kernel, which takes
  about two hours to build ([0011](0011-linux-surface-kernel.md)).

## Alternatives considered

- **A stable release:** fewer breaking changes, but older packages and a
  migration every six months.
