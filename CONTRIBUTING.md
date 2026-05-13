# Contributing to Posit Workbench container images

This guide covers how to build and test the Workbench container images with the `bakery` CLI. To build images directly with Docker, Buildah, or Podman, see the [README](README.md#build). To deploy or run pre-built images, see the [running the images](README.md#running-the-images) section.

## Using `bakery`

This repository follows the structure described in [bakery usage](https://github.com/posit-dev/images-shared/tree/main/posit-bakery#usage).

Additional documentation:
- [Configuration reference](https://github.com/posit-dev/images-shared/blob/main/posit-bakery/CONFIGURATION.md): `bakery.yaml` schema and options
- [Templating reference](https://github.com/posit-dev/images-shared/blob/main/posit-bakery/TEMPLATING.md): Jinja2 macros for Containerfile templates
- [CI workflows](https://github.com/posit-dev/images-shared/blob/main/CI.md): Shared GitHub Actions workflows for building and pushing images

The [`bakery.yaml`](https://github.com/posit-dev/images-shared/blob/main/posit-bakery/CONFIGURATION.md#bakery-configuration) file, or project, is in the root of this repository.

### Prerequisites

Build prerequisites:

* [python](https://docs.astral.sh/uv/guides/install-python/)
* [uv](https://docs.astral.sh/uv/getting-started/installation/)
* [docker buildx bake](https://github.com/docker/buildx#installing)
* [just](https://just.systems/man/en/prerequisites.html)
* [gh](https://github.com/cli/cli#installation) (required while repositories are private)
* `bakery`

    ```shell
    just install-bakery
    ```

* `goss` and `dgoss` for running image validation tests

    ```shell
    just install-goss
    ```

* [`pre-commit`](https://pre-commit.com/) hooks (for contributors)

    ```shell
    just setup
    ```

### Build with `bakery`

By default, bakery creates an ephemeral JSON [bakefile](https://docs.bakefile.org/en/latest/language.html) to render all containers in parallel.

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
