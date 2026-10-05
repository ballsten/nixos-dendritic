# Persist state

`/` and `/home` are wiped on every boot. Anything a program should keep has
to be declared under `/persist`, in the feature that creates it. See
[impermanence](../features/impermanence.md) for how the wipe works.

## Declare the path

In a NixOS aspect, with absolute paths:

```nix
environment.persistence."/persist".directories = [ "/var/lib/bluetooth" ];
```

In a home-manager aspect, with paths relative to home:

```nix
home.persistence."/persist".directories = [ ".config/BraveSoftware" ];
```

Add a short comment saying what the path holds, and list it in the Persists
row of the feature's docs page.

## Directories, not files

Persist a directory rather than a single file. A persisted file is
bind-mounted, and a program that saves it by renaming a new file over it
fails with `EBUSY`. If a program keeps a lone file in home, look for an
option that moves it into a directory (for example `CLAUDE_CONFIG_DIR` for
Claude Code, in `modules/users/ballsten/home.nix`).

## Keys needed during activation

Activation can run before the bind mounts exist, so a key it needs is read
from `/persist` directly rather than persisted with a bind mount: the SSH
host key (`services.openssh.hostKeys`), the admin age key
(`sops.age.keyFile`) and the Secure Boot keys (`boot.lanzaboote.pkiBundle`).

## Find what a program writes

Everything on `/` that isn't persisted is on the `@root` subvolume. The
other subvolumes are separate filesystems to `find -xdev`, so this lists
what was written recently and will be lost on the next reboot:

```sh
sudo find / -xdev -type f -newermt '-1 hour' 2>/dev/null
```

Use the program, then run it to see which paths to persist.

## Existing state

Persisting a path doesn't copy what is already there: the bind mount
hides it behind the empty directory under `/persist`, and the next boot
wipes it. To keep current state, copy it in before applying the new
configuration:

```sh
sudo mkdir -p /persist/home/ballsten/.config
sudo cp -a ~/.config/example /persist/home/ballsten/.config/
sudo chown -R ballsten:users /persist/home/ballsten/.config/example
```

Say in the PR whether this is needed.

## Get something back after a reboot

Old roots are kept for 30 days in `/old_roots/<time>` on the btrfs
filesystem:

```sh
sudo mount -o subvol=/ /dev/mapper/cryptroot /mnt
ls /mnt/old_roots/
sudo umount /mnt
```
