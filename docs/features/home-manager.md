# home-manager

Adds [home-manager](https://github.com/nix-community/home-manager) as a NixOS
module, so users' home configuration is built with the system.

| | |
|---|---|
| Module | `modules/features/home-manager.nix` |
| Aspects | `nixos.home-manager` |
| Hosts | All, through `workstation` |
| Inputs | `home-manager`, declared in `modules/flake/home-manager.nix` because it is shared |
| Persists | Nothing |
| Secrets | None |

- `useGlobalPkgs`: home-manager uses the system's `pkgs`, so its packages
  share the NixOS nixpkgs instance and its `allowUnfreePredicate` (see
  [unfree](unfree.md)).
- `useUserPackages`: `home.packages` are installed through
  `users.users.<name>.packages`.

Users import their home-manager aspects in
`home-manager.users.<name>.imports`; features add theirs to every user
through `home-manager.sharedModules` (see
[Architecture](../architecture.md#features-with-a-home-manager-side)).
