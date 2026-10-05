# obsidian

The [Obsidian](https://obsidian.md) notes app.

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
