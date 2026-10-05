{ inputs, ... }:
{
  # Run by `nix flake check` (and so by CI); `just lint` runs the same tools
  # on the working tree.
  perSystem =
    { pkgs, self', ... }:
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
      # Every feature, host and user has a page under docs/, and every page
      # has a module (docs/README.md). Run from the repo root.
      packages.check-docs = pkgs.writeShellApplication {
        name = "check-docs";
        text = ''
          status=0

          # check <kind> <names...>: docs/<kind>/<name>.md exists for each
          # name, and every page there names one of them.
          check() {
            local kind=$1 name page
            shift
            for name in "$@"; do
              [ -f "docs/$kind/$name.md" ] || {
                echo "missing docs/$kind/$name.md" >&2
                status=1
              }
            done
            for page in "docs/$kind"/*.md; do
              [ -e "$page" ] || continue
              name=$(basename "$page" .md)
              [[ " $* " == *" $name "* ]] || {
                echo "$page has no matching module" >&2
                status=1
              }
            done
          }

          # names <dir> <find tests...>: entries of dir, skipping /_ paths
          # as import-tree does.
          names() {
            find "$1" -mindepth 1 -maxdepth 1 ! -name '_*' "''${@:2}" -printf '%f\n' | sed 's/\.nix$//' | sort
          }

          mapfile -t features < <(names modules/features -name '*.nix')
          mapfile -t hosts < <(names modules/hosts -type d)
          mapfile -t users < <(names modules/users -type d)

          check features "''${features[@]}"
          check hosts "''${hosts[@]}"
          check users "''${users[@]}"

          exit "$status"
        '';
      };

      checks = {
        statix = lint "statix" [ pkgs.statix ] "statix check .";
        deadnix = lint "deadnix" [ pkgs.deadnix ] "deadnix --fail .";
        actionlint = lint "actionlint" [
          pkgs.actionlint
          pkgs.shellcheck
        ] "actionlint .github/workflows/*.yml";
        docs = lint "docs" [ self'.packages.check-docs ] "check-docs";
      };
    };
}
