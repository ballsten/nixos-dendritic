# Secrets

Secrets are managed with [sops-nix](https://github.com/Mic92/sops-nix) by the
`secrets` feature (`modules/features/secrets.nix`), which every host gets via
`workstation`. Encrypted values live in `secrets/secrets.yaml`; who can
decrypt them is listed in `.sops.yaml`.

| | |
|---|---|
| Module | `modules/features/secrets.nix` |
| Aspects | `nixos.secrets`, `homeManager.secrets` |
| Hosts | All, through `workstation`; the home-manager side is imported by [ballsten](../users/ballsten.md) |
| Inputs | `sops-nix` |
| Persists | `~/.config/sops/age/keys.txt` (the admin key); the host key is persisted by [ssh](ssh.md) |
| Secrets | See [What is stored](#what-is-stored) |
| Recipes | The `keys` and `secrets` groups in the Justfile |

Never commit a decrypted secret. Only the sops-encrypted file belongs in git.

All commands below run inside the dev shell (`nix develop`).

## Keys

`.sops.yaml` holds a flat list of age recipients, each labelled with a
comment:

- **admin**: Andrew's personal age key at `~/.config/sops/age/keys.txt`.
  Used to edit secrets. Keep a backup of it outside this machine; it is the
  recovery path if a host key is lost.
- **one entry per host**: age keys derived from each host's
  `/persist/etc/ssh/ssh_host_ed25519_key`. Hosts decrypt at activation time into
  `/run/secrets/`.

## What is stored

| Key | Used by | Set with |
|---|---|---|
| `users/ballsten/password` | Login password hash (`neededForUsers`) | `just set-password` |
| `wifi/home/ssid`, `wifi/home/psk` | NetworkManager profile `home` (`wifi` feature) | `just set-wifi home` |
| `users/ballsten/tokens/github` | `GH_TOKEN` for `gh` (home-manager) | `gh auth token \| just set-token github` |
| `users/ballsten/ssh/id_ed25519` | ballsten's SSH key, linked at `~/.ssh/id_ed25519` (home-manager) | `just set-ssh-key` |

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

## SSH key

ballsten's SSH private key is a home-manager secret, and `~/.ssh/id_ed25519`
is a link to the decrypted file. The public key is plain text in
`modules/users/ballsten/credentials.nix`, and GitHub's host key is in the
system-wide known hosts (`ssh` feature). With impermanence, `~/.ssh` needs no
persisting, and `git push` works on a fresh boot. git pushes to GitHub over
SSH even in clones with an HTTPS remote ([ballsten](../users/ballsten.md#home)).

To replace the key, generate a new one without a passphrase, run
`just set-ssh-key <file>`, update the public key in `credentials.nix`, and
rebuild.

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

## Impermanence

The host SSH key and the admin key are read straight from `/persist`
(`services.openssh.hostKeys` and `sops.age.keyFile`), not from bind mounts,
because activation can run before the bind mounts exist. Both must be
restored there when a host is reinstalled; see
[Install or reinstall a host](../howto/install-host.md).

## Guides

- [Add a secret](../howto/add-secret.md), including wrapping a tool with
  its token.
- [Add a host](../howto/add-host.md#3-keys): enrol its key before the first
  boot.
- `just admin-key` creates the admin key on a new workstation if it doesn't
  exist (restore it from backup instead if you have one), and prints its
  public key.
- `just enrol-host <name> [target]` enrols a host: it adds the host's age
  recipient to `.sops.yaml` and re-encrypts. Commit both files afterwards.
  `target` is one of:
  - `local` (the default): this machine, from its own sshd;
  - a hostname, reached with `ssh-keyscan`, which trusts whatever answers
    on the network. On an untrusted network, compare with `just host-key`
    run on the host itself first;
  - an age recipient (`age1…`), or an SSH public key file (`*.pub`), for a
    host that isn't running yet ([Add a host](../howto/add-host.md#3-keys)).

  `just host-key [target]` prints the recipient without enrolling it.
