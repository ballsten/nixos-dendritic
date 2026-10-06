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
    { osConfig, ... }:
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
          settings = {
            include.files = [
              "${osConfig.programs.umbriel.package}/share/umbriel/config.toml"
            ];

            # Media keys, which the packaged config leaves unbound. These
            # merge into its [keybinds] table. Noctalia shows its own OSD
            # for each, and sets the backlight through logind, so no
            # wpctl, brightnessctl, playerctl or video group is needed.
            # All of them are safe to allow on the lock screen.
            keybinds =
              let
                # Held volume and brightness keys keep stepping.
                step = action: {
                  action = "spawn:noctalia msg ${action} 5";
                  allow_when_locked = true;
                };
                once = action: {
                  action = "spawn:noctalia msg ${action}";
                  allow_when_locked = true;
                  repeat = false;
                };
              in
              {
                "XF86AudioRaiseVolume" = step "volume-up";
                "XF86AudioLowerVolume" = step "volume-down";
                "XF86AudioMute" = once "volume-mute";
                "XF86AudioMicMute" = once "mic-mute";
                "XF86MonBrightnessUp" = step "brightness-up";
                "XF86MonBrightnessDown" = step "brightness-down";
                # Keyboards send either Play or Pause for the one
                # play/pause key, so both toggle.
                "XF86AudioPlay" = once "media toggle";
                "XF86AudioPause" = once "media toggle";
                "XF86AudioStop" = once "media stop";
                "XF86AudioNext" = once "media next";
                "XF86AudioPrev" = once "media previous";
              };
          };
        };

        noctalia = {
          enable = true;
          systemd.enable = true;
          # Apps started from the launcher run as their own transient
          # systemd units. Otherwise they share noctalia.service's cgroup,
          # and restarting the service (as home-manager does on rebuild)
          # kills them or the helper processes they leave there.
          settings.shell.launch_apps_as_systemd_services = true;
        };

        # Umbriel's packaged config binds Mod+Return to kitty.
        kitty = {
          enable = true;
          settings = {
            # Lets the wallpaper show through a little.
            background_opacity = 0.85;
            window_padding_width = 8;
          };
        };
      };
    };
}
