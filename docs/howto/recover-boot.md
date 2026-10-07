# Recover a host that won't boot

## A new generation is broken

Pick an older generation from the boot menu; the last 10 are listed. Then
fix the configuration, or roll back with `nixos-rebuild switch --rollback`.
Booting an older generation doesn't affect Secure Boot or the TPM.

## Secure Boot refuses to boot

Turn Secure Boot off in the firmware. On a Surface, hold **Volume Up** while
powering on, then go to **Security → Secure Boot**. NixOS boots without
Secure Boot, and the keys on `/persist` are unchanged. The TPM won't unlock
the disk then, so type the LUKS passphrase.

To start over with new keys, put the firmware back into setup mode, then:

```sh
sudo rm -r /persist/var/lib/sbctl/keys /persist/var/lib/sbctl/GUID /boot/loader/keys/auto
sudo systemctl restart generate-sb-keys prepare-sb-auto-enroll
```

and reboot. Once Secure Boot is back on, [enrol the TPM](enroll-tpm.md)
again.

## It asks for the LUKS passphrase

The TPM refused, which is expected after a firmware or Secure Boot change.
Type the passphrase, then run `just tpm-enroll`. See
[When it asks for the passphrase again](../features/secure-boot.md#when-it-asks-for-the-passphrase-again).

## Files are missing after a reboot

The path wasn't persisted. The previous root is kept for 30 days; see
[Persist state](persist-state.md#get-something-back-after-a-reboot).

## Login fails

Passwords come from sops, and root has no password. If the host can't
decrypt its secrets, there's no login password either. That happens when
`/persist/etc/ssh/ssh_host_ed25519_key` is missing or isn't the key
enrolled in `.sops.yaml`, for example after a reinstall that didn't restore
it. An older generation doesn't help, since the key lives on `/persist`.

Boot the installer, unlock and mount the disk, and restore the key from the
backup into `/mnt/persist/etc/ssh/`. If there is no backup, enrol the new
key from another machine as in [Add a host](add-host.md#3-keys), and
reinstall.
