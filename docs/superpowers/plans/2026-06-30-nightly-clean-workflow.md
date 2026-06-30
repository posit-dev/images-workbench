# Nightly Clean Workflow Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Extract the cleanup step into a single dedicated `.github/workflows/clean.yml` that runs nightly, and remove the four inline `clean` jobs from the build workflows.

**Architecture:** A new standalone workflow calls the shared reusable workflow `posit-dev/images-shared/.github/workflows/clean.yml@main` once with `dev-versions: include` + `matrix-versions: include`, covering the union of all four current clean configs (standard, matrix, dev). The inline `clean` jobs are deleted from `production.yml`, `session.yml`, `development-workbench.yml`, and `development-positron.yml`.

**Tech Stack:** GitHub Actions (reusable workflow), YAML.

## Global Constraints

- Edit workflow YAML directly under `.github/workflows/`. These are not Jinja2-templated (the template pipeline in CLAUDE.md applies to image Containerfiles, not workflows).
- Shared workflow reference is pinned to `@main`, matching every existing call in this repo. Do not change the ref style.
- The repo's pre-commit config includes an actionlint hook ("Lint GitHub Actions workflow files") that runs on any changed `.github/workflows/*.yml` file. This is the lint gate for every task below.
- No `images-shared` changes. No build-schedule or build-job changes. No Slack/failure notification for the new workflow.

---

### Task 1: Create the nightly clean workflow

**Files:**
- Create: `.github/workflows/clean.yml`

**Interfaces:**
- Consumes: `posit-dev/images-shared/.github/workflows/clean.yml@main` (existing reusable workflow; inputs `dev-versions`, `matrix-versions`, `remove-dangling-caches`, `remove-caches-older-than`, `remove-dangling-temporary-images`).
- Produces: a `Clean` workflow triggered by `schedule` (cron `30 9 * * *`) and `workflow_dispatch`.

- [ ] **Step 1: Write the workflow file**

Create `.github/workflows/clean.yml` with exactly this content:

```yaml
name: Clean
on:
  workflow_dispatch:

  schedule:
    # Nightly cleanup of dangling caches and temporary images across all
    # version classes (standard, dev, matrix). Runs at 09:30 UTC, just ahead
    # of the daily dev builds (Development - Workbench 09:45, Positron 09:55),
    # so each night's sweep clears the previous day's artifacts before the new
    # builds run.
    - cron: "30 9 * * *" # At 09:30 every day

concurrency:
  group: ${{ github.workflow }}
  cancel-in-progress: false

jobs:
  clean:
    name: Clean
    permissions:
      contents: read
      packages: write

    uses: "posit-dev/images-shared/.github/workflows/clean.yml@main"
    with:
      # Include every version class so a single pass covers the union of the
      # former per-workflow clean jobs (standard + dev + matrix).
      dev-versions: include
      matrix-versions: include
      remove-dangling-caches: true
      remove-caches-older-than: 14
      remove-dangling-temporary-images: true
```

- [ ] **Step 2: Validate YAML parses**

Run: `python3 -c "import yaml,sys; yaml.safe_load(open('.github/workflows/clean.yml')); print('ok')"`
Expected: prints `ok` (no traceback).

- [ ] **Step 3: Confirm the trigger and inputs are present**

Run: `grep -E 'cron: "30 9 \* \* \*"|dev-versions: include|matrix-versions: include' .github/workflows/clean.yml`
Expected: all three lines printed.

- [ ] **Step 4: Commit**

```bash
git add .github/workflows/clean.yml
git commit -m "ci: add nightly clean workflow"
```

The pre-commit actionlint hook runs here; expect it to pass. If it reports an error, fix the YAML and re-commit before continuing.

---

### Task 2: Remove the inline clean job from production.yml and session.yml

**Files:**
- Modify: `.github/workflows/production.yml` (delete the trailing `clean:` job)
- Modify: `.github/workflows/session.yml` (delete the trailing `clean:` job and the `allowed-skips: clean` input)

**Interfaces:**
- Consumes: nothing new.
- Produces: build workflows with no `clean` job.

- [ ] **Step 1: Delete the clean job from `production.yml`**

It is the final job in the file. Remove the blank line plus the entire block beginning `  clean:` through end of file. The block to delete:

```yaml

  clean:
    name: Clean
    if: always() && github.ref == 'refs/heads/main'
    permissions:
      contents: read
      packages: write
    needs:
      - build

    uses: "posit-dev/images-shared/.github/workflows/clean.yml@main"
    with:
      remove-dangling-caches: true
      remove-caches-older-than: 14
      remove-dangling-temporary-images: true
```

After deletion the file's last job is `build:` and the file ends after the `build` job's `push:` input line.

- [ ] **Step 2: Delete the clean job from `session.yml`**

It is the final job in the file. Remove the blank line plus the entire block beginning `  clean:` through end of file. The block to delete:

```yaml

  clean:
    name: Clean
    if: always() && github.ref == 'refs/heads/main'
    permissions:
      contents: read
      packages: write
    needs:
      - build

    uses: "posit-dev/images-shared/.github/workflows/clean.yml@main"
    with:
      matrix-versions: "only"
      remove-dangling-caches: true
      remove-caches-older-than: 14
      remove-dangling-temporary-images: true
```

- [ ] **Step 3: Remove the now-unused `allowed-skips` input from `session.yml`**

In the `ci` job's `alls-green` step, delete the line `          allowed-skips: clean` so the `with:` block keeps only the `jobs:` line:

```yaml
      - uses: re-actors/alls-green@05ac9388f0aebcb5727afa17fcccfecd6f8ec5fe  # v1.2.2
        id: alls-green
        with:
          jobs: ${{ toJSON(needs) }}
```

- [ ] **Step 4: Verify both files no longer reference clean and still parse**

Run:
```bash
grep -n "clean" .github/workflows/production.yml .github/workflows/session.yml || echo "no clean references"
python3 -c "import yaml; yaml.safe_load(open('.github/workflows/production.yml')); yaml.safe_load(open('.github/workflows/session.yml')); print('ok')"
```
Expected: `no clean references` printed (grep finds nothing — case-insensitive `clean` should not appear), then `ok`.

- [ ] **Step 5: Commit**

```bash
git add .github/workflows/production.yml .github/workflows/session.yml
git commit -m "ci: remove inline clean job from production and session workflows"
```

The pre-commit actionlint hook runs here; expect it to pass.

---

### Task 3: Remove the inline clean job from the development workflows

**Files:**
- Modify: `.github/workflows/development-workbench.yml` (delete the trailing `clean:` job)
- Modify: `.github/workflows/development-positron.yml` (delete the trailing `clean:` job)

**Interfaces:**
- Consumes: nothing new.
- Produces: dev build workflows with no `clean` job. After this task, the new `clean.yml` is the only place `clean` runs.

- [ ] **Step 1: Delete the clean job from `development-workbench.yml`**

It is the final job in the file. Remove the blank line plus the entire block beginning `  clean:` through end of file. The block to delete:

```yaml

  clean:
    name: Clean
    if: always() && github.ref == 'refs/heads/main'
    permissions:
      contents: read
      packages: write
    needs:
      - dev

    uses: "posit-dev/images-shared/.github/workflows/clean.yml@main"
    with:
      dev-versions: "only"
      remove-dangling-caches: true
      remove-caches-older-than: 14
      remove-dangling-temporary-images: true
```

- [ ] **Step 2: Delete the clean job from `development-positron.yml`**

It is the final job in the file. The block to delete is identical to Step 1's block (same content, `needs: - dev`, `dev-versions: "only"`). Remove the leading blank line plus the whole `  clean:` block through end of file.

- [ ] **Step 3: Verify both files no longer reference clean and still parse**

Run:
```bash
grep -n "clean" .github/workflows/development-workbench.yml .github/workflows/development-positron.yml || echo "no clean references"
python3 -c "import yaml; yaml.safe_load(open('.github/workflows/development-workbench.yml')); yaml.safe_load(open('.github/workflows/development-positron.yml')); print('ok')"
```
Expected: `no clean references`, then `ok`.

- [ ] **Step 4: Confirm clean.yml is now the only workflow defining a clean job**

Run: `grep -rl "name: Clean" .github/workflows/`
Expected: only `.github/workflows/clean.yml`.

- [ ] **Step 5: Commit**

```bash
git add .github/workflows/development-workbench.yml .github/workflows/development-positron.yml
git commit -m "ci: remove inline clean job from development workflows"
```

The pre-commit actionlint hook runs here; expect it to pass.

---

## Self-Review

**Spec coverage:**
- New `clean.yml` with nightly cron + dispatch, combined includes → Task 1. ✓
- Remove inline clean from all 4 workflows → Tasks 2 & 3. ✓
- Remove `allowed-skips: clean` from `session.yml` → Task 2, Step 3. ✓
- Out-of-scope items (images-shared, build schedules, Slack) → untouched. ✓

**Placeholder scan:** No TBD/TODO/"handle edge cases"; every step has exact content and commands. ✓

**Type consistency:** Shared-workflow input names (`dev-versions`, `matrix-versions`, `remove-dangling-caches`, `remove-caches-older-than`, `remove-dangling-temporary-images`) match the existing inline jobs and the shared `clean.yml` definition verbatim. ✓
