_: {
  # Disk layout, used by disko to partition at install and to generate
  # fileSystems and swapDevices. LUKS (passphrase at boot) holds one btrfs
  # filesystem; the impermanence feature empties @root on every boot.
  flake.modules.nixos.surface-laptop.disko.devices.disk.main = {
    type = "disk";
    device = "/dev/disk/by-id/nvme-Skhynix_BC501_NVMe_256GB_SAKRB41QA1808O041D09";
    content = {
      type = "gpt";
      partitions = {
        ESP = {
          size = "512M";
          type = "EF00";
          content = {
            type = "filesystem";
            format = "vfat";
            mountpoint = "/boot";
            mountOptions = [ "umask=0077" ];
          };
        };
        luks = {
          size = "100%";
          content = {
            type = "luks";
            name = "cryptroot";
            settings.allowDiscards = true;
            content = {
              type = "btrfs";
              extraArgs = [ "-f" ];
              subvolumes =
                let
                  mountOptions = [
                    "compress=zstd"
                    "noatime"
                  ];
                in
                {
                  "@root" = {
                    mountpoint = "/";
                    inherit mountOptions;
                  };
                  "@nix" = {
                    mountpoint = "/nix";
                    inherit mountOptions;
                  };
                  "@persist" = {
                    mountpoint = "/persist";
                    inherit mountOptions;
                  };
                  # Inside LUKS, so hibernate images are encrypted. Sized
                  # for 8G of RAM.
                  "@swap" = {
                    mountpoint = "/swap";
                    swap.swapfile.size = "8G";
                  };
                };
            };
          };
        };
      };
    };
  };
}
