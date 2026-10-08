# ballsten

Andrew's account, and their home-manager configuration.

| | |
|---|---|
| Directory | `modules/users/ballsten/` |
| Aspects | `nixos.ballsten`, `homeManager.ballsten` |
| Hosts | [surface-laptop](../hosts/surface-laptop.md) |
| Unfree | `claude-code` |
| Secrets | `users/ballsten/password`, `users/ballsten/tokens/github`, `users/ballsten/ssh/id_ed25519` |

## Files

| File | Contents |
|---|---|
| `nixos.nix` | The account, sudo, and the home-manager aspects the user imports |
| `home.nix` | Packages, programs, and what is persisted in home |
| `credentials.nix` | The GitHub token and SSH key, from sops |

## Account

- uid 1000, pinned: files on `/persist` are owned by this uid, and it
  mustn't depend on `/var/lib/nixos` surviving.
- Groups: `wheel` and `networkmanager`, plus `gamemode` on hosts with
  [gaming](../features/gaming.md).
- Login shell: fish.
- The password hash comes from sops (`just set-password`), as accounts are
  [immutable](../features/immutable-users.md).
- sudo needs no password.

## Home

home-manager imports `homeManager.ballsten`, plus the
[direnv](../features/direnv.md) and [secrets](../features/secrets.md)
home-manager aspects. Features such as [desktop](../features/desktop.md),
[brave](../features/brave.md), [lazygit](../features/lazygit.md) and
[obsidian](../features/obsidian.md) add their own through
`home-manager.sharedModules`.

Set up in `home.nix`:

- Claude Code, with `CLAUDE_CONFIG_DIR=~/.claude` so its `.claude.json`
  lives inside `~/.claude`. A persisted single file breaks when a program
  saves it by renaming a new file over it.
- helix, fish, and git with the user's name and email. Pushes to
  `https://github.com/` URLs go over SSH instead (`pushInsteadOf`), with the
  key from sops, so every clone can push; fetches stay on HTTPS.
- The Obsidian vault `Ballsten.md` at `~/repos/Ballsten.md`.

## Persisted in home

Everything else in home is wiped on boot.

| Path | What |
|---|---|
| `repos`, `Documents`, `Pictures`, `Music`, `Videos` | User files |
| `.claude` | Claude Code login, settings, history and memory |
| `.local/share/fish` | fish history |

Features persist their own paths (for example `.config/BraveSoftware`); see
each feature's page.

## Credentials

`credentials.nix` wraps `gh` with `wrapWithSecrets`, so only `gh` gets
`GH_TOKEN`, and links `~/.ssh/id_ed25519` to the decrypted SSH key. The
public key is plain text in the same file. See
[secrets](../features/secrets.md#api-tokens).
