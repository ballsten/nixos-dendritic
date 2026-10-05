# nixos-dendritic

Personal NixOS configuration using the Dendritic pattern (flake-parts,
import-tree and flake-file).

## Tasks

The dev shell loads automatically through direnv: run `direnv allow` once in
the repo (or use `nix develop` without direnv). Then run `just` to list
recipes by group:

| Group | Recipe | What it does |
|---|---|---|
| nix | `just fmt` | Format all Nix files |
| | `just lint` | Lint Nix files (statix, deadnix) and GitHub workflows (actionlint), and check every feature, host and user has a docs page (check-docs); also run by `nix flake check` |
| | `just check` | Regenerate `flake.nix` (must produce no diff), then `nix flake check` |
| | `just lock` | Regenerate `flake.nix` and lock added or removed inputs |
| | `just build <host>` | Build a host's system closure without activating it |
| rebuild | `just test [host]` | Activate a host's configuration now, without adding a boot entry (default: this machine) |
| | `just switch [host]` | Activate a host's configuration now and make it the boot default (default: this machine) |
| | `just boot [host]` | Make a host's configuration the boot default without activating it (default: this machine) |
| keys | `just admin-key` | Create your admin age key if missing and print its public key |
| | `just host-key [target]` | Print a host's age recipient (`local`, or a hostname via `ssh-keyscan`) |
| | `just enrol-host <name> [target]` | Add a host as a secrets recipient and re-encrypt |
| | `just tpm-enroll` | Bind this machine's root LUKS volume to its TPM, replacing any old binding |
| secrets | `just secrets-edit` | Edit `secrets/secrets.yaml` |
| | `just set-password [user]` | Set a user's login password (default `ballsten`) |
| | `just set-wifi [network]` | Set a Wi-Fi network's SSID and PSK (default `home`) |
| | `just set-token <service> [user]` | Set an API token (`github`); reads stdin if piped |
| | `just set-ssh-key [key] [user]` | Store a user's SSH private key (default `~/.ssh/id_ed25519`) |

## Documentation

[docs/](docs/README.md) has the full documentation, starting with the
[architecture](docs/architecture.md). Commonly needed pages:

- [Secrets](docs/features/secrets.md): secrets management.
- [Impermanence](docs/features/impermanence.md): what survives a reboot, and
  how to install a host.
- [Secure Boot](docs/features/secure-boot.md): Secure Boot keys, TPM unlock
  and recovery.
