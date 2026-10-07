{ inputs, ... }:
{
  flake.modules.nixos.ballsten =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      sops.secrets."users/ballsten/password".neededForUsers = true;

      users.users.ballsten = {
        isNormalUser = true;
        # Pinned: files on /persist are owned by this uid, and it mustn't
        # depend on /var/lib/nixos surviving.
        uid = 1000;
        extraGroups = [
          "wheel"
          "networkmanager"
        ]
        # On hosts with the gaming feature: lets gamemode change the CPU
        # governor without a password.
        ++ lib.optional config.programs.gamemode.enable "gamemode";
        shell = pkgs.fish;
        hashedPasswordFile = config.sops.secrets."users/ballsten/password".path;
      };
      programs.fish.enable = true;

      security.sudo.extraRules = [
        {
          users = [ "ballsten" ];
          commands = [
            {
              command = "ALL";
              options = [ "NOPASSWD" ];
            }
          ];
        }
      ];

      home-manager.users.ballsten = {
        imports = with inputs.self.modules.homeManager; [
          ballsten
          direnv
          secrets
        ];
      };
    };
}
