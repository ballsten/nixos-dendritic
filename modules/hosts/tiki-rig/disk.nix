_: {
  # Disk layout, used by disko to partition at install and to generate
  # fileSystems and swapDevices. LUKS (passphrase at boot) holds one btrfs
  # filesystem; the impermanence feature empties @root on every boot.
  #
  # Only the Kingston disk. The WD SN750 holds Windows and is never touched.
  flake.modules.nixos.tiki-rig = {
    disko.devices.disk.main = {
      type = "disk";
      device = "/dev/disk/by-id/nvme-KINGSTON_SNV3S1000G_50026B768712DFBF";
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
                    # The Steam library, kept out of @persist (see the
                    # gaming feature). zstd's heuristic skips data that's
                    # already compressed.
                    "@games" = {
                      mountpoint = "/games";
                      inherit mountOptions;
                    };
                    # Inside LUKS, so the swap is encrypted. Suspend only,
                    # no hibernate, so it needn't match the 32G of RAM.
                    "@swap" = {
                      mountpoint = "/swap";
                      swap.swapfile.size = "16G";
                    };
                  };
              };
            };
          };
        };
      };
    };

    # impermanence binds home directories from /games during boot.
    fileSystems."/games".neededForBoot = true;
  };
}
