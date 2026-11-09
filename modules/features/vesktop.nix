{ inputs, ... }:
{
  # vesktop, a Discord client with Vencord built in. Its settings and Vencord
  # plugins are left to the app; only its state is persisted.
  flake.modules = {
    # Every home-manager user on the host gets it.
    nixos.vesktop.home-manager.sharedModules = [ inputs.self.modules.homeManager.vesktop ];

    homeManager.vesktop =
      { config, lib, ... }:
      {
        programs.vesktop.enable = true;
        # Login, vesktop and Vencord settings, plugins and the Electron profile.
        home.persistence."/persist".directories = [ ".config/vesktop" ];

        # Its own Chat workspace, toggled with Mod+Alt+C. Needs the
        # app-workspaces feature. Electron reports "vesktop" on Wayland and
        # the desktop file's class, "Vesktop", under XWayland.
        appWorkspaces.workspaces.Chat = {
          key = "C";
          apps.vesktop = {
            appId = "^[Vv]esktop$";
            command = lib.getExe config.programs.vesktop.package;
          };
        };
      };
  };
}
