# Impermanence

Every host wipes its root, including `/home`, on every boot. Only paths
declared under `/persist` survive. This is the `impermanence` feature
(`modules/features/impermanence.nix`), which every host gets via
`workstation`.

| | |
|---|---|
| Module | `modules/features/impermanence.nix` |
| Aspects | `nixos.impermanence` |
| Hosts | All, through `workstation` |
| Inputs | `impermanence`, `disko` |
| Persists | `/var/log`, `/var/lib/nixos`, `/var/lib/systemd/coredump`, `/var/lib/systemd/timers`, `/etc/machine-id` |
| Secrets | None |

## How it works

Each host has one LUKS-encrypted btrfs filesystem, declared with disko in
`modules/hosts/<host>/disk.nix`:

| Subvolume | Mounted at | On boot |
|---|---|---|
| `@root` | `/` | Replaced with an empty subvolume |
| `@nix` | `/nix` | Kept |
| `@persist` | `/persist` | Kept |
| `@swap` | `/swap` | Kept (swapfile, used for hibernate) |

On every boot, a service in the initrd (`rollback-root`) runs after the LUKS
unlock and after any resume from hibernate. It moves `@root` to
`/old_roots/<time>`, deletes old roots older than 30 days and creates an
empty `@root`. NixOS activation then rebuilds `/etc`, and impermanence
bind-mounts the persisted paths from `/persist` into place.

## Persisting a path

Persist state in the feature that creates it, next to its config:

```nix
# NixOS module: absolute paths
environment.persistence."/persist".directories = [ "/var/lib/bluetooth" ];

# home-manager module: paths relative to home
home.persistence."/persist".directories = [ ".config/BraveSoftware" ];
```

Prefer directories to single files. A persisted file is bind-mounted, and a
program that saves it by renaming a new file over it fails with `EBUSY`. If a
program keeps a lone file in home, look for an option that moves it into a
directory instead (for example `CLAUDE_CONFIG_DIR` for Claude Code).

Keys needed during activation are read straight from `/persist`, not from
bind mounts: the SSH host key (`services.openssh.hostKeys`, used by sops) and
the admin age key (`sops.age.keyFile`).

## Finding unpersisted state

Everything on `/` that isn't persisted is on the `@root` subvolume, and the
other subvolumes are separate filesystems to `find -xdev`:

```sh
sudo find / -xdev -type f -newermt '-1 hour' 2>/dev/null
```

Anything listed there is lost on the next reboot. To get something back
after a reboot, look in the old roots:

```sh
sudo mount -o subvol=/ /dev/mapper/cryptroot /mnt
ls /mnt/old_roots/
sudo umount /mnt
```

## Install or reinstall a host

This wipes the whole disk. **Don't switch an existing non-impermanent
install to this configuration** with `nixos-rebuild`: its filesystems no
longer match, and the system won't boot.

### 1. Before wiping

On the old install, with a USB stick mounted at `/run/media/ballsten/USB`
(adjust the path):

```sh
U=/run/media/ballsten/USB/restore

# Keys: without them sops can't decrypt the login password.
sudo install -d -m 700 "$U/ssh"
sudo cp -a /etc/ssh/ssh_host_ed25519_key /etc/ssh/ssh_host_ed25519_key.pub "$U/ssh/"
install -D -m 600 ~/.config/sops/age/keys.txt "$U/home/.config/sops/age/keys.txt"

# State to keep. Claude Code's config file moves inside ~/.claude.
cp -a ~/.claude "$U/home/.claude"
cp -a ~/.claude.json "$U/home/.claude/.claude.json"
cp -a ~/.config/BraveSoftware "$U/home/.config/"
cp -a ~/.local/share/fish ~/.local/share/direnv "$U/home/" 2>/dev/null || true
cp -a ~/Documents ~/Pictures ~/Music ~/Videos "$U/home/" 2>/dev/null || true
sudo cp -a /var/lib/bluetooth "$U/bluetooth"
```

Push every repo under `~/repos` (or copy it too), and keep a separate backup
of the admin key: it's the recovery path for all secrets.

The `linux-surface` kernel isn't in the binary cache and takes hours to
build, so build the system on the old install and copy it over on the USB
stick (about 7 GiB) rather than building it in the installer:

```sh
cd ~/repos/nixos-dendritic && git switch main && git pull
nix build .#nixosConfigurations.surface-laptop.config.system.build.toplevel --print-out-paths > "$U/toplevel"
nix copy --to "file://$U/cache" "$(cat "$U/toplevel")"
```

### 2. Partition from the installer

1. Turn Secure Boot off in the firmware, which also puts it back into setup
   mode (see [secure-boot.md](secure-boot.md#reinstalling)). Boot a NixOS
   installer USB. The Type Cover works there with the stock kernel.
2. Connect to Wi-Fi (`nmtui`), and mount the USB stick with the backup
   (below, at `/media/usb`).
3. Check the disk ID in `disk.nix` matches: `ls -l /dev/disk/by-id/ | grep nvme`.
4. Partition, format and mount with the locked disko version. This asks for
   the new LUKS passphrase:

   ```sh
   git clone https://github.com/ballsten/nixos-dendritic && cd nixos-dendritic
   sudo "$(nix --extra-experimental-features 'nix-command flakes' build --no-link --print-out-paths \
     .#nixosConfigurations.surface-laptop.config.system.build.diskoScript)"
   ```

### 3. Restore keys and state into `/persist`

```sh
U=/media/usb/restore
P=/mnt/persist

sudo install -d -m 755 $P/etc/ssh
sudo install -m 600 $U/ssh/ssh_host_ed25519_key $P/etc/ssh/
sudo install -m 644 $U/ssh/ssh_host_ed25519_key.pub $P/etc/ssh/

# ballsten is uid 1000, group users (100).
sudo install -d -m 700 -o 1000 -g 100 $P/home/ballsten
sudo cp -a $U/home/. $P/home/ballsten/
sudo mkdir -p $P/home/ballsten/.local/share
sudo mv $P/home/ballsten/fish $P/home/ballsten/direnv $P/home/ballsten/.local/share/ 2>/dev/null || true
sudo chown -R 1000:100 $P/home/ballsten
sudo chmod 600 $P/home/ballsten/.config/sops/age/keys.txt

sudo install -d -m 755 $P/var/lib
sudo cp -a $U/bluetooth $P/var/lib/bluetooth
```

### 4. Install

```sh
sudo nix --extra-experimental-features nix-command copy --no-check-sigs \
  --from file://$U/cache --to /mnt "$(cat $U/toplevel)"
sudo nixos-install --system "$(cat $U/toplevel)" --no-root-passwd
```

Root has no password; ballsten's comes from sops.

### 5. First boot

1. Type the LUKS passphrase, then log in as ballsten. The boot files are
   unsigned on this first boot. Secure Boot keys are generated in the
   background, and the next reboot enrolls them
   ([secure-boot.md](secure-boot.md)).
2. Clone repos back into `~/repos` if they weren't copied, and run
   `direnv allow` in each.
3. Check that it all works:
   - `touch ~/Downloads/test`, reboot: it's gone, while `~/repos`, Brave
     (Bitwarden still logged in) and Claude Code's login remain.
   - `ssh -T git@github.com` and `gh auth status` work.
   - `bluetoothctl devices` lists the old pairings.
   - `systemctl hibernate`, then power on: the session resumes after the
     LUKS passphrase.
   - After a reboot, `bootctl status` shows `Secure Boot: enabled (user)`.
     Then run `just tpm-enroll`, and the next boot unlocks without the
     passphrase.
