{ inputs, ... }:
{
  # lazygit, a terminal UI for git.
  flake.modules = {
    # Every home-manager user on the host gets it.
    nixos.lazygit.home-manager.sharedModules = [ inputs.self.modules.homeManager.lazygit ];

    homeManager.lazygit = {
      # Also defines `lg` in fish: runs lazygit, then changes to the repo
      # you switched to inside it.
      programs.lazygit.enable = true;
      # Recent repos and dismissed popups.
      home.persistence."/persist".directories = [ ".local/state/lazygit" ];
    };
  };
}
