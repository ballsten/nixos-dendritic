# lazygit

[lazygit](https://github.com/jesseduffield/lazygit), a terminal UI for git.

| | |
|---|---|
| Module | `modules/features/lazygit.nix` |
| Aspects | `nixos.lazygit`, `homeManager.lazygit` |
| Hosts | All, through `workstation` |
| Inputs | None |
| Persists | `~/.local/state/lazygit` (recent repos, dismissed popups) |
| Secrets | None |

Every home-manager user on the host gets it through
`home-manager.sharedModules`.

home-manager's `programs.lazygit` also defines an `lg` function in fish. It
runs lazygit and, on exit, changes to the repo you switched to inside it.
