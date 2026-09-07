# Ticketing: Jira (Atlassian MCP, REST fallback)

Prefer the Atlassian MCP server when its tools are visible in the session; fall back to the REST API v3 with an API token otherwise. Generate for whichever path is available, and say which one you wired in the report.

## Path A: Atlassian MCP

Detection: tools named like `mcp__atlassian__*` (getJiraIssue, transitionJiraIssue, addCommentToJiraIssue, searchJiraIssuesUsingJql).

Connect instructions to embed when absent/unauthenticated:

```
Atlassian MCP is not connected. Either:
- Claude Code: claude mcp add --transport sse atlassian https://mcp.atlassian.com/v1/sse
  then /mcp in an interactive session to authorize, or
- Claude Desktop/Web: Settings → Connectors → Atlassian → Connect
Then re-run /ticket <id>.
```

Operations: fetch issue by key; transition by **name** (see below); comment with the PR URL; assign to self.

## Path B: REST API

Credentials via environment (never in the repo): `JIRA_BASE_URL`, `JIRA_EMAIL`, `JIRA_API_TOKEN` (from id.atlassian.com → API tokens). Bootstrap adds the three names to `.env.example` with a comment, confirms `.env` is gitignored, and embeds this preamble in `/ticket` step 1:

```bash
: "${JIRA_BASE_URL:?Set JIRA_BASE_URL, JIRA_EMAIL, JIRA_API_TOKEN (see .env.example)}"
AUTH="$JIRA_EMAIL:$JIRA_API_TOKEN"
```

| Step | Command |
|---|---|
| Fetch | `curl -su "$AUTH" "$JIRA_BASE_URL/rest/api/3/issue/{{KEY}}-<n>?fields=summary,description,status,labels,comment"` |
| List transitions | `curl -su "$AUTH" "$JIRA_BASE_URL/rest/api/3/issue/<key>/transitions"` |
| Transition | `curl -su "$AUTH" -X POST -H "Content-Type: application/json" -d '{"transition":{"id":"<id>"}}' "$JIRA_BASE_URL/rest/api/3/issue/<key>/transitions"` |
| Comment (PR link) | `curl -su "$AUTH" -X POST -H "Content-Type: application/json" -d '{"body":{"type":"doc","version":1,"content":[{"type":"paragraph","content":[{"type":"text","text":"PR: <url>"}]}]}}' "$JIRA_BASE_URL/rest/api/3/issue/<key>/comment"` |

## Transitions: resolve by name at runtime

Jira transition IDs differ per workflow and can change; embedding IDs makes the skill rot. The generated `/ticket` always lists transitions first and picks the one whose **name** matches the interview-supplied status (`{{STARTED_STATE}}`, `{{REVIEW_STATE}}`), failing with the available names when no match exists. That failure message is the user's cue to fix the status mapping in the skill.

## Generation checklist

- Real project key everywhere; real status names from the interview (Jira workflows vary too much to default silently).
- Secrets only via env; `.env` gitignored; `.env.example` documents the three variables.
- Branch/commit ticket references use the Jira key (`feature/{{KEY}}-12-slug`, trailer `Refs {{KEY}}-12`); if the repo hosts on GitHub with the Jira GitHub app installed, that reference also auto-links the PR.
