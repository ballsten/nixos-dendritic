{ inputs, ... }:
{
  # Brave with Bitwarden. Logging in to Bitwarden stays manual.
  flake.modules = {
    nixos.brave =
      { config, lib, ... }:
      {
        # Other features add their extensions here, next to what they're for
        # (prun.nix, for example).
        options.brave.extensions = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [ ];
          description = "Chrome Web Store IDs of extensions Brave force-installs.";
        };

        config = {
          brave.extensions = [
            # Bitwarden
            "nngceckbapebfimnlniiiahkandclblb"
          ];

          # Brave only reads managed policies from /etc, so this is system-wide.
          environment.etc."brave/policies/managed/nixos.json".text = builtins.toJSON {
            # Force-installed: Brave keeps these installed and enabled, and
            # they can't be removed from the browser.
            ExtensionInstallForcelist = map (
              id: "${id};https://clients2.google.com/service/update2/crx"
            ) config.brave.extensions;
            # Bitwarden replaces the built-in password manager.
            PasswordManagerEnabled = false;
            # Brave blocks the Idle Detection API on every site. Teams uses
            # it to stay Available while we're active outside its tab
            # (docs/features/brave.md#teams-presence).
            IdleDetectionAllowedForUrls = [
              "https://teams.microsoft.com"
              "https://teams.cloud.microsoft"
            ];
          };

          # Every home-manager user on the host gets the user side.
          home-manager.sharedModules = [ inputs.self.modules.homeManager.brave ];
        };
      };

    homeManager.brave = {
      programs.brave.enable = true;
      # Profile: extension logins and settings, history, cookies.
      home.persistence."/persist".directories = [ ".config/BraveSoftware" ];
    };
  };
}
