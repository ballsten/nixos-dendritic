# direnv

[direnv](https://direnv.net) with nix-direnv, which loads a repo's dev shell
on `cd` through its `.envrc`.

| | |
|---|---|
| Module | `modules/features/direnv.nix` |
| Aspects | `homeManager.direnv` |
| Hosts | Users who import it: [ballsten](../users/ballsten.md) |
| Inputs | None |
| Persists | `~/.local/share/direnv` (the allow list) |
| Secrets | None |

nix-direnv caches the dev shell and keeps it from being garbage collected.
The allow list is persisted, so `.envrc` files don't need `direnv allow`
again after a reboot.

This is a home-manager-only aspect, so a user imports it directly rather
than getting it from a host.
