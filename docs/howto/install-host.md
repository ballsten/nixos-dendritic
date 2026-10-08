# Install or reinstall a host

Partition, install and boot a host from the NixOS installer. A reinstall
keeps the host's SSH key and its persisted state, so its secrets still
decrypt. For a new host, start with [Add a host](add-host.md), which ends
here.

This wipes the whole disk. **Don't switch an existing non-impermanent
install to this configuration** with `nixos-rebuild`: its filesystems no
longer match, and the system won't boot.

## The USB stick

One stick carries the installer and the files the install needs: the
host's keys, and for a reinstall the `/persist` backup. Writing the
installer ISO leaves the rest of the stick unused, so a second partition
after the ISO, labelled `KEYS`, holds the files.

On any Linux machine, with the stick at `/dev/sdX` (check with `lsblk`):

```sh
iso=nixos-minimal-<release>-x86_64-linux.iso dev=/dev/sdX
sudo dd if="$iso" of="$dev" bs=4M status=progress oflag=sync
sudo sfdisk -l "$dev"
```

The ISO's partition table lists a small EFI partition, which lies inside
the image. Delete any other partition listed
(`sudo sfdisk --delete "$dev" <n>`): if it overlaps the ISO, formatting it
overwrites the installer. Then add `KEYS`, starting 64 MiB past the end of
the ISO, and mount it:

```sh
start=$(( ($(stat -c %s "$iso") / 1048576 + 64) * 2048 ))   # in sectors
echo "start=$start, type=c" | sudo sfdisk --append --wipe never "$dev"
sudo mkfs.vfat -F 32 -n KEYS "${dev}2"
udisksctl mount -b /dev/disk/by-label/KEYS     # at /run/media/ballsten/KEYS
```

`KEYS` is FAT32, so any machine can read and write it
([0030](../decisions/0030-keys-partition-fat32.md)). udisks mounts it as
ballsten, so it's writable without `sudo`. FAT32 holds no file larger than
4 GiB, which is why the `/persist` backup below is split into parts.

The stick holds private keys until the host is installed. Delete them
after the first boot.

## 1. Before wiping (reinstall only)

Everything worth keeping is under `/persist`: the SSH host key, the admin
age key, home and system state. Copy it to the stick's `KEYS` partition
([The USB stick](#the-usb-stick)). tar keeps ownership and permissions,
which FAT32 can't, and `split` keeps each part under FAT32's 4 GiB limit:

```sh
U=/run/media/ballsten/KEYS/restore
sudo du -sh /persist          # check it fits
mkdir -p "$U"
sudo tar -C /persist -cpf - . | split -b 4000M - "$U/persist.tar."
```

Push every repo under `~/repos` as well, and keep a separate backup of the
admin key (`~/.config/sops/age/keys.txt`): it's the recovery path for all
secrets.

### tiki-rig: Windows, BitLocker and BIOS first

tiki-rig dual-boots Windows from its second disk. Before its first install,
work through [Before installing](../hosts/tiki-rig.md#before-installing)
on its host page: Windows updates, BitLocker, the BIOS update and the Steam
library.

### surface-laptop: build first

The `linux-surface` kernel isn't in the binary cache and takes about two
hours to build, so build the system on the old install and copy it over on
the stick (about 7 GiB) rather than building it in the installer:

```sh
cd ~/repos/nixos-dendritic && git switch main && git pull
nix build .#nixosConfigurations.surface-laptop.config.system.build.toplevel --print-out-paths > "$U/toplevel"
nix copy --to "file://$U/cache" "$(cat "$U/toplevel")"
```

## 2. Partition from the installer

1. Turn Secure Boot off and put the firmware in setup mode. The NixOS
   installer isn't signed with our keys, so it won't boot with Secure Boot
   on. On a Surface, hold **Volume Up** while powering on, then go to
   **Security → Secure Boot**; turning it off also enters setup mode. Other
   firmware may need the platform key deleted as well: see the host's page
   (tiki-rig: [Firmware](../hosts/tiki-rig.md#secure-boot)) or
   [Turn on Secure Boot](enable-secure-boot.md).
2. Boot the installer from [the USB stick](#the-usb-stick) and check the
   firmware is in setup mode: `bootctl status` shows `disabled (setup)`.
   Don't go on while it shows plain `disabled`: our keys won't be enrolled
   on the first boots, and turning Secure Boot on fails until they are.
3. Connect to Wi-Fi (`nmtui`), and mount the stick's `KEYS` partition:
   `sudo mkdir -p /media/keys && sudo mount -o loop /dev/disk/by-label/KEYS /media/keys`.
   A plain `mount` fails with "Can't open blockdev": the installer holds
   the whole stick open for the ISO, and `-o loop` mounts the partition
   through a loop device instead.
4. Check the disk ID in the host's `disk.nix` matches:
   `ls -l /dev/disk/by-id/ | grep nvme`.
5. Partition, format and mount with the locked disko version. This asks
   for the new LUKS passphrase:

   ```sh
   git clone https://github.com/ballsten/nixos-dendritic && cd nixos-dendritic
   sudo "$(nix --extra-experimental-features 'nix-command flakes' build --no-link --print-out-paths \
     .#nixosConfigurations.<host>.config.system.build.diskoScript)"
   ```

   For a new host, clone its branch: `git clone -b <branch> …`.

## 3. Restore `/persist`

For a reinstall, unpack the backup, leaving out the old Secure Boot keys so
new ones are generated and enrolled:

```sh
U=/media/keys/restore
cat "$U"/persist.tar.* | sudo tar -C /mnt/persist -xpf - --exclude=./var/lib/sbctl
```

For a new host, copy its keys from the stick instead, as in
[Add a host](add-host.md#4-partition-and-install).

## 4. Install

surface-laptop, from the system built in step 1:

```sh
sudo nix --extra-experimental-features nix-command copy --no-check-sigs \
  --from "file://$U/cache" --to /mnt "$(cat "$U/toplevel")"
sudo nixos-install --system "$(cat "$U/toplevel")" --no-root-passwd
```

Any other host, built in the installer:

```sh
sudo nixos-install --flake .#<host> --no-root-passwd
```

Root has no password; ballsten's comes from sops.

## 5. First boot

1. Type the LUKS passphrase, then log in as ballsten. The boot files are
   unsigned on this first boot. Secure Boot keys are generated in the
   background, and the next reboot enrolls them
   ([secure-boot](../features/secure-boot.md#how-it-works)).
2. Clone repos back into `~/repos` if they weren't restored, and run
   `direnv allow` in each.
3. Check that it all works:
   - `touch ~/wipe-test`, reboot: it's gone, while `~/repos`, Brave
     (Bitwarden still logged in) and Claude Code's login remain.
   - `ssh -T git@github.com` and `gh auth status` work.
   - `bluetoothctl devices` lists the old pairings.
   - On a host that hibernates (not tiki-rig, which only suspends):
     `systemctl hibernate`, then power on: the session resumes after the
     LUKS passphrase.
   - After a reboot, `bootctl status` shows `Secure Boot: enabled (user)`.
4. [Enrol the TPM](enroll-tpm.md). The old TPM key went with the old LUKS
   volume, so the passphrase is needed until then.
