{ inputs, ... }:
{
  # vesktop, a Discord client with Vencord built in. Its settings and Vencord
  # plugins are left to the app; only its state is persisted.
  flake.modules = {
    # Every home-manager user on the host gets it.
    nixos.vesktop.home-manager.sharedModules = [ inputs.self.modules.homeManager.vesktop ];

    homeManager.vesktop = {
      programs.vesktop.enable = true;
      # Login, vesktop and Vencord settings, plugins and the Electron profile.
      home.persistence."/persist".directories = [ ".config/vesktop" ];
    };
  };
}
