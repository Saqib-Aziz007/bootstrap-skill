# Harness blueprint

The file-by-file spec of what `/bootstrap-llm` generates. Templates live in `assets/templates/`; each is a skeleton with `{{PLACEHOLDER}}` slots plus `<!-- guidance -->` comments telling you what to write there. Fill, then delete every guidance comment. A shipped file contains neither.

Column "Depth": which harness depths include the file.

## Target tree

```
<repo>/
├── CLAUDE.md                          lean+full
├── AGENTS.md -> CLAUDE.md             lean+full   (symlink: ln -s CLAUDE.md AGENTS.md)
├── llm/
│   ├── PRODUCT.md                     lean+full   (lean may merge CONTEXT into it)
│   ├── CONTEXT.md                     full
│   ├── USER_FLOWS.md                  lean+full
│   ├── ARCHITECTURE.md                lean+full
│   └── PATTERNS.md                    lean+full
├── .claude/
│   ├── settings.json                  lean+full
│   ├── rules/
│   │   ├── workflow.md                lean+full
│   │   ├── git-workflow.md            lean+full
│   │   ├── engineering.md             lean only   (merged style+testing+security)
│   │   ├── coding-style.md            full
│   │   ├── testing.md                 full
│   │   ├── security.md                full
│   │   ├── pr-quality.md              full
│   │   ├── review-judgment.md         full
│   │   ├── refs.md                    full        (trigger table for .claude/refs/)
│   │   └── llm-docs.md                lean+full
│   ├── refs/
│   │   └── _TEMPLATE.md               lean+full
│   ├── skills/
│   │   ├── ticket/SKILL.md            lean+full   (see references/ticket-skill-spec.md)
│   │   ├── create-pr/                 lean+full   (SKILL.md + instructions/ + examples/)
│   │   ├── verify/SKILL.md            lean+full
│   │   ├── review/SKILL.md            full
│   │   └── plan/SKILL.md              full
│   └── hooks/
│       ├── check-rules-size.sh        lean+full
│       ├── typecheck-changed.sh       lean+full   (only when the stack has a type/syntax checker)
│       ├── check-debug-logging.sh     full
│       └── enforce-create-pr.sh       lean+full
└── .github/
    └── pull_request_template.md       lean+full   (path per hosting; github assumed)
```

## File specs

### CLAUDE.md (template `CLAUDE.md.tmpl`, target 4-6 KB)

The constitution: the only file guaranteed to be in every session's context, so it carries identity and pointers, never detail. Sections, in order:

1. **Role framing**: one paragraph, second person: senior engineer on this specific product, ticket-scoped, leaves the codebase better.
2. **Project overview**: the interview pitch, 3-5 lines.
3. **Technology stack**: exact versions from detection; one line on dependency discipline.
4. **Primary objectives**: 3-5, priority-ordered, project-specific (from interview: what does this project optimize for; correctness vs speed vs fidelity vs cost).
5. **Scope of work**: ticket-driven; implement only the current ticket; no unrelated refactors.
6. **Decision hierarchy**: `current ticket → existing architecture → existing code → this document → .claude/rules/* → engineering judgment`.
7. **Non-negotiables**: 4-8 bullets, each linking to the rule that details it. Only actual non-negotiables for this project.
8. **Documentation map**: table of every rules/llm/refs file with when to read it.
9. **Success criteria**: what "ticket complete" means (gates pass, scope respected, docs current, PR open).

### AGENTS.md

A relative symlink to CLAUDE.md, so Codex/Cursor/Copilot read the identical constitution and there is exactly one source of truth. Create with `ln -s CLAUDE.md AGENTS.md` from the repo root. If an AGENTS.md file already exists with distinct content, merge its content into CLAUDE.md first (merge mode), then replace the file with the symlink, telling the user.

### llm/ domain docs (templates `llm/*.tmpl`)

On-demand context; linked from the docs map. Write from interview answers and (ARCHITECTURE, PATTERNS) research + code reading.

- **PRODUCT.md**: what the product is, who pays/benefits, business concepts, how repos relate (if multi-repo). The doc a new session reads to understand *why* the ticket matters.
- **CONTEXT.md**: user types and what each cares about; domain glossary (term: meaning, why misreading it hurts); hard constraints.
- **USER_FLOWS.md**: the major user stories as numbered flows, each with actor, trigger, steps, outcome, and status (`planned` / `built` / `partial`). Future tickets reference these flows by number.
- **ARCHITECTURE.md**: system shape: layers, data flow, storage, external services, where things live in the tree. For a fresh repo, the intended architecture from research + interview; mark intent vs current reality.
- **PATTERNS.md**: concrete code patterns with short examples for this stack version (how to add a route/endpoint, a migration, a test, error handling, state). From Phase 2 research + existing code. Provenance footer required.

### .claude/rules/ (always loaded; hard size discipline)

Each rule is cross-cutting (applies to every ticket) or it does not belong here; module detail goes to `refs/`. Keep each ≤ 2 KB lean / ≤ 4 KB full.

- **workflow.md**: the ticket lifecycle (mirrors the `/ticket` skill): read ticket → discover/reuse before build → plan → implement scope only → verify between steps → update llm docs if drifted → PR. Includes the reuse-vs-create thresholds (≥80% fit: reuse; 50-80%: extend; <50%: create + document) and the stuck rule (3 failed attempts → stop, re-plan).
- **git-workflow.md**: protected default branch; branch naming; imperative commits with ticket trailer; check-your-diff-before-staging; push/PR discipline; **worktrees section**: parallel tickets each get `git worktree add ../<repo>-<ticket-ref> -b <branch>` and their own AI session; worktrees are removed after merge.
- **engineering.md** (lean) or **coding-style.md / testing.md / security.md** (full): the stack-specific hard rules from research: logging (never bare prints/console in production paths), typing discipline, import/module layout, error handling; testing approach and when tests are required; secrets never in code, input validation at boundaries, authz on every new surface. Every rule concrete enough that a violation is mechanically recognizable.
- **pr-quality.md** (full): every PR answers "what problem does this solve"; small, one-ticket PRs; description = problem, approach, verification.
- **review-judgment.md** (full): triage automated review feedback: fix in-diff / ticket it / dismiss with reason; never blind-apply.
- **refs.md** (full): trigger table: "touching X → read refs/Y first".
- **llm-docs.md**: docs update in the same change that makes them true; git is the archive (no changelog narration in docs); context budget and what belongs at which layer (rules vs llm/ vs refs/).

### .claude/refs/

`_TEMPLATE.md` only at bootstrap: the format for module reference docs (scope, entry points, invariants, gotchas, key files). Sessions add refs as modules grow; the llm-docs rule tells them to.

### .claude/skills/

- **ticket/**: the centerpiece; spec in `references/ticket-skill-spec.md`.
- **create-pr/**: SKILL.md + `instructions/description-format.md` + `examples/good-pr.md`, `examples/bad-pr.md`. Intent-driven PR: extract problem, validate diff against intent, fill the PR template, `gh pr create`.
- **verify/**: the quality gates in order, stop at first failure, exact commands from detection (typecheck, lint, tests, build). This is the single definition of "green" that workflow, ticket, and PR all reference.
- **review/** (full): run verify, then semantic self-review of the diff against the ticket: scope creep, missed edge cases, rule violations.
- **plan/** (full): structured planning for large tickets: load relevant llm/ + refs docs, produce step plan with files to touch.

### .claude/hooks/ + settings.json

Hooks are the mechanical guardrails; wire them in `settings.json` (template provided). Parameterize commands per stack; make executable.

- **check-rules-size.sh**: PostToolUse (Edit|Write): fail if CLAUDE.md + rules/ exceed the budget. Keeps the always-loaded set lean forever.
- **typecheck-changed.sh**: PostToolUse (Edit|Write): run the stack's fast checker on the changed file (`tsc --noEmit`, `ruff check`, `go vet`, ...). Skip when the stack has none.
- **check-debug-logging.sh** (full): PostToolUse: flag debug logging in changed source (`console.log`, bare `print(`, `dbg!`), pointing to the project logger.
- **enforce-create-pr.sh**: PreToolUse (Bash): intercept raw `gh pr create` and redirect to `/create-pr` so PR quality does not depend on session mood.
- Stop hook: desktop notification when a session finishes (nice for parallel worktree sessions).

### .github/pull_request_template.md

Problem (one sentence) / `Closes <ref>` / Solution (2-3 sentences, approach not file list) / How to verify (concrete steps) / Checklist (scoped to one ticket; gates pass; docs updated if drifted; project-specific items from non-negotiables).

## Merge mode

When a target file exists: read it fully; keep user content authoritative for facts, add missing harness sections around it; never delete user prose. If existing content contradicts harness structure (e.g., a CLAUDE.md that is one giant dump), propose the restructure in the report rather than silently rewriting. Existing `settings.json`: deep-merge hooks, keep user entries.

## Writing bar for every generated file

Written for a smart engineer with zero project history. No filler ("write clean code"), no duplicated content across files (link instead), every claim currently true of this repo, and no em dash characters anywhere.
