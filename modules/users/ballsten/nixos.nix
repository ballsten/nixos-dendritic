{ inputs, ... }:
{
  flake.modules.nixos.ballsten =
    { pkgs, ... }:
    {
      users.users.ballsten = {
        isNormalUser = true;
        extraGroups = [
          "wheel"
          "networkmanager"
        ];
        shell = pkgs.fish;
      };
      programs.fish.enable = true;

      home-manager.users.ballsten = {
        imports = [ inputs.self.modules.homeManager.ballsten ];
      };
    };
}
