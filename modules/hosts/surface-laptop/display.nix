_: {
  flake.modules.nixos.surface-laptop.home-manager.sharedModules = [
    {
      # Built-in 2736x1824 panel (~267 ppi); 2x gives 1368x912 logical.
      programs.umbriel.settings.output.eDP-1.scale = 2.0;
    }
  ];
}
