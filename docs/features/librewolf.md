# librewolf

LibreWolf, the main browser, with Bitwarden, uBlock Origin and floccus
force-installed. Teams runs in its own Chromium instead
([teams](teams.md)); why there are two browsers is in
[0047](../decisions/0047-librewolf-and-teams-chromium.md).

| | |
|---|---|
| Module | `modules/features/librewolf.nix` |
| Aspects | `nixos.librewolf`, `homeManager.librewolf` |
| Hosts | All, through `workstation` |
| Inputs | None |
| Persists | `~/.librewolf` (profile, extension logins and settings, floccus account, history, cookies) |
| Secrets | None |

## Policies

Every home-manager user on the host gets `programs.librewolf` through
`home-manager.sharedModules`. home-manager builds the policies into the
browser's wrapper, merged over LibreWolf's own (which keep telemetry and
studies off):

- `ExtensionSettings` installs every extension in `librewolf.extensions`
  with `force_installed`: it stays installed and enabled, and can't be
  removed from the browser. Those in `librewolf.toolbar` also get a
  toolbar button ([below](#toolbar)).
- `PasswordManagerEnabled = false` turns off the built-in password
  manager; passwords are in Bitwarden.

uBlock Origin comes with LibreWolf, but removable. Listing it keeps it.

## Profile

home-manager writes `librewolf.overrides.cfg` (below) to `~/.librewolf`, and
that's the persisted directory. LibreWolf 159 only keeps its profiles there
if `~/.librewolf/profiles.ini` already exists. Otherwise it starts a new
profile under `~/.config/librewolf/librewolf`, where the overrides aren't
read and nothing survives a reboot. The module declares one profile,
`default`, so home-manager writes `profiles.ini` and the profile lives in
`~/.librewolf/default`.

## Privacy settings

LibreWolf's defaults stay, with three changes. All are set in
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
- **WebGL allowed:** LibreWolf blocks WebGL on every site until it's
  allowed for that site (`librewolf.webgl.prompt`), and its build also
  hides the question (`librewolf.webgl.prompt.hide`). Pages that need
  WebGL just fail to draw. The prompt is turned off, so WebGL works
  everywhere, as in Firefox. Fingerprinting Protection still gives sites a
  generic GPU name ("NVIDIA GeForce GTX 980, or similar") instead of the
  real one.

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
published there. `librewolf` adds Bitwarden, uBlock Origin and floccus; other
features add theirs from their own file, as [prun](prun.md) does.

## Toolbar

Extension buttons go in the extensions menu (the puzzle piece) by
default. Add-on IDs in `librewolf.toolbar` get `default_area = "navbar"`
in `ExtensionSettings`, which puts their button on the toolbar instead.
`librewolf` puts Bitwarden and floccus there.

Firefox only places a button the first time it sees the extension. One
that was already installed, as Bitwarden was, stays in the menu until
pinned by hand (its gear in the extensions menu, then **Pin to
Toolbar**); the persisted profile keeps it from then on.

## By hand

Log in to Bitwarden once per profile. The login survives reboots because
the profile is persisted.

## Bookmark sync

[floccus](https://floccus.org/) syncs bookmarks between the hosts. It
writes them to one file in Google Drive, encrypted with a passphrase
before upload, so Google only holds ciphertext. Only bookmarks sync;
history, tabs and passwords stay on each host. Why floccus and Google
Drive is in [0049](../decisions/0049-librewolf-bookmark-sync.md).

floccus keeps its account and passphrase in its extension storage in the
profile, and nothing preconfigures it, so it's set up by hand once per
host (below). The setup survives reboots because `~/.librewolf` is
persisted.

### Setting up a host

1. Open floccus from the toolbar and add a profile: **Google Drive**.
2. Sign in to the Google account.
3. Set the passphrase. Use the same passphrase on every host and keep it
   in Bitwarden. Without it the file in Drive can't be read.
4. Keep the bookmark file name the same on every host.
5. Sync bookmarks only. Leave tab sync off.

### First sync

Sync started from an empty set. Before setting up floccus on the first
host, delete every bookmark on both hosts from the Library
(`Ctrl+Shift+O`). Don't delete `places.sqlite` instead: it holds history
too. Then set up the first host, sync, and set up the other.
