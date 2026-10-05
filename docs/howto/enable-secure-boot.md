# Turn on Secure Boot

For a host that is already installed with the
[secure-boot](../features/secure-boot.md) feature but has Secure Boot off.
A fresh install does this on its own over its first two boots
([Install or reinstall a host](install-host.md#5-first-boot)).

## 1. Put the firmware in setup mode

surface-laptop's firmware is in setup mode whenever Secure Boot shows as
**Disabled** in the Surface UEFI. On other hardware, look for an option to
reset to setup mode or erase the platform key. Don't clear all keys, which
also drops the list of revoked bootloaders (`dbx`).

## 2. Create and stage the keys

Apply the configuration with `just switch`. The switch also starts
`generate-sb-keys` and `prepare-sb-auto-enroll`, so the keys are created
and the ESP is re-signed right away. Check the keys and the staged
enrollment exist:

```sh
sudo sbctl status                  # Installed: ✓, Setup Mode: ✗ Enabled
sudo ls /boot/loader/keys/auto/    # PK.auth KEK.auth db.auth
sudo sbctl verify                  # boot entries and systemd-boot are signed
```

## 3. Reboot to enrol

systemd-boot enrolls the keys before showing the menu. On a Surface, leave
Secure Boot set to **Disabled** in the UEFI before the reboot; enrolling the
keys turns it on.

Check that Secure Boot is on:

```sh
bootctl status | grep 'Secure Boot'   # enabled (user)
sudo sbctl status                     # Secure Boot: ✓ Enabled
```

Then [enrol the TPM](enroll-tpm.md).
