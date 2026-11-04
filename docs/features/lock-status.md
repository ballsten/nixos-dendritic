# lock-status

A small user service that reports whether the screen is locked on
`org.gnome.ScreenSaver`, so browsers can see the lock. It exists for
[Teams presence](brave.md#teams-presence): with it, Teams in Brave goes
Away when the screen locks.

| | |
|---|---|
| Module | `modules/features/lock-status.nix` |
| Aspects | `nixos.lock-status`, `homeManager.lock-status` |
| Hosts | All, through `workstation` |
| Inputs | None |
| Persists | Nothing |
| Secrets | None |

It needs the [desktop](desktop.md) feature, whose Noctalia does the
locking. See [0046](../decisions/0046-lock-status.md) for why it's a
service of our own.

## How it works

Chromium learns about a lock by calling `GetActive` on a ScreenSaver D-Bus
service. When it starts, it tries `org.freedesktop.ScreenSaver`,
`org.cinnamon.ScreenSaver`, `org.gnome.ScreenSaver`, `org.mate.ScreenSaver`
and `org.xfce.ScreenSaver` in turn, and keeps the first one that has an
owner and answers. After that it listens for that service's
`ActiveChanged` signal.

Noctalia owns `org.freedesktop.ScreenSaver` (for idle inhibitors) but
doesn't implement `GetActive`, so Chromium skips it. This service claims
`org.gnome.ScreenSaver`, answers `GetActive` and emits `ActiveChanged`. It
takes the lock state from logind's `LockedHint` on the user's graphical
session, which Noctalia sets when it locks and unlocks.

The service starts with `graphical-session.target`. Chromium picks its
lock service only at startup, so a Brave started before the service (for
example while trying it out by hand) doesn't see the lock until it's
restarted. Once Brave has picked it, restarting the service is fine:
Brave follows the bus name to the new owner.

## Checking it

```sh
systemctl --user status lock-status
busctl --user call org.gnome.ScreenSaver /org/gnome/ScreenSaver org.gnome.ScreenSaver GetActive
```

The call answers `b false` while unlocked. To see what a page sees, run
an `IdleDetector` in the Teams tab's DevTools console; its `screenState`
turns `locked` within a second of locking:

```js
const d = new IdleDetector();
d.addEventListener('change', () => console.log(d.userState, d.screenState));
await d.start({ threshold: 60000 });
```

## Caveats

- Only `GetActive` and `ActiveChanged` are implemented. A program that
  calls another `org.gnome.ScreenSaver` method, such as `Lock`, gets an
  `UnknownMethod` error instead of finding no service.
- If Noctalia adds `GetActive`, Chromium will use it first and this
  feature can go. Every input update checks for it
  ([Update flake inputs](../howto/update-inputs.md#4-check-workarounds)).
