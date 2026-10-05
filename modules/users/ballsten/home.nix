_: {
  flake.modules = {
    # Unfree packages used below (see modules/features/unfree.nix).
    nixos.ballsten.unfree.packages = [ "claude-code" ];

    homeManager.ballsten =
      { config, pkgs, ... }:
      {
        home = {
          username = "ballsten";
          homeDirectory = "/home/ballsten";
          stateVersion = "25.11";

          packages = with pkgs; [
            claude-code
          ];

          # Keep Claude Code's .claude.json inside ~/.claude rather than at
          # ~/.claude.json: a persisted single file breaks when a program
          # saves it by renaming a new file over it.
          sessionVariables.CLAUDE_CONFIG_DIR = "${config.home.homeDirectory}/.claude";

          # Everything else in home is wiped on boot (docs/impermanence.md).
          persistence."/persist".directories = [
            "repos"
            "Documents"
            "Pictures"
            "Music"
            "Videos"
            # Claude Code: login, settings, history and memory.
            ".claude"
            # fish history.
            ".local/share/fish"
          ];
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

          # Notes vault, a git repo synced with obsidian-git.
          obsidian.vaults."Ballsten.md".target = "repos/Ballsten.md";
        };
      };
  };
}
