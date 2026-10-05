# 0001: Record design decisions

- **Status:** Accepted, 2026-10-06
- **Issue:** #52

## Context

The reasons behind this repo's design were spread across issue threads, PR
descriptions and `CLAUDE.md`. Finding out why something is the way it is
meant searching closed issues, and the rules in `CLAUDE.md` don't say what
was weighed against them.

## Decision

Keep a short record for each design decision in `docs/decisions/`, named
`NNNN-<slug>.md` and numbered in the order the decisions were made. Each
has a status (with the date and the issues and PRs involved), then Context,
Decision, Consequences and Alternatives considered.

A record isn't rewritten once accepted. When a decision changes, a new
record replaces it: the old one's status becomes "Superseded by NNNN" and
links to the new one.

The earlier records (0002 onwards) were written afterwards from the issues
and PRs they cite.

## Consequences

- A PR that makes a design choice with alternatives worth remembering adds
  a record (`CLAUDE.md`, Documentation).
- Rules stay in `CLAUDE.md`; records explain where they came from.

## Alternatives considered

- **Free prose per topic:** harder to scan, and no clear way to mark a
  decision as replaced.
- **Leaving it in issues and PRs:** the information exists, but only for
  someone who knows where to look.
