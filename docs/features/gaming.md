# gaming

Steam with Proton-GE and gamemode, plus Path of Exile tools. Only hosts
that game import it; it is never part of `workstation`.

| | |
|---|---|
| Module | `modules/features/gaming.nix` |
| Aspects | `nixos.gaming`, `homeManager.gaming` |
| Hosts | `tiki-rig` (#9) |
| Inputs | None |
| Unfree | `steam`, `steam-unwrapped` |
| Persists | `~/.local/share/Steam` on `/games`; `~/.config/unity3d`, `~/.local/share/RustyPathOfBuilding1`, `~/.local/share/RustyPathOfBuilding2`, `~/.config/awakened-poe-trade`, `~/.config/sidekick` and `~/AppImages` on `/persist` |
| Secrets | None |

## System side

- `programs.steam`, with GE-Proton added as a compatibility tool. Steam
  also turns on 32-bit graphics and the udev rules for Steam controllers.
- `programs.gamemode`. It changes the CPU governor through polkit, which
  only allows members of the `gamemode` group without a password, so a
  user who games adds themselves to it (ballsten does whenever
  `programs.gamemode.enable` is set). Run a game with
  `gamemoderun %command%` in its Steam launch options.
- `programs.appimage` with binfmt, so AppImages run directly. It carries
  the extra libraries Sidekick needs (`icu`, `xsel`, `webkitgtk_4_1`).

## User side

Every home-manager user on the host gets `rusty-path-of-building` (Path of
Building for PoE 1 and 2) and `awakened-poe-trade` through
`home-manager.sharedModules`.

Sidekick isn't in nixpkgs. Download its AppImage into `~/AppImages`, which
is persisted, and run it from there.

## The `/games` filesystem

The Steam library is far bigger than everything else persisted (over 400G
on tiki-rig), so it isn't in `/persist`. The host provides a separate
filesystem at `/games`, the `@games` btrfs subvolume in its `disk.nix`,
marked `neededForBoot` as impermanence requires. `home.persistence."/games"`
binds `~/.local/share/Steam` from it.

Evaluation fails with an assertion if a host imports `gaming` without a
`/games` filesystem. Otherwise the library would be bound from a directory
on the wiped root and lost on reboot.

The library includes `steamapps/compatdata`, the Proton prefixes, which
hold saves for games without Steam Cloud. `steamapps/shadercache` can be
deleted at any time; Steam rebuilds it.

See [0026](../decisions/0026-games-subvolume.md) for why.
