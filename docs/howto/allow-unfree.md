# Allow an unfree package

Unfree packages are allowed by name, in the file that installs them. See
[unfree](../features/unfree.md) for how it works.

## System package

Add the name to `unfree.packages` on the same NixOS aspect:

```nix
flake.modules.nixos.example =
  { pkgs, ... }:
  {
    unfree.packages = [ "example" ];
    environment.systemPackages = [ pkgs.example ];
  };
```

## Home-manager package

home-manager uses the system's nixpkgs, so the name goes on the matching
NixOS aspect from the same file:

```nix
flake.modules = {
  nixos.example.unfree.packages = [ "example" ];

  homeManager.example =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.example ];
    };
};
```

`modules/features/obsidian.nix` (a feature) and
`modules/users/ballsten/home.nix` (a user) are examples.

## Finding the name

The name is `lib.getName` of the package, which is usually its attribute
name but not always. If evaluation fails with "has an unfree license", the
error names the package with its version (`example-1.2.3`); the name to
allow is the part without the version. To check it:

```sh
nix eval --raw nixpkgs#example.pname
```

Add the name to the Unfree row of the feature's docs page.
