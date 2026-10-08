# 0032: git pushes to GitHub over SSH, whatever the remote URL

- **Status:** Accepted, 2026-10-09
- **Issue:** None
- **PR:** (this PR)

## Context

[0015](0015-user-ssh-key-in-sops.md) gives `git push` an SSH key from
sops. Repos cloned with an `https://github.com/` URL still pushed over
HTTPS, which has no credentials, so `git push` failed with
`could not read Username for 'https://github.com'`.

## Decision

ballsten's git config sets
`url."git@github.com:".pushInsteadOf = "https://github.com/"`. Pushes to
GitHub go over SSH with the sops key; fetches keep the URL they were
cloned with.

## Consequences

- Every clone can push, including ones made after a reinstall, with no
  per-repo step.
- Public repos still clone and fetch over HTTPS without a key.
- The GitHub API token stays with `gh` only
  ([0008](0008-wrap-cli-secrets.md)); git never sees it.

## Alternatives considered

- **Switch each repo's remote to SSH:** a manual step per clone, not
  declared.
- **`gh auth setup-git`:** writes a credential helper into
  `~/.config/git/config`, which home-manager manages.
- **`gh` as a declared credential helper:** works, but hands the API token
  to git as a second way to push, when SSH already covers it.
- **`insteadOf` (fetch and push):** fetching public repos would then need
  the SSH key too, for no gain.
