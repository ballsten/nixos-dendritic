{ inputs, ... }:
{
  # Brave with Bitwarden. Logging in to Bitwarden stays manual.
  flake.modules = {
    nixos.brave = {
      # Brave only reads managed policies from /etc, so this is system-wide.
      # Bitwarden replaces the built-in password manager.
      environment.etc."brave/policies/managed/password-manager.json".text = builtins.toJSON {
        PasswordManagerEnabled = false;
      };

      # Every home-manager user on the host gets the user side.
      home-manager.sharedModules = [ inputs.self.modules.homeManager.brave ];
    };

    homeManager.brave.programs.brave = {
      enable = true;
      extensions = [
        # Bitwarden
        { id = "nngceckbapebfimnlniiiahkandclblb"; }
      ];
    };
  };
}
