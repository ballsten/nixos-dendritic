{ inputs, ... }:
{
  flake.modules = {
    # Unfree packages used below (see modules/features/unfree.nix).
    nixos.ballsten.unfree.packages = [ "claude-code" ];

    # CLI tools wrapped so only they receive their tokens (docs/secrets.md).
    homeManager.ballsten =
      { config, pkgs, ... }:
      let
        inherit (inputs.self.lib) wrapWithSecrets;
        secrets = config.sops.secrets;
      in
      {
        sops.secrets = {
          "users/ballsten/tokens/github" = { };
          # Long-lived token from `claude setup-token`, not the short-lived one
          # Claude Code refreshes in ~/.claude/.credentials.json.
          "users/ballsten/tokens/claude" = { };
        };

        home.packages = [
          (wrapWithSecrets pkgs pkgs.gh { GH_TOKEN = secrets."users/ballsten/tokens/github".path; })
          (wrapWithSecrets pkgs pkgs.claude-code {
            CLAUDE_CODE_OAUTH_TOKEN = secrets."users/ballsten/tokens/claude".path;
          })
        ];
      };
  };
}
