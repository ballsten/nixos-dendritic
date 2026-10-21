# 0041: Backport the Rust softfloat fix to the Surface kernel

- **Status:** Accepted, 2026-10-22
- **PRs:** #127

## Context

The input update in #124 moved nixpkgs from rustc 1.98.1 to 1.99.0, which
no longer accepts `x86-softfloat` as a target `rustc-abi`; the name is now
`softfloat`. The kernel writes its own Rust target spec, and kernels
without upstream commit 905b06d32a52 ("rust: x86: support Rust >= 1.98.0
target spec") still write the old name, so their Rust support fails to
build:

```
error: error loading target specification: rustc-abi: invalid rustc abi: 'x86-softfloat'.
```

nixpkgs' own kernels (e.g. 6.18.57 on `tiki-rig`) already carry the fix.
nixos-hardware's Surface module pins linux-surface 6.19.8, an end-of-life
series that never received it, so `surface-laptop` stopped building.

## Decision

`modules/hosts/surface-laptop/hardware.nix` adds the upstream commit to
`boot.kernelPatches`, fetched from kernel.org. It changes only
`scripts/generate_rust_target.rs` and applies cleanly to 6.19.8.

## Consequences

- The kernel's configuration is unchanged; Rust stays enabled.
- When nixos-hardware moves to a kernel that already has the fix, the
  patch fails to apply (it is already there), and the build points at it.
  Remove the patch then.

## Alternatives considered

- **Turn off Rust in the Surface kernel** (`RUST = no`): also works, but
  changes the kernel configuration and drops Rust drivers (such as the DRM
  panic QR code) for a build-script bug.
- **Build the Surface kernel with an older rustc:** pins a toolchain
  nixpkgs no longer ships, and has to be undone later.
- **Revert #124:** blocks every other update until nixos-hardware moves
  on.
