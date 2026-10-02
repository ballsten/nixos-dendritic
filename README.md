# nixos-dendritic

Personal NixOS configuration using the Dendritic pattern (flake-parts,
import-tree and flake-file).

## Tasks

Enter the dev shell with `nix develop`, then run `just` to list recipes:

| Recipe | What it does |
|---|---|
| `just fmt` | Format all Nix files |
| `just check` | Regenerate `flake.nix` (must produce no diff), then `nix flake check` |
| `just build <host>` | Build a host's system closure without activating it |
| `just lock` | Regenerate `flake.nix` and lock added or removed inputs |
