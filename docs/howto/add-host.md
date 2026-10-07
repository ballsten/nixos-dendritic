# Add a host

A host is a directory under `modules/hosts/<host>/` that defines the
`nixos.<host>` aspect and its `nixosConfigurations` entry. Use
`modules/hosts/surface-laptop/` as the model, and see
[Architecture](../architecture.md#how-a-host-is-composed) for how a host is
composed.

The host's SSH key must be enrolled in `.sops.yaml` before its first boot:
the login password comes from sops, and root has no password. So the key
is generated ahead of the install onto the installer stick, and enrolled
before the installer runs ([0029](../decisions/0029-host-keys-before-install.md)).

## 1. Collect hardware details

Boot the NixOS installer from [the USB stick](install-host.md#the-usb-stick)
on the new machine (with Secure Boot off; see
[Install or reinstall a host](install-host.md#2-partition-from-the-installer)),
then:

```sh
ls -l /dev/disk/by-id/ | grep -v part                  # disk ID for disk.nix
free -g                                                # RAM, to size swap
nixos-generate-config --no-filesystems --show-hardware-config
```

Copy the hardware config output; it becomes `_hardware-configuration.nix`.
`--no-filesystems` leaves out mounts, which come from `disk.nix`.

## 2. Write the host

On a working machine, branch (`feat/<host>`) and create:

| File | Contents |
|---|---|
| `configuration.nix` | `nixos.<host>` importing `workstation` and the users, plus `networking.hostName`, `time.timeZone` and `system.stateVersion` (the installer's release, e.g. `"25.11"`) |
| `flake-parts.nix` | `flake.nixosConfigurations = inputs.self.lib.mkNixos "x86_64-linux" "<host>";` |
| `disk.nix` | A copy of surface-laptop's, with the new disk ID and a swapfile at least the size of RAM (for hibernate). Keep the LUKS name `cryptroot` and the subvolumes `@root`, `@nix`, `@persist` and `@swap`. |
| `hardware.nix` | Imports `./_hardware-configuration.nix`; CPU microcode, firmware, drivers, `boot.loader.efi.canTouchEfiVariables`, and any nixos-hardware module for the machine |
| `_hardware-configuration.nix` | The output from step 1 |
| `display.nix` | Display outputs and scaling, if needed (see surface-laptop's) |

Check nixos-hardware for a module matching the machine before writing
hardware settings by hand. Confirm the GPU vendor before adding graphics
drivers. Gaming goes in the `gaming` aspect, imported only by this host's
`configuration.nix`.

Add `docs/hosts/<host>.md` (see [Writing a page](../README.md#writing-a-page))
and a row in the docs index, and update the Hosts table in `CLAUDE.md`.

Build it, then push the branch:

```sh
just check
just build <host>
git push -u origin feat/<host>
```

## 3. Keys

On the working machine, which has the admin key, generate the host's SSH
key onto the installer stick's `KEYS` partition
([The USB stick](install-host.md#the-usb-stick)), and enrol it:

```sh
udisksctl mount -b /dev/disk/by-label/KEYS     # at /run/media/ballsten/KEYS
K=/run/media/ballsten/KEYS
mkdir -p "$K/<host>"
ssh-keygen -q -t ed25519 -N "" -C "root@<host>" -f "$K/<host>/ssh_host_ed25519_key"
just enrol-host <host> "$K/<host>/ssh_host_ed25519_key.pub"
cp ~/.config/sops/age/keys.txt "$K/"
udisksctl unmount -b /dev/disk/by-label/KEYS
git commit -am "feat: enrol <host> as a secrets recipient" && git push
```

`enrol-host` adds the recipient to `.sops.yaml` with the host's name as
its comment, and re-encrypts the secrets. The host's private key is only
on the stick, never in the repo or on the working machine's disk. The
admin key goes along because home-manager secrets decrypt with it.

If the host already has its configuration on `main`, as when its files
were merged before the install, enrol it in its own PR and merge that
before installing; the installer then clones `main`.

## 4. Partition and install

Back in the installer, with the stick's `KEYS` partition mounted at
`/media/keys` ([Install or reinstall a host](install-host.md#2-partition-from-the-installer),
steps 1–4), partition with the branch:

```sh
git clone -b feat/<host> https://github.com/ballsten/nixos-dendritic && cd nixos-dendritic
sudo "$(nix --extra-experimental-features 'nix-command flakes' build --no-link --print-out-paths \
  .#nixosConfigurations.<host>.config.system.build.diskoScript)"
```

Copy the keys from the stick into `/persist`:

```sh
K=/media/keys
sudo install -d -m 755 /mnt/persist/etc/ssh
sudo install -m 600 "$K/<host>/ssh_host_ed25519_key" /mnt/persist/etc/ssh/
sudo install -m 644 "$K/<host>/ssh_host_ed25519_key.pub" /mnt/persist/etc/ssh/
# ballsten is uid 1000, group users (100)
sudo install -d -m 700 -o 1000 -g 100 /mnt/persist/home/ballsten \
  /mnt/persist/home/ballsten/.config /mnt/persist/home/ballsten/.config/sops \
  /mnt/persist/home/ballsten/.config/sops/age
sudo install -m 600 -o 1000 -g 100 "$K/keys.txt" /mnt/persist/home/ballsten/.config/sops/age/keys.txt
```

Then follow [Install or reinstall a host](install-host.md#4-install) from
step 4, building with `nixos-install --flake .#<host>`. Once the host has
booted, delete the keys from the stick.

## 5. Open the PR

Open the PR from `feat/<host>` once the host has booted, with the results
of the first-boot checks in "Manual testing".
