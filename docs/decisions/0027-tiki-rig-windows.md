# 0027: Windows stays on tiki-rig's second disk, with Secure Boot on

- **Status:** Accepted, 2026-10-07
- **Issue:** #9

## Context

tiki-rig has two 1TB NVMe disks: a Kingston NV3 with the old NixOS install,
and a WD SN750 with Windows 11 and its own ESP. Every host has Secure Boot
with our own keys and TPM unlock ([0017](0017-secure-boot.md),
[0018](0018-tpm-unlock.md)), which was written for a laptop. A desktop that
stays at home gains less from it, and Windows complicates both.

## Decision

- **Windows stays** on the WD disk, untouched. NixOS replaces the old
  install on the Kingston, and `disk.nix` names only that disk.
- **Secure Boot and TPM unlock stay**, through `workstation`, as on
  surface-laptop.
- **Windows is booted from the firmware's boot menu (F8).** lanzaboote has
  no way to add a boot entry for a loader on another ESP.

## Consequences

- Windows Update, BitLocker and the BIOS are dealt with before install
  ([tiki-rig](../hosts/tiki-rig.md#before-installing)): once our keys are
  enrolled, Windows can't update the firmware's keys, and BitLocker sees a
  changed Secure Boot state.
- The keyboard is behind a USB switch. With TPM unlock, booting doesn't
  depend on the switch pointing at tiki-rig.
- lanzaboote enrols Microsoft's certificates with ours, so Windows and the
  RTX 3080's option ROM still load with Secure Boot on.
- The Steam library shares the Kingston with NixOS
  ([0026](0026-games-subvolume.md)).

## Alternatives considered

- **Drop Windows** and install on the faster WD disk, keeping the old
  install as a fallback: kept Windows for games and tools that need it.
- **No Secure Boot or TPM unlock on tiki-rig:** less to manage at firmware
  updates, but the LUKS passphrase would need the keyboard switched to
  tiki-rig on every boot, and `workstation` would have to be split.
- **systemd-boot with an entry chaining to Windows' ESP** (the old config's
  `boot.loader.systemd-boot.windows`): not available with lanzaboote.
