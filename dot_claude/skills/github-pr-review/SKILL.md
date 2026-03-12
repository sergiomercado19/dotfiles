---
name: github-pr-review
description: Review code changes on a pull request as a senior staff engineer. Check for correctness, performance, security, design quality, and more. Provide specific, actionable feedback with file names, line numbers, explanations, and proposed fixes. Use when asked to review a pull request, code changes, or diffs with an expert eye for detail and quality.
argument-hint: "[github-pr-link]"
---

# GitHub PR Review

Review every change on the current branch. Get the full diff, then review each changed file in context.

Review the code as a super-genius, mega-brained senior staff engineer. Be specific: cite file names and line numbers, explain *why* something is a problem, and propose concrete fixes with code snippets where useful.

## Steps to Review

1. Navigate to `~/work/canva` and make sure you have the latest main branch: `git checkout main && git pull`.
2. Check out the PR branch from the GitHub PR link ($0).
3. Get the full diff of the current branch against main (or the target branch) from the GitHub PR link ($0).
4. For each changed file, review the changes in context. Don't just look at the diff — understand how the changed code fits into the file and the codebase as a whole.
5. For each issue you find, note the file name and line number, explain why it's a problem, and propose a specific fix.

## What to check

### Correctness & edge cases
- Logic errors, off-by-one, null/undefined, empty collections, boundary conditions
- Race conditions, stale closures, unhandled promise rejections, missing `await`
- Anything that could block the main thread or lock up the render loop

### Performance
- Unnecessary re-renders, missing memoisation, expensive computations in render paths
- Algorithmic complexity -- flag anything worse than O(n) that could be improved
- Bundle size impact, unnecessary dependencies, large imports that could be tree-shaken
- Will this work well on low-powered mobile devices?

### Security
- XSS vectors, unsanitized user input, innerHTML usage
- Sensitive data exposure in logs, URLs, or client-side state
- Auth/authz gaps

### Error handling & resilience
- Missing try/catch, missing error boundaries, ungraceful failure modes
- Swallowed errors, catch blocks that silently discard context

### Code quality & design
- DRY violations, dead code, copy-pasted logic that should be extracted
- Naming clarity -- misleading or overly vague variable/function names
- Single Responsibility -- functions or components doing too many things
- Encapsulation, reusability, and extensibility of abstractions
- Consistency with existing codebase patterns and conventions
- Atomic, succinct, encapsulated changes
- Make sure code is appropriately commented, albeit not verbosely, and if function and variable arguments are descriptive enough, don't add what I would deem to be excessive commenting.
- Code should adhere to the styling, rules, and formatting of the rest of the codebase, so check if changes is overly aberrant to how code is elsewhere is in the codebase. 
- Similarly, don't reinvent the wheel, try and find pre-existing utilities or other helper functions, instead of reimplementing prior work. Note where something could be genericised and reused, instead of having two similar implementations of a concept or utility.
- Can we see if there are any avenues to make it so this is split into multiple PRs? We like to try and keep PRs to under 300, maybe 500 lines, and split them out into a PR train if they go above that change count.

### Type safety
- Use of `any`, missing generics, loose typing that could mask bugs
- Generally make sure things are in line with the monorepo's linting and prettier rules

### Accessibility
- Missing or incorrect ARIA attributes, keyboard navigation gaps, focus management
- Colour contrast, screen reader compatibility
- Reduced motion must be supported for users who prefer this

### Memory & cleanup
- Event listener leaks, unsubscribed observables, missing useEffect cleanup

### Testing
- Are changes covered by tests? Are the tests meaningful or just asserting implementation details?
- Missing edge case coverage

### Backwards compatibility
- Will this break existing consumers, APIs, or contracts?

## Output format

Produce a numbered list of findings grouped into three priority tiers:

**P0 — High (bugs, security, data loss, crashes)**
**P1 — Medium (performance, error handling, design issues)**
**P2 — Low (style, naming, minor improvements)**

For each finding: state the file + location, the problem, why it matters, and a suggested fix.
At the end, give a brief overall summary and a ship/don't-ship recommendation.
