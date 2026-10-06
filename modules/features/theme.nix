{ inputs, ... }:
let
  # One cursor everywhere: the greeter, Umbriel and apps. graphite-dark's
  # largest images are 48px, which is size 24 at scale 2.0.
  cursor = {
    name = "graphite-dark";
    size = 24;
  };
in
{
  # Desktop styling with Noctalia's own theming: dark colours generated from
  # the wallpaper, applied to the shell and, through Noctalia's built-in
  # templates, to other apps. See docs/features/theme.md.
  flake.modules = {
    nixos.theme =
      { pkgs, ... }:
      {
        # Noctalia has no font setting of its own: it asks fontconfig for
        # the default sans-serif, as most apps do.
        fonts = {
          packages = with pkgs; [
            inter
            nerd-fonts.fira-code
          ];
          fontconfig.defaultFonts = {
            sansSerif = [ "Inter" ];
            monospace = [ "FiraCode Nerd Font" ];
          };
        };

        services.displayManager.noctalia-greeter = {
          cursorTheme = {
            inherit (cursor) name;
            package = pkgs.graphite-cursors;
          };
          settings.cursor.size = cursor.size;
        };

        # Every home-manager user on the host gets it.
        home-manager.sharedModules = [ inputs.self.modules.homeManager.theme ];
      };

    homeManager.theme =
      let
        wallpapers = ../../assets/wallpapers;
      in
      { pkgs, lib, ... }:
      let
        # Noctalia's built-in kitty template, with ANSI colours 1-6 taken
        # from the custom colours below: each colour's main role for
        # normal, and its lighter on-container role for bright.
        ansi = [
          "red"
          "green"
          "yellow"
          "blue"
          "magenta"
          "cyan"
        ];
        slots =
          offset: role:
          lib.imap1 (i: c: "color${toString (i + offset)} {{colors.${role c}.default.hex}}") ansi;
        kittyColours = pkgs.writeText "kitty-colours.conf" ''
          color0 {{colors.terminal_normal_black.default.hex}}
          ${lib.concatLines (slots 0 (c: c))}color7 {{colors.terminal_normal_white.default.hex}}
          color8 {{colors.terminal_bright_black.default.hex}}
          ${
            lib.concatLines (slots 8 (c: "on_${c}_container"))
          }color15 {{colors.terminal_bright_white.default.hex}}

          cursor                {{colors.terminal_cursor.default.hex}}
          cursor_text_color     {{colors.terminal_cursor_text.default.hex}}
          background            {{colors.terminal_background.default.hex}}
          foreground            {{colors.terminal_foreground.default.hex}}
          selection_foreground  {{colors.terminal_selection_fg.default.hex}}
          selection_background  {{colors.terminal_selection_bg.default.hex}}
          active_border_color   {{colors.primary.default.hex}}
          inactive_border_color {{colors.surface_variant.default.hex}}
          url_color             {{colors.primary.default.hex}}

          active_tab_foreground   {{colors.on_primary.default.hex}}
          active_tab_background   {{colors.primary.default.hex}}
          inactive_tab_foreground {{colors.on_surface_variant.default.hex}}
          inactive_tab_background {{colors.surface_variant.default.hex}}
          cursor_trail_color      {{colors.on_surface_variant.default.hex}}
        '';
      in
      {
        # Installs the theme, links it as ~/.icons/default and sets it for
        # GTK (settings.ini and dconf).
        home.pointerCursor = {
          enable = true;
          inherit (cursor) name size;
          package = pkgs.graphite-cursors;
          gtk.enable = true;
        };

        programs = {
          noctalia.settings = {
            theme = {
              source = "wallpaper";
              mode = "dark";
              wallpaper_scheme = "m3-content";
              # Templates that write generated colours into other apps'
              # configs. Each one needs its include declared below, since
              # home-manager links those configs read-only.
              templates = {
                builtin_ids = [
                  "umbriel"
                  "gtk3"
                  "gtk4"
                ];

                # Terminal colours that stay recognisable on any wallpaper.
                # Noctalia's own kitty template fills ANSI green, blue and
                # so on with the palette's accents, which are all close in
                # hue. Each of these is toned for the dark background and,
                # with blend (the default), turned up to 15° towards the
                # wallpaper's colour.
                custom_colors = {
                  red = "#e53935";
                  green = "#43a047";
                  yellow = "#fdd835";
                  blue = "#1e88e5";
                  magenta = "#8e24aa";
                  cyan = "#00acc1";
                };

                # Replaces the built-in kitty template. It writes a file
                # with a different name, because dropping the built-in one
                # runs its undo hook, which deletes themes/noctalia.conf.
                user.kitty-colours = {
                  input_path = "${kittyColours}";
                  output_path = "$XDG_CONFIG_HOME/kitty/themes/colours.conf";
                  # Reloads running kitty windows.
                  post_hook = "${pkgs.procps}/bin/pkill -USR1 -x kitty || true";
                };
              };
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
          umbriel.settings = {
            include.optional.files = [ "noctalia.toml" ];
            # Umbriel exports these as XCURSOR_THEME and XCURSOR_SIZE to
            # everything it starts, replacing home.pointerCursor's values.
            # Without a theme it falls back to wlroots' built-in cursor,
            # which can't be scaled.
            input.cursor = {
              theme = cursor.name;
              inherit (cursor) size;
            };
          };

          kitty = {
            font.name = "FiraCode Nerd Font";
            extraConfig = "include themes/colours.conf";
          };
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
            # GTK reads these from dconf rather than fontconfig, and
            # Noctalia takes the icon theme for app icons from here too.
            font = {
              name = "Inter";
              size = 11;
            };
            iconTheme = {
              name = "Tela-dark";
              # Only the standard colour (Tela, Tela-dark, Tela-light): the
              # package installs all 15 colour variants, about 2.7 GB.
              package = pkgs.tela-icon-theme.overrideAttrs {
                installPhase = ''
                  runHook preInstall
                  patchShebangs install.sh
                  mkdir -p $out/share/icons
                  ./install.sh standard -d $out/share/icons
                  jdupes -l -r $out/share/icons
                  runHook postInstall
                '';
              };
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
