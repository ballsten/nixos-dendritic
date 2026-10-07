# 0028: NVIDIA's open kernel modules from the stable branch

- **Status:** Accepted, 2026-10-07
- **Issue:** #9

## Context

tiki-rig has an NVIDIA GeForce RTX 3080 (Ampere). The old config used the
open kernel modules with `nvidiaPackages.latest`, which was 615.71.09 when
this was written, against 595.104.02 on `stable`.

## Decision

`hardware.nix` uses the open kernel modules (`hardware.nvidia.open`) with
the default `stable` branch, plus modesetting and power management.

## Consequences

- nixpkgs moves `stable` to a new NVIDIA release once it's proven, so
  input updates are less likely to bring driver regressions.
- New driver features arrive a little later than with `latest`.
- Power management saves video memory across suspend, so the session
  survives it.
- `nvidia-x11` and `nvidia-settings` are allowed as unfree packages, in
  `hardware.nix`.

## Alternatives considered

- **`latest`:** what the old config used; newer features and fixes,
  sometimes with regressions.
- **The proprietary kernel modules:** NVIDIA recommends the open ones for
  Turing and newer.
- **nouveau:** no reclocking on Ampere, so unusable for gaming.
