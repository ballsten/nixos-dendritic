{ inputs, ... }:
{
  # The standard XDG home folders, created at every login and listed in
  # ~/.config/user-dirs.dirs for file pickers and browsers. Which of them
  # survive a reboot is up to each user's persistence.
  flake.modules = {
    # Every home-manager user on the host gets it.
    nixos.xdg-user-dirs.home-manager.sharedModules = [ inputs.self.modules.homeManager.xdg-user-dirs ];

    homeManager.xdg-user-dirs.xdg.userDirs = {
      enable = true;
      createDirectories = true;
      # Not wanted. Projects would duplicate ~/repos.
      desktop = null;
      templates = null;
      publicShare = null;
      projects = null;
    };
  };
}
