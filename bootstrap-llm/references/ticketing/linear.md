# Ticketing: Linear (MCP)

Linear integration runs through the official Linear MCP server. Detection: Linear tools (named like `mcp__linear__*` or `mcp__plugin_linear_linear__*`) visible in the session.

## Auth check at bootstrap

Try a cheap read (list teams / viewer). Three outcomes:

- **Works**: also fetch the team's workflow states now and embed the real status names in the generated files (do not assume "In Progress" exists; the interview default is only a fallback).
- **Tools present but unauthenticated**: generate the integration anyway; put the connect instructions below in the report and at the top of the generated `/ticket` skill.
- **No tools at all**: same, plus the install line.

Connect instructions to embed (adapt to what you observed):

```
Linear MCP is not connected. Either:
- Claude Code: run /mcp in an interactive session and authorize Linear, or
  install it first: claude mcp add --transport http linear https://mcp.linear.app/mcp
- Claude Desktop/Web: Settings → Connectors → Linear → Connect
Then re-run /ticket <id>.
```

## Commands to embed in the generated /ticket skill

Use whatever the session's actual Linear tool names are; the canonical operations:

| Step | Operation |
|---|---|
| Fetch | get issue by identifier `{{KEY}}-<n>`: title, description, state, labels, comments, attachments |
| Claim | update issue: state → `{{STARTED_STATE}}`, assignee → viewer |
| Ready for review | update issue: state → `{{REVIEW_STATE}}` |
| Attach PR | comment with the PR URL (belt-and-braces; see auto-linking below) |
| Blocked | comment explaining the blocker; move back to `{{BACKLOG_OR_TODO_STATE}}` if the run is abandoned |

**Auto-linking**: Linear links branches and PRs automatically when the issue identifier (`ABC-123`) appears in the branch name or PR title. The harness branch convention `<type>/{{KEY}}-<n>-<slug>` satisfies this; tell the generated `create-pr` skill to keep the identifier in the PR title too.

## Generation checklist

- Real team/project key from the interview in every command.
- Real state names (fetched if authed, interview answer otherwise) in the claim/review steps.
- `/ticket` step 1 fails fast with the connect instructions when tools are missing or unauthenticated.
