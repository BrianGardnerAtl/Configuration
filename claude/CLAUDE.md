# Global Development Guidelines

## Process: Review → Plan → Implement (RPI)

Always follow this sequence — do not skip or compress steps.

### 1. Review
- Read all relevant files before suggesting or making any changes
- Never propose changes to code you haven't read
- Understand existing patterns and conventions before introducing anything new

### 2. Plan
- For any non-trivial change, write out a clear plan before touching code
- Call out assumptions and open questions before implementing
- Use plan mode for larger tasks
- Get confirmation on the plan before proceeding to implementation

### 3. Implement
- Execute the confirmed plan — do not expand scope during implementation
- Make the minimum change necessary to accomplish the goal
- No incidental refactoring, added comments, or bonus features unless explicitly asked

---

## Test-Driven Development (TDD)

Follow red → green → refactor strictly.

1. **Red** — write a failing test that defines the desired behavior
2. **Green** — write the minimum production code to make the test pass
3. **Refactor** — clean up without changing behavior, then confirm tests still pass

Rules:
- Never write production code without a failing test driving it
- When fixing a bug, write a failing test that reproduces it first
- When asked to implement a feature, clarify the test approach before writing any code
- Keep each cycle small — one behavior at a time

---

## General Code Quality

- Match the scope of changes exactly to what was asked — no more, no less
- Do not add error handling for scenarios that cannot happen
- Trust existing framework and library guarantees; only validate at system boundaries
- Do not create helpers or abstractions for single-use operations
- Do not add docstrings, comments, or type annotations to code you didn't change
- Three similar lines of code is better than a premature abstraction
