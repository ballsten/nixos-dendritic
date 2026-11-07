# librewolf

LibreWolf, the main browser, with Bitwarden and uBlock Origin
force-installed. Teams runs in its own Chromium instead
([teams](teams.md)); why there are two browsers is in
[0047](../decisions/0047-librewolf-and-teams-chromium.md).

| | |
|---|---|
| Module | `modules/features/librewolf.nix` |
| Aspects | `nixos.librewolf`, `homeManager.librewolf` |
| Hosts | All, through `workstation` |
| Inputs | None |
| Persists | `~/.librewolf` (profile, extension logins and settings, history, cookies) |
| Secrets | None |

## Policies

Every home-manager user on the host gets `programs.librewolf` through
`home-manager.sharedModules`. home-manager builds the policies into the
browser's wrapper, merged over LibreWolf's own (which keep telemetry and
studies off):

- `ExtensionSettings` installs every extension in `librewolf.extensions`
  with `force_installed`: it stays installed and enabled, and can't be
  removed from the browser.
- `PasswordManagerEnabled = false` turns off the built-in password
  manager; passwords are in Bitwarden.

uBlock Origin comes with LibreWolf, but removable. Listing it keeps it.

## Privacy settings

LibreWolf's defaults stay, with one change:

- **Kept:** `privacy.resistFingerprinting`. Pages see UTC as the time zone,
  windows are letterboxed to common sizes, and canvas reads may ask for
  permission. A site that breaks can be exempted from LibreWolf's settings
  page.
- **Changed:** LibreWolf clears cookies and site data on every exit
  (`privacy.sanitize.sanitizeOnShutdown`). It's turned off, so site
  logins survive a restart. It's set in `librewolf.overrides.cfg`, which
  LibreWolf reads after its own defaults.

## Default browser

`xdg.mimeApps` makes LibreWolf the handler for web links, so `xdg-open`
and links from Element, vesktop and other apps open here.

## Adding extensions

`librewolf.extensions` maps an add-on ID to its addons.mozilla.org slug
(the last part of its AMO URL). The ID is the `guid` from the AMO API:

```sh
curl -s https://addons.mozilla.org/api/v5/addons/addon/<slug>/ | jq -r .guid
```

Every extension is installed from AMO's latest release, so it has to be
published there. `librewolf` adds Bitwarden and uBlock Origin; other
features add theirs from their own file, as [prun](prun.md) does.

## By hand

Log in to Bitwarden once per profile. The login survives reboots because
the profile is persisted.
