_: {
  perSystem =
    { pkgs, self', ... }:
    {
      # gh and claude-code stay in home-manager, where they are wrapped with
      # their tokens; a copy here would shadow the wrappers on PATH.
      devShells.default = pkgs.mkShell {
        packages = with pkgs; [
          just
          # secrets
          sops
          age
          ssh-to-age
          yq-go
          jq
          mkpasswd
          openssh
          # lint (just lint)
          statix
          deadnix
          actionlint
          shellcheck
          self'.packages.check-docs
          # inspect builds and closures
          nvd
          nix-tree
          nix-diff
          nix-output-monitor
          # fetcher hashes
          nurl
          # writing an empty dbx (docs/howto/update-firmware.md)
          gcab
          efitools
        ];
      };
    };
}
