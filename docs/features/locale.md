# locale

The system locale.

| | |
|---|---|
| Module | `modules/features/locale.nix` |
| Aspects | `nixos.locale` |
| Hosts | All, through `workstation` |
| Inputs | None |
| Persists | Nothing |
| Secrets | None |

Sets `i18n.defaultLocale = "en_US.UTF-8"`. The time zone is set per host,
in each host's `configuration.nix`.
