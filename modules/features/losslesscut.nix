{ inputs, ... }:
{
  # LosslessCut, for cutting long recordings into clips without re-encoding,
  # such as a squash session into one file per match. See
  # docs/features/losslesscut.md.
  flake.modules = {
    nixos.losslesscut =
      { pkgs, ... }:
      {
        environment.systemPackages = [ pkgs.losslesscut-bin ];
        # Every home-manager user on the host keeps their settings.
        home-manager.sharedModules = [ inputs.self.modules.homeManager.losslesscut ];
      };

    # Settings, keyboard layout and export options. electron-store saves
    # them by renaming over the file, so the directory is persisted.
    homeManager.losslesscut.home.persistence."/persist".directories = [ ".config/LosslessCut" ];
  };
}
