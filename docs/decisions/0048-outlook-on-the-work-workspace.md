# 0048: Outlook in the Teams Chromium, on the Work workspace

- **Status:** Accepted, 2026-11-09

## Context

Teams runs in a Chromium app window of its own, on the `Work` workspace
([0047](0047-librewolf-and-teams-chromium.md)). Outlook should work the
same way, and sit on the same workspace: mail and Teams together, toggled
with the one key.

App workspaces gave each workspace exactly one app
([0045](0045-app-workspaces.md)): one app ID to match and one command to
start.

## Decision

- An app workspace holds any number of apps:
  `appWorkspaces.workspaces.<Name> = { key; apps.<app> = { appId; command; }; }`.
  Each feature adds its own app, so `teams` defines `Work` and its key, and
  `outlook` adds itself to it. The key starts every app on the workspace
  that isn't running, and focuses the first one that is.
- Outlook is its own feature, `outlook`, in an app window of the same
  Chromium and profile as Teams. It reuses the Teams policies, which
  already allow Outlook, and shares the Microsoft sign-in.

## Consequences

- One press of `Mod+Alt+W` brings up both. Closing one and pressing again
  restarts it.
- Both windows are full width, so they sit side by side in the scrolling
  layout and one fills the screen at a time.
- `outlook` depends on `teams` for its Chromium policies.
- Obsidian and vesktop moved to the new option shape, one app each.

## Alternatives considered

- **A `Mail` workspace of its own, on `Mod+Alt+M`:** no change to app
  workspaces, but mail and Teams are used together and would need two
  keys.
- **Outlook in LibreWolf:** no Chromium window, but it would mix work mail
  into the everyday browser, and Microsoft's sign-in would be in two
  browsers.
- **Outlook in `teams.nix`:** fewer files, but it's a separate app with
  its own launcher and window, so it gets its own feature.
