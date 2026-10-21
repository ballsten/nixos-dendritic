{ inputs, ... }:
{
  flake-file.inputs.nixos-hardware = {
    url = "github:NixOS/nixos-hardware";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  flake.modules.nixos.surface-laptop =
    { pkgs, ... }:
    {
      imports = [
        ./_hardware-configuration.nix
        # linux-surface kernel (built from source, no binary cache), iptsd,
        # thermald and surface-control.
        inputs.nixos-hardware.nixosModules.microsoft-surface-pro-intel
      ];

      hardware.cpu.intel.updateMicrocode = true;
      hardware.enableRedistributableFirmware = true;

      boot = {
        # The Type Cover is a USB HID device; needed in the initrd to type the
        # LUKS passphrase.
        initrd.availableKernelModules = [
          "usbhid"
          "hid_generic"
          "hid_multitouch"
        ];

        loader.efi.canTouchEfiVariables = true;

        # nixos-hardware's linux-surface kernel (6.19.8) predates this fix, so
        # its Rust support fails to build with rustc >= 1.98 ("invalid rustc
        # abi: 'x86-softfloat'"). Drop this once nixos-hardware moves to a
        # kernel that includes it; the patch then fails to apply.
        kernelPatches = [
          {
            name = "rust-x86-softfloat-abi";
            patch = pkgs.fetchpatch {
              name = "rust-x86-softfloat-abi.patch";
              url = "https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/patch/?id=905b06d32a52afe32fcf5f30cf298c9ea6359f11";
              hash = "sha256-G5X1FPewzWACgefquexsbD3wGUAXuStDDbclSMcX4YE=";
            };
          }
        ];
      };
    };
}
