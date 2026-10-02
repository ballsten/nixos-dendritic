# Secrets

Secrets are managed with [sops-nix](https://github.com/Mic92/sops-nix) by the
`secrets` feature (`modules/features/secrets.nix`), which every host gets via
`workstation`. Encrypted values live in `secrets/secrets.yaml`; who can
decrypt them is listed in `.sops.yaml`.

Never commit a decrypted secret. Only the sops-encrypted file belongs in git.

All commands below run inside the dev shell (`nix develop`).

## Keys

`.sops.yaml` holds a flat list of age recipients, each labelled with a
comment:

- **admin**: Andrew's personal age key at `~/.config/sops/age/keys.txt`.
  Used to edit secrets. Keep a backup of it outside this machine; it is the
  recovery path if a host key is lost.
- **one entry per host**: age keys derived from each host's
  `/etc/ssh/ssh_host_ed25519_key`. Hosts decrypt at activation time into
  `/run/secrets/`.

## Edit secrets

```sh
just secrets-edit
```

Then reference the secret from a feature module:

```nix
sops.secrets."vpn/key" = { };
# available at config.sops.secrets."vpn/key".path
```

A declared secret that is missing from `secrets/secrets.yaml` fails the
**build**, so a missing secret is caught before anything is activated.

## What is stored

| Key | Used by | Set with |
|---|---|---|
| `users/ballsten/password` | Login password hash (`neededForUsers`) | `just set-password` |
| `wifi/home/ssid`, `wifi/home/psk` | NetworkManager profile `home` (`wifi` feature) | `just set-wifi home` |
| `users/ballsten/tokens/github` | `GH_TOKEN` for `gh` (home-manager) | `gh auth token \| just set-token github` |

## API tokens

Secrets used by command-line tools are never exported in a shell. Instead
the tool is wrapped with `wrapWithSecrets` (`modules/flake/lib.nix`), which
reads each secret file into an environment variable of that tool's process
only, at run time. Values stay out of the Nix store and out of other
processes' environments.

```nix
home.packages = [
  (inputs.self.lib.wrapWithSecrets pkgs pkgs.gh {
    GH_TOKEN = config.sops.secrets."users/ballsten/tokens/github".path;
  })
];
```

The wrapper exits with an error if a secret file is missing. A changed token
takes effect on the next run after rebuilding. `GH_TOKEN` takes precedence
over `~/.config/gh/hosts.yml`.

This limits accidental exposure (environment dumps, child processes, logs).
It is not a security boundary: anything running as the user can still run
`gh auth token` or read the decrypted file.

## Passwords

`users.mutableUsers = false` (in `workstation`): accounts are fully
declarative and `passwd` changes do not survive a rebuild. Change a password
with `just set-password`, then rebuild. Root has no password; use `sudo`.

If a password change goes wrong, boot the previous generation from the boot
menu. Try changes with `nixos-rebuild test` first and confirm
`sudo -k && sudo true` works before `switch`.

## Wi-Fi

The `wifi` feature declares a NetworkManager profile whose SSID and PSK are
substituted from a sops template at boot. Adding another network needs both
`just set-wifi <name>` and a matching profile in
`modules/features/wifi.nix`.

## home-manager secrets

ballsten's home-manager config imports the `secrets` home-manager module,
which decrypts with the admin key at `~/.config/sops/age/keys.txt`. That key
must be present on every host running this config, or user secrets will fail
to decrypt (system secrets are unaffected). Declare user secrets with
`sops.secrets.<name>` inside a home-manager module; they appear under
`~/.config/sops-nix/secrets/`.

## Set up the admin key on a new workstation

```sh
just admin-key
```

Creates `~/.config/sops/age/keys.txt` if it doesn't exist (restore it from
backup instead if you already have one) and prints the public key.

## Enrol a new host

From a machine that has the admin key, after the new host has booted once
(so its SSH host key exists):

```sh
just enrol-host tiki-rig tiki-rig.local   # fetch the key over the network
just enrol-host tiki-rig                  # or, when run on that host itself
```

This adds the host's age recipient to `.sops.yaml` and re-encrypts
`secrets/secrets.yaml`. Commit both files.

`ssh-keyscan` trusts whatever answers on the network. On an untrusted
network, compare `just host-key <target>` with `just host-key` run on the
host itself before enrolling.

## Impermanence

When impermanence lands (#6), the host SSH keys must be persisted and
`sops.age.sshKeyPaths` must point at the `/persist` copy, because
activation can run before the bind mount onto `/etc/ssh` exists.
