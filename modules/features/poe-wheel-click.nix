{ inputs, ... }:
{
  # In Path of Exile, the mouse wheel left-clicks: one click per notch, as
  # XMouseButtonControl does on Windows, for Ctrl-clicking items between
  # the inventory and the stash. input-remapper does the remapping, only
  # while the game has focus, so the wheel scrolls everywhere else. The
  # host names its mouse with poeWheelClick.device. See
  # docs/features/poe-wheel-click.md.
  flake.modules = {
    nixos.poe-wheel-click =
      { lib, ... }:
      {
        options.poeWheelClick.device = lib.mkOption {
          type = lib.types.str;
          example = "Logitech Gaming Mouse G502";
          description = ''
            The mouse to remap, as `input-remapper-control --list-devices`
            names it.
          '';
        };

        config = {
          # The daemon runs as root and grabs the mouse while a preset is
          # injected; any local user can control it over D-Bus.
          services.input-remapper.enable = true;

          # Every home-manager user on the host gets the user side.
          home-manager.sharedModules = [ inputs.self.modules.homeManager.poe-wheel-click ];
        };
      };

    homeManager.poe-wheel-click =
      {
        lib,
        pkgs,
        osConfig,
        ...
      }:
      let
        inherit (osConfig.poeWheelClick) device;
        input-remapper = osConfig.services.input-remapper.package;

        # EV_REL, so the wheel acts as a button: pressed while it turns,
        # released release_timeout after the last notch. The default 0.05 s
        # would merge a quick spin into one long click, so it's short
        # enough for each notch to be its own click, and rel_rate (how
        # often the release is checked) high enough to honour it.
        wheel = threshold: {
          input_combination = [
            {
              type = 2;
              code = 8; # REL_WHEEL
              analog_threshold = threshold;
            }
          ];
          target_uinput = "mouse";
          output_symbol = "BTN_LEFT";
          mapping_type = "key_macro";
          release_timeout = 1.0e-2;
          rel_rate = 200;
        };
        # The mouse also reports the wheel as REL_WHEEL_HI_RES, which would
        # still scroll.
        hiRes = threshold: {
          input_combination = [
            {
              type = 2;
              code = 11; # REL_WHEEL_HI_RES
              analog_threshold = threshold;
            }
          ];
          target_uinput = "mouse";
          output_symbol = "disable";
          mapping_type = "key_macro";
        };
        preset = pkgs.writeText "poe.json" (
          builtins.toJSON [
            (wheel 1)
            (wheel (-1))
            (hiRes 1)
            (hiRes (-1))
          ]
        );

        # Follows window focus, and starts the preset when Path of Exile
        # gains it and stops it when it loses it.
        poe-wheel-click = pkgs.writeShellApplication {
          name = "poe-wheel-click";
          runtimeInputs = [
            osConfig.programs.umbriel.package
            input-remapper
            pkgs.coreutils
            pkgs.jq
          ];
          text = ''
            device=${lib.escapeShellArg device}

            # The config lives in the runtime directory rather than
            # ~/.config: input-remapper rewrites its files when it migrates
            # them, so they can't be read-only links into the store. The
            # version stops it from migrating.
            dir="$XDG_RUNTIME_DIR/poe-wheel-click"
            mkdir -p "$dir/presets/$device"
            cp --no-preserve=mode ${preset} "$dir/presets/$device/poe.json"
            printf '{"version": "%s"}\n' ${lib.escapeShellArg input-remapper.version} >"$dir/config.json"

            # Each event is a snapshot of every window; the one with
            # keyboard focus is active. PoE 2 may share the executable
            # name, so the title is matched too.
            state=
            umbriel subscribe windows |
              jq --unbuffered -r '.data | any(.active and .app_id == "pathofexilesteam.exe" and .title == "Path of Exile")
                | if . then "start" else "stop" end' |
              while IFS= read -r want; do
                [ "$want" != "$state" ] || continue
                state=$want
                input-remapper-control --config-dir "$dir" --command "$want" \
                  --device "$device" --preset poe || true
              done
          '';
        };
      in
      {
        systemd.user.services.poe-wheel-click = {
          Unit = {
            Description = "Mouse wheel left-clicks while Path of Exile has focus";
            PartOf = [ "graphical-session.target" ];
            After = [ "graphical-session.target" ];
          };
          Service = {
            ExecStart = lib.getExe poe-wheel-click;
            # The wheel scrolls again when the service stops.
            ExecStopPost = "${lib.getExe' input-remapper "input-remapper-control"} --config-dir %t/poe-wheel-click --command stop --device ${lib.escapeShellArg device}";
            # umbriel subscribe ends when the compositor restarts.
            Restart = "always";
            RestartSec = 2;
          };
          Install.WantedBy = [ "graphical-session.target" ];
        };
      };
  };
}
