# 0002: The Dendritic pattern with flake-file

- **Status:** Accepted, 2026-10-02
- **PRs:** #4, #5

## Context

The previous configuration (`~/repos/nixos-config`) was a conventional
flake. This one was started from scratch, following Doc-Steve's Dendritic
guide (cloned at `~/repos/dendritic-reference`).

## Decision

Build the configuration on the Dendritic pattern:

- flake-parts, with every file under `modules/` a flake-parts module;
- import-tree to load every file, skipping `/_` paths;
- features published as `flake.modules.<class>.<name>` and composed by
  hosts by name;
- flake-file to generate `flake.nix`, so each flake input is declared with
  `flake-file.inputs` in the module that uses it.

Reasons:

- **Learning:** trying the pattern on a real configuration.
- **Inputs next to their use:** a feature's input, its NixOS config and its
  home-manager config sit in one file, and removing the file removes all
  three.

## Consequences

- `flake.nix` is generated and never edited by hand. `nix flake check`
  fails if it is stale (`check-flake-file`).
- Adding a file is enough to wire it in; there are no import lists to
  maintain.
- Hosts compose features by name, and never import files by path (except
  their own `_` files).
- Files have two levels of module arguments, which is easy to get wrong
  (see [Architecture](../architecture.md#two-levels-of-module-arguments)).

## Alternatives considered

- **A conventional flake** with hand-written `flake.nix` and import lists,
  as in the previous configuration.
