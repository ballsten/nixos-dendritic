_: {
  flake.modules.homeManager.ballsten = {
    home = {
      username = "ballsten";
      homeDirectory = "/home/ballsten";
      stateVersion = "25.11";
    };

    programs = {
      helix.enable = true;

      git = {
        enable = true;
        settings.user = {
          name = "ballsten";
          email = "theaks@gmail.com";
        };
      };

      fish.enable = true;
    };
  };
}
