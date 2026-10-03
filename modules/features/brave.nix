{ inputs, ... }:
{
  # Brave with Bitwarden. Logging in to Bitwarden stays manual.
  flake.modules = {
    nixos.brave = {
      # Brave only reads managed policies from /etc, so this is system-wide.
      environment.etc."brave/policies/managed/nixos.json".text = builtins.toJSON {
        # Force-installed: Brave keeps Bitwarden installed and enabled, and
        # it can't be removed from the browser.
        ExtensionInstallForcelist = [
          "nngceckbapebfimnlniiiahkandclblb;https://clients2.google.com/service/update2/crx"
        ];
        # Bitwarden replaces the built-in password manager.
        PasswordManagerEnabled = false;
      };

      # Every home-manager user on the host gets the user side.
      home-manager.sharedModules = [ inputs.self.modules.homeManager.brave ];
    };

    homeManager.brave.programs.brave.enable = true;
  };
}
