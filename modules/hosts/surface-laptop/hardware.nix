{ inputs, ... }:
{
  flake-file.inputs.nixos-hardware = {
    url = "github:NixOS/nixos-hardware";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  flake.modules.nixos.surface-laptop = {
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
    };
  };
}
