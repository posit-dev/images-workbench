<a href="https://posit.co/products/enterprise/workbench">
<picture>
  <source media="(prefers-color-scheme: dark)" srcset="https://cdn.posit.co/platform/containers/logos/logo_workbenchtag-reverse.svg">
  <source media="(prefers-color-scheme: light)" srcset="https://cdn.posit.co/platform/containers/logos/logo_workbenchtag-fullcolor.svg">
  <img alt="Posit Workbench Logo" src="https://cdn.posit.co/platform/containers/logos/logo_workbenchtag-fullcolor.svg">
</picture>
</a>

# Posit Workbench Positron Init container image

This container image is an init container for [Workbench](https://docs.posit.co/ide/server-pro/) Kubernetes deployments that copies Positron IDE components into a shared volume for session containers to consume. The image decouples the Positron IDE server from the Workbench session image, which enables Positron version upgrades outside the regular Workbench server release cadence.

[![GitHub Repository](https://img.shields.io/badge/github-repo?logo=github&color=grey)](https://github.com/posit-dev/images-workbench)
[![GitHub Workflow Status](https://img.shields.io/github/actions/workflow/status/posit-dev/images-workbench/session.yml?branch=main)](https://github.com/posit-dev/images-workbench/actions/workflows/session.yml)
[![Latest Version](https://img.shields.io/docker/v/posit/workbench-positron-init?sort=semver&label=latest)](https://hub.docker.com/r/posit/workbench-positron-init/tags)
![Docker Hub Pulls](https://img.shields.io/docker/pulls/posit/workbench-positron-init)
![Docker Image Size](https://img.shields.io/docker/image-size/posit/workbench-positron-init/latest)

> [!TIP]
> Deploying on Kubernetes? Try the <a href="https://docs.posit.co/helm/charts/rstudio-workbench/README.html">Posit Workbench Helm chart</a>!

## Quick reference

| |                                                                                                                                                                                                                                                                                                           |
|---|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| **Maintained by** | [the Posit Docker team](https://github.com/posit-dev/images)                                                                                                                                                                                                                                              |
| **Where to get help** | [GitHub Issues](https://github.com/posit-dev/images-workbench/issues), [Images Discussion Board](https://github.com/posit-dev/images/discussions), [the Posit Community Forum](https://forum.posit.co/c/posit-professional-hosted), [Posit Support](https://support.posit.co/hc/en-us) |
| **Where to file issues** | [https://github.com/posit-dev/images-workbench/issues](https://github.com/posit-dev/images-workbench/issues)                                                                                                                                                                                              |
| **Source** | [https://github.com/posit-dev/images-workbench](https://github.com/posit-dev/images-workbench)                                                                                                                                                                                                            |
| **License** | [MIT](https://github.com/posit-dev/images-workbench/blob/main/LICENSE.md)                                                                                                                                                                                                                                 |
| **Product documentation** | [Posit Workbench documentation](https://docs.posit.co/ide/server-pro/), [Upgrading Positron in Kubernetes deployments](https://docs.posit.co/ide/server-pro/admin/positron_sessions/upgrading_positron.html#kubernetes)                                                                                   |

## Related images

For Kubernetes deployments, Workbench uses several images together. See the [repository README](https://github.com/posit-dev/images-workbench#deploying-on-kubernetes) for Helm configuration.

| Image | Description | Docker Hub | GitHub Container Registry |
|:------|:------------|:-----------|:--------------------------|
| `workbench` | The Posit Workbench server | [posit/workbench](https://hub.docker.com/r/posit/workbench) | [posit-dev/workbench](https://github.com/posit-dev/images-workbench/pkgs/container/workbench) |
| `workbench-session` | Session images for Kubernetes (R and Python version matrix) | [posit/workbench-session](https://hub.docker.com/r/posit/workbench-session) | [posit-dev/workbench-session](https://github.com/posit-dev/images-workbench/pkgs/container/workbench-session) |
| `workbench-session-init` | Init container providing session runtime components | [posit/workbench-session-init](https://hub.docker.com/r/posit/workbench-session-init) | [posit-dev/workbench-session-init](https://github.com/posit-dev/images-workbench/pkgs/container/workbench-session-init) |

## How to use this image

### As a Kubernetes init container

The [rstudio-workbench Helm chart](https://docs.posit.co/helm/charts/rstudio-workbench/README.html) consumes this image from the `components.positron` values. If an image repository and version are provided, the chart uses the init container image to provide the specified Positron version to session pods.

```yaml
session:
  image:
    repository: "ghcr.io/posit-dev/workbench-session"
    tag: "latest"

components:
  positron:
    version: "2026.05.1-2"
    image:
      repository: "ghcr.io/posit-dev/workbench-positron-init"
```

For a guide to which Workbench image to customize for different goals, see the [Customizing images](https://github.com/posit-dev/images-workbench#customizing-images) section in the Workbench repository README.

## Image tags

Posit publishes images to:

- Docker Hub: `docker.io/posit/workbench-positron-init`
- GitHub Container Registry: `ghcr.io/posit-dev/workbench-positron-init`

Ubuntu 24.04 is the default OS.

Tag formats where `YYYY.MM.P-BUILD` is any supported Positron version:

- `YYYY.MM.P-BUILD` - Default OS
- `YYYY.MM.P-BUILD-ubuntu-24.04` - Explicit OS
- `latest` - Latest version, default OS
- `ubuntu-24.04` - Latest version, explicit OS

## Architectures

Posit publishes Ubuntu 24.04 init images for both `linux/amd64` and `linux/arm64`. Pull the same tag from either platform. Docker selects the matching manifest automatically.

> [!WARNING]
> Posit builds these images for both `linux/amd64` and `linux/arm64`, but builds the `workbench` and `workbench-session-init` images for `linux/amd64` only. `linux/arm64` builds for those images remain in developer preview until ARM64 platform support is officially added for Workbench.

## Components

The init container provides the following components in `/opt/positron`:

| Component | Path                                         | Description |
|-----------|----------------------------------------------|-------------|
| Positron IDE | `/opt/positron/bin/positron-server/bundled/` | Positron server (VS Code REH web) |
| Positron docs | `/opt/positron/docs/positron/bundled/`       | Positron Workbench documentation |
| Session init binary | `/usr/local/bin/positron-session-init`       | Go entrypoint that copies components at runtime |

## Environment variables

| Variable | Description | Values |
|----------|-------------|--------|
| `PWB_POSITRON_TARGET` | Selects which components to copy to `/mnt/init` | `positron`, `positron-docs` |

### Copy targets

- `positron`: copies `bin/positron-server` to `/mnt/init/bin/positron-server`
- `positron-docs`: copies `docs/positron` to `/mnt/init/docs/positron`

## Volumes

The init container copies components from `/opt/positron` in the image into `/mnt/init` on the shared volume.

| Mount point | Description                                                       |
|-------------|-------------------------------------------------------------------|
| `/mnt/init` | Shared volume populated with the selected Positron components     |

The session container mounts the same volume to consume the components at the path Workbench expects.

## User

The container starts as `root` so the entrypoint can write files into the shared volume with the permissions Workbench expects. The init container exits after the copy completes.

## Migrating from legacy image

This image replaces the legacy [`rstudio/workbench-positron-init`](https://hub.docker.com/r/rstudio/workbench-positron-init) image. The init container behavior is unchanged. The entrypoint copies Positron components into a shared volume at `/mnt/init` based on the `PWB_POSITRON_TARGET` environment variable. The differences are in how the image is published.

### Image references

Posit published the legacy image as `rstudio/workbench-positron-init` on Docker Hub and `ghcr.io/rstudio/workbench-positron-init` on GHCR, tagged by OS (`jammy`, `ubuntu2204`, `jammy-<version>`, `ubuntu2204-<version>`) for `linux/amd64` only. Update your image reference to one of the new locations and pick a tag that pins to your desired Positron version. See [Image tags](#image-tags) and [Architectures](#architectures).

### Base OS options

The legacy image shipped Ubuntu 22.04 only. This image ships Ubuntu 24.04 only. See [Image tags](#image-tags).

### What did not change

- Source path for Positron components (`/opt/positron`)
- Target path on the shared volume (`/mnt/init`)
- `PWB_POSITRON_TARGET` environment variable selects which components to copy
- Entrypoint behavior (one-shot copy, then exit)

## Caveats

### Security

Review these images before using them in production. Organizations with specific Common Vulnerabilities and Exposures (CVE) or vulnerability requirements can rebuild these images to meet their security standards.

Posit rebuilds published images weekly for Posit product editions under active support to pull in operating system patches.
