# brave

The Brave browser, with the Bitwarden extension force-installed.

| | |
|---|---|
| Module | `modules/features/brave.nix` |
| Aspects | `nixos.brave`, `homeManager.brave` |
| Hosts | All, through `workstation` |
| Inputs | None |
| Persists | `~/.config/BraveSoftware` (profile, extension logins and settings, history, cookies) |
| Secrets | None |

## System side

Brave only reads managed policies from `/etc`, so the policy is
system-wide (`/etc/brave/policies/managed/nixos.json`):

- `ExtensionInstallForcelist` installs every extension in
  `brave.extensions` and keeps it enabled; they can't be removed from the
  browser.
- `PasswordManagerEnabled = false` turns off Brave's own password manager.

## Adding extensions

`brave.extensions` is a list of Chrome Web Store IDs (the last part of the
extension's store URL). `brave` adds Bitwarden; other features add theirs
from their own file, as [prun](prun.md) does. Every ID gets Google's
update URL, so the extension has to be published on the Chrome Web Store.

## User side

Every home-manager user on the host gets `programs.brave` through
`home-manager.sharedModules`.

Logging in to Bitwarden is manual, once per profile. The login survives
reboots because the profile is persisted.
