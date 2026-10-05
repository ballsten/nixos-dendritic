# 0010: Allow unfree packages by name

- **Status:** Accepted, 2026-10-02
- **Issues:** #27, #29
- **PR:** #32

## Context

`workstation` set `nixpkgs.config.allowUnfree = true`, allowing every
unfree package on every host. #27 decided to limit unfree to packages that
are explicitly allowed.

## Decision

The [unfree](../features/unfree.md) feature defines `unfree.packages`, a
list option that merges across modules, and builds
`allowUnfreePredicate` from it. Each feature adds the names it needs in its
own file, next to the package. `allowUnfree` is never set.

A custom option is used because `allowUnfreePredicate` is a function, and
only one module can define it.

## Consequences

- An unlisted unfree package fails evaluation, naming the package.
- `gaming` can allow Steam without `workstation` naming it.
- home-manager packages are covered too (`useGlobalPkgs`), with their
  names set on the matching NixOS aspect.
- Unfree firmware would need listing in the host's hardware config.

## Alternatives considered

- **One predicate in `workstation` listing every name:** simpler, but
  gaming packages would be named in `workstation`.
