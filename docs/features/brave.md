# brave

The Brave browser, with the Bitwarden extension force-installed.

| | |
|---|---|
| Module | `modules/features/brave.nix` |
| Aspects | `nixos.brave`, `homeManager.brave` |
| Hosts | All, through `workstation` |
| Inputs | None |
| Persists | `~/.config/BraveSoftware` (profile, Bitwarden login, history, cookies) |
| Secrets | None |

## System side

Brave only reads managed policies from `/etc`, so the policy is
system-wide (`/etc/brave/policies/managed/nixos.json`):

- `ExtensionInstallForcelist` installs Bitwarden and keeps it enabled; it
  can't be removed from the browser.
- `PasswordManagerEnabled = false` turns off Brave's own password manager.

## User side

Every home-manager user on the host gets `programs.brave` through
`home-manager.sharedModules`.

Logging in to Bitwarden is manual, once per profile. The login survives
reboots because the profile is persisted.
