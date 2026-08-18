<a href="https://posit.co/products/enterprise/workbench">
<picture>
  <source media="(prefers-color-scheme: dark)" srcset="https://cdn.posit.co/platform/containers/logos/logo_workbenchtag-reverse.svg">
  <source media="(prefers-color-scheme: light)" srcset="https://cdn.posit.co/platform/containers/logos/logo_workbenchtag-fullcolor.svg">
  <img alt="Posit Workbench Logo" src="https://cdn.posit.co/platform/containers/logos/logo_workbenchtag-fullcolor.svg">
</picture>
</a>

# Posit Workbench Session Init container image

This container image is an init container for Workbench. It stages the Workbench session runtime components under `/opt/session-components` for use by another container. Use this image to share components with a session container through a Kubernetes volume, or to copy them into a custom session image at build time.

[![GitHub Repository](https://img.shields.io/badge/github-repo?logo=github&color=grey)](https://github.com/posit-dev/images-workbench)
[![GitHub Workflow Status](https://img.shields.io/github/actions/workflow/status/posit-dev/images-workbench/production.yml?branch=main)](https://github.com/posit-dev/images-workbench/actions/workflows/production.yml)
[![Latest Version](https://img.shields.io/docker/v/posit/workbench-session-init?sort=semver&label=latest)](https://hub.docker.com/r/posit/workbench-session-init/tags)
![Docker Hub Pulls](https://img.shields.io/docker/pulls/posit/workbench-session-init)
![Docker Image Size](https://img.shields.io/docker/image-size/posit/workbench-session-init/latest)

> [!TIP]
> Deploying on Kubernetes? Try the <a href="https://docs.posit.co/helm/charts/rstudio-workbench/README.html">Posit Workbench Helm chart</a>, which can configure Workbench to launch sessions with this image.

## Quick reference

| | |
|---|---|
| **Maintained by** | [the Posit Docker team](https://github.com/posit-dev/images) |
| **Where to get help** | [GitHub Issues](https://github.com/posit-dev/images-workbench/issues), [Images Discussion Board](https://github.com/posit-dev/images/discussions), [the Posit Community Forum](https://forum.posit.co/c/posit-professional-hosted), [Posit Support](https://support.posit.co/hc/en-us) |
| **Where to file issues** | [https://github.com/posit-dev/images-workbench/issues](https://github.com/posit-dev/images-workbench/issues) |
| **Source** | [https://github.com/posit-dev/images-workbench](https://github.com/posit-dev/images-workbench) |
| **License** | [MIT](https://github.com/posit-dev/images-workbench/blob/main/LICENSE.md) |
| **Product documentation** | [Posit Workbench documentation](https://docs.posit.co/ide/server-pro/), [Job Launcher overview](https://docs.posit.co/ide/server-pro/admin/job_launcher/job_launcher.html), [Kubernetes integration guide](https://docs.posit.co/ide/server-pro/integration/kubernetes.html)                               |

## Related images

For Kubernetes deployments, Workbench uses these images together. See the [repository README](https://github.com/posit-dev/images-workbench#deploying-on-kubernetes) for Helm configuration.

| Image | Description | Docker Hub | GHCR |
|:------|:------------|:-----------|:-----|
| `workbench` | The Posit Workbench server | [posit/workbench](https://hub.docker.com/r/posit/workbench) | [posit-dev/workbench](https://github.com/posit-dev/images-workbench/pkgs/container/workbench) |
| `workbench-session` | Session images for Kubernetes (R and Python version matrix) | [posit/workbench-session](https://hub.docker.com/r/posit/workbench-session) | [posit-dev/workbench-session](https://github.com/posit-dev/images-workbench/pkgs/container/workbench-session) |
| `workbench-positron-init` | Init container providing Positron Pro components | [posit/workbench-positron-init](https://hub.docker.com/r/posit/workbench-positron-init) | [posit-dev/workbench-positron-init](https://github.com/posit-dev/images-workbench/pkgs/container/workbench-positron-init) |

## How to use this image

### With the Workbench Helm chart

The [Workbench Helm chart](https://docs.posit.co/helm/charts/rstudio-workbench/README.html) by default configures Workbench to use a `workbench-session-init` image to bootstrap a `workbench-session` image. Configure the images as shown below.

> [!NOTE]
> The `workbench-session-init` version should always match the `workbench` server version. See [Version compatibility](#version-compatibility).

```yaml
session:
  image:
    repository: "ghcr.io/posit-dev/workbench-session"
    tag: "latest"

components:
  sessionInit:
    image:
      repository: "ghcr.io/posit-dev/workbench-session-init"
```

See the [repository README](https://github.com/posit-dev/images-workbench#deploying-on-kubernetes) for a full chart example.

## Image tags

Posit publishes images to:
- Docker Hub: `docker.io/posit/workbench-session-init`
- GitHub Container Registry: `ghcr.io/posit-dev/workbench-session-init`

Ubuntu 24.04 is the only OS.

Tag formats where `YYYY.MM.P` is any supported Workbench version:
- `YYYY.MM.P` - Default OS
- `YYYY.MM.P-ubuntu-24.04` - Explicit OS
- `latest` - Latest version, default OS

## Architectures

Posit publishes `workbench-session-init` images for `linux/amd64` only. `linux/arm64` builds remain in developer preview until Workbench supports ARM in production.

## Environment variables

The init container does not consume any environment variables at runtime.

## Volumes

The init container stages the Workbench session components at `/opt/session-components` in the image. Mount a shared volume at the same path to expose them to a session container.

| Mount point             | Description                                  |
|-------------------------|----------------------------------------------|
| `/opt/session-components` | Workbench session runtime components       |

The session container mounts the same volume at `/opt/session-components` to consume the runtime components at the path Workbench expects.

## User

The container starts as `root` so the session container can read the session components from the shared volume.

## Examples

### Building a custom session image

You can pull the session components into a custom session image at build time using a multi-stage build:

```dockerfile
FROM ghcr.io/posit-dev/workbench-session-init:2026.08.1 AS session-init

FROM your-custom-base
COPY --from=session-init /opt/session-components /opt/session-components
```

The resulting image bundles the session components directly, so it can run Workbench sessions without an init container at runtime.

See the [session-init extending example](https://github.com/posit-dev/images-examples/tree/main/extending/workbench/session-init) for a complete example of this pattern.

## Migrating from legacy image

This image replaces the legacy [`rstudio/workbench-session-init`](https://hub.docker.com/r/rstudio/workbench-session-init) image. The runtime contents are unchanged. The image still ships the Workbench session components at `/opt/session-components` for a session container to consume. The differences are in how the image is published.

### Image references

Posit published the legacy image as `rstudio/workbench-session-init` on Docker Hub and `ghcr.io/rstudio/workbench-session-init` on GHCR, tagged by OS (`jammy`, `ubuntu2204`, `jammy-<version>`, `ubuntu2204-<version>`) for `linux/amd64` only. Update your image reference to one of the new locations and pick a tag that pins to your desired Workbench version. See [Image tags](#image-tags) and [Architectures](#architectures).

### Base OS options

The legacy image shipped Ubuntu 22.04 only. This image ships Ubuntu 24.04 only. See [Image tags](#image-tags).

### What did not change

- Source path for the session runtime components (`/opt/session-components`)
- Compatibility with the Workbench server and session containers

## Caveats

### Security

Review these images before using them in production. Organizations with specific Common Vulnerabilities and Exposures (CVE) or vulnerability requirements can rebuild these images to meet their security standards.

Posit rebuilds these images weekly for Posit product editions under active support, pulling in operating system patches.

### Version compatibility

The `workbench-session-init` image version must match the Workbench server version. Mismatched versions can cause session startup failures or unexpected behavior.
