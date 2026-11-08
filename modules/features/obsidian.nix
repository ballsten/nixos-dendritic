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

    homeManager.obsidian =
      { config, lib, ... }:
      {
        programs.obsidian.enable = true;
        # Vault list, window state and Electron profile. Vault contents live
        # wherever the vault is (persisted separately).
        home.persistence."/persist".directories = [ ".config/obsidian" ];

        # Its own Notes workspace, toggled with Mod+Alt+N. Needs the
        # app-workspaces feature. Electron reports the desktop file's
        # class under XWayland and plain "obsidian" on Wayland.
        appWorkspaces.workspaces.Notes = {
          key = "N";
          apps.obsidian = {
            appId = "^(obsidian|md[.]obsidian[.]Obsidian)$";
            command = lib.getExe config.programs.obsidian.package;
          };
        };
      };
  };
}
