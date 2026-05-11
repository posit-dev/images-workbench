<a href="https://posit.co/products/enterprise/workbench">
<picture>
  <source media="(prefers-color-scheme: dark)" srcset="https://cdn.posit.co/platform/containers/logos/logo_workbenchtag-reverse.svg">
  <source media="(prefers-color-scheme: light)" srcset="https://cdn.posit.co/platform/containers/logos/logo_workbenchtag-fullcolor.svg">
  <img alt="Posit Package Manager Logo" src="https://cdn.posit.co/platform/containers/logos/logo_workbenchtag-fullcolor.svg">
</picture>
</a>

# Posit Workbench Positron Init container image

This container image is an init container for [Posit Workbench](https://docs.posit.co/ide/server-pro/) Kubernetes deployments that copies Positron IDE components into a shared volume for session containers to consume. The image decouples the Positron IDE server from the Workbench session image, which enables out-of-band Positron version upgrades without waiting for a full Workbench release.

[![GitHub Repository](https://img.shields.io/badge/github-repo?logo=github&color=grey)](https://github.com/posit-dev/images-workbench)
[![GitHub Workflow Status](https://img.shields.io/github/actions/workflow/status/posit-dev/images-workbench/session.yml?branch=main)](https://github.com/posit-dev/images-workbench/actions/workflows/session.yml)
[![Latest Version](https://img.shields.io/docker/v/posit/workbench-positron-init?sort=semver&label=latest)](https://hub.docker.com/r/posit/workbench-positron-init/tags)
![Docker Hub Pulls](https://img.shields.io/docker/pulls/posit/workbench-positron-init)
![Docker Image Size](https://img.shields.io/docker/image-size/posit/workbench-positron-init/latest)

> [!NOTE]
> These images are in preview as Posit migrates container images from <a href="https://github.com/rstudio/rstudio-docker-products">rstudio/rstudio-docker-products</a>. The <a href="https://github.com/rstudio/rstudio-docker-products">rstudio-docker-products</a> images remain supported.

## Quick reference

| |                                                                                                                                                                                                                                                                                                           |
|---|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| **Maintained by** | [the Posit Docker team](https://github.com/posit-dev/images)                                                                                                                                                                                                                                              |
| **Where to get help** | [GitHub Issues](https://github.com/posit-dev/images-workbench/issues), [Images Discussion Board](https://github.com/posit-dev/images/discussions), [the Posit Community Forum](https://forum.posit.co/c/posit-professional-hosted/posit-workbench/69), [Posit Support](https://support.posit.co/hc/en-us) |
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

Mount a shared volume at `/mnt/init` and set `PWB_POSITRON_TARGET` to select which components to copy. The session container then mounts the same volume to consume the components.

```yaml
initContainers:
  - name: positron-init
    image: ghcr.io/posit-dev/workbench-positron-init:2026.03.0-212
    env:
      - name: PWB_POSITRON_TARGET
        value: positron
    volumeMounts:
      - name: positron-components
        mountPath: /mnt/init

containers:
  - name: session
    image: your-custom-session-image
    volumeMounts:
      - name: positron-components
        mountPath: /mnt/init

volumes:
  - name: positron-components
    emptyDir: {}
```

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

Posit publishes multi-arch images for both `linux/amd64` and `linux/arm64`. Pull the same tag from either platform; Docker selects the matching manifest automatically.

## Components

The init container provides the following components in `/opt/positron`:

| Component | Path | Description |
|-----------|------|-------------|
| Positron IDE | `bin/positron-server/bundled/` | Positron server (VS Code REH web) |
| Positron docs | `docs/positron/bundled/` | Positron Workbench documentation |
| Session init binary | `/usr/local/bin/positron-session-init` | Go entrypoint that copies components at runtime |

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

## Migrating from rstudio/workbench-positron-init

This image replaces the legacy [`rstudio/workbench-positron-init`](https://hub.docker.com/r/rstudio/workbench-positron-init) image. The init container behavior is unchanged — the entrypoint copies Positron components into a shared volume at `/mnt/init` based on the `PWB_POSITRON_TARGET` environment variable. The differences are in how the image is published.

### Image references

The legacy image was published as `rstudio/workbench-positron-init` on Docker Hub and `ghcr.io/rstudio/workbench-positron-init` on GHCR, tagged by OS (`jammy`, `ubuntu2204`, `jammy-<version>`, `ubuntu2204-<version>`) for `linux/amd64` only. Update your image reference to one of the new locations and pick a tag that pins to your desired Positron version. See [Image tags](#image-tags) and [Architectures](#architectures).

### Base OS options

The legacy image shipped Ubuntu 22.04 only. This image ships Ubuntu 24.04. See [Image tags](#image-tags).

### What did not change

- Source path for Positron components (`/opt/positron`)
- Target path on the shared volume (`/mnt/init`)
- `PWB_POSITRON_TARGET` environment variable selects which components to copy
- Entrypoint behavior (one-shot copy, then exit)

## Caveats

### Security

Review these images before using them in production. Organizations with specific Common Vulnerabilities and Exposures (CVE) or vulnerability requirements should rebuild these images to meet their security standards.

Posit rebuilds published images for Posit product editions under active support weekly to pull in operating system patches.

## Documentation

- [Posit Workbench Documentation](https://docs.posit.co/ide/server-pro/)
- [Kubernetes Integration Guide](https://docs.posit.co/ide/server-pro/integration/kubernetes.html)
