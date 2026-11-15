# Project board review and manual movement / Scrum journal

Reviewed: 2026-11-15 UTC. Repository: moldovancsaba/calendar-agent.

Canonical board: [project board](https://github.com/users/moldovancsaba/projects/22). **The board is the owner's source of truth and is read-only. Never add, remove, reorder or move cards or edit project fields.** This file records observations and conditional proposals for manual owner decisions only.

## Verified coverage and limitations

- Repository collection: 0 entries, including 0 issues and 0 pull requests; 0 issues are open.
- Board: all 0 returned items were read; totalCount matches the captured item count.
- Linked issue-state / Done-status discrepancies: 0. Open issues absent from this board snapshot: 0. Absence here does not prove absence from every board and does not authorize creating a card.
- Exact title-and-body duplicate groups among open issues: 0. Similar titles alone were not treated as duplicates.
- Issue and board reads succeeded. No access failure was observed for these captured collections. No board write was attempted.
- This is a documentation-only review. No runtime suite, production flow, user data mutation, external message, dependency upgrade or deployment action was performed. Source presence and previous Done status are not fresh acceptance evidence.

## Source observations and work clusters

The repository returned no issues and the associated board snapshot is registered below. Feature checkmarks and historical production-ready delivery prose are not fresh native acceptance. Package.swift targets the Sources directory; root duplicate filenames are not the build authority. Sources/CalendarAgent.swift persists tasks/workflows in UserDefaults and contains model discovery, execution-log and update code. These source surfaces do not establish each calendar/mail/custom-action workflow actually executes correctly.

A concrete updater drift exists: the active source's updateCheckURL points to moldovan/calendar-agent, while this repository and README installation commands use moldovancsaba/calendar-agent. Reconcile the release source and validate download/integrity/install/recovery on the target Mac before calling auto-update accepted. Do not execute build-bundle.sh in this review: it installs/replaces an application under /Applications.

Modernization candidates include current supported native calendar permission APIs and a maintained signed update mechanism, evaluated against macOS version support, permissions, artifact trust and rollback. Changing a model tag or swapping an agent framework cannot prove workflow execution, safe scheduling or external-message consent. No calendar, task data, mail, Slack, Notes, model service, downloaded release or installed app was accessed. Native build, signing and permissions require macOS and remain unverified in this Linux docs-only review.

Inspected sources: [README.md](../README.md), [Package.swift](../Package.swift), [Sources/CalendarAgent.swift](../Sources/CalendarAgent.swift), [build-bundle.sh](../build-bundle.sh). Documentation paths and register coverage were checked before publication. No new technology is selected or installed by this assessment.

## Per-card review register

A destination is a proposal, never an executed move. Historical closed cards stay historical; migrated or not-planned closures do not prove feature delivery. Open work remains subject to its issue's acceptance criteria and owner decision.

| Issue / card | Title | Issue state / reason | Observed current column | Proposed destination / next evidence | Owner decision / manual execution |
| --- | --- | --- | --- | --- | --- |
| None | Empty board / no open repository issue | Not applicable | Empty observed | No move proposed | No action / not executed |

## Append-only Scrum / manual movement journal

| Date / Scrum reference | Board and issue | Verified current column | Proposed destination | Evidence / rationale | Dependency / blocker | Owner decision | Manual execution / person | Verified new column | Notes |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 2026-11-15 review | Board and issues above | Snapshot above | No automatic move | Recorded source/issue/board review | See unresolved requirements | Pending | Not executed | Snapshot only | Preserve history |
| YYYY-MM-DD / meeting link | Board URL + issue URL | Exact observed value | Exact proposed value or remain | Acceptance link | Specific condition | Pending | Not executed | Not verified | — |

Read the issue and actual board before each future proposal. Retain previous observations when a decision changes. Record execution only after the owner performs it and the result is read back. Documentation rollback requires no product or board rollback.
