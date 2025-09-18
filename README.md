# Posit Workbench Container Images

Container images for [Posit Workbench](https://docs.posit.co/ide/server-pro).

## Images

| Image | Docker Hub | GitHub Container Registry |
|:------|:-----------|:--------------------------|
| [workbench](./workbench/) | [`docker.io/posit/workbench`](https://hub.docker.com/repository/docker/posit/workbench/tags) | [`ghcr.io/posit-dev/workbench`](https://github.com/posit-dev/images-workbench/pkgs/container/workbench) |
| [workbench-session-init](./workbench-session-init/) | [`docker.io/posit/workbench-session-init`](https://hub.docker.com/repository/docker/posit/workbench-session-init/tags) | [`ghcr.io/posit-dev/workbench-session-init`](https://github.com/posit-dev/images-workbench/pkgs/container/workbench-session-init) |

Additional Posit container images are published to [Docker Hub](https://hub.docker.com/u/posit) and [GitHub Container Registry](https://github.com/orgs/posit-dev/packages).

## Getting Started

You can interact with this repository in multiple ways:

* [Build container images directly](#build) from the Containerfile.
* [Use the `bakery` CLI](#using-bakery) to manage and build container images.
* Extend the functionality by using the Minimal base image (see [examples](/posit-dev/images-examples)).

## Build

You can build OCI container images from the defitions in this repository using one of the following container build tools:

* [buildah](https://github.com/containers/buildah/blob/main/install.md)
* [docker buildx](https://github.com/docker/buildx#installing)

The root of the bakery project is used as the build context for each Containerfile.
Here, the `bakery.yaml` file, or project, is in the root of this repository.

```shell
PWB_VERSION="2025.05"

# Build the standard Workbench image using docker
docker buildx build \
    --tag workbench:${PWB_VERSION} \
    --file workbench/${PWB_VERSION}/Containerfile.ubuntu2204.std \
    .

# Build the minimal Workbench image using buildah
buildah build \
    --tag workbench:${PWB_VERSION} \
    --file workbench/${PWB_VERSION}/Containerfile.ubuntu2204.min \
    .
```

## Using `bakery`

The structure and contents of this reposity were created following the steps in [bakery usage](/posit-dev/images-shared/tree/main/posit-bakery#usage).

### Prerequisites

Build prerequisites

* [python](https://docs.astral.sh/uv/guides/install-python/)
* [pipx](https://pipx.pypa.io/stable/installation/)
* [docker buildx bake](https://github.com/docker/buildx#installing)
* [just](https://just.systems/man/en/prerequisites.html)
* [gh](https://github.com/cli/cli#installation) (required while repositories are private)
* `bakery`

    ```shell
    just install bakery
    ```

* `goss` and `dgoss` for running image validation tests

    ```shell
    just install-goss
    ```

### Build with `bakery`

By default, bakery creates a ephemeral JSON [bakefile](https://docs.bakefile.org/en/latest/language.html) to render all containers in parallel.

```shell
bakery build
```

You can view the bake plan using `bakery build --plan`.

You can use CLI flags to build only a subset of images in the project.

### Test images

After building the container images, run the test suite for all images:

```shell
bakery run dgoss
```

You can use CLI flags to limit the tests to run against a subset of images.

## Issues

If you encounter any issues or have any questions, please [open an issue](/posit-dev/images-workbench/issues). We appreciate your feedback.

## Code of Conduct

We expect all contributors to adhere to the project's [Code of Conduct](CODE_OF_CONDUCT.md) and create a positive and inclusive community.

## License

Posit Container Images and associated tooling are licensed under the [MIT License](LICENSE.md)
