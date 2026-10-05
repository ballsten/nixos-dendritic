_: {
  # Loads a repo's dev shell on cd (via its .envrc); nix-direnv caches it and
  # keeps it from being garbage collected.
  flake.modules.homeManager.direnv = {
    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    # The allow list, so .envrc files needn't be re-allowed after a reboot.
    home.persistence."/persist".directories = [ ".local/share/direnv" ];
  };
}
