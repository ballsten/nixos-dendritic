{ inputs, ... }:
{
  flake-file.inputs.sops-nix = {
    url = "github:Mic92/sops-nix";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  # Decrypts with the host's SSH key, which sops takes from
  # services.openssh.hostKeys (on /persist, see the ssh feature).
  flake.modules.nixos.secrets = {
    imports = [ inputs.sops-nix.nixosModules.sops ];

    sops.defaultSopsFile = ../../secrets/secrets.yaml;
  };

  flake.modules.homeManager.secrets =
    { config, ... }:
    {
      imports = [ inputs.sops-nix.homeManagerModules.sops ];

      sops = {
        defaultSopsFile = ../../secrets/secrets.yaml;
        # The admin age key; must be present on every host running this
        # config. Read from /persist directly, like the host key.
        age.keyFile = "/persist${config.xdg.configHome}/sops/age/keys.txt";
      };

      # The sops CLI (just secrets-edit) reads it from the usual place.
      home.persistence."/persist".files = [ ".config/sops/age/keys.txt" ];
    };
}
