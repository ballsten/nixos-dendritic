# Install or reinstall a host

Partition, install and boot a host from the NixOS installer. A reinstall
keeps the host's SSH key and its persisted state, so its secrets still
decrypt. For a new host, start with [Add a host](add-host.md), which ends
here.

This wipes the whole disk. **Don't switch an existing non-impermanent
install to this configuration** with `nixos-rebuild`: its filesystems no
longer match, and the system won't boot.

## 1. Before wiping (reinstall only)

Everything worth keeping is under `/persist`: the SSH host key, the admin
age key, home and system state. Copy it to a USB stick mounted at
`/run/media/ballsten/USB` (adjust the path). tar keeps ownership and
permissions on any filesystem:

```sh
U=/run/media/ballsten/USB/restore
sudo du -sh /persist          # check it fits
mkdir -p "$U"
sudo tar -C /persist -cpf "$U/persist.tar" .
```

Push every repo under `~/repos` as well, and keep a separate backup of the
admin key (`~/.config/sops/age/keys.txt`): it's the recovery path for all
secrets.

### surface-laptop: build first

The `linux-surface` kernel isn't in the binary cache and takes about two
hours to build, so build the system on the old install and copy it over on
the USB stick (about 7 GiB) rather than building it in the installer:

```sh
cd ~/repos/nixos-dendritic && git switch main && git pull
nix build .#nixosConfigurations.surface-laptop.config.system.build.toplevel --print-out-paths > "$U/toplevel"
nix copy --to "file://$U/cache" "$(cat "$U/toplevel")"
```

## 2. Partition from the installer

1. Turn Secure Boot off in the firmware, which also puts it back into setup
   mode. On a Surface, hold **Volume Up** while powering on, then go to
   **Security → Secure Boot**. The NixOS installer isn't signed with our
   keys, so it won't boot with Secure Boot on.
2. Boot a NixOS installer USB and check the firmware is in setup mode:
   `bootctl status` shows `disabled (setup)`. On other hardware, see
   [Turn on Secure Boot](enable-secure-boot.md) for entering setup mode.
3. Connect to Wi-Fi (`nmtui`), and mount the USB stick with the backup
   (below, at `/media/usb`).
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
U=/media/usb/restore
sudo tar -C /mnt/persist -xpf "$U/persist.tar" --exclude=./var/lib/sbctl
```

For a new host, [Add a host](add-host.md#4-keys) has already written its
keys here.

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
   - `touch ~/Downloads/test`, reboot: it's gone, while `~/repos`, Brave
     (Bitwarden still logged in) and Claude Code's login remain.
   - `ssh -T git@github.com` and `gh auth status` work.
   - `bluetoothctl devices` lists the old pairings.
   - `systemctl hibernate`, then power on: the session resumes after the
     LUKS passphrase.
   - After a reboot, `bootctl status` shows `Secure Boot: enabled (user)`.
4. [Enrol the TPM](enroll-tpm.md). The old TPM key went with the old LUKS
   volume, so the passphrase is needed until then.
