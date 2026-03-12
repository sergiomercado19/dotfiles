---
name: jira-create-ticket
description: Creates Jira tickets in the EXS project (Experience Solutions) at canva.atlassian.net. Use this skill whenever the user asks to create a Jira ticket, issue, story, task, or bug in the EXS project or for the Experience Solutions board. Always use this skill when the user says things like "create a ticket", "file a Jira", "add a story", "log an issue", or "raise a ticket". The skill enforces a specific description template (context, action items, impact) and always prompts for the target epic before creating the ticket.
---

# Jira – Create Ticket (into the EXS Project)

## Overview

Creates Jira tickets in the **EXS (Experience Solutions)** project at `canva.atlassian.net`, following a structured description template and placing tickets in the correct epic.

## Configuration

- **Project**: `EXS`
- **Default reporter**: Sergio Mercado-Ruiz (`61b5b14ef19b53006a67ed0c`)
- **Default issue type**: `Task` (use `Story` or `Bug` if the user specifies)
- **Backlog placement**: Tickets are created without a sprint, which places them in the backlog automatically.

## Tools

All Jira operations use the `otter` CLI:

```bash
otter mcp exec --no-confirm <tool_name> --param="value"
```

Available tools: `jira_search`, `jira_create`, `jira_link_issues`

### Verifying secrets are configured

Before making any Jira calls, run:

```bash
otter config mcp list
```

Check that `jira_api_token`, `jira_email`, and `jira_url` are all present. If any are missing, ask the user to set them:

```bash
otter config set-secret jira_api_token <atlassian-api-token>
otter config set-secret jira_email <canva-email>
otter config set-secret jira_url https://canva.atlassian.net
```

Atlassian API tokens can be generated at: https://id.atlassian.com/manage-profile/security/api-tokens

## Description

All tickets MUST use the exact description format (in Markdown) specified in `templates/ticket-description.tmpl`. If the user doesn't supply all three sections, ask for the missing parts before creating the ticket.

## Workflow

### Step 1 — Gather ticket details

Collect the following from the user (or infer from context if obvious):

- **Summary** (title)
- **Context / background** (top of description)
- **Action items** (dot points)
- **Impact** statement
- **Priority** — one of: `Must have`, `Should have`, `Nice to have`, `Someday`

### Step 2 — Ask for the epic

Before creating any tickets, search for epics and ask the user to pick one. For a batch of tickets, ask **once** — reuse the same epic for all unless the user says otherwise.

```bash
otter mcp exec --no-confirm jira_search \
  --jql="project = EXS AND issuetype = Epic AND statusCategory != Done ORDER BY updated DESC" \
  --fields="summary,status" \
  --limit=20
```

Present the list to the user and ask them to pick one. If they already mentioned an epic name or key, confirm it or look it up first.

### Step 3 — Confirm before creating

Show the user a summary of what will be created:

- Title(s)
- Epic
- Description preview (abbreviated if long)

Ask for explicit confirmation before proceeding.

### Step 4 — Create the ticket(s)

```bash
otter mcp exec --no-confirm jira_create \
  --summary="<title>" \
  --project_key="EXS" \
  --issue_type="Task" \
  --parent_key="<epic key>" \
  --description="<formatted markdown using the template>"
```

**Parameter reference:**
- `summary` — ticket title (required)
- `project_key` — always `EXS` (required)
- `issue_type` — `Task`, `Story`, or `Bug` (required)
- `parent_key` — epic key, e.g. `EXS-123` (optional)
- `description` — markdown body following the template (optional)

`jira_create` does not support setting priority. Immediately after creation, set it via `jira_update`:

```bash
otter mcp exec --no-confirm jira_update \
  --ticket_id="<issue key>" \
  --fields="priority=\"<priority value>\""
```

Valid priority values: `Must have`, `Should have`, `Nice to have`, `Someday`

**Important notes:**
- Do NOT set a sprint — omitting it places the issue in the backlog automatically.
- There is no reporter parameter; reporter defaults correctly without it.
- For batches, create all tickets first, then update their priorities in a second pass.

### Step 5 — Link dependencies

After creating multiple tickets, check whether any have dependencies on each other. If so, link them using `Blocks`:

```bash
otter mcp exec --no-confirm jira_link_issues \
  --inward_issue="EXS-123" \
  --outward_issue="EXS-456" \
  --link_type="Blocks"
# EXS-123 blocks EXS-456
```

**Available link types:** `Blocks`, `Depends`, `Relates`, `Duplicate`, `Contributes`, `Controls`, `Action`, `Impact`

### Step 6 — Return the links

After creation, share each issue key and its direct link:
`https://canva.atlassian.net/browse/<ISSUE-KEY>`

## Example Description

```
We currently have no automated way to track when third-party integrations go stale.
Engineers discover broken connections reactively, often after user reports.
This creates support burden and degrades user trust.

### 🚀 Action Items

- Audit all existing third-party integration health check mechanisms
- Design and implement a polling service that checks integration status every 15 minutes
- Add alerting to PagerDuty when an integration has been unhealthy for >30 minutes
- Update the integrations dashboard to surface health status to admins

### 💥 Impact

Admins will be able to proactively identify and resolve broken integrations before users are affected,
reducing integration-related support tickets and improving platform reliability.
```

## Edge Cases

- If the user provides all info upfront, skip straight to epic selection.
- If no suitable epic exists, ask the user whether to create one first or proceed without an epic.
- If the user specifies a different issue type (Story, Bug), use that instead of Task.
- For a batch of tickets, ask for the epic once upfront and reuse it for all tickets unless the user specifies otherwise.

