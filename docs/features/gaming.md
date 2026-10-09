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
| Persists | `~/.local/share/Steam` on `/games`; `~/.config/unity3d`, `~/.local/share/RustyPathOfBuilding1`, `~/.local/share/RustyPathOfBuilding2` and `~/.config/sidekick` on `/persist` |
| Secrets | None |

## System side

- `programs.steam`, with GE-Proton added as a compatibility tool. Steam
  also turns on 32-bit graphics and the udev rules for Steam controllers.
- `programs.gamemode`. It changes the CPU governor through polkit, which
  only allows members of the `gamemode` group without a password, so a
  user who games adds themselves to it (ballsten does whenever
  `programs.gamemode.enable` is set). Run a game with
  `gamemoderun %command%` in its Steam launch options.

## User side

Every home-manager user on the host gets `rusty-path-of-building` (Path of
Building for PoE 1 and 2) and [Sidekick](#sidekick) through
`home-manager.sharedModules`.

## Sidekick

[Sidekick](https://github.com/Sidekick-Poe/Sidekick) price-checks Path of
Exile items. This is its web variant: a local server on
`http://localhost:5000` with its UI in the browser. To price-check an
item, hover it in game, press <kbd>Ctrl</kbd>+<kbd>C</kbd> (the game
copies the item's text), and paste it into Sidekick's item box.

The web variant has no hotkeys or overlay. Sidekick's desktop build and
Awakened PoE Trade both use X11-only hooks and overlays, which can't see
Path of Exile running as a native Wayland window
(`PROTON_ENABLE_WAYLAND=1`, #98) and don't work under Umbriel's Xwayland
either (#99). The web variant needs neither.

- **Package:** Sidekick isn't in nixpkgs. The feature fetches the
  `Sidekick-linux-web-x64.AppImage` release and wraps it with
  `appimageTools.wrapType2`, adding `icu` and `openssl` for .NET. To
  update, change `version` and `hash` in `gaming.nix`. Sidekick's own
  updater can't replace a file in the Nix store, so ignore its update
  notices.
- **Service:** the server runs as the `sidekick` systemd user service. It
  only starts on demand and stops at logout.
- **Launcher:** **Sidekick** (`sidekick-open`) starts the service, and
  Sidekick opens its page. If it's already running, it opens the page
  again. **Stop Sidekick** stops the service.
- **Opening links:** Sidekick opens its page and its links (trade site,
  poe.ninja, wiki) with `xdg-open`. Inside the service, that would start
  Brave as part of `sidekick.service`, and stopping Sidekick would close
  Brave too. The wrapper puts its own `xdg-open` first on the AppImage
  sandbox's PATH (`profile`). It hands each URL to the real `xdg-open` in
  a separate transient unit (`systemd-run --user`).
- **Port:** Sidekick takes port 5000, or the next free port if something
  else has it. The launcher always opens 5000.
- **Data:** settings, the chosen league and the price cache live in
  `~/.config/sidekick/sidekick.db`, which is persisted.

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
