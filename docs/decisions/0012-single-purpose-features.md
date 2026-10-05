# 0012: Single-purpose features, composed by workstation

- **Status:** Accepted, 2026-10-03
- **Issue:** #8
- **PR:** #35

## Context

`workstation` started as one module with Nix settings, NetworkManager,
home-manager, SSH and locale together. `tiki-rig` (#9) will share most of
`surface-laptop`'s setup.

## Decision

One feature per file, each doing one thing. `workstation` only imports
features and has no settings of its own. Hosts import `workstation` plus
their users, and keep hardware-specific settings (and the hostname and
time zone) in their own directory. Gaming is a separate `gaming` aspect
that only `tiki-rig` imports, never part of `workstation`.

## Consequences

- A host that needs less (a server, say) can import single features
  instead of `workstation`.
- Each feature has its own docs page, checked by `check-docs`.
- Dependencies between features aren't expressed: `wifi` needs
  `networkmanager` but doesn't import it, and works because `workstation`
  imports both.

## Alternatives considered

- **One `workstation` module with everything:** fewer files, but against
  the one-feature-per-file rule, and hosts can't pick parts of it.
