# Secure Boot

Every host boots with Secure Boot on, using our own keys. This is the
`secure-boot` feature (`modules/features/secure-boot.nix`), which every host
gets via `workstation`. It uses
[lanzaboote](https://github.com/nix-community/lanzaboote) in place of plain
systemd-boot.

## How it works

Secure Boot makes the firmware refuse to start any boot file that isn't
signed by a key it trusts. The ESP (`/boot`) isn't encrypted, so without
Secure Boot anyone with the laptop could swap in a modified kernel or initrd.

lanzaboote installs systemd-boot and one signed boot entry per NixOS
generation. Each entry carries the hashes of its kernel and initrd, so they
are verified too.

| Path | Contents |
|---|---|
| `/persist/var/lib/sbctl/keys` | Our Secure Boot keys (PK, KEK, db). Root only. |
| `/boot/EFI/Linux/*.efi` | Signed boot entries, one per generation |
| `/boot/EFI/nixos/` | Kernels and initrds, verified by hash, not signed |

The keys sit on the encrypted disk and are read from `/persist` directly.

Enrollment needs the firmware in **setup mode**: no platform key (PK)
enrolled, so it accepts a new one. Provisioning then happens on its own:

1. **First boot with lanzaboote:** if `/persist/var/lib/sbctl/keys` doesn't
   exist, `generate-sb-keys.service` creates the keys. Next,
   `prepare-sb-auto-enroll.service` re-signs the ESP and puts the keys,
   with Microsoft's, in `/boot/loader/keys/auto/`.
2. **Next boot:** systemd-boot enrolls those keys into the firmware. The
   firmware leaves setup mode, and Secure Boot is on from then on.

The Microsoft keys are kept so that firmware drivers (option ROMs) signed by
Microsoft still load. Without them, a machine with such a device may not
boot.

## Turning it on for an existing install

surface-laptop's firmware is already in setup mode (Secure Boot shows as
**Disabled** in the Surface UEFI). On other hardware, enter setup mode
first: look for an option to reset to setup mode or erase the platform key.
Don't clear all keys, which also drops the list of revoked bootloaders
(`dbx`).

1. Apply the configuration (`just switch`). The switch also starts the two
   services above, so the keys are created and the ESP is re-signed right
   away.
2. Check the keys and staged enrollment exist:

   ```sh
   sudo sbctl status            # Installed: ✓, Setup Mode: ✗ Enabled
   sudo ls /boot/loader/keys/auto/    # PK.auth KEK.auth db.auth
   sudo sbctl verify            # boot entries and systemd-boot are signed
   ```

3. Reboot. systemd-boot enrolls the keys before showing the menu.
4. Check that Secure Boot is on:

   ```sh
   bootctl status | grep 'Secure Boot'   # enabled (user)
   sudo sbctl status                     # Secure Boot: ✓ Enabled
   ```

On a Surface, leave Secure Boot set to **Disabled** in the UEFI before the
reboot. Enrolling the keys turns it on.

## If it won't boot

Turn Secure Boot off in the firmware. On a Surface, hold **Volume Up** while
powering on, then go to **Security → Secure Boot**. NixOS boots without
Secure Boot, and the keys on `/persist` are unchanged.

To start over with new keys, put the firmware back into setup mode, then:

```sh
sudo rm -r /persist/var/lib/sbctl/keys /persist/var/lib/sbctl/GUID /boot/loader/keys/auto
sudo systemctl restart generate-sb-keys prepare-sb-auto-enroll
```

and reboot.

## Reinstalling

The NixOS installer USB isn't signed with our keys, so turn Secure Boot off
in the firmware before booting it, and check it is back in setup mode
(`bootctl status` in the installer: `disabled (setup)`). The fresh install
then generates and enrolls new keys over its first two boots. See
[impermanence.md](impermanence.md#install-or-reinstall-a-host).
