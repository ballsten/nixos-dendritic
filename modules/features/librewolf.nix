{ inputs, ... }:
{
  # LibreWolf, the main browser, with Bitwarden and uBlock Origin. Logging in
  # to Bitwarden stays manual. Teams has its own Chromium (teams.nix).
  # Mod+B opens it; that needs the desktop feature for Umbriel.
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

        config = {
          librewolf.extensions = {
            "{446900e4-71c2-419f-a6a7-df9c091e268b}" = "bitwarden-password-manager";
            # LibreWolf ships it installed but removable; forced, it stays.
            "uBlock0@raymondhill.net" = "ublock-origin";
          };

          # Every home-manager user on the host gets the user side, with the
          # extensions from every feature.
          home-manager.sharedModules = [
            inputs.self.modules.homeManager.librewolf
            {
              programs.librewolf.policies.ExtensionSettings = lib.mapAttrs (_: slug: {
                install_url = "https://addons.mozilla.org/firefox/downloads/latest/${slug}/latest.xpi";
                # Kept installed and enabled; they can't be removed from the
                # browser.
                installation_mode = "force_installed";
              }) config.librewolf.extensions;
            }
          ];
        };
      };

    homeManager.librewolf =
      { config, lib, ... }:
      {
        programs.librewolf = {
          enable = true;
          # Merged over LibreWolf's own policies, which keep telemetry and
          # studies off.
          policies = {
            # Bitwarden replaces the built-in password manager.
            PasswordManagerEnabled = false;
          };
          # LibreWolf's defaults otherwise, resistFingerprinting included. It
          # clears cookies and site data on every exit; keep them, so site
          # logins survive a restart (docs/features/librewolf.md).
          settings."privacy.sanitize.sanitizeOnShutdown" = false;
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
          action = "spawn:${lib.getExe config.programs.librewolf.finalPackage}";
          repeat = false;
        };

        # Profile: extension logins and settings, history, cookies.
        home.persistence."/persist".directories = [ ".librewolf" ];
      };
  };
}
