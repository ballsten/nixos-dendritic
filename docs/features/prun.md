# prun

Browser extensions for [Prosperous Universe](https://prosperousuniverse.com),
force-installed in Brave.

| | |
|---|---|
| Module | `modules/features/prun.nix` |
| Aspects | `nixos.prun` |
| Hosts | All, through `workstation` |
| Inputs | None |
| Persists | Nothing itself; extension settings live in the Brave profile, which [brave](brave.md) persists |
| Secrets | None |

| Extension | Chrome Web Store ID |
|---|---|
| [Refined PrUn](https://chromewebstore.google.com/detail/refined-prun/coabeheneafgglpakallmkienlidgaof) | `coabeheneafgglpakallmkienlidgaof` |
| [FIO Client](https://chromewebstore.google.com/detail/fio-client/honhnhpbngledkpkocmeihfgkfmocmkh) | `honhnhpbngledkpkocmeihfgkfmocmkh` |

## How it fits with brave

`prun` adds both IDs to `brave.extensions`, an option the
[brave](brave.md) feature defines and turns into Brave's
`ExtensionInstallForcelist`. It doesn't import `brave` itself: a host that
imports `prun` without `brave` fails evaluation on the unknown option.
See [0031](../decisions/0031-prun-feature.md) for why it is its own
feature.

## By hand

Log in to the FIO Client once per profile: open APEX, click the
extension's icon, and register or log in. The login is kept in the Brave
profile, so it survives reboots.
