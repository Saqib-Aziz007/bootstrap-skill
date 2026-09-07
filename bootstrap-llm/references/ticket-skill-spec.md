# Spec: the generated /ticket skill

`/ticket <id>` is the harness's centerpiece: the loop the user runs dozens of times after bootstrapping. It must work with **only a ticket ID as input**; every other fact comes from the harness docs. Generate it from `assets/templates/skills/ticket/SKILL.md.tmpl`, filling the tracker-specific commands from the matching `references/ticketing/*.md`.

## Contract

Input: a ticket reference (`ABC-123`, `#42`, or a ticket URL). Optional flags: `--worktree` (implement in a parallel worktree), `--no-pr` (stop before the PR, for stacked work).

Output: implemented, verified, documented change on a branch with an open PR, ticket status advanced, and a final report (what changed, verification evidence, PR URL, anything left open).

## Lifecycle (the template encodes these steps; keep the order)

1. **Fetch the ticket** using the tracker commands. If auth is missing, print the connect instructions (embedded at generation time) and stop; a half-authenticated run wastes the whole session.
2. **Understand scope**: restate the ticket in one sentence; list what is explicitly out of scope. If the ticket is too vague to restate, comment on the ticket asking for the missing decision instead of guessing; report and stop.
3. **Move status to started** (In Progress / label) and self-assign where the tracker supports it, so parallel sessions never double-take a ticket.
4. **Branch**: `<type>/<ticket-ref>-<slug>` off the freshly-pulled default branch. With `--worktree` (or when the user runs several tickets at once): `git worktree add ../<repo>-<ticket-ref> -b <branch>`; continue inside the worktree. One worktree per ticket is the parallelism mechanism: sessions never collide on a working tree.
5. **Discover before building**: read the docs map's relevant entries (`llm/ARCHITECTURE.md`, `llm/PATTERNS.md`, matching `refs/`), then search for existing code to reuse per the workflow rule's thresholds. The codebase outranks your instincts.
6. **Plan**: for non-trivial tickets, a short written plan (files to touch, components to reuse, risks). Use `/plan` where the harness includes it.
7. **Implement** only the ticket scope, following the rules. Verify incrementally; do not accumulate broken state.
8. **Verify**: run `/verify` (single definition of green). Fix until clean. Stuck rule: after ~3 failed attempts at one approach, stop, write down why, re-plan.
9. **Update the docs in the same change** when reality drifted: new pattern → `llm/PATTERNS.md`; new module surface → a `refs/` doc; new user-visible flow → `llm/USER_FLOWS.md` status. The llm-docs rule is the arbiter. This step is why docs stay trustworthy for session N+1.
10. **Commit and push** per the git rule (imperative subject, ticket trailer).
11. **Open the PR** via `/create-pr` (never raw `gh pr create`; a hook enforces this).
12. **Advance status to review** and attach the PR link to the ticket (comment or field).
13. **Report**: ticket restated, what changed, verification evidence (gate output, not "should work"), PR URL, assumptions made, anything discovered but out of scope (suggest filing it as a new ticket rather than doing it).

## Failure conduct

Blocked on missing auth, unresolvable ambiguity, or a red gate you cannot fix honestly: say exactly where it stopped and what would unblock; never claim done. Move the ticket back or leave a comment where the tracker supports it. A truthful stuck report preserves the trust that lets the user run this skill unattended; a false "done" destroys it.

## Generation notes

- Embed the tracker commands **concretely** (real project key, real repo, real status names from the interview): the skill must never need to rediscover configuration.
- Keep the generated SKILL.md ≤ ~150 lines; deep guidance belongs to the rules it links.
- Frontmatter: `name: ticket`, description mentioning the tracker and project key so it triggers on bare ticket IDs pasted in chat.
