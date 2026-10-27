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

        # Writes a launcher entry for each installed Steam game, from the
        # library's app manifests, and removes the entries of games that
        # are gone. Steam's own entries are removed too: Steam only writes
        # them on install, and they'd be wiped on the next boot anyway
        # (docs/decisions/0043-steam-launcher-entries.md).
        steam-launcher-entries = pkgs.writeShellApplication {
          name = "steam-launcher-entries";
          runtimeInputs = with pkgs; [
            coreutils
            findutils
            gnugrep
            gnused
          ];
          text = ''
            steam="$HOME/.local/share/Steam"
            apps="''${XDG_DATA_HOME:-$HOME/.local/share}/applications"
            mkdir -p "$apps"

            # The value of a top-level "key" "value" line in a VDF file.
            vdf() {
              sed -n "s/^[[:space:]]*\"$1\"[[:space:]]*\"\(.*\)\"[[:space:]]*$/\1/p" "$2" | head -n 1
            }

            # Every library folder, the default one first.
            libraries() {
              echo "$steam"
              if [ -f "$steam/steamapps/libraryfolders.vdf" ]; then
                sed -n 's/^[[:space:]]*"path"[[:space:]]*"\(.*\)"[[:space:]]*$/\1/p' \
                  "$steam/steamapps/libraryfolders.vdf"
              fi
            }

            declare -A wanted=()
            while IFS= read -r library; do
              for manifest in "$library"/steamapps/appmanifest_*.acf; do
                [ -f "$manifest" ] || continue
                appid=$(vdf appid "$manifest")
                name=$(vdf name "$manifest")
                [ -n "$appid" ] && [ -n "$name" ] || continue
                # Steam tools have manifests too, but aren't games.
                case "$name" in
                  Proton* | "Steam Linux Runtime"* | "Steamworks Common Redistributables") continue ;;
                esac

                # The small icon Steam shows in its library list.
                icon=$(find "$steam/appcache/librarycache/$appid" -maxdepth 1 \
                  -name '*.jpg' -print -quit 2>/dev/null || true)

                entry="$apps/steam-game-$appid.desktop"
                wanted["$entry"]=1
                content="[Desktop Entry]
            Type=Application
            Name=$name
            Comment=Play $name on Steam
            Exec=steam steam://rungameid/$appid
            Icon=''${icon:-steam}
            Terminal=false
            Categories=Game;
            X-Steam-AppId=$appid"
                # Only write on a change, so the path unit watching this
                # folder settles after one run.
                if [ "$(cat "$entry" 2>/dev/null)" != "$content" ]; then
                  printf '%s\n' "$content" >"$entry"
                fi
              done
            done < <(libraries | sort -u)

            # Steam's own entries, and ours for games no longer installed.
            for entry in "$apps"/*.desktop; do
              [ -f "$entry" ] || continue
              grep -q 'steam://rungameid/' "$entry" || continue
              [ -n "''${wanted[$entry]:-}" ] || rm -f "$entry"
            done
          '';
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

        systemd.user = {
          services = {
            # Started on demand by sidekick-open, stopped from the launcher
            # or at logout.
            sidekick = {
              Unit = {
                Description = "Sidekick price checker for Path of Exile";
                PartOf = [ "graphical-session.target" ];
              };
              Service.ExecStart = lib.getExe sidekick;
            };

            # Run at login, and by the path unit below.
            steam-launcher-entries = {
              Unit.Description = "Launcher entries for installed Steam games";
              Service = {
                Type = "oneshot";
                ExecStart = lib.getExe steam-launcher-entries;
              };
              Install.WantedBy = [ "default.target" ];
            };
          };

          # A game's manifest appears or goes when it's installed or
          # uninstalled. Steam writes its own entry after installing, so
          # the applications folder is watched too, to replace it.
          paths.steam-launcher-entries = {
            Unit.Description = "Watch the Steam library for installed and removed games";
            Path.PathChanged = [
              "%h/.local/share/Steam/steamapps"
              "%h/.local/share/applications"
            ];
            Install.WantedBy = [ "default.target" ];
          };
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
