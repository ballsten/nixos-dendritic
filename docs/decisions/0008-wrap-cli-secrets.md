# 0008: Command-line tools get their secrets by wrapping

- **Status:** Accepted, 2026-10-02
- **Issues:** #18, #19, #21
- **PR:** #20

## Context

`gh` needs a GitHub token. The first plan (#18) exported it as `GH_TOKEN`
in fish, which gives it to every process started from the shell.

## Decision

`flake.lib.wrapWithSecrets` (`modules/flake/lib.nix`) wraps a package so
each of its binaries reads its secret files into environment variables at
run time. Only the wrapped tool's process gets them; the values stay out
of the Nix store and the calling shell. Secrets for command-line tools are
never exported in a shell.

`gh` is the first user: `GH_TOKEN` from `users/ballsten/tokens/github`.

## Consequences

- If a secret file is missing, the wrapper exits with an error rather
  than running the tool unauthenticated.
- Wrapped tools mustn't be shadowed by unwrapped copies on `PATH`, so `gh`
  and `claude-code` are kept out of the dev shell
  ([0009](0009-dev-shell.md)).
- It limits accidental exposure (environment dumps, child processes,
  logs), but isn't a security boundary: anything running as the user can
  still read the decrypted file.
- It doesn't suit multi-call binaries that dispatch on their own name.

## Alternatives considered

- **Export in the shell (#18):** rejected; every process inherits it.
- **A Claude Code token in sops (#19):** not done. `claude setup-token`
  tokens are inference-only and break interactive Claude Code. The login
  is kept by persisting `~/.claude` instead
  ([0016](0016-impermanence.md)).
