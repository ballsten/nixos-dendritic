{ inputs, ... }:
{
  # CLI tools wrapped so only they receive their tokens (docs/secrets.md).
  flake.modules.homeManager.ballsten =
    { config, pkgs, ... }:
    let
      inherit (inputs.self.lib) wrapWithSecrets;
      secrets = config.sops.secrets;
    in
    {
      sops.secrets."users/ballsten/tokens/github" = { };

      home.packages = [
        (wrapWithSecrets pkgs pkgs.gh { GH_TOKEN = secrets."users/ballsten/tokens/github".path; })
      ];
    };
}
