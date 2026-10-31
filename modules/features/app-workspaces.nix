{ inputs, ... }:
{
  # App workspaces: an app gets its own named workspace, shown and hidden
  # with Mod+Alt+<key>, and started by the first press. Features register
  # their app in appWorkspaces.apps; a host with several monitors picks the
  # one they open on with appWorkspaces.output. Needs the desktop feature
  # for Umbriel (docs/decisions/0045-app-workspaces.md).
  flake.modules = {
    # Every home-manager user on the host gets the convention.
    nixos.app-workspaces.home-manager.sharedModules = [
      inputs.self.modules.homeManager.app-workspaces
    ];

    homeManager.app-workspaces =
      {
        config,
        lib,
        pkgs,
        osConfig,
        ...
      }:
      let
        inherit (lib) types mkOption;
        cfg = config.appWorkspaces;

        # Shows the app's workspace, starting the app if it isn't running.
        # Pressed again while the workspace shows, it switches back to the
        # workspace it replaced. workspace-focus-last can't do that: it acts
        # on the monitor under the pointer, which may be the other one.
        toggle =
          name: app:
          pkgs.writeShellApplication {
            name = "app-workspace-${lib.toLower name}";
            runtimeInputs = [
              osConfig.programs.umbriel.package
              pkgs.jq
            ];
            text = ''
              ws=${lib.escapeShellArg name}
              app_id=${lib.escapeShellArg app.appId}
              out=${lib.escapeShellArg (if cfg.output == null then "" else cfg.output)}
              if [ -z "$out" ]; then
                out=$(umbriel outputs --json |
                  jq -r 'first((.[] | select(.focused)), (.[] | select(.enabled)) | .name) // empty')
              fi
              state="''${XDG_RUNTIME_DIR:-/tmp}/app-workspace-$ws"

              workspaces=$(umbriel workspaces --json)
              active=$(jq -r --arg out "$out" --arg ws "$ws" \
                'first(.[] | select(.output == $out and .active) |
                  if .named and .name == $ws then "shown" else .id end) // empty' \
                <<<"$workspaces")

              if [ "$active" = shown ]; then
                # Back to the workspace this one replaced, or the output's
                # first other workspace if that one has gone since.
                prev=$(cat "$state" 2>/dev/null || true)
                index=$(jq -r --arg out "$out" --arg ws "$ws" --arg prev "$prev" \
                  '[.[] | select(.output == $out)] |
                    (first(.[] | select(.id == $prev)) //
                      first(.[] | select(.named and .name == $ws | not))) |
                    .index // empty' \
                  <<<"$workspaces")
                if [ -n "$index" ]; then
                  umbriel msg "workspace-switch:$index/$out"
                fi
                exit 0
              fi

              printf '%s\n' "$active" >"$state"
              # Quoted, so the name is never read as a position.
              umbriel msg "workspace-switch:\"$ws\"/$out"
              id=$(umbriel windows --json |
                jq -r --arg re "$app_id" 'first(.[] | select(.app_id // "" | test($re)) | .id) // empty')
              if [ -n "$id" ]; then
                umbriel msg "window-focus:$id"
              else
                exec ${app.command}
              fi
            '';
          };
      in
      {
        options.appWorkspaces = {
          output = mkOption {
            type = types.nullOr types.str;
            default = null;
            description = ''
              Output the app workspaces live on. null puts them on every
              output and toggles the focused one, which suits a host with
              one monitor.
            '';
          };

          apps = mkOption {
            default = { };
            description = "Apps with their own workspace, keyed by the workspace name.";
            type = types.attrsOf (
              types.submodule {
                options = {
                  key = mkOption {
                    type = types.str;
                    description = "Letter that, with Mod+Alt, toggles the workspace.";
                  };
                  appId = mkOption {
                    type = types.str;
                    description = "Regex for the app's Wayland app ID.";
                  };
                  command = mkOption {
                    type = types.str;
                    description = "Command that starts the app.";
                  };
                };
              }
            );
          };
        };

        config.programs.umbriel.settings =
          let
            onOutput = attrs: lib.optionalAttrs (cfg.output != null) attrs;
          in
          {
            # Named workspaces persist while empty, so the name stays in the
            # bar. Their windows open at full width.
            workspace = lib.mapAttrsToList (
              name: _:
              {
                inherit name;
                layout.scrolling.default_extent_fraction = 1.0;
              }
              // onOutput { inherit (cfg) output; }
            ) cfg.apps;

            window_rule = lib.mapAttrsToList (
              name: app:
              {
                match.app_id = app.appId;
                default_workspace = name;
              }
              // onOutput { default_output = cfg.output; }
            ) cfg.apps;

            keybinds = lib.mapAttrs' (
              name: app:
              lib.nameValuePair "Mod+Alt+${app.key}" {
                action = "spawn:${lib.getExe (toggle name app)}";
                repeat = false;
              }
            ) cfg.apps;
          };
      };
  };
}
