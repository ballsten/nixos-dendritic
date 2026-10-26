_: {
  # Two LG 27GL850 (2560x1440, 144 Hz): DP-3 on the left, DP-2 on the right.
  flake.modules.nixos.tiki-rig = {
    # The login box only on the right monitor. The greeter runs its own
    # compositor and switches DP-3 off while it shows. Its default mode is
    # already the monitor's preferred 144 Hz, the same as the desktop.
    services.displayManager.noctalia-greeter.settings.output.name = "DP-2";

    # Variable refresh rate stays off. Switching it on and off as a game
    # gains and loses focus blanks the monitor for a moment
    # (docs/decisions/0036-no-vrr-on-tiki-rig.md).
    home-manager.sharedModules = [
      {
        programs.umbriel.settings = {
          output =
            let
              monitor = position: {
                mode = "2560x1440@144";
                inherit position;
                scale = 1.0;
              };
            in
            {
              DP-3 = monitor [
                0
                0
              ];
              DP-2 = monitor [
                2560
                0
              ];
            };

          # The calculator (modules/features/calculator.nix) opens on the
          # left monitor, wherever the pointer is.
          window_rule = [
            {
              match.app_id = "^org[.]gnome[.]Calculator$";
              default_output = "DP-3";
            }
          ];
        };
      }
    ];
  };
}
