_: {
  # Unfree packages are allowed by name only. Each feature adds the names it
  # needs to unfree.packages, next to the package itself; anything else
  # unfree fails evaluation. Covers home-manager too (useGlobalPkgs).
  flake.modules.nixos.unfree =
    { config, lib, ... }:
    {
      options.unfree.packages = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
        description = "Names (lib.getName) of unfree packages allowed on this host.";
      };

      config.nixpkgs.config.allowUnfreePredicate =
        pkg: builtins.elem (lib.getName pkg) config.unfree.packages;
    };
}
