# app-workspaces

Gives an app its own named workspace, shown and hidden with
`Mod+Alt+<key>`. The first press starts the app. Obsidian has `Notes` on
`Mod+Alt+N`, and vesktop has `Chat` on `Mod+Alt+C`.

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
- **Layout:** the app's windows open at full width on their workspace.

Why a workspace rather than a scratchpad or a pinned window is in
[0045](../decisions/0045-app-workspaces.md).

## Adding an app

The app's own feature registers it, next to the rest of its config:

```nix
appWorkspaces.apps.Notes = {
  key = "N";
  appId = "^(obsidian|md[.]obsidian[.]Obsidian)$";
  command = lib.getExe config.programs.obsidian.package;
};
```

`appId` is a regex for the Wayland app ID. `umbriel windows --json` shows
the ID of a running window. That feature then needs `app-workspaces` too,
which `workstation` provides.

| Workspace | Key | App | Feature |
|---|---|---|---|
| `Notes` | `Mod+Alt+N` | Obsidian | [obsidian](obsidian.md) |
| `Chat` | `Mod+Alt+C` | vesktop | [vesktop](vesktop.md) |

## Which monitor

`appWorkspaces.output` puts every app workspace on one monitor. `tiki-rig`
sets it to DP-3, the left monitor (see
[tiki-rig](../hosts/tiki-rig.md#display)). Without it, as on
`surface-laptop`, each monitor gets the workspaces and the key toggles the
focused monitor's.

## What the key does

Each app gets an `app-workspace-<name>` script on its key:

- If its workspace isn't showing, it remembers the monitor's current
  workspace, switches to the app's and focuses the app. If the app isn't
  running, it starts it, and a window rule sends it to the workspace.
- If its workspace is showing, it switches back to the workspace it
  remembered, or to the monitor's first other one if that has gone since.

The remembered workspace is kept in `$XDG_RUNTIME_DIR`, so nothing is
persisted. Switching away with the usual workspace keys works too.

The app can still be started from the launcher; the window rule still sends
it to its workspace.
