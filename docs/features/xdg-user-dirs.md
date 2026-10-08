# xdg-user-dirs

The standard home folders (`~/Downloads`, `~/Documents` and so on), from
home-manager's `xdg.userDirs`.

| | |
|---|---|
| Module | `modules/features/xdg-user-dirs.nix` |
| Aspects | `nixos.xdg-user-dirs`, `homeManager.xdg-user-dirs` |
| Hosts | All, through `workstation` |
| Inputs | None |
| Persists | Nothing itself |
| Secrets | None |

Every home-manager user on the host gets it through
`home-manager.sharedModules`.

## Why it's needed

`/home` is wiped on boot ([impermanence](impermanence.md)), so a folder
only exists if something persists it or creates it again. Without this
feature, `~/Downloads` was missing after every reboot until an app made it,
and no `~/.config/user-dirs.dirs` told file pickers and browsers where the
folders are.

With `createDirectories`, home-manager creates them at every activation,
including the one that runs on each boot.

## Which folders

Downloads, Documents, Music, Pictures and Videos. Desktop, Templates,
Public and Projects are set to `null`, so they're neither created nor
listed. Projects would duplicate `~/repos`.

This feature doesn't persist anything. Each user chooses what survives a
reboot: ballsten persists Documents, Music, Pictures and Videos
([ballsten](../users/ballsten.md)), and `~/Downloads` stays scratch space
([0016](../decisions/0016-impermanence.md)).
