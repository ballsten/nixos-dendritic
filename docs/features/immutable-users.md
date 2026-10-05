# immutable-users

Makes user accounts fully declarative.

| | |
|---|---|
| Module | `modules/features/immutable-users.nix` |
| Aspects | `nixos.immutable-users` |
| Hosts | All, through `workstation` |
| Inputs | None |
| Persists | Nothing |
| Secrets | None |

Sets `users.mutableUsers = false`. Accounts, groups and passwords come only
from the configuration; `passwd` and `useradd` changes don't survive a
rebuild. Login passwords are hashes stored in sops (see
[secrets](secrets.md#passwords)). Root has no password.
