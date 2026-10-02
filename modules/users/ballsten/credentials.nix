{ ... }:
{
  # API tokens, exported to every fish shell.
  flake.modules.homeManager.ballsten =
    { config, ... }:
    let
      secrets = config.sops.secrets;
      exportSecret = var: name: ''
        if test -r ${secrets.${name}.path}
          set -gx ${var} (cat ${secrets.${name}.path})
        end
      '';
    in
    {
      sops.secrets."users/ballsten/tokens/github" = { };

      programs.fish.shellInit = exportSecret "GH_TOKEN" "users/ballsten/tokens/github";
    };
}
