# app-workspaces

Gives an app, or a few that belong together, a named workspace of their
own, shown and hidden with `Mod+Alt+<key>`. The first press starts the
apps. Obsidian has `Notes` on `Mod+Alt+N`, vesktop has `Chat` on
`Mod+Alt+C`, and Teams and Outlook share `Work` on `Mod+Alt+W`. A `Main`
workspace on `Mod+Alt+1` comes before them, for everything else.

| | |
|---|---|
| Module | `modules/features/app-workspaces.nix` |
| Aspects | `nixos.app-workspaces`, `homeManager.app-workspaces` |
| Hosts | All, through `workstation` |
| Inputs | None |
| Persists | Nothing |
| Secrets | None |

Every home-manager user on the host gets it through
`home-manager.sharedModules`. It adds to the [desktop](desktop.md)
feature's Umbriel config, so it needs that feature too.

## The convention

- **Workspace name:** the app's role, such as `Notes`. Named workspaces stay
  when empty, so the name is always in the bar.
- **Key:** `Mod+Alt` plus the workspace name's first letter, so the bar is
  the reminder. The packaged config only uses `Mod+Alt` with the arrow keys,
  so every letter is free.
- **Layout:** the app's windows open at full width on their workspace. A
  workspace shared by several apps can set a narrower `width` so they show
  side by side, as `Work` does with `width = 0.5`. `Mod+Ctrl+F` then
  maximizes the focused window and restores it.

Why a workspace rather than a scratchpad or a pinned window is in
[0045](../decisions/0045-app-workspaces.md).

## Main

`Main` is the workspace for everything without an app workspace. Umbriel
puts named workspaces first, in the order they're declared, and `Main` is
declared before the app workspaces, so the bar reads `Main`, `Chat`,
`Notes`, `Work`. A monitor starts on its first workspace, so `Main` is the
one showing after login.

`Mod+Alt+1` switches to it. With no apps to start, it doesn't toggle:
pressed on `Main`, it does nothing. It follows `appWorkspaces.output` like
the app workspaces, so on `tiki-rig` it lives on DP-3 and the key works
wherever the pointer is.

## Adding an app

The app's own feature registers it, next to the rest of its config:

```nix
appWorkspaces.workspaces.Notes = {
  key = "N";
  apps.obsidian = {
    appId = "^(obsidian|md[.]obsidian[.]Obsidian)$";
    command = lib.getExe config.programs.obsidian.package;
  };
};
```

`appId` is a regex for the Wayland app ID. `umbriel windows --json` shows
the ID of a running window. That feature then needs `app-workspaces` too,
which `workstation` provides.

To put an app on an existing workspace, add it to `apps` and leave the key
to the feature that defines the workspace, as Outlook does on `Work`
([0048](../decisions/0048-outlook-on-the-work-workspace.md)):

```nix
appWorkspaces.workspaces.Work.apps.outlook = {
  appId = "^chrome-outlook[.]cloud[.]microsoft__.*$";
  command = lib.getExe outlook;
};
```

| Workspace | Key | Apps | Features |
|---|---|---|---|
| `Main` | `Mod+Alt+1` | None | `app-workspaces` |
| `Notes` | `Mod+Alt+N` | Obsidian | [obsidian](obsidian.md) |
| `Chat` | `Mod+Alt+C` | vesktop | [vesktop](vesktop.md) |
| `Work` | `Mod+Alt+W` | Teams, Outlook | [teams](teams.md), [outlook](outlook.md) |

## Which monitor

`appWorkspaces.output` puts every app workspace on one monitor. `tiki-rig`
sets it to DP-3, the left monitor (see
[tiki-rig](../hosts/tiki-rig.md#display)). Without it, as on
`surface-laptop`, each monitor gets the workspaces and the key toggles the
focused monitor's.

## What the key does

Each workspace gets an `app-workspace-<name>` script on its key:

- If the workspace isn't showing, it remembers the monitor's current
  workspace, switches to the app workspace and focuses the first of its
  apps that's running. It starts every app that isn't running, one at a
  time: each gets up to 15 seconds to open its window before the next
  starts, because two apps on one browser profile (Teams and Outlook)
  can't start at the same moment. A window rule sends each one to the
  workspace.
- If its workspace is showing, it switches back to the workspace it
  remembered, or to the monitor's first other one if that has gone since.

The remembered workspace is kept in `$XDG_RUNTIME_DIR`, so nothing is
persisted. Switching away with the usual workspace keys works too.

The app can still be started from the launcher; the window rule still sends
it to its workspace.
