# 0050: LosslessCut on tiki-rig for cutting squash footage

- **Status:** Accepted, 2026-11-10

## Context

Phone recordings of squash sessions each cover several matches. The job
is to find where each match starts and ends, and export each one as its
own file. Titles, effects and multi-track editing aren't needed.

The footage is usually H.265/HEVC, often with a variable frame rate and
sometimes HDR, which some editors handle badly. It's copied onto tiki-rig,
whose `@persist` has room for it.

## Decision

A [losslesscut](../features/losslesscut.md) feature installs
`losslesscut-bin` and persists its settings. tiki-rig imports it directly,
the way hosts import [roblox](../features/roblox.md); it isn't part of
[workstation](../features/workstation.md) or
[gaming](../features/gaming.md).

## Consequences

- Splitting a session is one export, and each match keeps the phone's
  quality, because nothing is re-encoded.
- Cuts snap to keyframes, so a match can start a second or two early,
  unless smart cut is used.
- HEVC preview depends on VA-API, which tiki-rig's NVIDIA driver doesn't
  provide without `nvidia-vaapi-driver`; otherwise LosslessCut falls back
  to its FFmpeg-assisted playback.

## Alternatives considered

- **Kdenlive or Shotcut:** frame-accurate cuts, and titles or overlays
  later, but every match is re-encoded and splitting one file into many
  takes more steps. Either can be added later as its own feature if a
  polished highlight edit is wanted.
- **DaVinci Resolve:** unfree and heavy. Its free version on Linux can't
  decode H.264, H.265 or AAC, so phone footage would need converting first.
- **Both hosts through `workstation`:** surface-laptop would struggle with
  4K HEVC (battery, choppy scrubbing), and the footage lives on tiki-rig.
