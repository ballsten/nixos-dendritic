# screenshot

Screenshots with Noctalia's built-in capture, copied to the clipboard so
they paste straight into Obsidian.

| | |
|---|---|
| Module | `modules/features/screenshot.nix` |
| Aspects | `nixos.screenshot`, `homeManager.screenshot` |
| Hosts | All, through `workstation` |
| Inputs | None |
| Persists | Nothing (files land in `~/Pictures`, which the user persists) |
| Secrets | None |

Every home-manager user on the host gets the keybinds through
`home-manager.sharedModules`. It needs the [desktop](desktop.md) feature:
the capture is part of Noctalia, and the keybinds are added to Umbriel's
config. No screenshot app is installed.

## Keys

| Key | Captures |
|---|---|
| `Print` or `Mod+Shift+S` | A region you drag out |
| `Mod+Shift+A` | A region, then opens it for drawing arrows, boxes and text |
| `Mod+Print` | The focused window |
| `Shift+Print` | The focused monitor |

`Mod+Shift+S` is there for keyboards with no `Print` key, such as the
Surface Type Cover. The screen freezes while you pick a region; `Escape`
cancels.

## Pasting into Obsidian

Every capture is put on the clipboard as a PNG. `Ctrl+V` in an Obsidian
note saves it into the vault as an attachment and embeds it, in the folder
set under Settings → Files and links. The image then lives in the vault, so
it is kept and synced along with the notes.

## Saved copies

Each capture is also saved to the XDG Pictures folder (`~/Pictures`), named
by date and time. The folder survives a reboot only if the user persists it,
as `ballsten` does. Turn off `save_to_file` in the module to keep clipboard
copies only.
