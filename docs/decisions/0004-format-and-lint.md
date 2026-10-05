# 0004: nixfmt-tree, statix and deadnix, enforced in CI

- **Status:** Accepted, 2026-10-02
- **Issues:** #27, #30
- **PRs:** #4, #28, #31

## Context

Formatting and lint findings were otherwise left to review.

## Decision

- **Formatter:** `pkgs.nixfmt-tree` (RFC-style nixfmt over the whole tree)
  as the flake formatter. Bare `nixfmt` can't format a directory.
- **Linters:** statix and deadnix for Nix, actionlint (with shellcheck) for
  GitHub workflows.
- **Enforced:** all of them run as flake checks, so `nix flake check` and
  CI fail on findings. `just lint` runs the same tools on the working tree.
- **Every statix rule is enabled.** #28 first disabled `empty_pattern` and
  `repeated_keys` to avoid rewriting code; Andrew asked for the rules on and
  the code fixed instead (#30, #31). Only generated files are ignored, with
  the reason in `statix.toml`.

## Consequences

- Modules that take no arguments start with `_:`, and repeated attribute
  prefixes are nested.
- `_hardware-configuration.nix` is ignored, since edits would be lost when
  it is regenerated.
- The same mechanism later carried `check-docs` (#55).

## Alternatives considered

- **Provide the tools without enforcing them in CI:** offered in #27;
  Andrew chose CI enforcement.
- **Disable rules that flag the existing style:** done briefly in #28, then
  reverted in #31.
