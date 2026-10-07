{ inputs, ... }:
{
  # Steam with Proton-GE and gamemode, plus Path of Exile tools. Imported only
  # by hosts that game (tiki-rig), never by workstation.
  #
  # The Steam library is large, so it lives on its own filesystem at /games
  # (the host's @games subvolume) rather than in /persist. See
  # docs/features/gaming.md.
  flake.modules = {
    nixos.gaming =
      { config, pkgs, ... }:
      {
        assertions = [
          {
            # Without it, impermanence would bind the Steam library from a
            # directory on the wiped root, and it would be lost on reboot.
            assertion = config.fileSystems ? "/games";
            message = "gaming: the host needs a /games filesystem for the Steam library (see docs/features/gaming.md).";
          }
        ];

        unfree.packages = [
          "steam"
          "steam-unwrapped"
        ];

        programs = {
          # Also enables 32-bit graphics and the udev rules for Steam
          # controllers and headsets.
          steam = {
            enable = true;
            extraCompatPackages = [ pkgs.proton-ge-bin ];
          };
          # Members of the gamemode group can change the CPU governor without
          # a password; users add themselves.
          gamemode.enable = true;
        };

        # Every home-manager user on the host gets the user side.
        home-manager.sharedModules = [ inputs.self.modules.homeManager.gaming ];
      };

    homeManager.gaming =
      { pkgs, ... }:
      {
        home = {
          packages = with pkgs; [
            rusty-path-of-building
            awakened-poe-trade
          ];

          persistence = {
            # Steam client, game library and Proton prefixes (saves for games
            # without Steam Cloud).
            "/games".directories = [ ".local/share/Steam" ];
            "/persist".directories = [
              # Saves and settings of Unity games (e.g. Valheim).
              ".config/unity3d"
              # Path of Building for PoE 1 and 2: builds and settings.
              ".local/share/RustyPathOfBuilding1"
              ".local/share/RustyPathOfBuilding2"
              ".config/awakened-poe-trade"
            ];
          };
        };
      };
  };
}
