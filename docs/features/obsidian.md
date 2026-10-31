# obsidian

The [Obsidian](https://obsidian.md) notes app, on its own `Notes` workspace
toggled with `Mod+Alt+N`.

| | |
|---|---|
| Module | `modules/features/obsidian.nix` |
| Aspects | `nixos.obsidian`, `homeManager.obsidian` |
| Hosts | All, through `workstation` |
| Inputs | None |
| Unfree | `obsidian` |
| Persists | `~/.config/obsidian` (vault list, window state, Electron profile) |
| Secrets | None |

Every home-manager user on the host gets the app through
`home-manager.sharedModules`.

Vaults keep their own settings in their `.obsidian` folder, so only the app
is managed here. A user registers their vaults with
`programs.obsidian.vaults`, without settings, so nothing is written into the
vault. Vault contents are persisted wherever the vault lives; ballsten's is
`~/repos/Ballsten.md`, a git repo synced with the obsidian-git plugin (see
[ballsten](../users/ballsten.md)).

## The Notes workspace

Obsidian registers a `Notes` workspace with the
[app-workspaces](app-workspaces.md) feature, so it needs that feature too.
`Mod+Alt+N` shows the workspace, starting Obsidian on the first press, and
switches back on the next. On `tiki-rig` the workspace is on DP-3, the left
monitor.

The window rule matches both `obsidian`, Electron's app ID on Wayland, and
`md.obsidian.Obsidian`, the desktop file's class under XWayland.
