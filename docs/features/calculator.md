# calculator

[GNOME Calculator](https://apps.gnome.org/Calculator/), opened and closed
with `Mod+C` and pinned above other windows.

| | |
|---|---|
| Module | `modules/features/calculator.nix` |
| Aspects | `nixos.calculator`, `homeManager.calculator` |
| Hosts | All, through `workstation` |
| Inputs | None |
| Persists | Nothing |
| Secrets | None |

Every home-manager user on the host gets the app through
`home-manager.sharedModules`. It needs the [desktop](desktop.md) feature,
whose Umbriel config the keybind and window rule are added to.

## Mod+C

`Mod+C` runs `calculator-toggle`. If a calculator window is open it closes
it, otherwise it starts one. Closing clears the number on screen. Umbriel
has no minimise, and a scratchpad, which would hide it instead, can't be
pinned or kept on one monitor
([0042](../decisions/0042-calculator-pinned-toggle.md)).

The calculator can still be started from the launcher; `Mod+C` then closes
it.

## Floating on top

A window rule opens it pinned, 20 px in from the bottom-right corner.
Pinned windows float above the others on every workspace of their monitor.
`Mod+P` unpins it, and `Mod+T` tiles it.

On a host with several monitors, the host picks the calculator's monitor
with its own `default_output` rule. `tiki-rig` puts it on DP-3, the left
monitor (see [tiki-rig](../hosts/tiki-rig.md#display)).

## Nothing persisted

Its settings (mode, precision, window size) live in dconf and its exchange
rates in `~/.cache`. Both reset on reboot, which is fine for a calculator.
