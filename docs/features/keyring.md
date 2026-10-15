# keyring

gnome-keyring as the desktop's Secret Service, unlocked at login, for apps
that keep keys and passwords in the system keyring.

| | |
|---|---|
| Module | `modules/features/keyring.nix` |
| Aspects | `nixos.keyring`, `homeManager.keyring` |
| Hosts | All, through `workstation` |
| Inputs | None |
| Persists | `~/.local/share/keyrings` |
| Secrets | None |

Every home-manager user on the host gets the persisted keyrings through
`home-manager.sharedModules`.

## Unlocked at login

noctalia-greeter logs in through greetd, whose PAM stack includes `login`.
gnome-keyring adds its PAM module there, so the password typed at the
greeter unlocks the `login` keyring and starts the daemon. On the first
login after this feature is added, there's no keyring yet, and PAM creates
it with the login password.

The keyring isn't involved in unlocking the screen; it stays unlocked for
the session.

## Apps have to ask for it

Chromium and Electron apps choose a keyring from the desktop they run on.
They don't recognise Umbriel (`XDG_CURRENT_DESKTOP=umbriel`), so they fall
back to `basic_text`, a fixed built-in key, even with gnome-keyring running.
An app that should use the keyring is started with
`--password-store=gnome-libsecret`, in the feature that installs it, as
[element](element.md) is.

Brave isn't changed: it keeps its existing `basic_text` storage. Its
passwords are in Bitwarden rather than Brave's own password manager.

## Changing the login password

The keyring's password doesn't follow the login password. After
`just set-password` and a rebuild, the next login can't unlock the keyring,
and apps that use it ask for the old password. Open **Passwords and Keys**
(seahorse), right-click the **Login** keyring, choose **Change Password**,
and enter the old password, then the new one.

If the old password is lost, delete `~/.local/share/keyrings/login.keyring`
and log in again for a new, empty keyring. Apps that stored keys in it lose
them; Element, for example, needs its security key again.

## SSH agent

gnome-keyring's SSH agent (`services.gnome.gcr-ssh-agent`) is on by default
when gnome-keyring is. It's turned off: ssh uses the key from sops directly
([secrets](secrets.md#ssh-key)), without an agent.

See [0039](../decisions/0039-gnome-keyring.md) for why gnome-keyring.
