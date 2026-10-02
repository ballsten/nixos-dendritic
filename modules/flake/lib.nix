{ inputs, lib, ... }:
{
  options.flake.lib = lib.mkOption {
    type = lib.types.attrsOf lib.types.unspecified;
    default = { };
  };

  config.flake.lib.mkNixos = system: name: {
    ${name} = inputs.nixpkgs.lib.nixosSystem {
      modules = [
        inputs.self.modules.nixos.${name}
        { nixpkgs.hostPlatform = lib.mkDefault system; }
      ];
    };
  };

  # Wrap every binary of pkg so it reads each secret file into its env var
  # at run time. Values never enter the store or the calling shell.
  # Example: wrapWithSecrets pkgs pkgs.gh { GH_TOKEN = secrets.<name>.path; }
  config.flake.lib.wrapWithSecrets =
    pkgs: pkg: secrets:
    let
      inherit (lib) escapeShellArg concatMapStringsSep mapAttrsToList;
      name = lib.getName pkg;
      readSecret = var: path: ''
        [ -r ${escapeShellArg path} ] || { echo ${escapeShellArg "${name}: secret ${path} is missing"} >&2; exit 1; }
        export ${var}="$(< ${escapeShellArg path})"
      '';
      runArgs = concatMapStringsSep " " (code: "--run ${escapeShellArg code}") (
        mapAttrsToList readSecret secrets
      );
    in
    pkgs.symlinkJoin {
      name = "${name}-with-secrets";
      paths = [ pkg ];
      nativeBuildInputs = [ pkgs.makeWrapper ];
      postBuild = ''
        for f in $out/bin/*; do
          wrapProgram "$f" ${runArgs}
        done
      '';
      inherit (pkg) meta;
    };
}
