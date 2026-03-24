# Posit Workbench Positron Init Container Image

This init container image provides the Positron IDE components for [Posit Workbench](https://docs.posit.co/ide/server-pro/) Kubernetes deployments. It bundles the Positron IDE server, documentation, and a session-init binary that copies selected components into a shared volume at runtime.

> [!NOTE]
> These images are in preview as Posit migrates container images from [rstudio/rstudio-docker-products](https://github.com/rstudio/rstudio-docker-products). The existing images remain supported.

## Overview

This image is intended to be used as an init container in conjunction with:

- [Posit Workbench](https://hub.docker.com/r/posit/workbench) - The main Workbench server
- Custom session images - Your own images extended with Positron IDE components

The init container copies Positron components to a shared volume, which is then mounted into the session container.

## Quick Start

Use as an init container in your Kubernetes pod specification:

```yaml
initContainers:
  - name: positron-init
    image: posit/workbench-positron-init:2026.03.0-212
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

## Image Tags

Images are published to:

- Docker Hub: `docker.io/posit/workbench-positron-init`
- GitHub Container Registry: `ghcr.io/posit-dev/workbench-positron-init`

Tag formats:

- `2026.03.0-212` - Full version (Ubuntu 24.04)
- `2026.03.0-212-ubuntu-24.04` - Explicit OS
- `latest` - Latest stable release (Ubuntu 24.04)

## Components

The init container provides the following components in `/opt/positron`:

| Component | Path | Description |
|-----------|------|-------------|
| Positron IDE | `bin/positron-server/bundled/` | Positron server (VS Code REH web) |
| Positron docs | `docs/positron/bundled/` | Positron Workbench documentation |
| Session init binary | `/usr/local/bin/positron-session-init` | Go entrypoint that copies components at runtime |

## Environment Variables

| Variable | Description | Values |
|----------|-------------|--------|
| `PWB_POSITRON_TARGET` | Selects which components to copy to `/mnt/init` | `positron`, `positron-docs` |

### Copy Targets

- `positron` — copies `bin/positron-server` to `/mnt/init/bin/positron-server`
- `positron-docs` — copies `docs/positron` to `/mnt/init/docs/positron`

## Volume Mounts

| Mount Point | Description |
|-------------|-------------|
| `/mnt/init` | Target directory for copied components (output) |

## Caveats

### Security

These images should be reviewed before production use. Organizations with specific CVE or vulnerability requirements should rebuild these images to meet their security standards.

Published images for Posit Product editions under active support are re-built on a weekly basis to pull in operating system patches.

## Documentation

- [Posit Workbench Documentation](https://docs.posit.co/ide/server-pro/)
- [Kubernetes Integration Guide](https://docs.posit.co/ide/server-pro/integration/kubernetes.html)
