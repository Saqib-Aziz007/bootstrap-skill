---
name: bootstrap-llm
description: One-time project setup that turns a repository into an AI-first, ticket-driven development environment. Interviews the user about domain and workflow, researches current best practices for the detected stack, and generates the full harness; CLAUDE.md constitution, llm/ domain docs, .claude/rules, quality-gate hooks, PR template, and a project-local /ticket skill wired to Linear, GitHub Issues, or Jira. Use whenever the user starts a new project and wants LLM docs, AI dev setup, a "harness", CLAUDE.md generation, ticket-driven automation, or says things like "set up this repo for AI development", "bootstrap llm docs", or "prepare this project for Claude". Invoked as /bootstrap-llm.
---

# /bootstrap-llm - Project harness bootstrap

Turn the current repository into a self-documenting, ticket-driven AI development environment. After this skill finishes, any AI session in the repo can take a ticket ID and carry it to a merged-ready PR: the project carries its own context (domain, architecture, conventions, quality gates), so sessions need no hand-holding, and several tickets can run in parallel through git worktrees.

You are generating the **operating system of every future AI session in this repo**. Vague docs produce vague sessions; everything you write should be specific, verifiable, and current. Quality here compounds across hundreds of future tickets.

The run has six phases. Do them in order; each feeds the next.

```
0. Detect      - read the repo; never ask what you can detect
1. Interview   - AskUserQuestion for domain + process, batched
2. Research    - live web research on the stack's current best practices
3. Generate    - fill assets/templates into the repo
4. Ticketing   - wire Linear / GitHub Issues / Jira
5. Verify      - lint the harness, then report
```

## Usage

```
/bootstrap-llm                      # full guided run in the current repo
/bootstrap-llm <inline answers>     # pre-supplied answers skip matching interview questions
/bootstrap-llm --refresh            # re-research stack practices, update research-derived docs only
```

Inline answers look like: `domain: ...; users: ...; stories: ...; ticketing: linear (project KEY); depth: lean`. Treat anything the user supplies (in the invocation or earlier in the conversation) as already-answered interview questions.

**Non-interactive contexts** (no user available to answer): proceed with pre-supplied answers, apply sensible defaults for the rest, and clearly list every assumption in the final report instead of blocking.

## Phase 0 - Detect

Build a facts sheet before asking anything. The interview exists only for what the repo cannot tell you; asking detectable questions wastes the user's time and erodes trust in the tool.

Scan for:

- **Stack**: `package.json` (framework deps, scripts), `pyproject.toml`, `go.mod`, `Cargo.toml`, `Gemfile`, `*.xcodeproj`, `pubspec.yaml`. Record exact framework versions; research in Phase 2 is version-specific.
- **Package manager**: lockfile (`pnpm-lock.yaml`, `package-lock.json`, `yarn.lock`, `uv.lock`, `poetry.lock`).
- **Quality gates**: existing scripts for typecheck / lint / test / build; test dirs; CI workflows under `.github/workflows/`.
- **Git**: is it a repo, default branch, `git remote -v` (owner/repo for PRs), existing `.github/pull_request_template.md`.
- **Existing AI docs**: `CLAUDE.md`, `AGENTS.md`, `.claude/`, `.cursor/`, `docs/`, `llm/`. If any exist, you are in **merge mode** for those files: read them fully, preserve the user's content, and integrate rather than overwrite. Never delete or rewrite user-authored docs without showing what changes.
- **Tooling available**: `gh auth status`; whether Linear or Atlassian MCP tools are present in this session.

If the directory is empty or has no code yet, that is fine: the harness still works (docs, rules, workflow, ticketing), and stack-specific pieces are generated from the interview answer about the intended stack.

## Phase 1 - Interview

Read `references/interview-guide.md` and run the interview with AskUserQuestion in 2-3 batches (4 questions max per batch, multiSelect where natural). Skip every question already answered by detection or pre-supplied input.

The interview covers, in this order:

1. **Domain** (the part only the user knows): elevator pitch, user types, 3-7 major user stories, domain glossary terms, hard constraints (compliance, integrations, offline, etc.).
2. **Process**: ticketing system (Linear / GitHub Issues / Jira) + project key or repo, branch and commit conventions (offer the defaults from `references/harness-blueprint.md` as the recommended option), review setup (CodeRabbit, human, none), CI expectations.
3. **Calibration**: harness depth **lean** vs **full** (guide has the decision matrix; recommend lean for solo projects under ~3 months), plus anything detection left ambiguous.

Domain answers become `llm/` docs almost verbatim, so when an answer is thin ("it's a todo app"), ask the one follow-up that makes it usable ("who is it for, and what makes it different from every other todo app?"). Do not interrogate; two rounds of questions is the ceiling.

## Phase 2 - Research

Read `references/research-guide.md`, then research the stack's **current** best practices with WebSearch/WebFetch: framework-version idioms, recommended project structure, testing approach, common AI-generated-code pitfalls for this stack, security notes. This is why the skill bundles no stack templates: a project bootstrapped today should get today's idioms, not the ones from the skill's training data.

Budget: roughly 4-8 searches. Distill findings into the generated `rules/coding-style.md`, `llm/PATTERNS.md`, and `llm/ARCHITECTURE.md`. Every research-derived doc ends with a provenance footer (date + sources) so future sessions know when it was last refreshed and can re-run `/bootstrap-llm --refresh` when it goes stale.

If web access is unavailable, generate from your own knowledge, mark the footer `researched: no (model knowledge, cutoff <date>)`, and say so in the report.

## Phase 3 - Generate

Read `references/harness-blueprint.md` for the full file-by-file spec, then generate the harness from `assets/templates/`. The templates are skeletons with `{{PLACEHOLDER}}` slots and HTML-comment guidance for you; fill them with detection facts, interview answers, and research findings, then **delete the guidance comments**. A shipped file must contain no `{{...}}` and no template commentary.

Ground rules that apply to every generated file:

- **Depth scales.** Lean depth merges rules into fewer files and skips optional skills; full depth is the complete blueprint. The blueprint marks each file lean/full.
- **Single source of truth.** `AGENTS.md` is a symlink to `CLAUDE.md` (`ln -s CLAUDE.md AGENTS.md`), never a copy. Rules link to refs and docs instead of restating them.
- **Context budget.** `CLAUDE.md` + `.claude/rules/` are loaded into every session. Keep their combined size under 45 KB (lean: aim well under 20 KB). Detail goes in `llm/` and `.claude/refs/`, loaded on demand.
- **House punctuation**: never use the em dash character in generated docs; use periods, commas, colons, or parentheses.
- **Specific beats generic.** "Use the logger" is filler; "use `log.error(err, ctx)` from `src/lib/log.ts`; `console.*` fails the lint gate" earns its context cost. When the repo has code, cite real paths.
- Hooks must end up executable (`chmod +x .claude/hooks/*.sh`).

## Phase 4 - Ticketing

Read the matching file: `references/ticketing/linear.md`, `references/ticketing/github.md`, or `references/ticketing/jira.md`. Each gives the auth check, the fetch/transition commands, and the exact snippets to embed in the generated `/ticket` skill and `rules/workflow.md`.

If auth is missing (MCP not connected, `gh` not logged in), do not fail and do not half-wire it: generate the integration anyway, and put the exact connect instructions both in the final report and at the top of the generated `/ticket` skill, so the first real ticket run tells the user what to do.

## Phase 5 - Verify and report

Run these checks; fix failures before reporting:

1. Every generated relative link resolves; `AGENTS.md` symlink resolves to `CLAUDE.md`.
2. `.claude/settings.json` parses as JSON; every hook it references exists and is executable.
3. No `{{placeholder}}` or template guidance comment survives in any generated file.
4. Combined size of `CLAUDE.md` + `.claude/rules/*.md` is under the context budget.
5. `.gitignore` covers anything the harness expects ignored (secrets, local settings).

Then print the final report, exactly this shape:

```
## Harness ready

<one-line project summary from the interview>

### Generated
<tree of created/updated files, one line each, "(merged)" where merge mode applied>

### Ticketing
<system, project key/repo, auth status; connect instructions if auth is pending>

### Assumptions
<only if non-interactive defaults were applied; omit otherwise>

### Next steps
1. Review CLAUDE.md and llm/PRODUCT.md; fix anything I got wrong (2 min).
2. Run: /ticket <your-first-ticket-id>
3. For parallel work: one git worktree + one session per ticket (see .claude/rules/git-workflow.md).
```

Commit the harness on a branch per the generated git workflow (`chore/bootstrap-llm-harness`) unless the user asked otherwise or the repo has no git.

## Re-running

`/bootstrap-llm` in an already-bootstrapped repo means **update, not regenerate**: re-detect, show what drifted (new deps, changed scripts, stale research footers), and refresh only the affected files. `--refresh` limits this to research-derived docs. User-edited content always survives; when your update and their edit collide, show the conflict instead of silently winning.
