---
name: project-checks
description: Discover and run the appropriate validation commands for the current project. Use after changing code or configuration, or when asked to test, lint, format, type-check, build, or verify a project.
---

# Project Checks

Identify the checks documented by the repository and run the smallest relevant
set before expanding to broader or slower validation.

## Workflow

1. Read applicable `AGENTS.md`, `CLAUDE.md`, and project documentation.
2. Inspect package scripts, task runners, flake outputs, and CI configuration.
3. Select checks that cover the changed files and requested behavior.
4. Run read-only or local checks first.
5. Do not deploy, publish, push, or mutate external systems unless explicitly requested.
6. Report each command, its result, and any check that remains unrun.

Prefer project-provided commands over invented equivalents. Do not silently
rewrite files with a formatter unless formatting changes are within the task.
