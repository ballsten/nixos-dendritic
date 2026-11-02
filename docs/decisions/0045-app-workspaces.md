# 0045: Apps on their own named workspaces, toggled with Mod+Alt+<letter>

- **Status:** Accepted, 2026-11-01

## Context

Obsidian should come up with one key and go away again, without taking a
place in the normal layout (#67). On `tiki-rig` it should fill the left
monitor. More apps will want the same, so it needs to be a convention
rather than an Obsidian-only setting.

Umbriel offers three ways to do it:

- **Scratchpads** hide and show windows with one key, and a named one can
  start its app when empty (`spawn_when_empty`). But a scratchpad always
  appears on the monitor under the pointer, and the toggle takes no output.
  Defining any named scratchpad also removes the implicit `default` one
  that the packaged `Mod+Space` bindings use.
- **Pinned windows** float on a chosen monitor, but Umbriel has no
  minimise, so hiding one means closing it, as the calculator does
  ([0042](0042-calculator-pinned-toggle.md)).
- **Named workspaces** can be tied to an output with a `[[workspace]]`
  entry, persist when empty, and a window rule can open an app on one.

## Decision

Each app gets a named workspace, named after its role (`Notes` for
Obsidian), and the key `Mod+Alt` plus the name's first letter, so the bar
shows the reminder. A window rule opens the app there at full width. The
key runs a script that switches the monitor to the workspace and starts the
app if needed, or switches back when it's already showing. Hosts with
several monitors choose the output once, with `appWorkspaces.output`.

The script remembers the replaced workspace itself, because
`workspace-focus-last` acts on the monitor under the pointer, which on
`tiki-rig` may be the right one.

## Consequences

- Obsidian stays running between toggles, so every press after the first
  is instant, and it's always on DP-3.
- The app replaces what the monitor was showing rather than floating over
  it.
- The packaged scratchpad bindings are untouched.
- The workspaces show in the bar even when the app isn't running.

## Alternatives considered

- **A named scratchpad per app:** floats over the current workspace, but
  appears on the pointer's monitor, and needs the packaged `Mod+Space`
  bindings moved to a named scratchpad.
- **A pinned window, closed on toggle:** always on the left monitor, but
  Obsidian starts afresh on every press.
- **A scratchpad, with the script warping the pointer to the left monitor
  first:** fixed monitor and instant, but the pointer jumps and Umbriel has
  no action to warp to an output, only to a window.
- **`workspaces.back_and_forth = true` instead of a remembered workspace:**
  pressing the key again would return without a script, but it changes what
  the numbered workspace keys do everywhere.
