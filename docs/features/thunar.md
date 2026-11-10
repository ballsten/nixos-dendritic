# thunar

[Thunar](https://docs.xfce.org/xfce/thunar/start), the file manager, opened
with `Mod+E`. gvfs puts phones, USB drives and the trash in its sidebar, and
xarchiver handles archives.

| | |
|---|---|
| Module | `modules/features/thunar.nix` |
| Aspects | `nixos.thunar`, `homeManager.thunar` |
| Hosts | All, through `workstation` |
| Inputs | None |
| Persists | `~/.config/xfce4` (Thunar's settings in xfconf), `~/.config/Thunar` (custom actions, keyboard shortcuts) |
| Secrets | None |

Thunar is a GTK 3 app, so it follows the Noctalia colours and the icon
theme from [theme](theme.md) with nothing extra. Every home-manager user on
the host gets the user side through `home-manager.sharedModules`. It needs
the [desktop](desktop.md) feature, whose Umbriel config the keybind is
added to.

## Phones and USB drives

`services.gvfs` mounts devices for Thunar, and turns on udisks2 for drives.
It uses the plain `gvfs` build rather than the module's default GNOME one,
which adds GNOME Online Accounts.
Android phones don't show up as a USB drive: they share their storage over
MTP, which gvfs's MTP backend mounts.

To copy footage or photos off a phone:

1. Plug it in and unlock it.
2. On the phone, set the USB connection to **File transfer** (Android
   asks in a notification, or under USB preferences).
3. The phone shows up in Thunar's sidebar. Open it and copy files into
   `~/Videos` or `~/Pictures`, which are persisted.

If the phone shows up but is empty, Android hasn't shared its storage: the
log has `Get Storage information failed`. With the phone unlocked, open
the USB notification, pick **No data transfer**, then **File transfer**
again, and reopen it in Thunar. Videos are under
`Internal shared storage/DCIM/Camera`.

Large files copy more slowly over MTP than from a drive. If a big copy
stalls, the mount is also under `/run/user/1000/gvfs/`, where `rsync` can
copy it and resume.

USB drives and SD cards also show up in the sidebar and mount when
clicked. Unmount them from the sidebar before unplugging.

The persisted folders aren't listed as drives ([impermanence](impermanence.md)),
and on tiki-rig the Windows disk is hidden
([tiki-rig](../hosts/tiki-rig.md#windows)).

After the feature is first added, log out and back in (or reboot): gvfs
plugs into GIO through `GIO_EXTRA_MODULES`, which is only set at login.
Until then Thunar starts without it and shows no phones or drives.

## Archives

thunar-archive-plugin adds **Extract here**, **Extract to** and **Create
archive** to the right-click menu, and hands the work to xarchiver, Xfce's
GTK 3 archive manager. Opening an archive opens it in xarchiver. GNOME's
file-roller isn't used because it pulls in Nautilus.

## Default for folders

`xdg.mimeApps` makes Thunar the handler for `inode/directory`, so "show in
folder" in other apps opens it.

## Mod+E

`Mod+E` starts Thunar, or opens a new window if it's already running.

## What isn't kept

- **Bookmarks** (the sidebar's own places) live in
  `~/.config/gtk-3.0/bookmarks`. That directory also holds home-manager's
  GTK files, so it can't be persisted as a whole, and GTK saves the file by
  renaming over it, which breaks a single bind-mounted file. Bookmarks
  reset on reboot.
- **Trash** is in `~/.local/share/Trash`, which isn't persisted: anything
  in it is gone after a reboot.
- **Thumbnails** aren't generated (no tumbler); files show their type's
  icon.
