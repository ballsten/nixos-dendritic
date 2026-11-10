# losslesscut

[LosslessCut](https://github.com/mifi/lossless-cut) cuts long recordings into
clips without re-encoding. It's here for phone recordings of squash
sessions: one recording per session, cut into one file per match.

| | |
|---|---|
| Module | `modules/features/losslesscut.nix` |
| Aspects | `nixos.losslesscut`, `homeManager.losslesscut` |
| Hosts | `tiki-rig` |
| Inputs | None |
| Persists | `~/.config/LosslessCut` (settings, keyboard layout, export options) |
| Secrets | None |

It installs `losslesscut-bin`, the upstream AppImage, which is GPL-2.0, so
no unfree allowance is needed. It brings its own FFmpeg. Every home-manager
user on the host gets the persisted settings through
`home-manager.sharedModules`.

tiki-rig imports it directly rather than through
[workstation](workstation.md): the footage lives there, and surface-laptop
would struggle to scrub 4K HEVC. See
[0050](../decisions/0050-losslesscut.md).

## Cutting a session into matches

1. Copy the recording off the phone into `~/Videos`
   ([thunar](thunar.md#phones-and-usb-drives)), which is persisted.
2. Open it in LosslessCut (drag it onto the window, or **File → Open**).
3. For each match, move to its start and press `I`, then to its end and
   press `O`. Press `+` to start the next segment. Name a segment (the
   opponent or the score) from the segment list; the name can go into the
   exported file name.
4. Press **Export**, and check that **Separate files** is selected. Each
   segment is written as its own file next to the recording, in seconds.

Cuts snap to the nearest keyframe, so a match can start a second or two
early. If a tighter start is wanted, turn on **Smart cut** in the export
options: it re-encodes only the few frames before the first keyframe.

The output name comes from a template in the export options, such as
`{FILENAME}-{SEG_LABEL}`. It's saved with the other settings.

## Phone footage

Phones usually record H.265/HEVC, often with a variable frame rate and
sometimes HDR.

- **Preview.** LosslessCut plays video through Electron's Chromium, which
  only decodes HEVC on Linux through VA-API hardware decoding. tiki-rig's
  NVIDIA driver has no VA-API without `nvidia-vaapi-driver`, which isn't
  configured. If the preview is black or won't play, LosslessCut offers
  **FFmpeg-assisted playback**: rougher, but enough to find where a match
  starts. Cutting and exporting don't depend on the preview.
- **Variable frame rate and HDR** are copied as they are, since nothing is
  re-encoded. Play an exported match elsewhere to check that the audio
  stays in sync and the colours look right.

## Not included

LosslessCut doesn't do titles, effects or multi-track editing, and isn't
set as the default app for video files: open it by hand.
