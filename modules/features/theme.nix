{ inputs, ... }:
{
  # Desktop styling with Noctalia's own theming: dark colours generated from
  # the wallpaper, applied to the shell and, through Noctalia's built-in
  # templates, to other apps. See docs/features/theme.md.
  flake.modules = {
    # Every home-manager user on the host gets it.
    nixos.theme.home-manager.sharedModules = [ inputs.self.modules.homeManager.theme ];

    homeManager.theme =
      let
        wallpapers = ../../assets/wallpapers;
      in
      { pkgs, ... }:
      {
        programs = {
          noctalia.settings = {
            theme = {
              source = "wallpaper";
              mode = "dark";
              wallpaper_scheme = "m3-content";
              # Templates that write generated colours into other apps'
              # configs. Each one needs its include declared below, since
              # home-manager links those configs read-only.
              templates.builtin_ids = [
                "umbriel"
                "kitty"
                "gtk3"
                "gtk4"
              ];
            };

            wallpaper = {
              # Wallpapers to pick from in Noctalia's picker. A choice made
              # there lasts until reboot, when /home is wiped and the
              # default comes back.
              directory = "${wallpapers}";
              default.path = "${wallpapers}/astronaut-and-robot.jpg";
            };
          };

          # Noctalia's umbriel template writes ~/.config/umbriel/noctalia.toml
          # and adds this include if it's missing. Declaring it here means the
          # hook finds it already present and leaves config.toml alone.
          umbriel.settings.include.optional.files = [ "noctalia.toml" ];

          # The kitty template writes ~/.config/kitty/themes/noctalia.conf,
          # and its hook reloads running kitty windows.
          kitty.extraConfig = "include themes/noctalia.conf";
        };

        # The gtk3 and gtk4 templates write noctalia.css next to each
        # gtk.css and import it from there. Their hook also sets gtk-theme
        # and color-scheme through dconf, to the same values as below.
        gtk =
          let
            importNoctalia = ''@import url("noctalia.css");'';
          in
          {
            enable = true;
            colorScheme = "dark";
            # adw-gtk3 makes GTK 3 apps look like libadwaita ones and uses
            # the same colour names, so noctalia.css restyles both.
            theme = {
              name = "adw-gtk3-dark";
              package = pkgs.adw-gtk3;
            };
            gtk3.extraCss = importNoctalia;
            gtk4 = {
              # libadwaita apps take their colours from noctalia.css alone,
              # so no GTK 4 theme is imported as well.
              theme = null;
              extraCss = importNoctalia;
            };
          };
      };
  };
}
