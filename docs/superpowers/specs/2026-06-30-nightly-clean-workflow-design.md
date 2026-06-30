# Nightly Clean Workflow

## Problem

The registry/cache cleanup step currently lives as an inline `clean` job duplicated
across four build workflows:

| Workflow | `needs` | Version filters |
|---|---|---|
| `production.yml` | `build` | (defaults — standard versions only) |
| `session.yml` | `build` | `matrix-versions: only` |
| `development-workbench.yml` | `dev` | `dev-versions: only` |
| `development-positron.yml` | `dev` | `dev-versions: only` |

Each calls the shared reusable workflow
`posit-dev/images-shared/.github/workflows/clean.yml@main`. Cleanup is therefore
coupled to build runs: it only happens when a build workflow runs, and the logic is
duplicated four times with subtly different inputs.

## Goal

Extract cleanup into a single dedicated workflow that runs on a nightly schedule,
independent of builds, and remove the four inline `clean` jobs.

## Design

### New file: `.github/workflows/clean.yml`

```yaml
name: Clean
on:
  workflow_dispatch:
  schedule:
    - cron: "30 9 * * *"  # Nightly at 09:30 UTC

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
      dev-versions: include
      matrix-versions: include
      remove-dangling-caches: true
      remove-caches-older-than: 14
      remove-dangling-temporary-images: true
```

Design rationale:

- **Single combined job.** Setting both `dev-versions: include` and
  `matrix-versions: include` makes one clean pass cover standard, dev, and matrix
  versions — the union of all four current configs. The shared `clean.yml` treats
  `include` as "do not filter this class out", so nothing is excluded.
- **Triggers.** `schedule` (nightly) plus `workflow_dispatch` for manual runs. No
  `push` trigger — cleanup should not run on every merge. No `github.ref` guard:
  scheduled runs always execute on the default branch, and `workflow_dispatch` is
  operator-initiated.
- **Concurrency.** `cancel-in-progress: false` so an in-flight clean is not killed by
  a subsequent trigger (e.g. a manual dispatch overlapping the nightly run).
- **Permissions.** `contents: read`, `packages: write` — same as the inline jobs.
- **Secrets.** None passed, matching the current inline jobs (the shared workflow's
  `DOCKER_HUB_ACCESS_TOKEN` secret is optional and unused here).
- **No failure notification.** Runs silently; failures are visible in the GitHub
  Actions tab. (The build workflows notify Slack; cleanup intentionally does not.)

### Schedule timing

`09:30 UTC` runs 15 minutes before the daily dev builds
(`development-workbench.yml` at 09:45, `development-positron.yml` at 09:55). The
nightly clean therefore sweeps the previous day's dangling caches and temporary
images just before the new dev builds run — a sensible ordering. It is tight against
those two builds but does not conflict (cleanup targets prior, dangling artifacts).

### Removals

Delete the inline `clean:` job from each of:

- `.github/workflows/production.yml`
- `.github/workflows/session.yml`
- `.github/workflows/development-workbench.yml`
- `.github/workflows/development-positron.yml`

Additionally, in `session.yml`, remove `allowed-skips: clean` from the `ci`
(`alls-green`) job's `with:` block — that input only existed to tolerate the clean
job being skipped, and the job no longer exists in that workflow.

## Out of Scope

- No change to the shared `clean.yml` reusable workflow in `images-shared`.
- No change to build schedules or build job behavior.
- No Slack/failure-notification wiring for the new workflow.

## Verification

- `actionlint` / YAML lint passes on all five touched workflow files.
- The four build workflows no longer reference a `clean` job, and `session.yml`'s
  `ci` job no longer references `allowed-skips`.
- New `clean.yml` validates as a callable wrapper of the shared workflow.
