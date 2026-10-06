# 0020: fwupd on every host, for dbx and firmware updates

- **Status:** Accepted, 2026-10-06
- **Issue:** #48

## Context

`dbx`, the firmware's list of revoked bootloaders, is empty on
surface-laptop: the Surface firmware probably wiped it when it went into
Secure Boot setup mode, before #46. Every host trusts Microsoft's keys
([0017](0017-secure-boot.md)), so with an empty `dbx` an old, vulnerable
Microsoft-signed bootloader could be booted to bypass Secure Boot. TPM
unlock isn't exposed by this, since a different bootloader changes PCR 7
([0018](0018-tpm-unlock.md)), but Secure Boot itself is.

## Decision

The [fwupd](../features/fwupd.md) feature enables `services.fwupd`:

- **On every host**, through `workstation`. `dbx` matters wherever Secure
  Boot trusts Microsoft's keys, which is every host, and fwupd finds the
  devices it can update at runtime.
- **`/var/lib/fwupd` is persisted**, so update history and pending capsule
  updates survive the reboot that applies them.
- **Metadata refreshes in the background** with NixOS's default
  `fwupd-refresh.timer`. Updates are only applied by hand.
- **No signing setup:** lanzaboote signs fwupd's EFI capsule updater with
  our `db` key whenever both are enabled.

## Consequences

- `dbx` can be brought up to date with `fwupdmgr update`, signed by
  Microsoft's KEK, without touching our own keys.
- fwupd can't create an empty `dbx`: with no version to compare, it
  reports `dbx` as up to date and refuses to install. On surface-laptop
  the first `dbx` (20260707) was written by hand with `efi-updatevar`,
  from the same Microsoft-signed payload on LVFS
  ([Update firmware](../howto/update-firmware.md#if-dbx-is-empty)).
  After that, fwupd shows its version and can update it. Adding
  `efitools` and `gcab` to the dev shell was simpler than scripting the
  same steps in a recipe for something done once per host.
- Every `dbx` or system firmware update changes PCR 7, so it's followed by
  one passphrase boot and `just tpm-enroll`
  ([Update firmware](../howto/update-firmware.md)).
- surface-laptop gets no system firmware from LVFS; Surface Pro 6 firmware
  was only ever shipped through Windows Update.
- About 48 MiB more in the closure, including udisks2, which fwupd needs
  to update disk firmware.

## Alternatives considered

- **Per host:** firmware is hardware-specific, but fwupd itself isn't, and
  every host has the same `dbx` exposure.
- **Refresh by hand only:** one less timer, but `fwupdmgr get-updates`
  would show stale results until `fwupdmgr refresh` is run.
- **Not persisting `/var/lib/fwupd`:** updates still apply, but their
  results are lost on reboot and metadata is downloaded again every boot.
