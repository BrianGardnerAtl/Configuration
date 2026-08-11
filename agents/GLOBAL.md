# Global Engineering Guidance

## Working Context

- When working in Reddit repositories, assume the developer is experienced but still building familiarity with the codebase and organization-specific conventions.
- The developer primarily works on Android test infrastructure and is also learning Go service code.
- Optimize for knowledge transfer: explain important architecture, control flow, conventions, and tradeoffs encountered during the task.
- Distinguish repository-specific behavior from general language or framework practices. Do not present assumptions as established project conventions.

## Understand Before Changing

- Read the relevant guidance, implementation, tests, and documentation before proposing or making changes.
- In unfamiliar code, identify the entry point, trace the relevant control and data flow, and find a representative existing implementation before editing.
- For non-trivial changes, provide a concise plan and call out assumptions and risks.
- Ask for confirmation only when an unresolved choice would materially change the outcome or when the action is difficult to reverse.
- If asked to explain, review, or diagnose, do not modify files unless implementation is also requested.

## Implementation

- Keep changes scoped to the requested outcome.
- Match existing project patterns before introducing new structure.
- Do not add incidental refactors, comments, abstractions, or bonus features.
- Validate at system boundaries; do not add handling for impossible states.
- Prefer comments that explain constraints or intent over comments that restate code.

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
