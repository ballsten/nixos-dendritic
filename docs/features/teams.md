# teams

Microsoft Teams in a Chromium app window, on its own `Work` workspace
toggled with `Mod+Alt+W`. This Chromium is only for Teams and the
Microsoft 365 sites it links to; everything else goes in
[librewolf](librewolf.md). Why there are two browsers is in
[0047](../decisions/0047-librewolf-and-teams-chromium.md).

| | |
|---|---|
| Module | `modules/features/teams.nix` |
| Aspects | `nixos.teams`, `homeManager.teams` |
| Hosts | All, through `workstation` |
| Inputs | None |
| Persists | `~/.config/chromium` (sign-in, cookies, site permissions) |
| Secrets | None |

## The app

`teams` (the **Teams** launcher entry, and `Mod+Alt+W` through
[app-workspaces](app-workspaces.md)) starts Chromium with
`--app=https://teams.cloud.microsoft`: a window with no tabs or address
bar. Chromium itself isn't on `PATH`, so there's no general-purpose
Chromium to start by mistake.

It runs with `--password-store=gnome-libsecret`, so its cookies are
encrypted with a key in [keyring](keyring.md) rather than Chromium's
built-in one.

## Policies

Chromium only reads managed policies from `/etc`, so they're system-wide
(`programs.chromium.extraOpts`, written to
`/etc/chromium/policies/managed/extra.json`):

- **Sites:** `URLBlocklist = [ "*" ]` with an allowlist of Teams, the
  Microsoft sign-in, and the Microsoft 365 sites files and links in Teams
  open (SharePoint, OneDrive, Office, Outlook). A link to anything else
  shows Chromium's "blocked" page; copy it into LibreWolf. A Microsoft page
  that turns up blocked needs its domain added to the list.
- **Presence:** `IdleDetectionAllowedForUrls` for the Teams origins (see
  [Presence](#presence)).
- **No extras:** extensions are blocked, there's no Google sign-in or
  sync, and the password manager and autofill are off.
- **Google services off:** metrics, Safe Browsing lookups, search
  suggestions, the spelling service, translation, error-page suggestions
  and prefetching. Safe Browsing guards little when only Microsoft sites
  can load.

## Presence

Teams on the web normally only counts input in its own window, so working
anywhere else turns it Away. With its **Keep my current status when I'm
active outside of Teams on the web** setting (*Settings → Notifications and
activity → Presence*), it asks the browser for the system-wide idle state
through the Idle Detection API instead. Firefox and LibreWolf don't have
that API, which is why Teams has a Chromium of its own.

Chromium blocks the API on every site by default. The policy allows it for
`teams.microsoft.com` and `teams.cloud.microsoft` only. Turning on the
Teams setting is still a manual step.

Chromium on Wayland gets the idle time from Umbriel's `ext-idle-notify-v1`,
the same source Noctalia's idle lock uses
([desktop](desktop.md#screen-lock)).

Idle time alone isn't enough: with the setting on, Teams stays Available
while the page reports `idle` but the screen `unlocked`, however long
that lasts. It goes Away once the screen locks, which the
[lock-status](lock-status.md) feature reports to Chromium. With Noctalia's
idle lock, that's 5 minutes after the last input, or straight away after
<kbd>Mod</kbd>+<kbd>Shift</kbd>+<kbd>L</kbd>
([0046](../decisions/0046-lock-status.md)).

Teams combines presence from every device signed in to the account, so
using Teams on a phone or another computer keeps it Available whatever
this machine reports.

## Workspace

`Mod+Alt+W` shows and hides the `Work` workspace, starting Teams on the
first press. [outlook](outlook.md) shares the workspace and this Chromium's
profile. Chromium names an app window after its URL and profile, and
the window rule matches `chrome-teams.cloud.microsoft__…`. If Teams opens
on the wrong workspace, `umbriel windows --json` shows the ID to match.

## By hand

- Sign in to Teams. Bitwarden isn't installed here, so use a passkey, the
  Authenticator app, or copy the password from Bitwarden in LibreWolf.
- Turn on the presence setting above.
- Allow the camera, microphone and notifications when Teams first asks.
  Chromium remembers them in the persisted profile.
