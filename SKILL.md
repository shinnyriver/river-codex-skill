---
name: river-codex-skill
description: "Rigorous but right-sized repo workflow for Codex: scope control, project preflight, implementation, review, verification, branch docs, rollback hygiene, worktree sessions, and resumable project memory. Use for non-trivial code changes, backend reviews, PR-description refreshes, test/CI verification, commit preparation, or repo-specific routines such as trio-backend AGENTS/River preflight and integrationTest proof."
---

# River Codex Skill

Use this skill to run a disciplined change workflow inside an existing repository.

# GRAND PRINCIPLES

The following principles take precedence over all instructions in the applicable skill.

1. Think Before Coding
2. Simplicity First
3. Surgical Changes
4. Goal-Driven Execution
5. Right-Size the Ritual

Use the workflow to improve correctness, not to create ceremony. For direct questions, reviews, or small documentation fixes, gather only the evidence needed and answer or edit directly. For substantial changes, follow the full preflight, planning, implementation, verification, and reporting loop.

## Quick Start

1. Initialize project scaffolding if `.river/workflow/config.yaml` is missing.

```bash
bash scripts/bootstrap-project.sh /absolute/path/to/project
```

2. Read `.river/workflow/config.yaml` and the relevant `.river/memory/*.md` files before planning.
3. Create or update:
   - `.river/memory/requirements.md`
   - `.river/memory/branch-name.md`
   - `.river/memory/plan-summary.md`
4. Use a `codex/` branch name when creating a new branch.
5. Choose one review path and record it in `.river/memory/plan-summary.md`:
   - `SMALL`: implement, targeted review, regression check, final readiness
   - `STANDARD`: full staged workflow
   - `LARGE`: full staged workflow plus deeper failure-mode analysis

6. For `trio-backend`, treat this extra preflight as mandatory before edits, commits, or PR-ready docs:
   - Read `AGENTS.md` from disk.
   - Follow any River files or repo workflow files it points to.
   - Refresh `.river/memory/requirements.md` and `.river/memory/plan-summary.md` for the active task, even for docs-only work.
   - Use the repo commit format from the first draft: `:gitmoji: type: message`.

## Workflow

Execute phases in order. Parallelize only independent reads and deterministic checks.

### 1. Scope

- Inspect the current code before proposing changes.
- Identify what already exists, the minimum viable change, and the likely risk areas.
- Identify cache impact, query count, join complexity, and likely DB hot paths before locking the plan.
- Check whether the request appears to exceed the configured limits in `.river/workflow/config.yaml`.
- If the work needs an isolated session, create a worktree on the branch from `.river/memory/branch-name.md`.
- Distinguish the user's intent before acting:
  - If the user asks a question, explain from repository evidence instead of making edits.
  - If the user asks for a review, lead with findings and file/line references.
  - If the user asks to implement, keep going through verification unless blocked.
  - If the user interrupts with rollback, revert only changes made in the current attempt and preserve unrelated or earlier requested work.

### 2. Plan

- Write a compact plan in `.river/memory/plan-summary.md`.
- Split work into small units when the diff is likely to span multiple concerns.
- Record:
  - completion criteria
  - in-scope files
  - out-of-scope items
  - unresolved decisions
  - expected risks
- Keep the plan grounded in the existing codebase rather than idealized architecture.
- Update the plan as the task changes. If the user pivots from implementation to explanation, stop expanding the edit scope.
- Prefer concise user-facing plans. The user values exact endpoints, files, commands, and consequences more than broad architecture narration.

### 3. Implement

- Read the relevant sections from [review-lenses.md](references/review-lenses.md) before editing risky domains.
- Prefer incremental changes that preserve existing patterns.
- Design classes with clear responsibilities, extension points, and object-oriented boundaries that respect SOLID principles.
- Prefer domain behavior over anemic models: update state by sending messages to objects and keeping invariants inside the owning object.
- Avoid broad getter/setter-driven mutation unless a framework requirement makes it necessary.
- When the domain is non-trivial, favor DDD-style aggregates, entities, and value objects over procedural service-only state management.
- Consider caching and DB performance early: avoid N+1 patterns, unnecessary entity loading, overly chatty repository access, and unbounded reads.
- Use JPA for short, readable, low-complexity queries.
- Use QueryDSL for long, join-heavy, dynamic, or projection-heavy queries where explicit composition improves readability and maintenance.
- Use the bundled scripts for deterministic checks instead of re-deriving shell commands each time.
- Keep edits scoped to the requested behavior. Do not convert a narrow migration, API, or documentation request into a broad refactor.
- For schema migrations, prefer the repository's existing idempotent or recovery-friendly style when such a pattern already exists.
- For branch documentation, replace stale narratives wholesale when the branch topic has changed instead of patching around outdated text.

Useful commands:

```bash
bash scripts/extract-diff.sh main /absolute/path/to/project
bash scripts/verify-build.sh /absolute/path/to/project
bash scripts/typecheck.sh /absolute/path/to/project
bash scripts/run-tests.sh /absolute/path/to/project
```

### 4. Review

- Review only the changed files first.
- Load [review-lenses.md](references/review-lenses.md) only for the domains present in the change.
- Check whether the change preserves domain invariants, avoids setter-centric state updates, and keeps query logic in the appropriate persistence tool.
- Review cache usage, query count, fetch strategy, and join complexity before calling the change ready.
- Run the appropriate checks:

```bash
bash scripts/check-sizes.sh main /absolute/path/to/project
bash scripts/find-dead-code.sh main /absolute/path/to/project
```

- Raise findings by severity: `CRITICAL`, `HIGH`, `MEDIUM`, `LOW`.
- Fix `CRITICAL` and `HIGH` issues before reporting completion unless the user explicitly accepts the risk.
- When asked to "review" or "review again", re-scan the current diff instead of reusing an earlier verdict.
- When the user says to proceed without an external reviewer, perform a direct manual review and do not stall on unavailable tools.

### 5. Report

- Produce a concise delivery report using [report-template.md](assets/report-template.md).
- Capture final risks, tests run, skipped checks, and unresolved decisions.
- Update `.river/memory/retrospective.md` when the run revealed a reusable lesson for future sessions.
- Keep the final report short and concrete:
  - what changed
  - where it changed
  - what was verified
  - what remains risky or unverified
- If command output matters, summarize the important lines; do not assume the user saw terminal output.

## User Habit Defaults

Apply these defaults unless the user's latest message says otherwise:

- Prefer repo-grounded answers over generic advice. Cite exact files, endpoints, fields, commands, and error strings.
- For `PR_DESCRIPTION` requests in `trio-backend`, update `untracked/PR_DESCRIPTION.md` with the current backend/API contract and frontend integration guide.
- If the user asks whether integration tests were run, use the repo's real integration path rather than a pattern guess.
- If the user asks for similar risks, fix the direct issue and scan sibling call sites before reporting completion.
- If the user requests SQL, provide executable SQL directly.
- If the user is exploring policy or architecture, answer decisively from the code first and avoid speculative edits.

## Verification Defaults

Choose the smallest checks that prove the change, then broaden for shared contracts:

- Run `git diff --check` for edited tracked files before completion.
- For Java backend changes, prefer `./gradlew compileJava` or focused tests early.
- In `trio-backend`, `./gradlew integrationTest` is the real integration-test path. Do not substitute `./gradlew test --tests '*IntegrationTest*'` as proof of integration coverage.
- For docs-only work, verify against the actual controller, DTO, service, migration, and test code that define the contract.
- If a check is skipped, state why.

## Sessions

Use worktrees for longer or branch-specific tasks. Manage them with:

```bash
bash scripts/manage-sessions.sh list /absolute/path/to/project
bash scripts/manage-sessions.sh info /absolute/path/to/project codex/feature-name
bash scripts/manage-sessions.sh delete /absolute/path/to/project codex/feature-name
```

Rules:

- Ask for explicit confirmation before `delete`.
- Do not remove a session to clean up around unrelated work.
- Resume by reading the `.river/memory/` files inside the worktree before making new edits.

## Resources

- Use [config-template.yaml](assets/config-template.yaml) as the default project workflow config.
- Use [review-lenses.md](references/review-lenses.md) when a change touches security, auth, API integration, DB, caching, messaging, infra, or concurrency.
- Use the shell scripts in `scripts/` for build, test, diff extraction, size checks, and session management.

## Constraints

- Do not assume Claude Code features such as AskUserQuestion, slash commands, MCP-only helpers, or agent spawning.
- Treat this as a Codex workflow guide, not an autonomous multi-agent system.
- Keep memory files short and actionable.
- Prefer local verification and repository evidence over speculative redesign.
- Never revert user changes or earlier requested work while cleaning up your own attempt.
- When interrupted, sanity-check that the next response follows the newest request rather than the previous plan.

## Design Defaults

- Default to object-oriented designs that remain open to extension without spreading responsibilities across god classes.
- Prefer behavior-rich domain objects over setter-driven data containers.
- Treat cache strategy and DB performance as first-class design concerns, not late-stage cleanup.
- Default persistence choice:
  - JPA for short and simple queries.
  - QueryDSL for long, join-heavy, or dynamically composed queries.
- Default DTO should be 'record' type
  - Response DTO should contain 'from' or 'of' constructor static method.

## Git Convention

- Every Commit must be in the following format
- `:gitmoji: type: message`
