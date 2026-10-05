# ssh

The OpenSSH server, the host's SSH key, and GitHub's host key.

| | |
|---|---|
| Module | `modules/features/ssh.nix` |
| Aspects | `nixos.ssh` |
| Hosts | All, through `workstation` |
| Inputs | None |
| Persists | `/persist/etc/ssh/ssh_host_ed25519_key` (read in place, not bind-mounted) |
| Secrets | None |

## Host key

`services.openssh.hostKeys` points at `/persist/etc/ssh/` directly. sops
derives the host's age key from this SSH key and decrypts during
activation, which can run before impermanence's bind mounts exist (see
[secrets](secrets.md#impermanence)). Only an ed25519 key is generated.

On a reinstall, restore this key into `/persist/etc/ssh/` before the first
boot, or the host can't decrypt its secrets (see
[Install or reinstall a host](../howto/install-host.md)).

## Known hosts

GitHub's ed25519 host key is in the system-wide known hosts
(`programs.ssh.knownHosts`), so a wiped `~/.ssh/known_hosts` doesn't prompt
again. Its fingerprint is in a comment in the module, as published on
docs.github.com.

The user's own SSH key comes from sops; see
[secrets](secrets.md#ssh-key).
