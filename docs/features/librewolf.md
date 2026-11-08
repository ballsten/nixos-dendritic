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

LibreWolf's defaults stay, with two changes. Both are set in
`librewolf.overrides.cfg`, which LibreWolf reads after its own defaults.

- **Cookies kept:** LibreWolf clears cookies and site data on every exit
  (`privacy.sanitize.sanitizeOnShutdown`). It's turned off, so site
  logins survive a restart.
- **Fingerprinting Protection instead of `resistFingerprinting`:**
  `resistFingerprinting` always tells sites the theme is light, so sites
  such as GitHub stay light on a dark desktop. Its protections can't be
  turned off one at a time. Firefox's newer Fingerprinting Protection
  covers the same protections ("targets"), and each one can be switched
  off. `privacy.fingerprintingProtection.overrides` turns on every target
  except `CSSPrefersColorScheme`. Pages still see UTC as the time zone, for
  example, but follow the desktop's dark theme.

To check which targets are on, open `about:config` and search for
`fingerprintingProtection`. A site that breaks can be exempted from
LibreWolf's settings page.

## Default browser

`xdg.mimeApps` makes LibreWolf the handler for web links, so `xdg-open`
and links from Element, vesktop and other apps open here.

## Mod+B

`Mod+B` starts LibreWolf, or opens a new window if it's already running.
The bind is added to the Umbriel config from the [desktop](desktop.md)
feature.

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
