# Ticketing: GitHub Issues (gh CLI)

The lightest integration: tickets and PRs live in the same repo, `gh` is the only dependency, and issues auto-close on merge.

## Auth check at bootstrap

```bash
gh auth status
```

Not authenticated: generate anyway; embed `gh auth login` as the connect instruction in the report and the `/ticket` skill.

## One-time setup done BY bootstrap (Phase 4)

Status travels via labels, so create them now (idempotent):

```bash
gh label create in-progress --color FBCA04 --description "Being implemented" 2>/dev/null || true
gh label create in-review  --color 0E8A16 --description "PR open, awaiting review" 2>/dev/null || true
```

## Commands to embed in the generated /ticket skill

| Step | Command |
|---|---|
| Fetch | `gh issue view <n> --json title,body,labels,assignees,comments` |
| Claim | `gh issue edit <n> --add-assignee @me --add-label in-progress` |
| Ready for review | `gh issue edit <n> --remove-label in-progress --add-label in-review` |
| Attach PR + auto-close | PR body contains `Closes #<n>` (the PR template has the slot); merge closes the issue |
| Blocked | `gh issue comment <n> --body "<blocker>"` and remove `in-progress` if abandoning |

Ticket references in branches/commits use `#<n>` in commit trailers (`Refs #12` / `Closes #12`) and `issue-<n>` in branch names (`feature/issue-12-slug`); a bare `#` starts a comment in many shells, so branch names avoid it.

## Generation checklist

- Real `owner/repo` from `git remote` in any command that needs `-R`.
- The label names above match what `rules/workflow.md` and `/ticket` reference.
- `/create-pr` keeps `Closes #<n>` in the body so merges close tickets without manual bookkeeping.
