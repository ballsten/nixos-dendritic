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

## If `dbx` is empty

fwupd won't update a `dbx` that doesn't exist yet: the device has no
version, so `fwupdmgr get-updates` wrongly lists it as up to date, and
`fwupdmgr install` fails with "has no firmware version", even with
`--force`. surface-laptop was like this, since its firmware wiped `dbx`
when it went into Secure Boot setup mode. Check with:

```sh
ls /sys/firmware/efi/efivars/dbx-*   # "No such file" means empty
```

Write the first `dbx` by hand, from the same Microsoft-signed payload
fwupd would use. These steps need the dev shell (`gcab`, `efitools`).

1. Find the payload in fwupd's metadata. Pick the release signed by the
   KEK the host has: `fwupdmgr get-devices` shows `KEK CA` at version
   `2023` for Microsoft's 2023 KEK, which uses
   `com.microsoft.dbx.x64-kek2023`; a host with only the 2011 KEK uses
   `com.microsoft.dbx.x64`. The newest release is listed first.

   ```sh
   zstdcat /var/lib/fwupd/metadata/lvfs/firmware.xml.zst | tr '\n' ' ' \
     | sed 's#</component>#&\n#g' \
     | grep '<id>com.microsoft.dbx.x64-kek2023.firmware</id>' \
     | grep -oE 'https://[^<]*\.cab' | head -1
   ```

2. Download it, check the name starts with its SHA-256, and extract it:

   ```sh
   curl -fLO <url>
   sha256sum *DBXUpdate*.cab
   gcab -x *DBXUpdate*.cab     # gives DBXUpdate-<date>.x64.bin
   ```

3. Append it to `dbx`. The firmware checks Microsoft's signature, so a bad
   payload is refused:

   ```sh
   sudo "$(command -v efi-updatevar)" -a -f DBXUpdate-<date>.x64.bin dbx
   ```

   This skips fwupd's check of the ESP's boot files against the new list.
   Our boot files are signed with our own `db` key, which `dbx` doesn't
   revoke.

4. Carry on from step 3 above: reboot, then `just tpm-enroll`. After the
   reboot `fwupdmgr get-devices` shows the `dbx` version, and later
   updates go through `fwupdmgr update` as normal.

## If it won't boot

A `dbx` update only revokes bootloaders signed by others; fwupd checks the
ESP's own boot files against it before applying. If the machine still
refuses to boot, see [Recover a host that won't boot](recover-boot.md):
turning Secure Boot off gets it booting again.
