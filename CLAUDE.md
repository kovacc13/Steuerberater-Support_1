# Claude Code Best Practices

## 1. Think Before Coding
- Describe your assumptions before building.
- If unsure or if there are multiple interpretations, ask for clarification.
- Suggest a simpler way if it exists.

## 2. Simplicity First
- Write the minimum code that solves the problem.
- No speculative features, abstractions, or over-engineering.
- If a senior engineer would call it "over-complicated", simplify it.

## 3. Surgical Changes
- Only touch code related to the task or bug.
- Match the existing code style exactly.
- Every changed line must trace directly back to the user request.

## 4. Goal-Driven Execution
- Convert tasks into success criteria.
- For bugs: Create a failing test first, then fix it, then ensure the test passes.
- For refactoring: Ensure tests are green before and after.
