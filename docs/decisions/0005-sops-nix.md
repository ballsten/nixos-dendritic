# 0005: sops-nix with age keys

- **Status:** Accepted, 2026-10-02
- **Issues:** #7, #11
- **PRs:** #15 (re-opened from #14), #17

## Context

The repo is public, and features need passwords, Wi-Fi keys and tokens.
#7 left the choice between sops-nix and agenix open.

## Decision

Use [sops-nix](https://github.com/Mic92/sops-nix), with age keys:

- One encrypted file, `secrets/secrets.yaml`, holds every secret as a key
  path. Recipients are a flat, commented list in `.sops.yaml`.
- Each host decrypts with an age key derived from its SSH ed25519 host key.
- An admin age key (`~/.config/sops/age/keys.txt`) edits secrets and
  decrypts home-manager secrets.

Reasons for sops-nix over agenix:

- **One file, many secrets**, edited as a whole with `sops`, rather than
  one `.age` file per secret.
- **Templates** render secrets into config files, which the
  [wifi](../features/wifi.md) feature uses for NetworkManager.
- **A home-manager module** for user secrets.

## Consequences

- A declared secret missing from the file fails the build, not activation.
- Every host running ballsten's home config needs the admin key on
  `/persist`.
- A new host must be enrolled before its first boot, or it can't decrypt
  the login password ([Add a host](../howto/add-host.md#3-keys)).
- Host and admin keys are read from `/persist` directly, because
  activation can run before bind mounts exist
  ([0016](0016-impermanence.md)).

## Alternatives considered

- **agenix:** one file per secret, no templates.
