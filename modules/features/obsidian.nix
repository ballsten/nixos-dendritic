{ inputs, ... }:
{
  # Obsidian. Vaults keep their own settings in their .obsidian folder, so
  # only the app is managed here; users register their vaults with
  # programs.obsidian.vaults (no settings, so nothing is written into the
  # vault).
  flake.modules = {
    nixos.obsidian = {
      unfree.packages = [ "obsidian" ];
      # Every home-manager user on the host gets the app.
      home-manager.sharedModules = [ inputs.self.modules.homeManager.obsidian ];
    };

    homeManager.obsidian = {
      programs.obsidian.enable = true;
      # Vault list, window state and Electron profile. Vault contents live
      # wherever the vault is (persisted separately).
      home.persistence."/persist".directories = [ ".config/obsidian" ];
    };
  };
}
