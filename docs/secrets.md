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
sops.secrets."wifi/home" = { };
# available at config.sops.secrets."wifi/home".path
```

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
