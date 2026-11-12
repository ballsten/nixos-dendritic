{ inputs, ... }:
{
  # LibreWolf, the main browser, with Bitwarden, uBlock Origin and floccus.
  # Logging in to Bitwarden and setting up floccus stay manual. Teams has its
  # own Chromium (teams.nix). Mod+B opens it; that needs the desktop feature
  # for Umbriel.
  flake.modules = {
    nixos.librewolf =
      { config, lib, ... }:
      {
        # Other features add their extensions here, next to what they're for
        # (prun.nix, for example).
        options.librewolf.extensions = lib.mkOption {
          type = lib.types.attrsOf lib.types.str;
          default = { };
          example = {
            "uBlock0@raymondhill.net" = "ublock-origin";
          };
          description = "Extensions LibreWolf force-installs, as add-on ID = addons.mozilla.org slug.";
        };

        options.librewolf.toolbar = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [ ];
          example = [ "{446900e4-71c2-419f-a6a7-df9c091e268b}" ];
          description = "Add-on IDs from librewolf.extensions whose button goes on the toolbar instead of the extensions menu.";
        };

        config = {
          # Firefox only places a button when it first sees the extension,
          # so an already-installed one stays where it is until moved by
          # hand.
          librewolf.toolbar = [
            "{446900e4-71c2-419f-a6a7-df9c091e268b}"
            "floccus@handmadeideas.org"
          ];

          librewolf.extensions = {
            "{446900e4-71c2-419f-a6a7-df9c091e268b}" = "bitwarden-password-manager";
            # LibreWolf ships it installed but removable; forced, it stays.
            "uBlock0@raymondhill.net" = "ublock-origin";
            # Syncs bookmarks between hosts, encrypted, through Google Drive
            # (docs/features/librewolf.md#bookmark-sync).
            "floccus@handmadeideas.org" = "floccus";
          };

          # Every home-manager user on the host gets the user side, with the
          # extensions from every feature.
          home-manager.sharedModules = [
            inputs.self.modules.homeManager.librewolf
            {
              programs.librewolf.policies.ExtensionSettings = lib.mapAttrs (
                id: slug:
                {
                  install_url = "https://addons.mozilla.org/firefox/downloads/latest/${slug}/latest.xpi";
                  # Kept installed and enabled; they can't be removed from the
                  # browser.
                  installation_mode = "force_installed";
                }
                // lib.optionalAttrs (lib.elem id config.librewolf.toolbar) {
                  default_area = "navbar";
                }
              ) config.librewolf.extensions;
            }
          ];
        };
      };

    homeManager.librewolf =
      { config, lib, ... }:
      {
        programs.librewolf = {
          enable = true;
          # LibreWolf only keeps its profile in ~/.librewolf, where
          # home-manager writes librewolf.overrides.cfg, if profiles.ini is
          # there. Otherwise it starts one in ~/.config/librewolf, which
          # doesn't read the overrides and isn't persisted. Declaring the
          # profile writes profiles.ini.
          profiles.default.isDefault = true;
          # Merged over LibreWolf's own policies, which keep telemetry and
          # studies off.
          policies = {
            # Bitwarden replaces the built-in password manager.
            PasswordManagerEnabled = false;
          };
          # LibreWolf's defaults otherwise, with three changes
          # (docs/features/librewolf.md#privacy-settings).
          settings = {
            # It clears cookies and site data on every exit; keep them, so
            # site logins survive a restart.
            "privacy.sanitize.sanitizeOnShutdown" = false;
            # resistFingerprinting always reports a light theme, and none of
            # its protections can be turned off on their own. Fingerprinting
            # Protection with every target applies the same protections,
            # minus that one, so sites follow the desktop's dark theme.
            "privacy.resistFingerprinting" = false;
            "privacy.fingerprintingProtection" = true;
            "privacy.fingerprintingProtection.overrides" = "+AllTargets,-CSSPrefersColorScheme";
            # LibreWolf blocks WebGL until it's allowed per site, and hides
            # the prompt, so pages that need it silently fail. Allow it
            # everywhere, as Firefox does; sites still get a generic GPU name.
            "librewolf.webgl.prompt" = false;
          };
        };

        # Links from other apps open here.
        xdg.mimeApps = {
          enable = true;
          defaultApplications = lib.genAttrs [
            "text/html"
            "x-scheme-handler/http"
            "x-scheme-handler/https"
          ] (_: "librewolf.desktop");
        };

        # Starts LibreWolf, or opens a new window in the running one.
        programs.umbriel.settings.keybinds."Mod+B" = {
          action = "spawn ${lib.getExe config.programs.librewolf.finalPackage}";
          repeat = false;
        };

        # Profile: extension logins and settings, history, cookies.
        home.persistence."/persist".directories = [ ".librewolf" ];
      };
  };
}
