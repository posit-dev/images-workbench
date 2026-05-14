<a href="https://posit.co/products/enterprise/workbench">
<picture>
  <source media="(prefers-color-scheme: dark)" srcset="https://cdn.posit.co/platform/containers/logos/logo_workbenchtag-reverse.svg">
  <source media="(prefers-color-scheme: light)" srcset="https://cdn.posit.co/platform/containers/logos/logo_workbenchtag-fullcolor.svg">
  <img alt="Posit Workbench Logo" src="https://cdn.posit.co/platform/containers/logos/logo_workbenchtag-fullcolor.svg">
</picture>
</a>

# Posit Workbench container images

Container images for [Workbench](https://docs.posit.co/ide/server-pro).

[![Production CI Build Status](https://github.com/posit-dev/images-workbench/actions/workflows/production.yml/badge.svg?branch=main)](https://github.com/posit-dev/images-workbench/actions/workflows/production.yml)
[![Development CI Build Status](https://github.com/posit-dev/images-workbench/actions/workflows/development.yml/badge.svg?branch=main)](https://github.com/posit-dev/images-workbench/actions/workflows/development.yml)
[![Session Image CI Build Status](https://github.com/posit-dev/images-workbench/actions/workflows/session.yml/badge.svg?branch=main)](https://github.com/posit-dev/images-workbench/actions/workflows/session.yml)
[![Latest Version](https://img.shields.io/docker/v/posit/workbench?sort=semver&label=latest)](https://hub.docker.com/r/posit/workbench/tags)

## Prerequisites

| Tool | Required for | Install                                                                                                                         |
|------|-------------|---------------------------------------------------------------------------------------------------------------------------------|
| [Docker](https://docs.docker.com/get-docker/) | Running containers locally | [Get Docker](https://docs.docker.com/get-docker/)                                                                               |
| [Helm](https://helm.sh/docs/intro/install/) | Deploying on Kubernetes | [Install Helm](https://helm.sh/docs/intro/install/)                                                                             |
| [kubectl](https://kubernetes.io/docs/tasks/tools/) | Deploying on Kubernetes | [Install kubectl](https://kubernetes.io/docs/tasks/tools/)                                                                      |
| Product license | Running Workbench | [Licensing FAQ](https://docs.posit.co/licensing/licensing-faq.html), [Request a trial license](https://posit.co/trial-license/) |

## Images

| Image | Docker Hub | GitHub Container Registry |
|:------|:-----------|:--------------------------|
| [workbench](./workbench/) | [`docker.io/posit/workbench`](https://hub.docker.com/r/posit/workbench) | [`ghcr.io/posit-dev/workbench`](https://github.com/posit-dev/images-workbench/pkgs/container/workbench) |
| [workbench-session](./workbench-session/) | [`docker.io/posit/workbench-session`](https://hub.docker.com/r/posit/workbench-session) | [`ghcr.io/posit-dev/workbench-session`](https://github.com/posit-dev/images-workbench/pkgs/container/workbench-session) |
| [workbench-session-init](./workbench-session-init/) | [`docker.io/posit/workbench-session-init`](https://hub.docker.com/r/posit/workbench-session-init) | [`ghcr.io/posit-dev/workbench-session-init`](https://github.com/posit-dev/images-workbench/pkgs/container/workbench-session-init) |
| [workbench-positron-init](./workbench-positron-init/) | [`docker.io/posit/workbench-positron-init`](https://hub.docker.com/r/posit/workbench-positron-init) | [`ghcr.io/posit-dev/workbench-positron-init`](https://github.com/posit-dev/images-workbench/pkgs/container/workbench-positron-init) |

Posit publishes additional container images to [Docker Hub](https://hub.docker.com/u/posit) and [GitHub Container Registry](https://github.com/orgs/posit-dev/packages).

## Running the images

The fastest way to get started is to pull and run a pre-built image. See each image's documentation for Quick Start examples, configuration, and environment variables.

- [Workbench](./workbench/): the Workbench server
- [Workbench Session](./workbench-session/): session images for Kubernetes
- [Workbench Session Init](./workbench-session-init/): init container for Kubernetes session deployments
- [Workbench Positron Init](./workbench-positron-init/): init container for Positron IDE in Kubernetes

See the [Workbench installation guide](https://docs.posit.co/ide/server-pro/getting_started/installation/) for full setup instructions.

## Deploying on Kubernetes

Use the [Posit Workbench Helm chart](https://docs.posit.co/helm/charts/rstudio-workbench/README.html) to deploy on Kubernetes. These images are the default in chart versions `>= 0.20.0`; see the [image migration guide](https://docs.posit.co/helm/docs/migrating-to-posit-images.html) if you are upgrading from an earlier chart version.

## Build

You can build Open Container Initiative (OCI) container images from the definitions in this repository using one of the following container build tools:

* [docker buildx](https://github.com/docker/buildx#installing)
* [buildah](https://github.com/containers/buildah/blob/main/install.md)
* [podman](https://podman.io/docs/installation)

Each Containerfile uses the root of the repository as the build context.

```shell
PWB_VERSION="2026.04"

# Build the standard Workbench image using docker
docker buildx build \
    --tag workbench:${PWB_VERSION} \
    --file workbench/${PWB_VERSION}/Containerfile.ubuntu2404.std \
    .

# Build the minimal Workbench image using buildah
buildah build \
    --tag workbench:${PWB_VERSION} \
    --file workbench/${PWB_VERSION}/Containerfile.ubuntu2404.min \
    .

# Build the minimal Workbench image using podman
podman build \
    --tag workbench:${PWB_VERSION} \
    --file workbench/${PWB_VERSION}/Containerfile.ubuntu2404.min \
    .
```

## Contributing

To build images with `bakery` or run the test suite, see the [contributing guide](CONTRIBUTING.md).

## Related repositories

This repository is part of the [Posit Container Images](https://github.com/posit-dev/images) ecosystem. To extend the Minimal image with additional languages or system dependencies, see the [extending examples](https://github.com/posit-dev/images-examples/tree/main/extending). For shared build tooling and CI workflows, see [images-shared](https://github.com/posit-dev/images-shared).

## Share your feedback

We invite you to join us on [GitHub Discussions](https://github.com/posit-dev/images/discussions) to ask questions and share feedback.

## Issues

If you encounter any issues or have any questions, please [open an issue](https://github.com/posit-dev/images-workbench/issues). We appreciate your feedback.

## Code of Conduct

We expect all contributors to adhere to the project's [Code of Conduct](CODE_OF_CONDUCT.md) and create a positive and inclusive community.

## License

Posit licenses these container images and associated tooling under the [MIT License](LICENSE.md).
