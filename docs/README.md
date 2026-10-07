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
| [fwupd](features/fwupd.md) | Firmware and `dbx` updates from LVFS |
| [gaming](features/gaming.md) | Steam, Proton-GE, gamemode and Path of Exile tools |
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
| [theme](features/theme.md) | Colours from the wallpaper, applied to the shell and apps |
| [tpm-unlock](features/tpm-unlock.md) | Unlocks the disk with the TPM |
| [unfree](features/unfree.md) | Allows unfree packages by name |
| [wifi](features/wifi.md) | Wi-Fi networks with keys from sops |
| [workstation](features/workstation.md) | The feature set every host imports |

## Hosts

| Host | Hardware |
|---|---|
| [surface-laptop](hosts/surface-laptop.md) | Microsoft Surface Pro (Intel) |
| [tiki-rig](hosts/tiki-rig.md) | Desktop PC (Ryzen 7 5800X, RTX 3080) |

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
| [Update firmware](howto/update-firmware.md) | Applying firmware or `dbx` updates with fwupd |
| [Turn on Secure Boot](howto/enable-secure-boot.md) | An installed host with Secure Boot off |
| [Enrol the TPM](howto/enroll-tpm.md) | After install, or when it asks for the passphrase again |
| [Recover a host that won't boot](howto/recover-boot.md) | Boot, unlock or login problems |

## Decisions

Why things are the way they are. See [0001](decisions/0001-record-decisions.md)
for the format.

| Record | Decision |
|---|---|
| [0001](decisions/0001-record-decisions.md) | Record design decisions |
| [0002](decisions/0002-dendritic-pattern.md) | The Dendritic pattern with flake-file |
| [0003](decisions/0003-nixos-unstable.md) | Follow nixos-unstable |
| [0004](decisions/0004-format-and-lint.md) | nixfmt-tree, statix and deadnix, enforced in CI |
| [0005](decisions/0005-sops-nix.md) | sops-nix with age keys |
| [0006](decisions/0006-immutable-users.md) | Declarative users, with passwords from sops |
| [0007](decisions/0007-declarative-wifi.md) | Wi-Fi networks are declared, not saved |
| [0008](decisions/0008-wrap-cli-secrets.md) | Command-line tools get their secrets by wrapping |
| [0009](decisions/0009-dev-shell.md) | A complete dev shell, loaded by direnv |
| [0010](decisions/0010-unfree-by-name.md) | Allow unfree packages by name |
| [0011](decisions/0011-linux-surface-kernel.md) | The linux-surface kernel, built locally |
| [0012](decisions/0012-single-purpose-features.md) | Single-purpose features, composed by workstation |
| [0013](decisions/0013-passwordless-sudo.md) | Passwordless sudo for ballsten |
| [0014](decisions/0014-noctalia-desktop.md) | Umbriel and Noctalia from nixpkgs |
| [0015](decisions/0015-user-ssh-key-in-sops.md) | The user's SSH key lives in sops |
| [0016](decisions/0016-impermanence.md) | Impermanence with a btrfs root rollback |
| [0017](decisions/0017-secure-boot.md) | Secure Boot with lanzaboote and our own keys |
| [0018](decisions/0018-tpm-unlock.md) | TPM unlock bound to PCR 7 and PCR 15, without a PIN |
| [0019](decisions/0019-nix-gc.md) | Weekly garbage collection and store optimisation |
| [0020](decisions/0020-fwupd.md) | fwupd on every host, for dbx and firmware updates |
| [0021](decisions/0021-noctalia-theming.md) | Desktop styling with Noctalia, coloured from the wallpaper |
| [0022](decisions/0022-fonts-and-icons.md) | Inter, Fira Code and Tela-dark for fonts and icons |
| [0023](decisions/0023-cursor.md) | graphite-dark cursor at size 24 |
| [0024](decisions/0024-terminal-colours.md) | Fixed terminal hues, blended with the wallpaper |
| [0025](decisions/0025-greeter-theme.md) | The login screen's look is declared, from the default wallpaper |
| [0026](decisions/0026-games-subvolume.md) | The Steam library on its own `/games` subvolume |
| [0027](decisions/0027-tiki-rig-windows.md) | Windows stays on tiki-rig's second disk, with Secure Boot on |
| [0028](decisions/0028-nvidia-driver.md) | NVIDIA's open kernel modules from the stable branch |

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

`check-docs` (part of `just lint` and `nix flake check`) fails when a
feature, host or user has no page here, or a page has no matching module.
