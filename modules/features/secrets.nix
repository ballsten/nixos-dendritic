{ inputs, ... }:
{
  flake-file.inputs.sops-nix = {
    url = "github:Mic92/sops-nix";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  flake.modules.nixos.secrets = {
    imports = [ inputs.sops-nix.nixosModules.sops ];

    sops.defaultSopsFile = ../../secrets/secrets.yaml;
    # Decrypt with the host's SSH key. Impermanence (#6) must change this to
    # the /persist path, as bind mounts may not exist yet during activation.
    sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

    # Placeholder proving decryption works; remove once a real secret exists (#11).
    sops.secrets.example = { };
  };
}
