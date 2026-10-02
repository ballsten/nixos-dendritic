{ ... }:
{
  # Loads a repo's dev shell on cd (via its .envrc); nix-direnv caches it and
  # keeps it from being garbage collected.
  flake.modules.homeManager.direnv = {
    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
  };
}
