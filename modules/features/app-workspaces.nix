{ inputs, ... }:
{
  # App workspaces: an app, or a few that belong together, gets its own named
  # workspace, shown and hidden with Mod+Alt+<key>, and started by the first
  # press. Features register their app in appWorkspaces.workspaces; a host
  # with several monitors picks the one they open on with
  # appWorkspaces.output. Needs the desktop feature for Umbriel
  # (docs/decisions/0045-app-workspaces.md).
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

        # Shows the workspace, starting each of its apps that isn't running.
        # Pressed again while the workspace shows, it switches back to the
        # workspace it replaced. workspace-focus-last can't do that: it acts
        # on the monitor under the pointer, which may be the other one.
        toggle =
          name: workspace:
          pkgs.writeShellApplication {
            name = "app-workspace-${lib.toLower name}";
            runtimeInputs = [
              osConfig.programs.umbriel.package
              pkgs.coreutils
              pkgs.jq
            ];
            text = ''
              ws=${lib.escapeShellArg name}
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
              window() {
                umbriel windows --json |
                  jq -r --arg re "$1" 'first(.[] | select(.app_id // "" | test($re)) | .id) // empty'
              }
              # Focuses the first app found running, and starts the others
              # one at a time: apps sharing a browser profile can't start
              # together, so each gets up to 15 seconds to open its window.
              focused=
              ${lib.concatMapStrings (app: ''
                re=${lib.escapeShellArg app.appId}
                id=$(window "$re")
                if [ -z "$id" ]; then
                  ${app.command} &
                  for _ in $(seq 30); do
                    sleep 0.5
                    [ -n "$(window "$re")" ] && break
                  done
                elif [ -z "$focused" ]; then
                  umbriel msg "window-focus:$id"
                  focused=1
                fi
              '') (lib.attrValues workspace.apps)}
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

          workspaces = mkOption {
            default = { };
            description = "App workspaces, keyed by the workspace name.";
            type = types.attrsOf (
              types.submodule {
                options = {
                  key = mkOption {
                    type = types.str;
                    description = "Letter that, with Mod+Alt, toggles the workspace.";
                  };
                  apps = mkOption {
                    description = ''
                      Apps on the workspace, keyed by any name. Several
                      features can each add one.
                    '';
                    type = types.attrsOf (
                      types.submodule {
                        options = {
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
            ) cfg.workspaces;

            window_rule = lib.concatLists (
              lib.mapAttrsToList (
                name: workspace:
                map (
                  app:
                  {
                    match.app_id = app.appId;
                    default_workspace = name;
                  }
                  // onOutput { default_output = cfg.output; }
                ) (lib.attrValues workspace.apps)
              ) cfg.workspaces
            );

            keybinds = lib.mapAttrs' (
              name: workspace:
              lib.nameValuePair "Mod+Alt+${workspace.key}" {
                action = "spawn:${lib.getExe (toggle name workspace)}";
                repeat = false;
              }
            ) cfg.workspaces;
          };
      };
  };
}
