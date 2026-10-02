{ ... }:
{
  flake.modules.homeManager.ballsten =
    { pkgs, ... }:
    {
      home.username = "ballsten";
      home.homeDirectory = "/home/ballsten";
      home.stateVersion = "25.11";

      home.packages = with pkgs; [
        claude-code
      ];

      programs.helix.enable = true;

      programs.git = {
        enable = true;
        settings.user = {
          name = "ballsten";
          email = "theaks@gmail.com";
        };
      };

      programs.fish.enable = true;
    };
}
