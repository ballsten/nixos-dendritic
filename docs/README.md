# Documentation

Reference for maintaining this NixOS configuration. The rules for changing
it are in [`CLAUDE.md`](../CLAUDE.md); these pages explain how it works and
why.

## Start here

- [Architecture](architecture.md): how flake-parts, import-tree and
  flake-file fit together, and how a host is composed from features.

## Features

One page per feature in `modules/features/`, named after it.

| Feature | What it does |
|---|---|
| [brave](features/brave.md) | Brave browser with Bitwarden |
| [desktop](features/desktop.md) | Umbriel compositor, Noctalia shell, greeter and audio |
| [direnv](features/direnv.md) | Loads a repo's dev shell on `cd` |
| [home-manager](features/home-manager.md) | home-manager as a NixOS module |
| [immutable-users](features/immutable-users.md) | Declarative accounts and passwords |
| [impermanence](features/impermanence.md) | Wipes `/` and `/home` on boot |
| [lazygit](features/lazygit.md) | Terminal UI for git, with `lg` in fish |
| [locale](features/locale.md) | System locale |
| [networkmanager](features/networkmanager.md) | NetworkManager |
| [nix-settings](features/nix-settings.md) | Nix daemon settings, GC and store optimisation |
| [obsidian](features/obsidian.md) | Obsidian notes app |
| [secrets](features/secrets.md) | sops-nix, keys, and wrapping tools with their tokens |
| [secure-boot](features/secure-boot.md) | Secure Boot keys and TPM unlock |
| [ssh](features/ssh.md) | OpenSSH, the host key, and GitHub's host key |
| [tpm-unlock](features/tpm-unlock.md) | Unlocks the disk with the TPM |
| [unfree](features/unfree.md) | Allows unfree packages by name |
| [wifi](features/wifi.md) | Wi-Fi networks with keys from sops |
| [workstation](features/workstation.md) | The feature set every host imports |

## Hosts

| Host | Hardware |
|---|---|
| [surface-laptop](hosts/surface-laptop.md) | Microsoft Surface Pro (Intel) |

## Users

| User | |
|---|---|
| [ballsten](users/ballsten.md) | Andrew |

## How-to guides

| Guide | When |
|---|---|
| [Add a feature](howto/add-feature.md) | A new feature module, from branch to PR |
| [Add or change a flake input](howto/add-input.md) | A feature needs a new flake, or an input changes |
| [Allow an unfree package](howto/allow-unfree.md) | Evaluation fails with an unfree license |
| [Persist state](howto/persist-state.md) | A program loses its state on reboot |
| [Add a secret](howto/add-secret.md) | A feature needs a password, key or token |
| [Update flake inputs](howto/update-inputs.md) | A `chore/update-inputs` PR |
| [Add a host](howto/add-host.md) | A new machine, such as `tiki-rig` |
| [Install or reinstall a host](howto/install-host.md) | Wiping and installing a machine |
| [Turn on Secure Boot](howto/enable-secure-boot.md) | An installed host with Secure Boot off |
| [Enrol the TPM](howto/enroll-tpm.md) | After install, or when it asks for the passphrase again |
| [Recover a host that won't boot](howto/recover-boot.md) | Boot, unlock or login problems |

## Writing a page

Each feature, host and user page starts with a short description and a
summary table:

| Row | Contents |
|---|---|
| Module / Directory | The file or directory it documents |
| Aspects | The `flake.modules` names it defines |
| Hosts | Which hosts get it (usually "All, through `workstation`") |
| Inputs | Flake inputs it declares |
| Unfree | Unfree packages it allows (omit if none) |
| Persists | What it keeps under `/persist` |
| Secrets | sops keys it uses |
| Recipes | `just` recipes it relates to (omit if none) |

Then a few sections on anything not obvious from the module: how it fits
with other features, what to do by hand, and known caveats. Don't repeat
what the module's comments already say in full; link to the module or
summarise.

## Layout

| Folder | Contents |
|---|---|
| `features/` | One page per `modules/features/<name>.nix` |
| `hosts/` | One page per `modules/hosts/<host>/` |
| `users/` | One page per `modules/users/<user>/` |
| `howto/` | Step-by-step guides for common tasks |
| `decisions/` | Records of design decisions, numbered `NNNN-<slug>.md` |

`decisions/` is added as #52 progresses.

`check-docs` (part of `just lint` and `nix flake check`) fails when a
feature, host or user has no page here, or a page has no matching module.
