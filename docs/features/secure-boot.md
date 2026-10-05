# Secure Boot and TPM unlock

Every host boots with Secure Boot on, using our own keys. This is the
`secure-boot` feature (`modules/features/secure-boot.nix`), which every host
gets via `workstation`. It uses
[lanzaboote](https://github.com/nix-community/lanzaboote) in place of plain
systemd-boot.

| | |
|---|---|
| Module | `modules/features/secure-boot.nix` |
| Aspects | `nixos.secure-boot` |
| Hosts | All, through `workstation` |
| Inputs | `lanzaboote` (pinned to a release tag; bump it by hand) |
| Persists | `/persist/var/lib/sbctl` (keys, read in place) |
| Secrets | None |

Boot settings: at most 10 boot menu entries (`configurationLimit`), and no
kernel command-line editing from the menu (`settings.editor = false`).
`sbctl` is installed for checking signatures and Secure Boot state.

With Secure Boot on, the TPM can unlock the disk at boot instead of the LUKS
passphrase ([TPM unlock](#tpm-unlock)).

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

## TPM unlock

The `tpm-unlock` feature (`modules/features/tpm-unlock.nix`, also in
`workstation`) lets the TPM unlock the root LUKS volume (`cryptroot`), so
the machine boots straight to the greeter. The passphrase keeps working as a
fallback: whenever the TPM refuses, or no key is enrolled, the initrd asks
for it as before.

### How it works

`just tpm-enroll` seals a new LUKS key in the TPM, which only releases it
while two PCRs (TPM registers that record the boot) match:

| PCR | Must be | Meaning |
|---|---|---|
| 7 | As at enrollment | Secure Boot is on, with our keys, and the same firmware Secure Boot settings |
| 15 | All zeros | No encrypted volume has been unlocked yet on this boot |

The initrd gets the key from the TPM, unlocks `cryptroot`, then records the
unlocked volume in PCR 15 (`tpm2-measure-pcr=yes`). From then on the TPM
refuses. This blocks two attacks:

- **A fake root partition.** Someone could replace the LUKS partition with
  one of their own and type its passphrase. Our signed initrd would boot
  their system, and PCR 7 would still match, but PCR 15 is no longer zero,
  so their system can't get our key.
- **The running system.** After boot, not even root can get the key back
  out of the TPM.

There's no TPM PIN. A powered-off laptop boots to the greeter, so the login
password is what protects a stolen machine. A pulled SSD is still useless
on its own.

### Enrolling

Once Secure Boot is on (`bootctl status`: `enabled (user)`):

```sh
just tpm-enroll
```

It asks for the LUKS passphrase and replaces any earlier TPM key. Reboot to
check: the disk unlocks without a prompt.

To see the enrolled slots, or to remove the TPM key and go back to the
passphrase only:

```sh
sudo systemd-cryptenroll /dev/disk/by-partlabel/disk-main-luks
sudo systemd-cryptenroll --wipe-slot=tpm2 /dev/disk/by-partlabel/disk-main-luks
```

### When it asks for the passphrase again

These change PCR 7, so the TPM refuses until you run `just tpm-enroll`
again:

- turning Secure Boot off, or re-enrolling Secure Boot keys
- firmware updates that change Secure Boot settings, including updates to
  the revoked-bootloader list (`dbx`)
- changes to Secure Boot settings in the firmware menu

Kernel and NixOS updates, and booting an older generation, don't change
PCR 7: lanzaboote signs every generation with the same key.

## If it won't boot

Turn Secure Boot off in the firmware. On a Surface, hold **Volume Up** while
powering on, then go to **Security → Secure Boot**. NixOS boots without
Secure Boot, and the keys on `/persist` are unchanged. The TPM won't unlock
the disk then, so type the LUKS passphrase.

To start over with new keys, put the firmware back into setup mode, then:

```sh
sudo rm -r /persist/var/lib/sbctl/keys /persist/var/lib/sbctl/GUID /boot/loader/keys/auto
sudo systemctl restart generate-sb-keys prepare-sb-auto-enroll
```

and reboot. Once Secure Boot is back on, run `just tpm-enroll`.

## Reinstalling

The NixOS installer USB isn't signed with our keys, so turn Secure Boot off
in the firmware before booting it, and check it is back in setup mode
(`bootctl status` in the installer: `disabled (setup)`). The fresh install
then generates and enrolls new keys over its first two boots. Run
`just tpm-enroll` once Secure Boot is on: disko creates a new LUKS volume, so
the old TPM key is gone. See
[impermanence.md](impermanence.md#install-or-reinstall-a-host).
