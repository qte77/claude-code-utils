---
plan: ../plans/NNN-slug.md
status: <not started | in progress — resume at X | shipped>
updated: YYYY-MM-DD
---

# Handoff — <Title>

Onboarding for the next session. Full detail + `file:line` source map:
[plan NNN](../plans/NNN-slug.md). **Read the plan's source map first — you should not need to
re-explore.** Tracking issue: <#NNN>.

> Delete this callout before use. Instantiates the estate
> [unattended-execution contract](https://github.com/qte77/qte77/blob/main/docs/unattended-execution.md). The handoff is read FIRST, the plan
> second. Keep it in sync with the plan + `MEMORY.md` at every milestone.

## State at handoff (YYYY-MM-DD)

- **Branch / sync:** <branch, clean or dirty, ahead/behind main>.
- **Prod:** <live version, deploy state, last remote e2e result e.g. 111/111>.
- **Shipped this arc:** <merged PR numbers + one-liners>.
- **Resume point:** <the single NEXT action>.
- **Owner action that unblocks the rest:** <the one pre-staged Phase B gate, if any>.

## How to handle the plan (order)

<Numbered, ordered steps. What to build first and WHY (usually the backend/data slice that reaches
green now and unblocks the rest). Explicit "do NOT start X first".>

## First actions on resume

- <The literal first commands/edits — branch name, files to touch, tests to write red.>

## Working style

- **Strict TDD, RED first** — model the expected behavior red, then green. Modules only; glue/config/CSS
  and one-shot scripts are covered by build + lint + e2e, never unit tests. Value-add tests only.
- **Run the whole gate == CI** (`make check` / `npm run validate`) + the audit target before pushing.
  Strict lint + type + security on every file.
- **Merge is an owner gate** — park the green PR for approval; never auto squash-merge.

## Owner-gates (pre-staged; batch into one sitting)

<Each gate: what is pre-staged in Phase A, and the single switch the owner flips in Phase B.>

## Gotchas (the unattended tax + arc-specific traps)

- Prefix every `git`/`gh` with `env -u GH_TOKEN -u GITHUB_TOKEN`; commit `--no-gpg-sign` and `-F` (not
  `-m`). See the [unattended tax](https://github.com/qte77/qte77/blob/main/docs/unattended-execution.md#the-unattended-tax) for the full list.
- **Verify on the live target** (local + remote); edge-settle before the remote sweep; console errors
  fail the run; read 2-3 screenshots.
- Cross-repo: delegate content edits to a subagent inside the target repo; the main agent does git
  plumbing only.
- <Arc-specific verified traps — the "these WILL bite you" list carried forward so the next session
  does not rediscover them.>

## At arc close (mine, then prune)

This handoff, its plan, the findings, and the arc's memory are **ephemeral working state**. When the arc
ships: **mine** them — promote durable learnings to `AGENT_LEARNINGS.md` / a rule / an ADR, and the
*why* into commit bodies — migrate any remainder to the next `NNN`, then **prune** this scaffolding. Do
not leave shipped arcs as permanent docs.
