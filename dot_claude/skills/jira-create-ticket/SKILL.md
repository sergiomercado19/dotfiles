---
name: jira-create-ticket
description: Creates Jira tickets in the EXS project (Experience Solutions) at canva.atlassian.net. Use this skill whenever the user asks to create a Jira ticket, issue, story, task, or bug in the EXS project or for the Experience Solutions board. Always use this skill when the user says things like "create a ticket", "file a Jira", "add a story", "log an issue", or "raise a ticket". The skill enforces a specific description template (context, action items, impact) and always prompts for the target epic before creating the ticket.
---

# Create Jira Ticket (EXS Project)

## Overview

Creates Jira tickets in the **EXS (Experience Solutions)** project at `canva.atlassian.net`, following a structured description template and placing tickets in the correct epic.

## Configuration

- **Cloud ID**: `canva.atlassian.net` (resolved UUID: `d3a6b95b-bc47-4f92-b865-3ec7796e70f5`)
- **Project**: `EXS`
- **Default reporter**: Sergio Mercado-Ruiz (`61b5b14ef19b53006a67ed0c`)
- **Default issue type**: `Task` (use `Story` or `Bug` if the user specifies)
- **Backlog placement**: Tickets are created without a sprint, which places them in the backlog automatically.

## Description

All tickets MUST use the exact description format (in Markdown) specified in `templates/ticket-description.tmpl`. If the user doesn't supply all three sections, ask for the missing parts before creating the ticket.

## Workflow

### Step 1 — Gather ticket details

Collect the following from the user (or infer from context if obvious):

- **Summary** (title)
- **Context / background** (top of description)
- **Action items** (dot points)
- **Impact** statement

### Step 2 — Ask for the epic

Before creating the ticket, always ask which epic it should belong to. Search for epics in the EXS project:

```
Atlassian:searchJiraIssuesUsingJql
  cloudId: "canva.atlassian.net"
  jql: "project = EXS AND issuetype = Epic AND statusCategory != Done ORDER BY updated DESC"
  fields: ["summary", "status", "key"]
  maxResults: 20
```

Present the list to the user and ask them to pick one. If they already mentioned an epic name or key, confirm it or look it up first.

### Step 3 — Confirm before creating

Show the user a summary of what will be created:

- Title
- Epic
- Description preview (abbreviated if long)

Ask for explicit confirmation before proceeding.

### Step 4 — Create the ticket

Use `Atlassian:createJiraIssue` with:

```
cloudId: "canva.atlassian.net"
projectKey: "EXS"
issueTypeName: "Task"   // or "Story" / "Bug" as appropriate
summary: <title>
description: <formatted markdown using the template above>
additional_fields:
  reporter: { id: "61b5b14ef19b53006a67ed0c" }
  parent: { key: "<epic key>" }
```

**Important notes:**
- Do NOT set a sprint unless explicitly specified — omitting sprint places the issue in the backlog.
- The `parent` field links to the epic in next-gen / team-managed projects. For classic projects, use `customfield_10014` (epic link) if `parent` doesn't work. Try `parent` first.
- Reporter must always be set to Sergio's account ID above.

### Step 5 — Return the link

After creation, share the issue key and a direct link:
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
- If the user wants to create multiple tickets at once, loop through each one, asking for epic per ticket (or confirm if they should all go under the same epic).
