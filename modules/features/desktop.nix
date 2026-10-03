{ inputs, ... }:
{
  # Umbriel compositor, Noctalia shell and noctalia-greeter, all with their
  # default configuration. Umbriel runs as a systemd user session that pulls
  # in graphical-session.target, which starts the Noctalia user service.
  flake.modules.nixos.desktop = {
    programs = {
      umbriel.enable = true;
      # System side of Noctalia: xdg sounds and the services its widgets use
      # (NetworkManager, Bluetooth, UPower, power-profiles-daemon). The shell
      # itself runs from home-manager below.
      noctalia = {
        enable = true;
        recommendedServices.enable = true;
      };
    };

    services = {
      displayManager.noctalia-greeter.enable = true;

      pipewire = {
        enable = true;
        alsa.enable = true;
        pulse.enable = true;
      };
    };

    security.rtkit.enable = true;

    fonts.enableDefaultPackages = true;

    # Every home-manager user on a desktop host gets the user side.
    home-manager.sharedModules = [ inputs.self.modules.homeManager.desktop ];
  };

  flake.modules.homeManager.desktop =
    { pkgs, ... }:
    {
      programs.noctalia = {
        enable = true;
        systemd.enable = true;
      };

      # Umbriel's default config binds Mod+Return to kitty.
      home.packages = [ pkgs.kitty ];
    };
}
