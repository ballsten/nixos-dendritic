{ ... }:
{
  flake.modules.nixos.surface-laptop = {
    imports = [ ./_hardware-configuration.nix ];

    hardware.cpu.intel.updateMicrocode = true;
    hardware.enableRedistributableFirmware = true;

    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;
  };
}
