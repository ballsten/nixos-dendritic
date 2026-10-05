# 0011: The linux-surface kernel, built locally

- **Status:** Accepted, 2026-10-03
- **Issue:** #10
- **PRs:** #5, #33

## Context

The MVP (#5) skipped nixos-hardware's Surface module, because its
linux-surface kernel has no binary cache. Then the stock kernel's Marvell
Wi-Fi driver (`mwifiex_pcie`) hung and broke suspend until a reboot (#10),
a known problem the linux-surface patches fix.

## Decision

`surface-laptop` imports nixos-hardware's `microsoft-surface-pro-intel`
module, in `modules/hosts/surface-laptop/hardware.nix`. It brings the
linux-surface kernel, iptsd (touch and pen), thermald and surface-control.
The kernel is built locally.

## Consequences

- The kernel takes about two hours to build, on every kernel bump in
  nixpkgs or nixos-hardware. Run it in a terminal, not as a background
  task.
- A reinstall builds the system on a running machine first and copies it
  over ([Install or reinstall a host](../howto/install-host.md#surface-laptop-build-first)).
- iptsd brought in GUI and multimedia libraries, most of which the desktop
  needs anyway.

## Alternatives considered

- **Stock kernel with workarounds** (Wi-Fi power saving off, reloading
  `mwifiex_pcie` around suspend): no touch or pen, and not a real fix.
- **A binary cache (e.g. Cachix) for the kernel:** would avoid the build;
  left as a possible follow-up.
