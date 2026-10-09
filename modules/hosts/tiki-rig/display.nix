_: {
  # Two LG 27GL850 (2560x1440, 144 Hz): DP-3 on the left, DP-2 on the right.
  # Variable refresh rate stays off. Switching it on and off as a game gains
  # and loses focus blanks the monitor for a moment
  # (docs/decisions/0036-no-vrr-on-tiki-rig.md).
  flake.modules.nixos.tiki-rig.home-manager.sharedModules = [
    {
      programs.umbriel.settings.output =
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
    }
  ];
}
