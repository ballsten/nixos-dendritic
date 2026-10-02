{ ... }:
{
  perSystem =
    { pkgs, ... }:
    {
      devShells.default = pkgs.mkShell {
        packages = with pkgs; [
          just
          # secrets
          sops
          age
          ssh-to-age
          yq-go
          openssh
        ];
      };
    };
}
