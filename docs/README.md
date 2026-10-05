# Documentation

Reference for maintaining this NixOS configuration. The rules for changing
it are in [`CLAUDE.md`](../CLAUDE.md); these pages explain how it works and
why.

## Start here

- [Architecture](architecture.md): how flake-parts, import-tree and
  flake-file fit together, and how a host is composed from features.

## Features

One page per feature in `modules/features/`, named after it.

- [impermanence](features/impermanence.md): what survives a reboot, and how
  to install a host.
- [secrets](features/secrets.md): sops-nix, keys, and wrapping tools with
  their tokens.
- [secure-boot](features/secure-boot.md): Secure Boot keys, TPM unlock and
  recovery.

## Layout

| Folder | Contents |
|---|---|
| `features/` | One page per `modules/features/<name>.nix` |
| `hosts/` | One page per `modules/hosts/<host>/` |
| `users/` | One page per `modules/users/<user>/` |
| `howto/` | Step-by-step guides for common tasks |
| `decisions/` | Records of design decisions, numbered `NNNN-<slug>.md` |

So far only `features/` has pages; the other folders are added as #52
progresses.
