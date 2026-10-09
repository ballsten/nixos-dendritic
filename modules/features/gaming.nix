{ inputs, ... }:
{
  # Steam with Proton-GE and gamemode, plus Path of Exile tools (Path of
  # Building and Sidekick). Imported only
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
      { lib, pkgs, ... }:
      let
        # Sidekick, the PoE price checker, in its web variant: a local server
        # with the UI in the browser. Unlike its desktop build and Awakened
        # PoE Trade, it uses no X11 hotkeys or overlay, so it works with the
        # game on native Wayland. Not in nixpkgs.
        sidekick =
          let
            pname = "sidekick";
            version = "2026.9.2";
            src = pkgs.fetchurl {
              url = "https://github.com/Sidekick-Poe/Sidekick/releases/download/v${version}/Sidekick-linux-web-x64.AppImage";
              hash = "sha256-Fje6/Socg1nBQ607127fTEEIiDChzLA8O4q5HENxiDA=";
            };
            # Sidekick opens its page on start, and its links (trade site,
            # poe.ninja, wiki), with xdg-open. Run from sidekick.service,
            # that would start the browser inside the service and stop it
            # with Sidekick. This xdg-open, first on PATH in the AppImage
            # sandbox, opens them as a separate transient unit.
            xdg-open = pkgs.writeShellScriptBin "xdg-open" ''
              exec ${lib.getExe' pkgs.systemd "systemd-run"} --user --collect --quiet \
                ${lib.getExe' pkgs.xdg-utils "xdg-open"} "$@"
            '';
          in
          pkgs.appimageTools.wrapType2 {
            inherit pname version src;
            # .NET's globalization and TLS.
            extraPkgs = p: [
              p.icu
              p.openssl
            ];
            # Runs after the sandbox's /etc/profile puts /usr/bin first.
            profile = ''export PATH="${xdg-open}/bin:$PATH"'';
            passthru.icon = "${pkgs.appimageTools.extract { inherit pname version src; }}/Sidekick.png";
          };

        # Starts Sidekick, which opens its page, or opens the page if it's
        # already running.
        sidekick-open = pkgs.writeShellApplication {
          name = "sidekick-open";
          runtimeInputs = [ pkgs.xdg-utils ];
          text = ''
            if systemctl --user is-active --quiet sidekick.service; then
              exec xdg-open http://localhost:5000
            fi
            exec systemctl --user start sidekick.service
          '';
        };
      in
      {
        home = {
          packages = with pkgs; [
            rusty-path-of-building
            sidekick-open
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
              # Sidekick: settings, league and price cache (sidekick.db).
              ".config/sidekick"
            ];
          };
        };

        # Started on demand by sidekick-open, stopped from the launcher or
        # at logout.
        systemd.user.services.sidekick = {
          Unit = {
            Description = "Sidekick price checker for Path of Exile";
            PartOf = [ "graphical-session.target" ];
          };
          Service.ExecStart = lib.getExe sidekick;
        };

        xdg.desktopEntries = {
          sidekick = {
            name = "Sidekick";
            comment = "Price check Path of Exile items";
            exec = lib.getExe sidekick-open;
            inherit (sidekick) icon;
            categories = [ "Game" ];
          };
          sidekick-stop = {
            name = "Stop Sidekick";
            comment = "Stop the Sidekick server";
            exec = "systemctl --user stop sidekick.service";
            inherit (sidekick) icon;
            categories = [ "Game" ];
          };
        };
      };
  };
}
