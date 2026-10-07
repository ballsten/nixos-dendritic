_: {
  # ASUS ROG Crosshair VIII Hero (Wi-Fi), Ryzen 7 5800X, RTX 3080. There's no
  # nixos-hardware module for the board, and its common-cpu-amd,
  # common-gpu-nvidia and common-pc-ssd modules each set a single option,
  # so they're written out here.
  flake.modules.nixos.tiki-rig = {
    imports = [ ./_hardware-configuration.nix ];

    unfree.packages = [
      "nvidia-x11"
      "nvidia-settings"
    ];

    hardware = {
      cpu.amd.updateMicrocode = true;
      enableRedistributableFirmware = true;
      graphics.enable = true;
      # The driver comes from the default "stable" branch, which nixpkgs
      # moves to new NVIDIA releases once they're proven, rather than
      # "latest".
      nvidia = {
        # Open kernel modules: NVIDIA's recommendation for Turing and newer.
        open = true;
        modesetting.enable = true;
        # Saves video memory across suspend, so the session survives it.
        powerManagement.enable = true;
      };
    };
    services = {
      xserver.videoDrivers = [ "nvidia" ];
      fstrim.enable = true;
      # Lighting on the board's AURA controller and the G560 speakers. The
      # server keeps its profiles in /var/lib/OpenRGB.
      hardware.openrgb.enable = true;
    };

    boot = {
      # The keyboard sits behind a USB switch and hubs. Listed here as well
      # as in the generated file, because nixos-generate-config leaves them
      # out when the switch points at another machine. Needed to type the
      # LUKS passphrase.
      initrd.availableKernelModules = [
        "usbhid"
        "usb_storage"
        "sd_mod"
      ];
      loader.efi.canTouchEfiVariables = true;
    };

    environment.persistence."/persist".directories = [ "/var/lib/OpenRGB" ];
    home-manager.sharedModules = [
      {
        # OpenRGB's client settings and saved profiles.
        home.persistence."/persist".directories = [ ".config/OpenRGB" ];
      }
    ];
  };
}
