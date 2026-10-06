# fwupd

Firmware updates from [LVFS](https://fwupd.org) with
[fwupd](https://github.com/fwupd/fwupd), including the UEFI revocation list
(`dbx`).

| | |
|---|---|
| Module | `modules/features/fwupd.nix` |
| Aspects | `nixos.fwupd` |
| Hosts | All, through `workstation` |
| Inputs | None |
| Persists | `/var/lib/fwupd` (update history, pending updates, metadata) |
| Secrets | None |

## What it covers

- **`dbx`:** the list of signed bootloaders the firmware must refuse.
  Microsoft publishes updates signed with its KEK, which every host trusts
  ([secure-boot](secure-boot.md)), so fwupd can apply them without our
  keys. This is the main reason for the feature: an empty `dbx` lets an
  old, vulnerable Microsoft-signed bootloader bypass Secure Boot.
- **Device firmware** that vendors publish on LVFS: system firmware (UEFI
  capsules), and some docks, drives and peripherals.
  [surface-laptop](../hosts/surface-laptop.md) gets no system firmware
  this way; Microsoft shipped Surface Pro 6 firmware through Windows Update
  only, and the model is past end of support.

## How it fits with Secure Boot

UEFI capsule updates run a small EFI program, `fwupdx64.efi`, on the next
boot. With Secure Boot on, the firmware only runs it if it is signed. When
both lanzaboote and fwupd are enabled, lanzaboote's module adds a
`fwupd-efi` service that signs it with our `db` key into `/run/fwupd-efi`,
and points fwupd there. It also sets `DisableShimForSecureBoot`, since we
boot without shim.

Updating `dbx` or system firmware changes PCR 7, so the next boot asks for
the LUKS passphrase and the TPM needs enrolling again
([tpm-unlock](tpm-unlock.md)).

## Metadata

`fwupd-refresh.timer` (on by default in NixOS) downloads LVFS metadata in
the background. It never installs anything; updates are applied by hand
([Update firmware](../howto/update-firmware.md)).

## Persisted state

`/var/lib/fwupd` holds the update history and any pending capsule update.
A capsule is applied during the reboot after it is staged, and fwupd
reports the result from this history on the following boot, so it has to
survive the wipe.
