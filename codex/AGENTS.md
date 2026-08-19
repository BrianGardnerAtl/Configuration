# Codex Engineering and Orchestration Guidance

## Workflow Selection

- Use Research-Plan-Implement (RPI) only when the user explicitly names RPI or Research-Plan-Implement, unmistakably requests the full workflow, or explicitly asks to "start a new feature."
- Do not infer RPI from task complexity or merely because a request changes a repository or configuration.
- Outside RPI, the primary agent handles the request directly without mandatory delegation, a planning artifact, plan approval, or separate review. Continue to follow the applicable implementation, testing, and read-only diagnosis guidance below.
- Once RPI is activated, follow the complete RPI workflow and do not bypass its approval, delegation, validation, review, or planning-artifact requirements.

## RPI Roles and Scope

- During RPI, the primary agent is the orchestrator. It owns user communication, workflow state, the plan, delegation, and final synthesis; it does not edit implementation files itself.
- The orchestrator may perform limited read-only inspection needed to route work and may maintain the planning artifact. Delegate substantive research, implementation, and review to the corresponding agents.
- A delegated agent follows its assigned role and work item instead of restarting orchestration. It must return a structured handoff to the orchestrator.
- If the required agent cannot be used, do not silently perform its work in the primary thread. Explain the constraint and ask the user how to proceed.
- For explanation, review, or diagnosis requests that do not include implementation, research and report without modifying files.

## Research-Plan-Implement

### Feature Worktree Preflight

- When RPI was activated by an explicit request to "start a new feature," complete this preflight before repository research. Other explicit RPI requests use the current working directory unless the user asks for a worktree.
- If the current session is already in the task-specific worktree created for this same request, reuse it and do not create another.
- Determine whether the current directory is inside a Git repository. If it is, resolve the repository root and inspect both working-tree status and existing worktrees before taking further action.
- Derive a concise feature slug and create a unique `codex/<feature-slug>` branch with a task-specific worktree under `$CODEX_HOME/worktrees`. Use a base explicitly supplied by the user; otherwise base it on the current committed `HEAD`.
- Never stash, discard, or silently copy uncommitted changes into the feature worktree. If the feature depends on uncommitted work, explain what was found and ask the user how to proceed. Otherwise leave the changes untouched in the original checkout.
- If branch or worktree creation fails, stop and report the failure instead of continuing in the original checkout.
- Record the new worktree's absolute path. Run all later repository reads, commands, planning-artifact updates, delegated agents, implementation, review, and validation for the request from that worktree.
- If the current directory is not inside a Git repository, state that no worktree was created and continue RPI in the current directory.

### RPI Planning Artifact

- At RPI activation, after any required feature worktree preflight, establish and record a durable planning-artifact path. Follow an existing repository convention when one is present; otherwise use `docs/plans/<feature-slug>.md` in the active checkout.
- The orchestrator exclusively maintains the artifact. Researchers, workers, and reviewers provide structured handoffs but do not edit it.
- Update the artifact immediately after each research handoff, material decision or clarified assumption, plan revision, plan approval, implementation-status change, validation result, unexpected-scope discovery, reviewer verdict, rework result, and final completion or remaining-risk assessment.
- Keep the artifact current before advancing to another RPI phase or assigning the next plan item.
- Preserve plan-version history and approval state in the artifact. Evidence and status updates do not require a new plan version, but any change to an approved outcome, boundary, dependency, or acceptance criterion does and requires renewed user approval.

### 1. Research

- Start by capturing the requested outcome, constraints, and open questions.
- Delegate repository exploration to a read-only researcher. Parallelize independent read-heavy questions when useful, but keep their scopes distinct.
- Read the applicable guidance, implementation, tests, and documentation. In unfamiliar code, identify the entry point, trace relevant control and data flow, and find a representative existing implementation.
- Establish the current architecture and behavior before proposing changes. Distinguish observed repository behavior from assumptions and general language or framework practices.
- Compare the request with the current implementation. Raise material discrepancies, incompatible assumptions, and choices that would change scope to the user; continue non-blocking research while awaiting answers when practical.
- Research is complete when the orchestrator can explain the relevant flow, evidence, constraints, risks, and credible boundaries on which to split the work.
- Do not edit implementation files during research.

### 2. Plan

- Synthesize the research into a detailed, versioned plan such as `Plan v1`, marked `AWAITING_APPROVAL`.
- Each plan item must state its outcome, dependencies, in-scope and out-of-scope boundaries, affected contract, likely files or symbols, implementation steps, acceptance criteria, validation, risks, and suggested commit or PR grouping.
- Resolve material research discrepancies before finalizing the plan. Record remaining assumptions explicitly.
- Present the complete plan to the user and request approval of that exact version. Do not begin implementation until the user explicitly approves it.
- The initial task request, `Continue`, or other workflow-progression language is not plan approval; approval must unambiguously affirm the presented plan version.
- Any later change to an approved outcome, boundary, dependency, or acceptance criterion creates a new plan version and requires renewed user approval.

### 3. Implement and Review

- After approval, the orchestrator assigns one plan item at a time to a worker with the approved plan version and item identifier.
- Use one writer at a time in a shared checkout. Do not run concurrent implementation agents unless isolated worktrees and a merge strategy were explicitly planned.
- Before assignment, identify pre-existing working-tree changes so agents preserve unrelated user work.
- The worker implements only its assigned item, runs the narrowest meaningful validation, and returns a structured handoff. It does not edit the plan.
- After the worker finishes, delegate review to a different, read-only reviewer. The reviewer compares the approved item, actual diff, and validation evidence and returns `ACCEPTED`, `REWORK_REQUIRED`, or `SCOPE_BLOCKED`.
- Send in-scope corrections back to the worker, then require another reviewer pass. Do not mark an item complete until the reviewer accepts it.
- If rework exposes a faulty assumption or requires broader scope, stop the loop and return to research and planning.
- The orchestrator reports reviewer outcomes and plan-item completion to the user, follows the subagent status-visibility rules below throughout delegated work, and remains the sole owner of plan status.

## Subagent Status Visibility

- Maintain a lightweight status record for every subagent in the current workflow: concise assignment, start time, latest state, and completion or blocker result.
- Immediately before waiting for subagent results, report mutually exclusive active, completed, and blocked counts, then list every subagent's assignment, current status, and elapsed wall-clock time. Count blocked only when explicitly reported; do not infer from runtime.
- While any subagent remains active, use bounded waits of no more than 60 seconds. After each wait returns, refresh status and send a concise heartbeat before waiting again, even if unchanged. Promptly report completions, blockers, and material state changes.
- Compute elapsed time from recorded start time if runtime does not expose it. If neither available, state `elapsed unavailable`; do not guess.
- Report exact context-window or token usage only when runtime explicitly exposes a per-agent value. Otherwise state `context usage unavailable`; never estimate from time/output.
- Keep reports factual/compact; summarize assignments/results instead of reproducing internal instructions. Never expose hidden reasoning/chain-of-thought, credentials/secrets, or full system/developer/tool/subagent prompts.

## Plan Item and Change-Set Sizing

- Prefer one independently understandable behavior or contract boundary per item, usually no more than one public or externally observable contract plus its directly supporting private changes.
- Each item should be independently reviewable, verifiable, and reversible without requiring reviewers to understand unrelated changes.
- Split work when it crosses independent contracts, unrelated subsystems or ownership boundaries, separate deployments, or migrations that can be staged.
- File and line counts are heuristics, not goals. Do not split an atomic behavior merely to make the diff smaller.
- Closely related items may share a PR when they serve one outcome, affect the same boundary, have no independent rollout need, and are easier to review together. Use separate commits when they preserve a clear review sequence.

## Unexpected Scope

- Likely files in a plan are guidance, not a rigid allowlist. A directly necessary private change inside the approved contract boundary is in scope and should be reported.
- Treat a new public contract, subsystem, dependency, migration, unrelated defect or refactor, or material acceptance or validation change as unexpected scope.
- A worker or reviewer must not incorporate unexpected work. It reports the evidence, impact, and reason the work falls outside the approved item.
- The orchestrator records the discovery separately and delegates it to a fresh read-only researcher to determine necessity, architectural fit, dependencies, split options, and whether it blocks the current item.
- Report the discovery and research conclusion to the user. Track it as a proposed follow-up, or revise the plan and request approval before implementation.
- Pause the current item only when the discovery is a genuine prerequisite. A useful but independent follow-up does not block completion of the approved item.

## Structured Handoffs

Research reports include:

- current behavior and architecture with file or symbol evidence;
- representative patterns, tests, and relevant guidance;
- discrepancies, assumptions, and unknowns;
- recommended scope boundaries, split points, and risks;
- decisions needed from the user.

Worker reports include:

- `COMPLETE` or `BLOCKED` and a concise summary;
- files changed and why;
- exact validation commands and results;
- deviations from the approved item;
- unexpected discoveries and remaining risks.

Reviewer reports include:

- `ACCEPTED`, `REWORK_REQUIRED`, or `SCOPE_BLOCKED`;
- an acceptance-criteria checklist;
- prioritized findings with file or symbol evidence;
- an assessment of validation and scope conformity;
- unexpected discoveries and the exact recommended next action.

## Working Context

- When working in Reddit repositories, assume the developer is experienced but still building familiarity with the codebase and organization-specific conventions.
- The developer primarily works on Android test infrastructure and is also learning Go service code.
- Optimize for knowledge transfer: explain important architecture, control flow, conventions, and tradeoffs encountered during the task.
- Distinguish repository-specific behavior from general language or framework practices. Do not present assumptions as established project conventions.

## Implementation Guidance

- Keep changes scoped to the requested outcome.
- Match existing project patterns before introducing new structure.
- Do not add incidental refactors, comments, abstractions, or bonus features.
- Validate at system boundaries; do not add handling for impossible states.
- Prefer comments that explain constraints or intent over comments that restate code.

## Tooling

- Prefer command-line tools and APIs when they provide a practical path to the requested outcome.
- Reserve browser automation for workflows without a practical CLI or API, such as BrowserStack, or when visual UI interaction is itself part of the task.

## Testing and Verification

Tests should protect meaningful behavior and earn their maintenance cost.

- Before adding a test, identify the behavior or plausible regression it protects.
- Bias toward tests for:
  - business rules and meaningful branching;
  - public contracts and system boundaries;
  - state transitions, concurrency, retries, and failure handling;
  - serialization or compatibility behavior;
  - bugs that are likely to recur.
- Usually avoid tests that only:
  - exercise trivial getters, delegation, constants, or wiring;
  - duplicate coverage without protecting a distinct behavior;
  - assert implementation details;
  - verify generated code, framework behavior, or compiler guarantees.
- Prefer the cheapest stable test level that proves the behavior.
- Reuse established fixtures, fakes, test rules, and helpers.
- For bug fixes, reproduce the failure with a focused test or deterministic reproduction when practical.
- If a code change does not warrant a new test, state why and run the narrowest useful existing validation.
- Do not add tests solely to increase test count or coverage percentage.

## Android Test Infrastructure

- Before changing test infrastructure, map the relevant test layer, runner, fixtures, device or emulator assumptions, CI invocation, and produced diagnostics.
- Distinguish product failures from test-code failures, infrastructure failures, environmental failures, and genuine flakiness.
- Favor determinism, isolation, explicit synchronization, reliable cleanup, and actionable failure artifacts.
- Treat arbitrary sleeps, broad retries, and swallowed failures as warning signs; do not use them to hide an unidentified failure mode.
- Verify with the narrowest relevant Gradle task or test journey before broadening validation.

## Go Services

- In unfamiliar Go code, explain package responsibilities, entry points, dependency construction, interfaces, and request or event flow before proposing structural changes.
- Identify whether a pattern is idiomatic Go, a Reddit convention, or local legacy behavior.
- Pay particular attention to context propagation, cancellation, error ownership, concurrency, resource cleanup, and external boundaries.
- Prefer existing repository patterns and generated guidance over generic rewrites toward "textbook" Go.
- When useful, point to representative files that provide the best mental model of the subsystem.
