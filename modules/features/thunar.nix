{ inputs, ... }:
{
  # Thunar, the file manager, with gvfs so phones (MTP), USB drives and the
  # trash show up in its sidebar, and xarchiver behind its right-click
  # extract and compress. Mod+E opens it; that needs the desktop feature for
  # Umbriel.
  flake.modules = {
    nixos.thunar =
      { pkgs, ... }:
      {
        programs.thunar = {
          enable = true;
          plugins = [ pkgs.thunar-archive-plugin ];
        };
        # The archive manager the plugin hands archives to. file-roller
        # would pull in Nautilus.
        environment.systemPackages = [ pkgs.xarchiver ];
        # Mounts phones over MTP, and USB drives through udisks2. The plain
        # build, not the module's default GNOME one, which adds GNOME
        # Online Accounts.
        services.gvfs = {
          enable = true;
          package = pkgs.gvfs;
        };

        # Every home-manager user on the host gets the user side.
        home-manager.sharedModules = [ inputs.self.modules.homeManager.thunar ];
      };

    homeManager.thunar =
      { lib, osConfig, ... }:
      {
        # Folders opened from other apps ("show in folder") open here.
        xdg.mimeApps = {
          enable = true;
          defaultApplications."inode/directory" = "thunar.desktop";
        };

        # Starts Thunar, or opens a new window in the running one.
        programs.umbriel.settings.keybinds."Mod+E" = {
          action = "spawn ${lib.getExe' osConfig.programs.thunar.finalPackage "thunar"}";
          repeat = false;
        };

        # Settings (xfconf, written by renaming over the file) and custom
        # actions and keyboard shortcuts.
        home.persistence."/persist".directories = [
          ".config/xfce4"
          ".config/Thunar"
        ];
      };
  };
}
