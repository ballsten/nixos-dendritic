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
- `IdleDetectionAllowedForUrls` lets Teams use the Idle Detection API (see
  [Teams presence](#teams-presence)).

## Teams presence

Teams on the web normally only counts input in its own tab, so working in
any other window turns it Away. With its **Keep my current status when I'm
active outside of Teams on the web** setting (*Settings → Notifications and
activity → Presence*), it asks the browser for the system-wide idle state
through the Idle Detection API instead.

Brave blocks that API on every site by default, so the Teams setting
couldn't take effect. The policy allows it for `teams.microsoft.com` and
`teams.cloud.microsoft` only; every other site stays blocked. Turning on the
Teams setting is still a manual step.

Brave runs on Wayland and gets the idle time from Umbriel's
`ext-idle-notify-v1`, the same source Noctalia's idle lock uses
([desktop](desktop.md#screen-lock)). Locking the screen doesn't change Teams' status on its own; Teams only
goes Away once the idle time passes its own threshold. That's what we
want. Chromium would report a lock through `org.freedesktop.ScreenSaver`'s
`GetActive`, which Noctalia's service doesn't implement. If Noctalia adds
it, Teams may start going Away on lock.

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
