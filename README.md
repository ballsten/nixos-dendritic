# nixos-dendritic

Personal NixOS configuration using the Dendritic pattern (flake-parts,
import-tree and flake-file).

## Tasks

Enter the dev shell with `nix develop`, then run `just` to list recipes by
group:

| Group | Recipe | What it does |
|---|---|---|
| nix | `just fmt` | Format all Nix files |
| | `just check` | Regenerate `flake.nix` (must produce no diff), then `nix flake check` |
| | `just lock` | Regenerate `flake.nix` and lock added or removed inputs |
| | `just build <host>` | Build a host's system closure without activating it |
| keys | `just admin-key` | Create your admin age key if missing and print its public key |
| | `just host-key [target]` | Print a host's age recipient (`local`, or a hostname via `ssh-keyscan`) |
| | `just enrol-host <name> [target]` | Add a host as a secrets recipient and re-encrypt |
| secrets | `just secrets-edit` | Edit `secrets/secrets.yaml` |
| | `just set-password [user]` | Set a user's login password (default `ballsten`) |
| | `just set-wifi [network]` | Set a Wi-Fi network's SSID and PSK (default `home`) |
| | `just set-token <service> [user]` | Set an API token (`github`); reads stdin if piped |

See [docs/secrets.md](docs/secrets.md) for secrets management.
