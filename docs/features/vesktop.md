# vesktop

[vesktop](https://github.com/Vencord/Vesktop), a Discord client with
[Vencord](https://vencord.dev) built in.

| | |
|---|---|
| Module | `modules/features/vesktop.nix` |
| Aspects | `nixos.vesktop`, `homeManager.vesktop` |
| Hosts | All, through `workstation` |
| Inputs | None |
| Persists | `~/.config/vesktop` (login, settings, Vencord plugins) |
| Secrets | None |

Every home-manager user on the host gets it through
`home-manager.sharedModules`.

## Settings are the app's

vesktop's and Vencord's settings, themes and plugins are changed in the
app and kept by persisting `~/.config/vesktop`. home-manager's
`programs.vesktop.settings` and `vencord.settings` are left empty: declaring
them would link those files read-only from the Nix store, and changes made
in the app would no longer stick.

## Not started with the session

vesktop starts when you launch it. Its "Minimize to tray" setting decides
whether closing the window quits it or keeps it in Noctalia's tray.

## Why vesktop

The old config installed the official `discord` client on tiki-rig only.
vesktop is free software, so it needs no `unfree.packages` entry, and its
screen sharing works on Wayland through the desktop portal. It runs on both
hosts (#9).
