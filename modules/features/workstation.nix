{ inputs, ... }:
{
  flake.modules.nixos.workstation = {
    imports = [
      inputs.home-manager.nixosModules.home-manager
      inputs.self.modules.nixos.secrets
      inputs.self.modules.nixos.wifi
      inputs.self.modules.nixos.unfree
    ];

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

    # Passwords come from sops (see users/); passwd changes do not persist.
    users.mutableUsers = false;

    i18n.defaultLocale = "en_US.UTF-8";

    services.openssh.enable = true;
  };
}
