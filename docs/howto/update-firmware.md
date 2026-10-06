# Update firmware

Firmware and the UEFI revocation list (`dbx`) are updated by hand with
`fwupdmgr`. See [fwupd](../features/fwupd.md) for what it covers.

## 1. Check what's available

```sh
fwupdmgr get-devices       # devices fwupd can update, with versions
fwupdmgr get-updates       # updates for them (metadata refreshes in the background)
```

If the metadata is stale, `fwupdmgr refresh` first.

## 2. Apply

```sh
fwupdmgr update
```

As a normal user it asks for your password through polkit (passwordless
sudo doesn't cover polkit); `sudo fwupdmgr update` works too. Updates are
of two kinds:

- **`dbx`** is written straight to the firmware's variables, and takes
  effect on the next boot.
- **Capsule updates** (system firmware) are staged on the ESP and applied
  by the firmware during the next reboot. Keep the machine on AC power.

## 3. Reboot and re-enrol the TPM

Both kinds change PCR 7, so the next boot asks for the LUKS passphrase.
Once logged in:

```sh
just tpm-enroll
```

The boot after that unlocks with the TPM again ([Enrol the TPM](enroll-tpm.md)).

## 4. Check

```sh
fwupdmgr get-history                      # result of the last update
ls -l /sys/firmware/efi/efivars/dbx-*     # dbx exists and isn't empty
fwupdmgr security                         # HSI checks, including dbx
bootctl status | grep 'Secure Boot'       # still enabled (user)
```

## If it won't boot

A `dbx` update only revokes bootloaders signed by others; fwupd checks the
ESP's own boot files against it before applying. If the machine still
refuses to boot, see [Recover a host that won't boot](recover-boot.md):
turning Secure Boot off gets it booting again.
