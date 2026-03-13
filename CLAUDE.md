# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

Posit Workbench container images built with [Posit Bakery](https://github.com/posit-dev/images-shared/tree/main/posit-bakery). Contains `workbench` (Standard/Minimal variants), `workbench-session` (R x Python matrix), and `workbench-session-init`. Uses Go for session init builds.

## Sibling Repositories

This project is part of a multi-repo ecosystem for Posit container images. Sibling repos
are configured as additional directories (see `.claude/settings.json`). **Read the CLAUDE.md
in each affected sibling repo before making changes there.**

- `../images-shared/` - Posit Bakery CLI tool for building, testing, and managing container images. Jinja2 templates, macros, and shared build tooling.
- `../images/` - Meta repository with documentation, design principles, and links across all image repos.
- `../images-examples/` - Examples for using and extending Posit container images.
- `../helm/` - Helm charts for Posit products: Connect, Workbench, Package Manager, and Chronicle.

### Worktrees for Cross-Repo Changes

When making changes across repositories, use worktrees to isolate work from `main`. Multiple
sessions may be running concurrently, so never work directly on `main` in any repo.

- **Primary repo:** Use `EnterWorktree` with a descriptive name.
- **Sibling repos:** Create worktrees via `git worktree add` before making changes. Store
  them in `.claude/worktrees/<name>` within each repo (matching the `EnterWorktree` convention).

```bash
# Create a worktree in a sibling repo
git -C ../images-shared worktree add .claude/worktrees/<name> -b <branch-name>
```

Read and write files via the worktree path (e.g., `../images-shared/.claude/worktrees/<name>/`)
instead of the repo root. Clean up when finished:

```bash
git -C ../images-shared worktree remove .claude/worktrees/<name>
```

> **Note:** The `additionalDirectories` in `.claude/settings.json` point to the sibling repo
> roots, not to worktree paths. File reads and writes via those directories will access the
> repo root (typically on `main`). Always use the full worktree path when reading or writing
> files in a sibling worktree.
