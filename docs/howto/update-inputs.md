# Update flake inputs

Input revisions are updated in their own PR, never as part of a feature.

## 1. Branch and update

```sh
git switch main && git pull
git switch -c chore/update-inputs
just update                # every input; or: just update nixpkgs umbriel
```

`just update` regenerates `flake.nix`, runs `nix flake update` and prints
a table of the inputs whose lock changed, with old and new revision and
date, ready to paste into the PR. Only `flake.lock` changes.

Inputs pinned to a tag (such as `lanzaboote`) stay on that tag; bump those
by editing the module, as in
[Add or change a flake input](add-input.md#change-an-input).

## 2. Build every host

```sh
just check
just build surface-laptop
```

A nixpkgs update usually changes the linux-surface kernel, which isn't in
the binary cache and takes about two hours to build. Run that build in a
terminal rather than in the background of another task.

## 3. Compare closures

For each host:

```sh
old=$(nix build --no-link --print-out-paths "git+file://$PWD?ref=main#nixosConfigurations.<host>.config.system.build.toplevel")
new=$(nix build --no-link --print-out-paths ".#nixosConfigurations.<host>.config.system.build.toplevel")
nvd diff "$old" "$new"
```

## 4. Check workarounds

Some features work around a missing upstream feature and can go once the
upstream catches up. Check each one against the updated build, and note
the result in the PR:

| Workaround | Check | Redundant when |
|---|---|---|
| [lock-status](../features/lock-status.md) | `strings $(nix eval --raw .#nixosConfigurations.tiki-rig.pkgs.noctalia)/bin/.noctalia-wrapped \| grep -cx GetActive` | the count is above 0 (`-x`, so `GetActivePlayer` doesn't match): Noctalia's `org.freedesktop.ScreenSaver` has `GetActive` |

When a check passes, remove the workaround in its own PR, not in the
update PR.

A new workaround adds a row here.

## 5. Open the PR

Paste the table `just update` printed (`git diff flake.lock` has the same
revisions), and summarise the `nvd diff` output in "Manual testing":
kernel and systemd version changes, and anything removed, are the ones to
look at before switching.

Check the release notes of anything with breaking changes, such as the
nixos-unstable and home-manager changelogs, for options this repo sets.
