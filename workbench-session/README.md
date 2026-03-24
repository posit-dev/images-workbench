# Posit Workbench Session Container Images

These container images provide the session runtime environments for [Posit Workbench](https://docs.posit.co/ide/server-pro/) in Kubernetes deployments. Each image includes a specific combination of R and Python for running interactive sessions (RStudio IDE, VS Code, Jupyter, Positron).

> [!NOTE]
> These images are in preview as Posit migrates container images from [rstudio/rstudio-docker-products](https://github.com/rstudio/rstudio-docker-products). The existing images remain supported.

## Overview

When Posit Workbench runs on Kubernetes with the Job Launcher, user sessions execute inside session containers. Each session image provides a specific R and Python version pair.

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
