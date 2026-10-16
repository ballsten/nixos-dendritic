# element

[Element](https://element.io), the Matrix client.

| | |
|---|---|
| Module | `modules/features/element.nix` |
| Aspects | `nixos.element`, `homeManager.element` |
| Hosts | All, through `workstation` |
| Inputs | None |
| Persists | `~/.config/Element` (login, session and encryption keys, message database, settings) |
| Secrets | None |

Every home-manager user on the host gets it through
`home-manager.sharedModules`.

## Database key in the keyring

Element encrypts its local message database with a key it keeps in the
system keyring. It's started with `--password-store=gnome-libsecret`, so
the key goes in gnome-keyring from the [keyring](keyring.md) feature,
which `workstation` also imports. Without the flag, Electron doesn't
recognise Umbriel and would fall back to its built-in key.

The flag is added by a small wrapper around nixpkgs' `element-desktop`
rather than by overriding its `commandLineArgs`, which would rebuild
Element from source instead of downloading it from the binary cache.

If the keyring is reset (see
[Changing the login password](keyring.md#changing-the-login-password)),
Element can't open its database. Log in again and verify with the
security key to get encrypted history back.

## Settings are the app's

Element's settings, including the homeserver, are changed in the app and
kept by persisting `~/.config/Element`. `programs.element-desktop.settings`
is left empty: declaring it would link `config.json` read-only from the Nix
store.

## Not started with the session

Element starts when you launch it. Its "Show tray icon and minimise window
to it on close" setting decides whether closing the window quits it or
keeps it in Noctalia's tray.
