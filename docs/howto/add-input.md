# Add or change a flake input

`flake.nix` is generated, so inputs are declared in modules with
`flake-file.inputs.<name>` and never written into `flake.nix` directly.

## Add an input

Declare it in the module that uses it, next to that code:

```nix
{ inputs, ... }:
{
  flake-file.inputs.example = {
    url = "github:owner/example";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  flake.modules.nixos.example = {
    imports = [ inputs.example.nixosModules.default ];
  };
}
```

- Add `inputs.nixpkgs.follows = "nixpkgs"` if the input has a `nixpkgs`
  input. Without it, the input brings its own nixpkgs, which is another
  copy to download and build against. If there's a reason not to, say it
  in the PR.
- An input used only to develop the input itself (a test framework,
  pre-commit hooks) can be dropped with `follows = ""`; see `lanzaboote` in
  `modules/features/secure-boot.nix` and `impermanence` in
  `modules/features/impermanence.nix`.
- An input shared by many features goes in `modules/flake/` instead, like
  `nixpkgs` and `home-manager`.

To see what an input offers and which inputs it has:

```sh
nix flake show github:owner/example
nix flake metadata github:owner/example
```

## Regenerate and lock

```sh
just lock      # nix run .#write-flake, then nix flake lock
```

`nix flake lock` adds only the new input to `flake.lock`; it doesn't update
the others. Commit `flake.nix` and `flake.lock` in the same commit as the
module.

## Change an input

Edit its `flake-file.inputs.<name>` (for example a new `url` or tag), then:

```sh
nix run .#write-flake
nix flake update <name>    # re-lock only this input
```

Bumping an input pinned to a release tag (such as `lanzaboote`) is a
feature change like any other. Updating the revisions of inputs that
follow a branch is done in its own PR; see
[Update flake inputs](update-inputs.md).

## Remove an input

Delete its `flake-file.inputs.<name>` and every use of `inputs.<name>`,
then `just lock`.

`nix flake check` fails (the `check-flake-file` check) if `flake.nix`
doesn't match the modules, so a forgotten `write-flake` is caught.
