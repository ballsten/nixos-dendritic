# Architecture

How the pieces of this repo fit together, from `flake.nix` down to a host's
system closure. The rules for working in the repo are in
[`CLAUDE.md`](../CLAUDE.md); this page explains the mechanics behind them.

## The building blocks

| Tool | Role here |
|---|---|
| [flake-parts](https://flake.parts) | Turns the flake into a set of modules that are merged like NixOS modules. Its `modules` flake module adds the `flake.modules.<class>.<name>` option used for every feature. |
| [import-tree](https://github.com/vic/import-tree) | Imports every `.nix` file under `modules/` as a flake-parts module, so adding a file is enough to wire it in. Paths containing `/_` are skipped. |
| [flake-file](https://github.com/denful/flake-file) | Generates `flake.nix` from `flake-file.*` options set in the modules, so each input is declared next to the code that uses it. Provides `nix run .#write-flake` and a check that `flake.nix` is up to date. |

All three are set up in `modules/flake/dendritic.nix`. That file declares
their inputs, imports the flake-parts `modules` module and flake-file's
default module, and sets `flake-file.outputs` to:

```nix
inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } (inputs.import-tree ./modules)
```

## From flake.nix to a host

```
flake.nix  (generated)
  └─ mkFlake (import-tree ./modules)
       └─ every modules/**/*.nix, merged as flake-parts modules
            ├─ flake-file.inputs.*         →  inputs in flake.nix
            ├─ flake.modules.nixos.*       →  NixOS aspects
            ├─ flake.modules.homeManager.* →  home-manager aspects
            ├─ flake.lib.*                 →  helpers (mkNixos, wrapWithSecrets)
            ├─ flake.nixosConfigurations.* →  hosts
            └─ perSystem.*                 →  dev shell, formatter, checks
```

1. `flake.nix` is generated. Its `outputs` hand the whole `modules/` tree to
   flake-parts, and its `inputs` are collected from every
   `flake-file.inputs.<name>` in that tree. `nix run .#write-flake`
   rewrites it after an input changes, and `nix flake check` fails if it is
   stale.
2. Each file is a flake-parts module. It can set any flake-parts option, and
   most set one or more of `flake.modules.nixos.<name>` and
   `flake.modules.homeManager.<name>`.
3. A host's `flake-parts.nix` calls `inputs.self.lib.mkNixos` (from
   `modules/flake/lib.nix`). That builds a `nixosSystem` from the single
   module `flake.modules.nixos.<host>` and sets `nixpkgs.hostPlatform`.
4. `flake.modules.nixos.<host>` imports aspects by name from
   `inputs.self.modules.nixos`, which pulls in the rest.

## Aspects

An aspect is one name under `flake.modules.<class>`, where the class is
`nixos` or `homeManager`. Its value is an ordinary NixOS or home-manager
module.

Several files can set the same aspect, and flake-parts merges them. A
feature normally lives in one file, but hosts and users are split by
concern:

| Aspect | Set in |
|---|---|
| `nixos.surface-laptop` | `configuration.nix`, `hardware.nix`, `disk.nix`, `display.nix` in `modules/hosts/surface-laptop/` |
| `nixos.tiki-rig` | `configuration.nix`, `hardware.nix`, `disk.nix`, `display.nix` in `modules/hosts/tiki-rig/` |
| `nixos.ballsten` | `modules/users/ballsten/nixos.nix`, plus `unfree.packages` from `home.nix` |
| `homeManager.ballsten` | `modules/users/ballsten/home.nix` and `credentials.nix` |

### Two levels of module arguments

A file under `modules/` is a flake-parts module, and the aspect it defines
is a NixOS or home-manager module inside it. Each level gets its own
arguments:

```nix
{ inputs, ... }:                      # flake-parts: inputs, self, lib, ...
{
  flake.modules.nixos.example =
    { config, pkgs, ... }:            # NixOS: config, pkgs, lib, utils, ...
    {
      imports = [ inputs.example.nixosModules.default ];
      environment.systemPackages = [ pkgs.hello ];
    };
}
```

`pkgs` and the host's `config` exist only at the inner level. A file that
needs no arguments at the outer level starts with `_:` (statix enforces
this).

## How a host is composed

```
nixos.surface-laptop
  ├─ nixos.workstation           shared by every desktop host
  │    ├─ nix-settings, home-manager, secrets, unfree, immutable-users
  │    ├─ locale, networkmanager, wifi, ssh
  │    ├─ desktop, theme, brave, lazygit, obsidian
  │    └─ impermanence, secure-boot, tpm-unlock
  ├─ nixos.ballsten              the user account
  │    └─ home-manager.users.ballsten
  │         └─ homeManager: ballsten, direnv, secrets
  └─ hardware, disk layout, display scaling (host files)
```

`workstation` (`modules/features/workstation.nix`) is the shared feature
set. A host imports it plus its users, and keeps hardware-specific settings
in its own directory. `tiki-rig` also imports the `gaming` aspect.
The list above mirrors `workstation.nix`; check that file for the current
set.

### Features with a home-manager side

A feature that configures both the system and the user's home publishes two
aspects with the same name. The NixOS aspect adds the home-manager one to
`home-manager.sharedModules`, so every home-manager user on a host that
imports the feature gets it. `modules/features/brave.nix` is an example:

```nix
flake.modules = {
  nixos.brave = {
    environment.etc."brave/policies/managed/nixos.json".text = ...;
    home-manager.sharedModules = [ inputs.self.modules.homeManager.brave ];
  };
  homeManager.brave = {
    programs.brave.enable = true;
  };
};
```

A home-manager aspect that only one user wants is imported by that user
instead, as `nixos.ballsten` does with `direnv` and `secrets`.

Hosts use `home-manager.sharedModules` the same way to set per-host user
settings. `modules/hosts/surface-laptop/display.nix` sets the display scale
there.

## Flake inputs

Each input is declared with `flake-file.inputs.<name>` in the module that
uses it. Inputs used across the repo (nixpkgs, home-manager and the
dendritic tooling) are declared in `modules/flake/`. To find where an input
comes from:

```sh
grep -rn 'flake-file.inputs' modules/
```

## Directory layout

| Path | Contents |
|---|---|
| `modules/flake/` | Flake plumbing: the dendritic wiring, shared inputs, `flake.lib`, dev shell, formatter and lint checks. |
| `modules/features/` | One feature per file, each publishing `flake.modules.*.<name>`. |
| `modules/hosts/<host>/` | One host: its `flake.modules.nixos.<host>` aspect, `nixosConfigurations` entry, disk layout and hardware. Files starting with `_` (such as `_hardware-configuration.nix`) are plain NixOS modules that import-tree skips; the host imports them by path. |
| `modules/users/<user>/` | One user: the NixOS account and their home-manager config. |
| `secrets/` | sops-encrypted secrets ([features/secrets.md](features/secrets.md)). |
| `docs/` | This documentation ([index](README.md)). |
| `Justfile` | Task recipes (see the table in the [README](../README.md#tasks)). |

## Per-system outputs

Modules under `modules/flake/` also set `perSystem` outputs for
`x86_64-linux`:

| Output | File | Used by |
|---|---|---|
| `devShells.default` | `devshell.nix` | direnv through `.envrc`, or `nix develop` |
| `formatter` (`nixfmt-tree`) | `formatter.nix` | `nix fmt`, `just fmt` |
| `checks.{statix,deadnix,actionlint,docs}` | `lint.nix` | `nix flake check`; `just lint` runs the same tools on the working tree |
| `packages.check-docs` | `lint.nix` | The `docs` check, `just lint` and the dev shell: fails when a feature, host or user has no page in `docs/`, or a page has no module |
| `packages.write-flake` | flake-file | `nix run .#write-flake` |
| `checks.check-flake-file` | flake-file | `nix flake check`: fails if `flake.nix` differs from what the modules generate |
