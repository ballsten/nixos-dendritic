{ inputs, ... }:
{
  flake-file.inputs = {
    impermanence = {
      url = "github:nix-community/impermanence";
      # Both are only used to develop impermanence itself (see its README).
      inputs = {
        nixpkgs.follows = "";
        home-manager.follows = "";
      };
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  # Root and home are wiped on every boot; only paths declared under
  # /persist survive. Each feature persists the state it creates, with
  # environment.persistence (system) or home.persistence (home-manager).
  #
  # Every host needs a disko layout (modules/hosts/<host>/disk.nix) with
  # / on the btrfs subvolume @root, plus @nix and @persist. See
  # docs/impermanence.md.
  flake.modules.nixos.impermanence =
    {
      config,
      pkgs,
      utils,
      ...
    }:
    let
      rootDevice = config.fileSystems."/".device;
      rootDeviceUnit = "${utils.escapeSystemdPath rootDevice}.device";
    in
    {
      imports = [
        inputs.impermanence.nixosModules.impermanence
        inputs.disko.nixosModules.disko
      ];

      environment.persistence."/persist" = {
        hideMounts = true;
        directories = [
          "/var/log"
          "/var/lib/nixos"
          "/var/lib/systemd/coredump"
          "/var/lib/systemd/timers"
        ];
        files = [ "/etc/machine-id" ];
      };

      fileSystems."/persist".neededForBoot = true;

      boot.initrd.systemd = {
        enable = true;
        extraBin.find = "${pkgs.findutils}/bin/find";

        # Move the old @root to /old_roots/<time>, drop old roots older than
        # 30 days and start from an empty @root. Runs after a hibernate
        # resume attempt: changing the filesystem under a hibernated system
        # would corrupt it.
        services.rollback-root = {
          description = "Roll back the btrfs root subvolume";
          wantedBy = [ "initrd.target" ];
          requires = [ rootDeviceUnit ];
          after = [
            rootDeviceUnit
            "systemd-hibernate-resume.service"
          ];
          before = [ "sysroot.mount" ];
          unitConfig.DefaultDependencies = "no";
          serviceConfig.Type = "oneshot";
          script = ''
            mkdir -p /btrfs
            mount -t btrfs -o subvol=/ ${rootDevice} /btrfs

            if [ -e /btrfs/@root ]; then
              mkdir -p /btrfs/old_roots
              time="$(date --date="@$(stat -c %Y /btrfs/@root)" +%Y-%m-%d_%H-%M-%S)"
              mv /btrfs/@root "/btrfs/old_roots/$time"
            fi

            # Nested subvolumes (e.g. from systemd-machined) must go first.
            delete_subvolume() {
              btrfs subvolume list -o "$1" | cut -f 9- -d ' ' | while read -r sub; do
                delete_subvolume "/btrfs/$sub"
              done
              btrfs subvolume delete "$1"
            }
            find /btrfs/old_roots -mindepth 1 -maxdepth 1 -mtime +30 | while read -r old; do
              delete_subvolume "$old"
            done

            btrfs subvolume create /btrfs/@root
            umount /btrfs
          '';
        };
      };
    };
}
