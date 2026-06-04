# Contributing to Posit Workbench container images

This guide covers how to build and test the Workbench container images locally, and how
to perform common maintenance tasks. To build images directly with Docker, Buildah, or
Podman, see the [README](README.md#build). To deploy or run pre-built images, see the
[README](README.md#running-the-images).

## Build and test

### Prerequisites

| Tool | Install |
|---|---|
| [python](https://docs.astral.sh/uv/guides/install-python/) + [uv](https://docs.astral.sh/uv/getting-started/installation/) | Required for `bakery` |
| [docker buildx bake](https://github.com/docker/buildx#installing) | Required for builds |
| [just](https://just.systems/man/en/prerequisites.html) | Task runner |
| [gh](https://github.com/cli/cli#installation) | Required while repositories are private |

```shell
# Install bakery and goss
just init

# Install pre-commit hooks
just setup
```

### Build

```shell
# Preview the build plan
bakery build --plan

# Build all images
bakery build

# Build a specific image and version
bakery build --image-name workbench --image-version 2026.01
```

### Test

```shell
# Run goss tests for all images
bakery run dgoss

# Run goss tests for a specific image
bakery run dgoss --image-name workbench
```

### Re-render templates

After changing any file in a `template/` directory, re-render the version directories:

```shell
bakery update files
bakery update files --image-name workbench --image-version 2026.01
```

## Maintainer tasks

Each section below has Workbench-specific context and a concrete example. The linked
procedure in the [shared maintainer guide](https://github.com/posit-dev/images-shared/blob/main/CONTRIBUTING.md)
covers the full workflow.

### Add a version

Workbench versions are dispatched automatically from `rstudio/rstudio-pro` via the
`workbench-ide-release` GitHub App, which triggers this repo's `release.yml` workflow.
Manual steps are only needed for hotfixes.

```bash
# Create a new version manually (e.g. a hotfix to 2026.01)
bakery create version 2026.01.2 --image-name workbench --image-name workbench-session-init
bakery update files --image-name workbench --image-version 2026.01
bakery update files --image-name workbench-session-init --image-version 2026.01
```

`workbench-session` is a matrix image. Its versions are managed via `matrixVersions` in
`bakery.yaml`, not with `bakery create version`.

→ [Shared procedure](https://github.com/posit-dev/images-shared/blob/main/CONTRIBUTING.md#add-a-version)

### Add an image

This repo has four images: `workbench` (server), `workbench-session` (R×Python matrix),
`workbench-session-init`, and `workbench-positron-init`. Adding a new image requires
coordination with the Workbench product team.

```bash
# Scaffold a new image directory and template
bakery create image <new-image-name>
```

→ [Shared procedure](https://github.com/posit-dev/images-shared/blob/main/CONTRIBUTING.md#add-an-image)

### Update dependencies

`workbench-session` is a matrix image with R×Python combinations defined in `bakery.yaml`
under `matrixVersions`. To add a new R or Python version to the session matrix, add it
to `matrixVersions` and re-render:

```bash
bakery update files --image-name workbench-session
```

`workbench` and `workbench-session-init` use `dependencyConstraints` for their
non-matrix dependencies.

→ [Shared procedure](https://github.com/posit-dev/images-shared/blob/main/CONTRIBUTING.md#update-dependencies)

### Update older versions

```bash
# Edit the template, then re-render a specific edition
bakery update files --image-name workbench --image-version 2026.01
bakery update files --image-name workbench-session-init --image-version 2026.01

# Build and test before opening a PR
bakery build --image-name workbench --image-version 2026.01
bakery run dgoss --image-name workbench --image-version 2026.01
```

→ [Shared procedure](https://github.com/posit-dev/images-shared/blob/main/CONTRIBUTING.md#update-older-versions)

### Footguns

**`workbench-session-init` downloads from S3 during build.** The Containerfile fetches
a binary whose URL embeds the image version with `+` replaced by `-` (via
`{{ Image.Version | replace('+', '-') }}`). Verify the S3 artifact exists at the
expected URL before creating a new version.

**Workbench needs time to start.** The server, supervisor, and launcher all need to come
up before goss can probe the container. Check the `wait:` value in the image's `options`
block in `bakery.yaml` if goss probes fail immediately.

**`workbench-session` has no version directories.** It renders into
`workbench-session/matrix/`. Do not create `workbench-session/<edition>/` directories
manually.

**Dev images push to AWS ECR.** The `development.yml` workflow requires `id-token: write`
and `AWS_ROLE` for ECR auth.

→ [Shared footguns](https://github.com/posit-dev/images-shared/blob/main/CONTRIBUTING.md#footguns)

### Diagnose a build failure

| Workflow | Schedule | Builds |
|---|---|---|
| `production.yml` | Weekly Sun 03:15 UTC, push to main, dispatch | `workbench` + `workbench-session-init` (excludes dev and matrix) |
| `development.yml` | Daily 09:45 UTC, push to main, dispatch | Dev stream previews → AWS ECR |
| `session.yml` | Weekly Sun 03:45 UTC, push to main, dispatch | `workbench-session` matrix images only |

All workflows use `bakery-build-native.yml` (native amd64 + arm64 runners).

**Workbench-specific failures:**

- _S3 download failure in `workbench-session-init`_ — the build fetches a binary from
  S3. If the artifact does not exist for the dispatched version, the build fails at the
  download step. Verify the product build artifact was published before the image build
  was triggered.
- _Goss timeout_ — Workbench needs supervisor and launcher to fully start before probes
  succeed. If goss fails immediately, check the `wait:` value in `bakery.yaml`.

→ [Shared failure scenarios](https://github.com/posit-dev/images-shared/blob/main/CONTRIBUTING.md#diagnose-a-build-failure)
