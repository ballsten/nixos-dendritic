# 0017: Secure Boot with lanzaboote and our own keys

- **Status:** Accepted, 2026-10-05
- **Issue:** #45
- **PR:** #46

## Context

The ESP is unencrypted. Without Secure Boot, anyone with the machine could
replace the kernel or initrd, and binding the disk key to the TPM
([0018](0018-tpm-unlock.md)) wouldn't mean much.

## Decision

The [secure-boot](../features/secure-boot.md) feature replaces systemd-boot
with lanzaboote, on every host through `workstation`:

- lanzaboote generates our keys on the first boot and systemd-boot enrolls
  them on the next, while the firmware is in setup mode
  (`autoGenerateKeys`, `autoEnrollKeys`).
- The Microsoft keys are enrolled too (lanzaboote's default), so firmware
  drivers (option ROMs) and vendor tools signed by Microsoft still load.
- Keys live in `/persist/var/lib/sbctl`, read directly.
- The input tracks a release tag, as lanzaboote recommends.

Secure Boot first and TPM unlock second, in separate PRs, once Secure
Boot was live and verified.

## Consequences

- The NixOS installer isn't signed with our keys; reinstalling starts with
  turning Secure Boot off.
- With the Microsoft keys trusted, an empty revocation list (`dbx`) leaves
  old, vulnerable Microsoft-signed bootloaders bootable. `dbx` is empty on
  surface-laptop; #48 plans fwupd to restore it.
- Recovery is turning Secure Boot off in the firmware
  ([Recover a host](../howto/recover-boot.md)).
- `lanzaboote` is bumped by hand, not by `nix flake update`.

## Alternatives considered

- **Only our own keys:** a machine whose firmware drivers are signed by
  Microsoft might not boot.
