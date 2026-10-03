{ inputs, ... }:
{
  # The home-manager input is declared in modules/flake/home-manager.nix.
  flake.modules.nixos.home-manager = {
    imports = [ inputs.home-manager.nixosModules.home-manager ];

    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
    };
  };
}
