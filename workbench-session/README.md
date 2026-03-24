# Posit Workbench Session Container Images

These container images provide the session runtime environments for [Posit Workbench](https://docs.posit.co/ide/server-pro/) in Kubernetes deployments. Each image includes a specific combination of R and Python for running interactive sessions (RStudio IDE, VS Code, Jupyter, Positron).

> [!NOTE]
> These images are in preview as Posit migrates container images from [rstudio/rstudio-docker-products](https://github.com/rstudio/rstudio-docker-products). The existing images remain supported.

## Overview

When [Posit Workbench](https://docs.posit.co/ide/server-pro/) runs on Kubernetes with the Job Launcher, user sessions execute inside session containers. Each `workbench-session` image provides a specific R and Python version pair.

| Image | Description | Docker Hub | GHCR |
|:------|:------------|:-----------|:-----|
| `workbench` | The Posit Workbench server | [posit/workbench](https://hub.docker.com/r/posit/workbench) | [posit-dev/workbench](https://github.com/posit-dev/images-workbench/pkgs/container/workbench) |
| `workbench-session` | Session images for Kubernetes | [posit/workbench-session](https://hub.docker.com/r/posit/workbench-session) | [posit-dev/workbench-session](https://github.com/posit-dev/images-workbench/pkgs/container/workbench-session) |
| `workbench-session-init` | Init container providing session runtime components | [posit/workbench-session-init](https://hub.docker.com/r/posit/workbench-session-init) | [posit-dev/workbench-session-init](https://github.com/posit-dev/images-workbench/pkgs/container/workbench-session-init) |
| `workbench-positron-init` | Init container providing Positron IDE components | [posit/workbench-positron-init](https://hub.docker.com/r/posit/workbench-positron-init) | [posit-dev/workbench-positron-init](https://github.com/posit-dev/images-workbench/pkgs/container/workbench-positron-init) |

See the [repository README](https://github.com/posit-dev/images-workbench#deploying-on-kubernetes) for Helm configuration.

## Image Tags

Images are published to:
- Docker Hub: `docker.io/posit/workbench-session`
- GitHub Container Registry: `ghcr.io/posit-dev/workbench-session`

Tag format: `R{r_version}-python{python_version}-{os}`

Examples:
- `R4.5.2-python3.14.3-ubuntu-24.04` — R 4.5.2, Python 3.14.3, Ubuntu 24.04

## Usage

These images are not run directly. They are configured as session images in the Posit Workbench Helm chart. See the [repository README](../README.md#deploying-on-kubernetes) for Helm configuration details.

## Installed Software

Each image includes:

| Component | Path |
|-----------|------|
| R | `/opt/R/{version}/bin/R` |
| Python | `/opt/python/{version}/bin/python3` |

## Documentation

- [Posit Workbench Documentation](https://docs.posit.co/ide/server-pro/)
- [Kubernetes Integration Guide](https://docs.posit.co/ide/server-pro/integration/kubernetes.html)
- [Posit Workbench Helm Chart](https://docs.posit.co/helm/charts/rstudio-workbench/README.html)
