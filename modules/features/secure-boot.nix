{ inputs, ... }:
{
  flake-file.inputs.lanzaboote = {
    # Tracks a release tag, as lanzaboote recommends; bump it by hand.
    url = "github:nix-community/lanzaboote/v1.2.0";
    inputs = {
      nixpkgs.follows = "nixpkgs";
      # Only used to develop lanzaboote itself.
      pre-commit.follows = "";
    };
  };

  # Secure Boot with our own keys. lanzaboote replaces systemd-boot and signs
  # the boot files on the ESP. On the first boot it creates the keys, and on
  # the next boot systemd-boot enrolls them while the firmware is in setup
  # mode, turning Secure Boot on. See docs/secure-boot.md.
  flake.modules.nixos.secure-boot =
    { pkgs, ... }:
    {
      imports = [ inputs.lanzaboote.nixosModules.lanzaboote ];

      boot.lanzaboote = {
        enable = true;
        # Read from /persist directly: the keys are needed to sign during
        # activation.
        pkiBundle = "/persist/var/lib/sbctl";
        autoGenerateKeys.enable = true;
        # Keeps the Microsoft keys (the default), which option ROMs need.
        autoEnrollKeys.enable = true;
      };

      # For checking signatures and Secure Boot state (sbctl status, verify).
      environment.systemPackages = [ pkgs.sbctl ];
    };
}
