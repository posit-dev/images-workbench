# Posit Workbench Container Image

This container image provides [Posit Workbench](https://docs.posit.co/ide/server-pro/) (PWB), an integrated development environment for data science teams that supports R, Python, and VS Code.

> [!NOTE]
> These images are in preview as Posit migrates container images from [rstudio/rstudio-docker-products](https://github.com/rstudio/rstudio-docker-products). The existing images remain supported.

## Related Images

For Kubernetes deployments, Workbench uses these images together. See the [repository README](https://github.com/posit-dev/images-workbench#deploying-on-kubernetes) for Helm configuration.

| Image | Description | Docker Hub | GHCR |
|:------|:------------|:-----------|:-----|
| `workbench-session` | Session images for Kubernetes (R and Python version matrix) | [posit/workbench-session](https://hub.docker.com/r/posit/workbench-session) | [posit-dev/workbench-session](https://github.com/posit-dev/images-workbench/pkgs/container/workbench-session) |
| `workbench-session-init` | Init container providing session runtime components | [posit/workbench-session-init](https://hub.docker.com/r/posit/workbench-session-init) | [posit-dev/workbench-session-init](https://github.com/posit-dev/images-workbench/pkgs/container/workbench-session-init) |
| `workbench-positron-init` | Init container providing Positron IDE components | [posit/workbench-positron-init](https://hub.docker.com/r/posit/workbench-positron-init) | [posit-dev/workbench-positron-init](https://github.com/posit-dev/images-workbench/pkgs/container/workbench-positron-init) |

## Quick Start

```bash
PWB_VERSION="2026.01.2"
PWB_IMAGE="ghcr.io/posit-dev/workbench"  # or docker.io/posit/workbench
PWB_LICENSE="/path/to/license.lic"
docker run -d \
  --name workbench \
  -p 8787:8787 \
  -e PWB_TESTUSER=posit \
  -e PWB_TESTUSER_PASSWD=posit \
  -v ${PWB_LICENSE}:/etc/rstudio-server/license.lic \
  ${PWB_IMAGE}:${PWB_VERSION}
```

Access Workbench at `http://localhost:8787`. Log in with username `posit` and password `posit`.

> [!NOTE]
> This example does not mount a data volume. Session data will not persist when the container stops. See [Volume Mounts](#volume-mounts) for persistent storage.

## Image Variants

Two variants are available:

| Variant | Description |
|---------|-------------|
| `std` (Standard) | Opinionated image, runs out of the box |
| `min` (Minimal) | Small image you can extend with desired dependencies, *will not run as is* |

See [extending examples](https://github.com/posit-dev/images-examples/tree/main/extending) for how to build on the Minimal image.

## Image Tags

Images are published to:
- Docker Hub: `docker.io/posit/workbench`
- GitHub Container Registry: `ghcr.io/posit-dev/workbench`

Ubuntu 24.04 is the default OS.

Tag formats:
- `2026.01.2` - Latest OS, standard variant
- `2026.01.2-ubuntu-24.04` - Explicit OS, standard variant
- `2026.01.2-ubuntu-24.04-std` - Explicit OS and variant
- `2026.01.2-ubuntu-24.04-min` - Minimal variant
- `latest` - Latest version, default OS, standard variant

## Configuration

### License Activation

A [product license](https://docs.posit.co/licensing/licensing-faq.html) is required. Posit recommends license file activation. Choose one method:

**Option 1: License File (Recommended)**
```bash
docker run -v /path/to/license.lic:/etc/rstudio-server/license.lic ...
```

**Option 2: License Key**
```bash
docker run -e PWB_LICENSE="your-license-key" ...
```

**Option 3: Floating License Server**
```bash
docker run -e PWB_LICENSE_SERVER="http://license-server:8989" ...
```

### Environment Variables

| Variable              | Description                                                         |
|-----------------------|---------------------------------------------------------------------|
| `PWB_LICENSE`         | License key for activation                                          |
| `PWB_LICENSE_SERVER`  | URL of floating license server                                      |
| `PWB_LAUNCHER`        | Enable the Job Launcher (default: `true`)                           |
| `PWB_LAUNCHER_TIMEOUT`| Launcher startup timeout in seconds (default: `10`)                 |
| `PWB_TESTUSER`        | Test user name. If empty, no test user is created.                  |
| `PWB_TESTUSER_PASSWD` | Test user password                                                  |
| `PWB_TESTUSER_UID`    | Test user UID (default: `10000` when `PWB_TESTUSER` is set)         |
| `STARTUP_DEBUG_MODE`  | Set to `1` for verbose startup logging                              |
| `DIAGNOSTIC_ENABLE`   | Enable diagnostic logging (default: `false`)                        |
| `DIAGNOSTIC_DIR`      | Directory for diagnostic logs (default: `/var/log/rstudio`)         |

#### Legacy Environment Variables

| Legacy Variable        | Preferred Equivalent   | Notes         |
|------------------------|------------------------|---------------|
| `RSW_LICENSE`          | `PWB_LICENSE`          | Same behavior |
| `RSW_LICENSE_SERVER`   | `PWB_LICENSE_SERVER`   | Same behavior |
| `RSW_LAUNCHER`         | `PWB_LAUNCHER`         | Same behavior |
| `RSW_LAUNCHER_TIMEOUT` | `PWB_LAUNCHER_TIMEOUT` | Same behavior |
| `RSW_TESTUSER`         | `PWB_TESTUSER`         | Same behavior |
| `RSW_TESTUSER_PASSWD`  | `PWB_TESTUSER_PASSWD`  | Same behavior |
| `RSW_TESTUSER_UID`     | `PWB_TESTUSER_UID`     | Same behavior |

**Note:** Legacy `RSW_` variables are supported but are planned for deprecation after 2025. For more details and updates, see the [Posit Workbench release notes](https://docs.posit.co/ide/server-pro/news/). For new deployments, always use the `PWB_` prefix to ensure forward compatibility.

### Volume Mounts

For persistent data, add these volume mounts to your `docker run` command:

```bash
-v /data/rstudio-server:/var/lib/rstudio-server \
-v /data/rstudio-server-config:/etc/rstudio
```

| Mount Point             | Description               |
|-------------------------|---------------------------|
| `/var/lib/rstudio-server` | Session data and database |
| `/etc/rstudio`          | Configuration files       |

### Custom Configuration

Mount custom configuration files:

```bash
docker run -v /path/to/rserver.conf:/etc/rstudio/rserver.conf ...
```

See the [configuration documentation](https://docs.posit.co/ide/server-pro/reference/rserver_conf.html) for available options.

## Exposed Ports

| Port | Description |
|------|-------------|
| 8787 | HTTP web interface |
| 5559 | Job Launcher |

## User

Runs as the `rstudio-server` user.

## Differences from rstudio/rstudio-workbench

This image differs from the legacy [`rstudio/rstudio-workbench`](https://hub.docker.com/r/rstudio/rstudio-workbench) image:

| Aspect           | This Image                             | rstudio/rstudio-workbench                                     |
|------------------|----------------------------------------|---------------------------------------------------------------|
| Registry         | `posit/workbench`                      | `rstudio/rstudio-workbench`                                   |
| License env vars | `PWB_` prefix                          | `RSW_` prefix                                                 |
| Variants         | `std` (with R/Python), `min` (minimal) | Single variant; multiple tags for different R/Python versions |
| Base OS options  | Ubuntu 24.04, Ubuntu 22.04             | Ubuntu 22.04                                                  |

## Caveats

### Security

These images should be reviewed before production use. Organizations with specific CVE or vulnerability requirements should rebuild these images to meet their security standards.

Published images for Posit Product editions under active support are re-built on a weekly basis to pull in operating system patches.

### License Keys

License keys used in containers risk activation slot loss if containers aren't gracefully stopped. The license deactivates on container exit, but ungraceful shutdowns (crashes, `docker kill`) may leave the activation slot consumed on Posit's license server.

To ensure proper license deactivation, use a sufficient stop timeout:

```bash
docker run -d \
  --stop-timeout 120 \
  -e PWB_LICENSE="your-license-key" \
  ...
```

For production deployments, license files are recommended over license keys.

### Hardware Locking

License state files are hardware-locked. Changes to MAC addresses, hostnames, or container orchestration platforms, such as Kubernetes, may invalidate existing license state, requiring reactivation.

## Documentation

- [Posit Workbench Documentation](https://docs.posit.co/ide/server-pro/)
- [Admin Guide](https://docs.posit.co/ide/server-pro/getting_started/installation/index.html)
- [Configuration Reference](https://docs.posit.co/ide/server-pro/reference/rserver_conf.html)
