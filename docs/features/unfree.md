# unfree

Allows unfree packages by name only.

| | |
|---|---|
| Module | `modules/features/unfree.nix` |
| Aspects | `nixos.unfree` |
| Hosts | All, through `workstation` |
| Inputs | None |
| Persists | Nothing |
| Secrets | None |

Defines the option `unfree.packages`, a list of package names
(`lib.getName`), and sets `nixpkgs.config.allowUnfreePredicate` to allow
only those. Any other unfree package fails evaluation.

Each feature adds the names it needs next to the package itself:

```nix
flake.modules.nixos.obsidian.unfree.packages = [ "obsidian" ];
```

Because home-manager uses the system `pkgs` (`useGlobalPkgs`, see
[home-manager](home-manager.md)), the same list covers home-manager
packages. A home-manager package's name goes on the matching NixOS aspect,
as `modules/users/ballsten/home.nix` does for `claude-code`.
