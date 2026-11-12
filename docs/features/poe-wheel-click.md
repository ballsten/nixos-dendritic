# poe-wheel-click

While Path of Exile has focus, each notch of the mouse wheel is a left
click, as [XMouseButtonControl](https://www.highrez.co.uk/downloads/xmousebuttoncontrol.htm)
does on Windows. Hold Ctrl and roll the wheel over the inventory to move
items into the stash one per notch, instead of clicking each one. Everywhere
else, the wheel scrolls.

| | |
|---|---|
| Module | `modules/features/poe-wheel-click.nix` |
| Aspects | `nixos.poe-wheel-click`, `homeManager.poe-wheel-click` |
| Hosts | `tiki-rig` |
| Inputs | None |
| Persists | Nothing |
| Secrets | None |

## How it works

- **System side:** `services.input-remapper` runs the input-remapper
  daemon. While a preset is injected, it grabs the mouse and sends its
  events through a virtual device instead, with the mapped ones changed.
  The host names the mouse with `poeWheelClick.device`, as
  `input-remapper-control --list-devices` lists it.
- **User side:** the `poe-wheel-click` user service follows
  `umbriel subscribe windows`. When the window with keyboard focus is
  Path of Exile (app id `pathofexilesteam.exe`, title `Path of Exile`), it
  starts the preset with `input-remapper-control`; when focus moves
  anywhere else, it stops it. Stopping the service stops the preset, so a
  crash leaves the wheel scrolling, not clicking.

The preset maps `REL_WHEEL` up and down to `BTN_LEFT`, and disables
`REL_WHEEL_HI_RES`, which the G502 also reports and which would still
scroll. It's generated in Nix and copied into
`$XDG_RUNTIME_DIR/poe-wheel-click` when the service starts, with a
`config.json` holding input-remapper's version: input-remapper migrates
and rewrites its config files when their version is older, so they can't
be read-only links in `~/.config`.

input-remapper treats the wheel as a button: pressed while it turns, and
released `release_timeout` after the last notch. Its default, 50 ms, is
longer than the gap between notches on a quick spin, which would merge
them into one long click. The preset sets 10 ms, with `rel_rate` at 200
so the release is checked every 5 ms. If a fast spin still drops clicks,
or the game misses them, these are the two values to change.

The title is matched as well as the app id because PoE 2 may run under the
same executable name, and only PoE 1 gets the remap.

## Checking it

```sh
systemctl --user status poe-wheel-click
journalctl --user -u poe-wheel-click -f   # start/stop as focus changes
```

`input-remapper-gtk` shows the device and the injected preset, but changes
made there aren't kept: the preset comes from the module.

See [0051](../decisions/0051-poe-wheel-click.md) for why it's done this
way.
