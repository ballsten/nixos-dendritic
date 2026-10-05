# Add a host

A host is a directory under `modules/hosts/<host>/` that defines the
`nixos.<host>` aspect and its `nixosConfigurations` entry. Use
`modules/hosts/surface-laptop/` as the model, and see
[Architecture](../architecture.md#how-a-host-is-composed) for how a host is
composed.

The host's SSH key must be enrolled in `.sops.yaml` before its first boot:
the login password comes from sops, and root has no password. So the key
is generated in the installer, and the config is installed only after it is
enrolled.

## 1. Collect hardware details

Boot the NixOS installer on the new machine (with Secure Boot off; see
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

## 3. Partition

Back in the installer, partition with the branch:

```sh
git clone -b feat/<host> https://github.com/ballsten/nixos-dendritic && cd nixos-dendritic
sudo "$(nix --extra-experimental-features 'nix-command flakes' build --no-link --print-out-paths \
  .#nixosConfigurations.<host>.config.system.build.diskoScript)"
```

## 4. Keys

Generate the host's SSH key straight into `/persist`, and print its age
recipient:

```sh
sudo install -d -m 755 /mnt/persist/etc/ssh
sudo ssh-keygen -t ed25519 -N "" -C "root@<host>" -f /mnt/persist/etc/ssh/ssh_host_ed25519_key
nix --extra-experimental-features 'nix-command flakes' run nixpkgs#ssh-to-age \
  < /mnt/persist/etc/ssh/ssh_host_ed25519_key.pub
```

On the working machine, add that recipient to `.sops.yaml` with the host's
name as its comment, re-encrypt, and push:

```yaml
          - age1… # <host>
```

```sh
sops updatekeys --yes secrets/secrets.yaml
git commit -am "feat: enrol <host> as a secrets recipient" && git push
```

`just enrol-host` does the same for a host that is already running; it
can't read a key that only exists in an installer.

Copy the admin age key to the new host's `/persist` too; home-manager
secrets decrypt with it. Over SSH from the working machine (set a password
for `nixos` in the installer with `passwd` first), or from a USB stick:

```sh
# in the installer; ballsten is uid 1000, group users (100)
sudo install -d -m 700 -o 1000 -g 100 /mnt/persist/home/ballsten \
  /mnt/persist/home/ballsten/.config /mnt/persist/home/ballsten/.config/sops \
  /mnt/persist/home/ballsten/.config/sops/age
sudo install -m 600 -o 1000 -g 100 keys.txt /mnt/persist/home/ballsten/.config/sops/age/keys.txt
```

## 5. Install

`git pull` the branch in the installer to get the re-encrypted secrets,
then follow [Install or reinstall a host](install-host.md#4-install) from
step 4, building with `nixos-install --flake .#<host>`.

## 6. Open the PR

Open the PR from `feat/<host>` once the host has booted, with the results
of the first-boot checks in "Manual testing".
