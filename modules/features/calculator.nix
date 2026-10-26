{ inputs, ... }:
{
  # GNOME Calculator, opened and closed with Mod+C and pinned above other
  # windows. Needs the desktop feature for Umbriel.
  flake.modules = {
    # Every home-manager user on the host gets the app.
    nixos.calculator.home-manager.sharedModules = [ inputs.self.modules.homeManager.calculator ];

    homeManager.calculator =
      {
        lib,
        pkgs,
        osConfig,
        ...
      }:
      let
        appId = "org.gnome.Calculator";
        # Closes the calculator if it's open, otherwise opens it. Umbriel
        # has no minimise, and a scratchpad can't be pinned or kept on one
        # output (docs/decisions/0042-calculator-pinned-toggle.md).
        toggle = pkgs.writeShellApplication {
          name = "calculator-toggle";
          runtimeInputs = [
            osConfig.programs.umbriel.package
            pkgs.gnome-calculator
            pkgs.jq
          ];
          text = ''
            id=$(umbriel windows --json |
              jq -r 'first(.[] | select(.app_id == "${appId}") | .id) // empty')
            if [ -n "$id" ]; then
              umbriel msg "window-close:$id"
            else
              exec gnome-calculator
            fi
          '';
        };
      in
      {
        home.packages = [ pkgs.gnome-calculator ];

        programs.umbriel.settings = {
          keybinds."Mod+C" = {
            action = "spawn:${lib.getExe toggle}";
            repeat = false;
          };

          # Pinned windows float above the others on every workspace of
          # their output. Hosts with more than one monitor pick the output
          # with a second rule (default_output).
          window_rule = [
            {
              match.app_id = "^org[.]gnome[.]Calculator$";
              default_pinned = true;
              default_position = {
                x = 20;
                y = 20;
                anchor = "bottom_right";
              };
            }
          ];
        };
      };
  };
}
