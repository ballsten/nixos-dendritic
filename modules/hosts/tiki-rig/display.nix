_: {
  # Two LG 27GL850 (2560x1440, 144 Hz): DP-3 on the left, DP-2 on the right.
  flake.modules.nixos.tiki-rig.home-manager.sharedModules = [
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
        # Variable refresh rate for games only. On the desktop it can make
        # the panels flicker at low frame rates.
        window_rule = [
          {
            match.content_type = "game";
            vrr = "always";
          }
        ];
      };
    }
  ];
}
