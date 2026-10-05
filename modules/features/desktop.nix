{ inputs, ... }:
{
  # Only for its home-manager module (programs.umbriel.settings). The
  # compositor itself comes from nixpkgs via the NixOS programs.umbriel.
  flake-file.inputs.umbriel = {
    url = "github:noctalia-dev/umbriel";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  # Umbriel compositor, Noctalia shell and noctalia-greeter. Umbriel runs as a
  # systemd user session that pulls in graphical-session.target, which starts
  # the Noctalia user service.
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

    # Bluetooth (from Noctalia's recommended services) keeps pairings here.
    environment.persistence."/persist".directories = [ "/var/lib/bluetooth" ];

    fonts.enableDefaultPackages = true;

    # Every home-manager user on a desktop host gets the user side.
    home-manager.sharedModules = [ inputs.self.modules.homeManager.desktop ];
  };

  flake.modules.homeManager.desktop =
    { osConfig, pkgs, ... }:
    {
      imports = [ inputs.umbriel.homeModules.default ];

      programs = {
        umbriel = {
          enable = true;
          # Use the system package from nixpkgs rather than the flake's own
          # build, which isn't in the binary cache.
          package = null;
          # Writing ~/.config/umbriel/config.toml replaces the packaged
          # config, so include it first to keep its keybinds and rules. The
          # including file is applied last, so settings here and in hosts
          # (outputs, scaling) override it.
          settings.include.files = [
            "${osConfig.programs.umbriel.package}/share/umbriel/config.toml"
          ];
        };

        noctalia = {
          enable = true;
          systemd.enable = true;
        };
      };

      # Umbriel's packaged config binds Mod+Return to kitty.
      home.packages = [ pkgs.kitty ];
    };
}
