# Posit Workbench Session Init Container Image

This init container image provides the session runtime components for [Posit Workbench](https://docs.posit.co/ide/server-pro/). It can be used to pull the session runtime components into another base session image, which can then be used to run Workbench sessions in Kubernetes environments.

> [!NOTE]
> These images are in preview as Posit migrates container images from [rstudio/rstudio-docker-products](https://github.com/rstudio/rstudio-docker-products). The existing images remain supported.

## Overview

The `workbench-session-init` container copies session runtime components to a shared volume, which is then mounted into the session container. It is used as a Kubernetes init container alongside `posit/workbench` and `posit/workbench-session`, or with custom session images extended with Workbench session components.

| Image | Description | Docker Hub | GHCR |
|:------|:------------|:-----------|:-----|
| `workbench` | The Posit Workbench server | [posit/workbench](https://hub.docker.com/r/posit/workbench) | [posit-dev/workbench](https://github.com/posit-dev/images-workbench/pkgs/container/workbench) |
| `workbench-session` | Session images for Kubernetes (R and Python version matrix) | [posit/workbench-session](https://hub.docker.com/r/posit/workbench-session) | [posit-dev/workbench-session](https://github.com/posit-dev/images-workbench/pkgs/container/workbench-session) |
| `workbench-session-init` | Init container providing session runtime components | [posit/workbench-session-init](https://hub.docker.com/r/posit/workbench-session-init) | [posit-dev/workbench-session-init](https://github.com/posit-dev/images-workbench/pkgs/container/workbench-session-init) |
| `workbench-positron-init` | Init container providing Positron IDE components | [posit/workbench-positron-init](https://hub.docker.com/r/posit/workbench-positron-init) | [posit-dev/workbench-positron-init](https://github.com/posit-dev/images-workbench/pkgs/container/workbench-positron-init) |

See the [repository README](https://github.com/posit-dev/images-workbench#deploying-on-kubernetes) for Helm configuration.

## Quick Start

Use as an init container in your Kubernetes pod specification:

```yaml
initContainers:
  - name: session-init
    image: ghcr.io/posit-dev/workbench-session-init:2026.01.1-ubuntu-24.04
    volumeMounts:
      - name: session-components
        mountPath: /opt/session-components

containers:
  - name: session
    image: your-custom-session-image
    volumeMounts:
      - name: session-components
        mountPath: /opt/session-components

volumes:
  - name: session-components
    emptyDir: {}
```

## Image Tags

Images are published to:

- Docker Hub: `docker.io/posit/workbench-session-init`
- GitHub Container Registry: `ghcr.io/posit-dev/workbench-session-init`

Tag formats:

- `2026.01.1` - Full version (Ubuntu 24.04)
- `2026.01.1-ubuntu-24.04` - Explicit OS
- `2026.01.1-ubuntu-22.04` - Ubuntu 22.04
- `latest` - Latest stable release (Ubuntu 24.04)

## Session Components

The init container provides the following components in `/opt/session-components`:

| Component | Description |
|-----------|-------------|
| `rsession` | RStudio IDE session binary |
| `rserver` | RStudio server components |
| Jupyter integration | Components for Jupyter notebook/lab sessions |
| VS Code integration | Components for VS Code sessions |

## Volume Mounts

| Mount Point | Description |
|-------------|-------------|
| `/opt/session-components` | Session runtime components (output) |

## Differences from rstudio/workbench-session-init

This image differs from the legacy [`rstudio/workbench-session-init`](https://hub.docker.com/r/rstudio/workbench-session-init) image:

| Aspect           | This Image                          | rstudio/workbench-session-init |
|------------------|-------------------------------------|--------------------------------|
| Registry         | `posit/workbench-session-init`      | `rstudio/workbench-session-init` |
| Base OS options  | Ubuntu 24.04, Ubuntu 22.04          | Ubuntu 22.04                   |

## Caveats

### Security

These images should be reviewed before production use. Organizations with specific CVE or vulnerability requirements should rebuild these images to meet their security standards.

Published images for Posit Product editions under active support are re-built on a weekly basis to pull in operating system patches.

### Version Compatibility

The `workbench-session-init` image version must match the Posit Workbench server version. Using mismatched versions may cause session startup failures or unexpected behavior.

## Documentation

- [Posit Workbench Documentation](https://docs.posit.co/ide/server-pro/)
- [Kubernetes Integration Guide](https://docs.posit.co/ide/server-pro/integration/kubernetes.html)
- [Session Components Documentation](https://docs.posit.co/ide/server-pro/job_launcher/kubernetes_plugin.html)
