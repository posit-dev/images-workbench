<a href="https://posit.co/products/enterprise/workbench">
<picture>
  <source media="(prefers-color-scheme: dark)" srcset="https://cdn.posit.co/platform/containers/logos/logo_workbenchtag-reverse.svg">
  <source media="(prefers-color-scheme: light)" srcset="https://cdn.posit.co/platform/containers/logos/logo_workbenchtag-fullcolor.svg">
  <img alt="Posit Package Manager Logo" src="https://cdn.posit.co/platform/containers/logos/logo_workbenchtag-fullcolor.svg">
</picture>
</a>

# Posit Workbench Session container image

These container images provide the session runtime environments for [Posit Workbench](https://docs.posit.co/ide/server-pro/) in Kubernetes. Each image bundles a specific R and Python version pair, along with Jupyter, Quarto, and Posit Professional Drivers, so that user sessions run in an environment matching the user's language requirements.

[![GitHub Repository](https://img.shields.io/badge/github-repo?logo=github&color=grey)](https://github.com/posit-dev/images-workbench)
[![GitHub Workflow Status](https://img.shields.io/github/actions/workflow/status/posit-dev/images-workbench/session.yml?branch=main)](https://github.com/posit-dev/images-workbench/actions/workflows/session.yml)
![Docker Hub Pulls](https://img.shields.io/docker/pulls/posit/workbench-session)
<!-- 
TODO: uncomment after https://github.com/posit-dev/images-shared/pull/501 is merged
[![Latest Version](https://img.shields.io/docker/v/posit/workbench-session?sort=semver&label=latest)](https://hub.docker.com/r/posit/workbench-session/tags)
![Docker Image Size](https://img.shields.io/docker/image-size/posit/workbench-session/latest)
-->

> [!NOTE]
> These images are in preview as Posit migrates container images from [rstudio/rstudio-docker-products](https://github.com/rstudio/rstudio-docker-products). The previous `rstudio/workbench-session` and `rstudio/r-session-complete` images remain supported.

> [!TIP]
> Deploying on Kubernetes? Try the [Posit Workbench Helm chart](https://docs.posit.co/helm/charts/rstudio-workbench/README.html)!

## Quick reference

|                           |                                                                                                                                                                                                                                                                                                            |
|---------------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| **Maintained by**         | [the Posit Docker team](https://github.com/posit-dev/images)                                                                                                                                                                                                                                               |
| **Where to get help**     | [GitHub Issues](https://github.com/posit-dev/images-workbench/issues), [Images Discussion Board](https://github.com/posit-dev/images/discussions), [the Posit Community Forum](https://forum.posit.co/c/posit-professional-hosted/posit-workbench/69), [Posit Support](https://support.posit.co/hc/en-us)  |
| **Where to file issues**  | [https://github.com/posit-dev/images-workbench/issues](https://github.com/posit-dev/images-workbench/issues)                                                                                                                                                                                               |
| **Source**                | [https://github.com/posit-dev/images-workbench](https://github.com/posit-dev/images-workbench)                                                                                                                                                                                                             |
| **License**               | [MIT](https://github.com/posit-dev/images-workbench/blob/main/LICENSE.md)                                                                                                                                                                                                                                  |
| **Product documentation** | [Posit Workbench documentation](https://docs.posit.co/ide/server-pro/), [Job Launcher overview](https://docs.posit.co/ide/server-pro/admin/job_launcher/job_launcher.html), [Kubernetes integration guide](https://docs.posit.co/ide/server-pro/integration/kubernetes.html)                               |

## Related images

For Kubernetes deployments, Workbench uses several images together. See the [repository README](https://github.com/posit-dev/images-workbench#deploying-on-kubernetes) for Helm configuration.

| Image | Description | Docker Hub | GHCR |
|:------|:------------|:-----------|:-----|
| `workbench` | The Posit Workbench server | [posit/workbench](https://hub.docker.com/r/posit/workbench) | [posit-dev/workbench](https://github.com/posit-dev/images-workbench/pkgs/container/workbench) |
| `workbench-session-init` | Init container providing session runtime components | [posit/workbench-session-init](https://hub.docker.com/r/posit/workbench-session-init) | [posit-dev/workbench-session-init](https://github.com/posit-dev/images-workbench/pkgs/container/workbench-session-init) |
| `workbench-positron-init` | Init container providing Positron IDE components | [posit/workbench-positron-init](https://hub.docker.com/r/posit/workbench-positron-init) | [posit-dev/workbench-positron-init](https://github.com/posit-dev/images-workbench/pkgs/container/workbench-positron-init) |

## How to use this image

Do not run these images directly. The Workbench Job Launcher schedules them as session pods when users start sessions on Kubernetes. Each pod runs an interactive session — RStudio Pro, VS Code, Positron, or Jupyter — using the R and Python versions baked into the image. The `workbench-session-init` and `workbench-positron-init` init containers supply the session runtime components that the session image itself does not bundle.

Configure these images as session images for Workbench through any of the following methods:

1. **Helm chart values:** The `rstudio/rstudio-workbench` Helm chart includes a default set of session images. See the [repository README](https://github.com/posit-dev/images-workbench#deploying-on-kubernetes) for configuration details.
2. **Launcher configuration:** Define available session images in the Workbench Job Launcher configuration. See [Using Docker images with Posit Workbench, Launcher, and Kubernetes](https://support.posit.co/hc/en-us/articles/360019253393-Using-Docker-images-with-Posit-Workbench-Launcher-and-Kubernetes).

## Image tags

Posit publishes images to:
- Docker Hub: `docker.io/posit/workbench-session`
- GitHub Container Registry: `ghcr.io/posit-dev/workbench-session`

Ubuntu 24.04 is the default OS.

The tag format is: `R{r_version}-python{python_version}-{os}`

Examples:
- `R4.5.2-python3.14.3-ubuntu-24.04` — R 4.5.2, Python 3.14.3, Ubuntu 24.04
- `R4.4.3-python3.12.12-ubuntu-22.04` — R 4.4.3, Python 3.12.12, Ubuntu 22.04
- `R4.3.3-python3.11.15-ubuntu-24.04` — R 4.3.3, Python 3.11.15, Ubuntu 24.04

## Architectures

Posit publishes Ubuntu 24.04 session images for both `linux/amd64` and `linux/arm64`. Pull the same tag from either platform; Docker selects the matching manifest automatically. Ubuntu 22.04 session images are published for `linux/amd64` only.

## Installed software

Each image includes:

| Component                    | Path                                |
|------------------------------|-------------------------------------|
| R                            | `/opt/R/{version}/bin/R`            |
| Python                       | `/opt/python/{version}/bin/python3` |
| JupyterLab and Jupyter kernel | Installed under the bundled Python  |
| Quarto                       | `/opt/quarto/{version}/bin/quarto`  |
| TinyTeX                      | `/opt/TinyTeX/bin/`                 |
| Posit Professional Drivers   | `/opt/rstudio-drivers/`             |

These images do not bundle the Workbench session components themselves. The `workbench-session-init` init container provides those components at runtime through a shared volume.

## User

These images do not declare a `USER`. Containers start as `root`. The Workbench Job Launcher manages the runtime user when scheduling session pods, dropping privileges to the signed-in user as configured by the Workbench administrator.

## Examples

### Extending an image with additional R packages

Use any tag as a base for a derived image with additional dependencies. For example, an image with Tidyverse pre-installed:

```dockerfile
FROM ghcr.io/posit-dev/workbench-session:R4.5.2-python3.14.3-ubuntu-24.04

RUN /opt/R/4.5.2/bin/R -e 'install.packages("tidyverse", repos = "https://p3m.dev/cran/__linux__/noble/latest")'
```

See [extending examples](https://github.com/posit-dev/images-examples/tree/main/extending) for additional patterns.

## Migrating from legacy image

These images replace the legacy [`rstudio/workbench-session`](https://hub.docker.com/r/rstudio/workbench-session) and [`rstudio/r-session-complete`](https://hub.docker.com/r/rstudio/r-session-complete) images. The runtime tools are unchanged. R, Python, Jupyter, Quarto, and Posit Professional Drivers install at the same paths under `/opt`, and Workbench schedules sessions into these images the same way. The differences are in how Posit publishes and tags the images, and how session components are packaged.

### Image references

Posit published the legacy images as `rstudio/workbench-session` and `rstudio/r-session-complete` on Docker Hub and at the equivalent paths on GitHub Container Registry, with tags like `ubuntu2204-r{R1}_{R2}-py{Py1}_{Py2}` for `linux/amd64` only. Update your image references to one of the replacement locations and pick a tag that pins to your desired R, Python, and OS versions. See [Image tags](#image-tags) and [Architectures](#architectures).

### Tag format

Legacy `workbench-session` tags bundled two R versions and two Python versions per image, for example `ubuntu2204-r4.4.1_4.3.3-py3.12.6_3.11.10`. Replacement tags pin a single R and Python version per image and follow `R{r_version}-python{python_version}-{os}`, for example `R4.5.2-python3.14.3-ubuntu-24.04`. To cover the same set of R and Python combinations, configure Workbench to use multiple session images instead of one.

### Session components

The legacy `r-session-complete` image bundled the Workbench session components directly. The replacement `workbench-session` image does not. Instead, the `workbench-session-init` init container delivers session components into the session pod through a shared volume at runtime. When migrating from `r-session-complete`, configure the `workbench-session-init` init container alongside the session image. See the [`workbench-session-init` README](../workbench-session-init/README.md) for details.

The legacy `rstudio/workbench-session` image already followed this init container pattern, so this migration step does not apply when moving from `rstudio/workbench-session`.

### What did not change

- R, Python, Jupyter, Quarto, and Posit Professional Drivers installation paths under `/opt`.
- The role of these images as session execution environments managed by the Workbench Job Launcher.
- The system dependencies bundled to support popular R packages.

## Caveats

### Security

Review these images before using them in production. Organizations with specific Common Vulnerabilities and Exposures (CVE) or vulnerability requirements should rebuild these images to meet their security standards.

Posit rebuilds published images weekly for Posit product editions under active support to pull in operating system patches.

### Image dependency licenses

These images contain third-party software (R, Python, Jupyter, Quarto, TinyTeX, Posit Professional Drivers, system libraries, and their transitive dependencies) under various licenses. Image users are responsible for ensuring that use of these images and any of their dependent layers complies with all relevant licenses for the contained software.