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
| `just admin-key` | Create your admin age key if missing and print its public key |
| `just host-key [target]` | Print a host's age recipient (`local`, or a hostname via `ssh-keyscan`) |
| `just enrol-host <name> [target]` | Add a host as a secrets recipient and re-encrypt |
| `just secrets-edit` | Edit `secrets/secrets.yaml` |

See [docs/secrets.md](docs/secrets.md) for secrets management.
