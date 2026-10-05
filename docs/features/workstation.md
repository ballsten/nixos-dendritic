# workstation

The feature set shared by every desktop host.

| | |
|---|---|
| Module | `modules/features/workstation.nix` |
| Aspects | `nixos.workstation` |
| Hosts | All |
| Inputs | None |
| Persists | Nothing itself |
| Secrets | None itself |

`workstation` only imports other features; it has no settings of its own.
`modules/features/workstation.nix` is the list. Each imported feature has
its own page here.

What goes in:

- Features every host should have.

What stays out:

- Hardware-specific settings (kernel, firmware, drivers, power management,
  display scaling, input devices): in `modules/hosts/<host>/`.
- Host settings such as the hostname and time zone: in the host's
  `configuration.nix`.
- Gaming: in a separate `gaming` aspect that only `tiki-rig` imports (#9),
  so it can't reach `surface-laptop`.
- Users: each host imports its users' aspects itself.
