{ inputs, ... }:
{
  # Run by `nix flake check` (and so by CI); `just lint` runs the same tools
  # on the working tree.
  perSystem =
    { pkgs, ... }:
    let
      lint =
        name: tools: script:
        pkgs.runCommand "lint-${name}" { nativeBuildInputs = tools; } ''
          cd ${inputs.self}
          ${script}
          touch $out
        '';
    in
    {
      checks = {
        statix = lint "statix" [ pkgs.statix ] "statix check .";
        deadnix = lint "deadnix" [ pkgs.deadnix ] "deadnix --fail .";
        actionlint = lint "actionlint" [
          pkgs.actionlint
          pkgs.shellcheck
        ] "actionlint .github/workflows/*.yml";
      };
    };
}
