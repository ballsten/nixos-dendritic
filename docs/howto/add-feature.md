# Add a feature

A feature is one file in `modules/features/` that publishes
`flake.modules.nixos.<name>` and/or `flake.modules.homeManager.<name>`. See
[Architecture](../architecture.md#aspects) for how aspects work.

## 1. Branch

```sh
git switch main && git pull
git switch -c feat/<name>
```

## 2. Write the module

Create `modules/features/<name>.nix`. import-tree picks it up; nothing else
needs to import the file.

A system-only feature:

```nix
_: {
  flake.modules.nixos.<name> = {
    services.example.enable = true;
  };
}
```

A feature with a user side, which every home-manager user on the host gets
through `home-manager.sharedModules`:

```nix
{ inputs, ... }:
{
  flake.modules = {
    nixos.<name>.home-manager.sharedModules = [ inputs.self.modules.homeManager.<name> ];

    homeManager.<name> = {
      programs.example.enable = true;
    };
  };
}
```

Start with `_:` when the outer module uses no arguments, and nest repeated
attribute prefixes; statix flags both.

As needed, in the same file:

- A flake input: [Add or change a flake input](add-input.md).
- An unfree package: [Allow an unfree package](allow-unfree.md).
- State to keep across reboots: [Persist state](persist-state.md).
- A password, key or token: [Add a secret](add-secret.md).

## 3. Give it to hosts

- Every host: add `<name>` to the imports in
  `modules/features/workstation.nix`.
- Gaming: the `gaming` aspect, never `workstation`.
- Home-manager only, for one user: add it to
  `home-manager.users.<user>.imports` in `modules/users/<user>/nixos.nix`.
- Hardware-specific settings don't belong in a feature; put them in
  `modules/hosts/<host>/`.

## 4. Document it

Add `docs/features/<name>.md`, starting with the summary table described
in [Writing a page](../README.md#writing-a-page), and a row in the index.
`check-docs` fails without the page.

If the feature adds a `just` recipe, also add it to the task table in
`README.md`.

## 5. Check and build

```sh
just fmt
just lint
just check                 # write-flake (no diff) and nix flake check
just build <host>          # for each affected host
```

Compare the closure with `main` for each host, and summarise the changes in
the PR's "Manual testing" section:

```sh
old=$(nix build --no-link --print-out-paths "git+file://$PWD?ref=main#nixosConfigurations.<host>.config.system.build.toplevel")
new=$(nix build --no-link --print-out-paths ".#nixosConfigurations.<host>.config.system.build.toplevel")
nvd diff "$old" "$new"
```

## 6. Open the PR

Push the branch and open the PR with `gh pr create`, filling in the
template. List any new flake inputs, and say whether existing state needs
moving into `/persist` by hand.
