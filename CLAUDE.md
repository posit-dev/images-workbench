# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

Posit Workbench container images built with [Posit Bakery](https://github.com/posit-dev/images-shared/tree/main/posit-bakery). Contains `workbench` (Standard/Minimal variants), `workbench-session` (R x Python matrix), and `workbench-session-init`.

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

## Product Naming

| Current Name | Legacy Name | ENV Prefix | Legacy Prefix |
|---|---|---|---|
| Posit Workbench | RStudio Workbench | `PWB_` | `RSW_`, `RSP_` |
| Posit Connect | RStudio Connect | `PCT_` | `RSC_` |
| Posit Package Manager | RStudio Package Manager | `PPM_` | `RSPM_` |

## Images

### workbench

The main Posit Workbench server image. Two variants:

- **Standard** (`std`, primary) — includes R, Python, Quarto, VS Code integration, Jupyter, supervisord, and the Job Launcher.
- **Minimal** (`min`) — base image for customers to extend.

**Key env vars** (set in Containerfile, consumed by `startup.sh`):
- `PWB_LICENSE` — license key (falls back to `RSW_LICENSE`, then `RSP_LICENSE`)
- `PWB_LICENSE_SERVER` — floating license server URL (falls back to `RSW_LICENSE_SERVER`, then `RSP_LICENSE_SERVER`)
- `PWB_LICENSE_FILE_PATH` — path to license file, default `/etc/rstudio-server/license.lic`
- `PWB_TESTUSER` — test user name, default `rstudio` (falls back to `RSW_TESTUSER`)
- `PWB_TESTUSER_PASSWD` — test user password, default `rstudio`
- `PWB_TESTUSER_UID` — test user UID, default `10000`
- `PWB_LAUNCHER` — enable Launcher startup, default `true` (falls back to `RSW_LAUNCHER`)
- `PWB_LAUNCHER_TIMEOUT` — Launcher readiness timeout in seconds, default `10`
- `STARTUP_DEBUG_MODE` — set to `1` for verbose startup logging
- `DIAGNOSTIC_ENABLE` — set to `true` to run diagnostic checks on startup

All license env vars are unset after activation to prevent child process inheritance.

### workbench-session

Session images for Workbench's Launcher. Uses a **matrix** of R x Python versions
(e.g., `R4.5.2-python3.14.3`). No variants — single image per combination.
Also includes Quarto and TinyTeX.

### workbench-session-init

Session initialization image. Downloads and packages the session components binary
(`rsp-session-multi-linux`) from S3. Ubuntu 24.04 only, no dependencies.
Uses a multi-stage build: downloads and extracts in a builder stage, copies to a minimal final image.

## Template Pipeline

**Always edit Jinja2 templates in `template/`, never rendered files in version directories.**

After changing templates, re-render: `bakery update files`

```
workbench/
├── template/                          # EDIT THESE
│   ├── Containerfile.ubuntu{2204,2404}.jinja2
│   ├── conf/                          # Config templates
│   │   ├── jupyter/, launcher/, rstudio/, sssd/, vscode/
│   ├── deps/                          # OS package lists
│   ├── scripts/{install_workbench,startup}.sh.jinja2
│   ├── startup/                       # Supervisord configs
│   │   ├── supervisord.conf.jinja2
│   │   ├── base/, launcher/, user-provisioning/
│   └── test/goss.yaml.jinja2
├── 2026.01/                           # Rendered (do not edit)
└── ...

workbench-session/
├── template/                          # EDIT THESE
│   ├── Containerfile.ubuntu{2204,2404}.jinja2
│   ├── conf/, deps/, test/
└── matrix/                            # Rendered (do not edit)

workbench-session-init/
├── template/                          # EDIT THESE
│   ├── Containerfile.ubuntu2404.jinja2
│   └── test/goss.yaml.jinja2
├── 2026.01/                           # Rendered (do not edit)
└── ...
```

### Macros imported in templates

Workbench Containerfiles import:
```jinja2
{%- import "apt.j2" as apt -%}
{%- import "python.j2" as python -%}
{%- import "quarto.j2" as quarto -%}
{%- import "r.j2" as r -%}
{%- import "wait-for-it.j2" as waitforit -%}
```

Session Containerfiles are similar but omit `wait-for-it.j2`.
Session-init only imports `apt.j2`.

### Template variables

- `Image.Version`, `Image.Variant`, `Image.OS`, `Image.IsDevelopmentVersion`
- `Dependencies.python`, `Dependencies.R`, `Dependencies.quarto` (lists of version strings)
- `Path.Version`, `Path.Image`

## Build and Test

```bash
# Install bakery and goss
just init

# Preview the build plan
bakery build --plan

# Build all images
bakery build

# Build a specific image/version/variant
bakery build --image-name workbench --image-version '2026.01.1+403.pro11' --image-variant Standard

# Run goss tests
bakery run dgoss
bakery run dgoss --image-name workbench

# Re-render templates after changes
bakery update files
```

Note: Workbench versions include build metadata (e.g., `2026.01.1+403.pro11`). Quote version
strings containing `+` in shell commands.

## CI Workflows

All workflows call shared reusable workflows from `images-shared`:

| Workflow | Schedule | What it builds | Shared workflow |
|---|---|---|---|
| `production.yml` | Weekly (Sun 03:15 UTC), PR, push to main | `workbench` + `workbench-session-init` (excludes dev/matrix) | `bakery-build.yml` |
| `development.yml` | Daily (04:45 UTC), PR, push to main | Dev versions only (daily stream previews) | `bakery-build.yml` |
| `session.yml` | Weekly (Sun 04:15 UTC), PR, push to main | `workbench-session` matrix images only | `bakery-build.yml` |

Images push to `docker.io/posit` and `ghcr.io/posit-dev` on main merges and scheduled runs.
Dev preview images push to AWS ECR.

### CI failure checklist

1. **Check which workflow failed** — production vs development vs session have different scopes
2. **Read the failing step** — usually Build or Test
3. **Common failures:**
   - Python version not available in UV — a new Python minor version may not be in UV's release metadata yet
   - Session-init download failure — S3 URL format uses `{{ Image.Version | replace('+', '-') }}`; verify the build artifact exists
   - Goss test timeout — Workbench needs supervisor + launcher to start
   - Registry auth — Docker Hub requires `DOCKER_HUB_ACCESS_TOKEN`, ECR requires AWS OIDC
4. **Cache issues** — builds use `--cache-registry ghcr.io/posit-dev` for layer caching; stale caches can cause unexpected behavior

## Helm Integration

The corresponding Helm chart is `rstudio-workbench` in `../helm/charts/rstudio-workbench/`.

- Chart `appVersion` in `Chart.yaml` drives the default image tag
- Main image tag pattern: `{appVersion}-{os}` (e.g., `2026.01.1-ubuntu-24.04`)
- Session image tag pattern: `R{rVersion}-python{pythonVersion}-{os}`
- Session-init image tag: `{appVersion}` (no OS suffix)
- `values.yaml` references `ghcr.io/posit-dev/workbench`, `workbench-session`, and `workbench-session-init`

When bumping image versions, coordinate updates to the helm chart's `appVersion` and session image defaults.
