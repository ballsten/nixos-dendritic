_: {
  flake.modules.nixos.nix-settings = {
    nix = {
      settings = {
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
        # Build everything that can be built, even after one build fails.
        keep-going = true;
      };
      extraOptions = "warn-dirty = false";

      # Weekly, and caught up after the machine was off or asleep (the
      # timers' state is persisted). 30 days matches how long impermanence
      # keeps old roots.
      gc = {
        automatic = true;
        dates = [ "weekly" ];
        options = "--delete-older-than 30d";
      };
      # Hard-links identical files in the store. A timer rather than
      # auto-optimise-store, which slows down every build.
      optimise = {
        automatic = true;
        dates = [ "weekly" ];
      };
    };
  };
}
