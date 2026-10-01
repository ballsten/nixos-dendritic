# NixOS configuration (Dendritic pattern)

Personal NixOS configuration built on the Dendritic pattern using flake-parts
and import-tree. Andrew is the repository administrator; Claude proposes
changes through pull requests and Andrew reviews, tests and merges them.

## This repository is public

- Never commit secrets: passwords or password hashes, API tokens, Wi-Fi keys,
  VPN keys, private SSH/GPG keys, or anything similar.
- Anything sensitive goes through the secrets feature module (sops-nix or
  agenix, to be added). If a feature needs a secret and that module doesn't
  exist yet, stop and say so rather than working around it.

## Reference material

- Doc-Steve's dendritic guide is cloned at `~/src/dendritic-reference`.
  Read it for patterns and conventions. Adapt ideas to this repo; don't copy
  files wholesale.

## Architecture rules

- `flake.nix` stays minimal: inputs, `mkFlake`, and `import-tree ./modules`.
  No configuration logic goes in it.
- Every `.nix` file under `modules/` is a flake-parts module. Never place a
  plain NixOS or home-manager module there directly.
- One feature (aspect) per file. A feature publishes its parts from that one
  file into `flake.modules.nixos.<name>` and/or
  `flake.modules.homeManager.<name>`.
- Hosts live under `modules/hosts/<host>/` and compose features by name via
  `config.flake.modules.*`. Hosts never import feature files by path.
- import-tree ignores any path containing `/_`. Use this for
  `hardware-configuration.nix` and other non-flake-parts files, and import
  them explicitly from the host.
- Prefer existing nixpkgs and home-manager options. Only define custom
  options when a feature genuinely needs to be configurable.
- Once a formatter is configured, run `nix fmt` before every commit.

## Workflow

- Never commit or push to `main`. Use one branch per change:
  `feat/<name>`, `fix/<name>` or `chore/<name>`.
- Use conventional commit messages (`feat:`, `fix:`, `chore:`, `docs:`).
- Before opening a PR, run `nix flake check` and build every affected host:
  `nix build .#nixosConfigurations.<host>.config.system.build.toplevel`
- Never run `nixos-rebuild` (switch, test or boot) and never use `sudo`.
  Andrew applies changes to real machines.
- Open PRs with `gh pr create`, filling in the PR template. Never merge.
- Keep each PR to a single feature. If you notice something unrelated,
  note it in the PR description instead of fixing it.
- If a design choice is unclear, ask before implementing.

## Hosts

(Filled in as hosts are added.)
