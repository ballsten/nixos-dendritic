{ inputs, ... }:
{
  flake.modules.nixos.ballsten =
    { config, pkgs, ... }:
    {
      sops.secrets."users/ballsten/password".neededForUsers = true;

      users.users.ballsten = {
        isNormalUser = true;
        extraGroups = [
          "wheel"
          "networkmanager"
        ];
        shell = pkgs.fish;
        hashedPasswordFile = config.sops.secrets."users/ballsten/password".path;
      };
      programs.fish.enable = true;

      home-manager.users.ballsten = {
        imports = with inputs.self.modules.homeManager; [
          ballsten
          secrets
        ];
      };
    };
}
