# prun

Browser extensions for [Prosperous Universe](https://prosperousuniverse.com),
force-installed in LibreWolf.

| | |
|---|---|
| Module | `modules/features/prun.nix` |
| Aspects | `nixos.prun` |
| Hosts | All, through `workstation` |
| Inputs | None |
| Persists | Nothing itself; extension settings live in the LibreWolf profile, which [librewolf](librewolf.md) persists |
| Secrets | None |

| Extension | Add-on ID |
|---|---|
| [Refined PrUn](https://addons.mozilla.org/firefox/addon/refined-prun/) | `{c35c3edc-0acc-4531-b01c-35b6bede69fb}` |
| [FIO Client](https://addons.mozilla.org/firefox/addon/fio/) | `{d7a1061c-6d18-48fb-a42c-3f1c73b0cdf9}` |

## How it fits with librewolf

`prun` adds both to `librewolf.extensions`, an option the
[librewolf](librewolf.md) feature defines and turns into LibreWolf's
`ExtensionSettings` policy. It doesn't import `librewolf` itself: a host
that imports `prun` without `librewolf` fails evaluation on the unknown
option. See [0031](../decisions/0031-prun-feature.md) for why it is its
own feature.

## By hand

Log in to the FIO Client once per profile: open APEX, click the
extension's icon, and register or log in. The login is kept in the
LibreWolf profile, so it survives reboots.
