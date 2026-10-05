# 0009: A complete dev shell, loaded by direnv

- **Status:** Accepted, 2026-10-02
- **Issue:** #27
- **PR:** #28

## Context

Tools needed to work on the repo came from the user profile, or were
fetched ad hoc with `nix run nixpkgs#…`.

## Decision

- `devShells.default` (`modules/flake/devshell.nix`) has every tool the
  repo's tasks need: just, the sops and age tools, linters, closure tools
  (`nvd`, `nix-tree`, `nix-diff`, `nix-output-monitor`) and `nurl`.
- direnv with nix-direnv loads it on entering the repo (`.envrc`), through
  the [direnv](../features/direnv.md) feature.
- A missing tool is added to the dev shell, not fetched with `nix run`.
- `gh` and `claude-code` stay in home-manager and out of the dev shell,
  because a dev shell copy would shadow the wrapper that gives them their
  tokens ([0008](0008-wrap-cli-secrets.md)).

## Consequences

- Claude Code started inside the repo inherits the dev shell, so its
  commands have the same tools.
- PRs include an `nvd diff` per affected host.
- The dev shell needs nothing unfree.

## Alternatives considered

- **`claude-code` only in the dev shell** (the #16 todo): Claude would
  only run inside this repo, and the wrapper couldn't apply. Andrew chose
  home-manager.
