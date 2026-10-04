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
      sops.secrets = {
        "users/ballsten/tokens/github" = { };
        # SSH key for git push; ~/.ssh/id_ed25519 links to the decrypted file.
        "users/ballsten/ssh/id_ed25519".path = "${config.home.homeDirectory}/.ssh/id_ed25519";
      };

      home = {
        file.".ssh/id_ed25519.pub".text =
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJkft2bDJQf3o3GNXTWayI4jphfK5c50hXoIPQIPC2G2\n";

        packages = [
          (wrapWithSecrets pkgs pkgs.gh { GH_TOKEN = secrets."users/ballsten/tokens/github".path; })
        ];
      };
    };
}
