# outlook

Outlook on the web in an app window of the [teams](teams.md) Chromium, on
the `Work` workspace next to Teams. Why they share a workspace is in
[0048](../decisions/0048-outlook-on-the-work-workspace.md).

| | |
|---|---|
| Module | `modules/features/outlook.nix` |
| Aspects | `nixos.outlook`, `homeManager.outlook` |
| Hosts | All, through `workstation` |
| Inputs | None |
| Persists | Nothing of its own: the profile is Teams' `~/.config/chromium` |
| Secrets | None |

Every home-manager user on the host gets it through
`home-manager.sharedModules`. It needs the [teams](teams.md) feature, whose
Chromium policies it runs under, and [app-workspaces](app-workspaces.md).

## The app

`outlook` (the **Outlook** launcher entry) starts Chromium with
`--app=https://outlook.cloud.microsoft/mail/` and the same flags as
`teams`. Both use Chromium's default profile, so one Microsoft sign-in
covers both, and the Teams policies apply: only Microsoft sites load, and
a link to anything else shows Chromium's "blocked" page. Copy those into
LibreWolf.

## Workspace

Outlook adds itself to Teams' `Work` workspace. `Mod+Alt+W` starts
whichever of the two isn't running and focuses the other. `Work` opens
windows at half width, so the two show side by side; `Mod+Ctrl+F`
maximizes the focused one and restores it. The window rule matches
`chrome-outlook.cloud.microsoft__…`.

## By hand

- Nothing, if you're signed in to Teams. Otherwise sign in once in either
  window.
- Allow notifications when Outlook first asks.
