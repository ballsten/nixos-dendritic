{ inputs, ... }:
{
  flake.modules.nixos.workstation = {
    imports = [ inputs.home-manager.nixosModules.home-manager ];

    nix.settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      trusted-users = [
        "root"
        "@wheel"
      ];
      substituters = [ "https://cache.nixos.org" ];
      trusted-public-keys = [ "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=" ];
    };
    nix.extraOptions = "warn-dirty = false";

    home-manager.useGlobalPkgs = true;
    home-manager.useUserPackages = true;

    networking.networkmanager.enable = true;

    i18n.defaultLocale = "en_US.UTF-8";

    services.openssh.enable = true;

    nixpkgs.config.allowUnfree = true;
  };
}
