# gaming

Steam with Proton-GE, gamemode and gamescope, plus Path of Exile tools.
Only hosts that game import it; it is never part of `workstation`.

| | |
|---|---|
| Module | `modules/features/gaming.nix` |
| Aspects | `nixos.gaming`, `homeManager.gaming` |
| Hosts | `tiki-rig` (#9) |
| Inputs | None |
| Unfree | `steam`, `steam-unwrapped` |
| Persists | `~/.local/share/Steam` on `/games`; `~/.config/unity3d`, `~/.local/share/RustyPathOfBuilding1`, `~/.local/share/RustyPathOfBuilding2` and `~/.config/awakened-poe-trade` on `/persist` |
| Secrets | None |

## System side

- `programs.steam`, with GE-Proton added as a compatibility tool. Steam
  also turns on 32-bit graphics and the udev rules for Steam controllers.
- `programs.gamemode`. It changes the CPU governor through polkit, which
  only allows members of the `gamemode` group without a password, so a
  user who games adds themselves to it (ballsten does whenever
  `programs.gamemode.enable` is set). Run a game with
  `gamemoderun %command%` in its Steam launch options.
- `programs.gamescope`, a nested compositor with its own Xwayland and X11
  window manager, for games that don't work under Umbriel's Xwayland (see
  [Path of Exile](#path-of-exile)). `capSysNice` stays off, because Steam's
  sandbox can't start a binary that has capabilities.

## User side

Every home-manager user on the host gets `rusty-path-of-building` (Path of
Building for PoE 1 and 2), `awakened-poe-trade` and
`with-awakened-poe-trade` through `home-manager.sharedModules`.

## Path of Exile

Path of Exile runs inside gamescope, with Awakened PoE Trade started next
to it. Set the game's Steam launch options to:

```
gamescope -W 2560 -H 1440 -r 144 -f -- with-awakened-poe-trade %command%
```

The size and refresh rate match tiki-rig's monitors. They're in Steam's
launch options rather than the feature because they depend on the host.

`with-awakened-poe-trade` starts Awakened PoE Trade in the background with
`--ozone-platform=x11`, then runs the game. Inside gamescope, both connect
to gamescope's Xwayland. Awakened PoE Trade's hotkeys (XRecord) and overlay
(which finds the game window by its title) only work on X11. Without the
flag, Electron would open it on Umbriel's Wayland socket, outside
gamescope. If it's already running outside gamescope, the new copy hands
over to that one and exits, so close it before starting the game.

Run directly under Umbriel, the game and the overlay don't work together.
Umbriel's Xwayland window manager has no minimise and no "keep above", so
Wine withdraws the game window when it loses focus (#98), and the overlay
can't stay above the game (#99). See
[0031](../decisions/0031-gamescope-for-path-of-exile.md).

Two per-game fallbacks don't need gamescope:

- `PROTON_ENABLE_WAYLAND=1 %command%` runs the game as a native Wayland
  window, which stays put, but Awakened PoE Trade can't see it.
- `"UseTakeFocus"="N"` under `[Software\\Wine\\X11 Driver]` in the
  prefix's `user.reg` (`steamapps/compatdata/238960/pfx`, edited with the
  game closed) stops most focus changes from withdrawing the window.

A withdrawn window can be mapped again with `xdotool windowmap <id>`,
using the id `xwininfo -root -tree` shows for "Path of Exile".

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
