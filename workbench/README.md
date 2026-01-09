# Posit Workbench Container Image

This container image provides [Posit Workbench](https://docs.posit.co/ide/server-pro/) (PWB), an integrated development environment for data science teams that supports R, Python, and VS Code.

> [!IMPORTANT]
> This image is under active development and testing and is not yet supported by Posit.
>
> Please see [rstudio-workbench image](https://github.com/rstudio/rstudio-docker-products/tree/main/workbench) in `rstudio/rstudio-docker-products` for the officially supported image.

## Quick Start

```bash
PWB_VERSION="2025.09.2-418.pro4"
docker run -d \
  --name workbench \
  -p 8787:8787 \
  -v /path/to/license.lic:/etc/rstudio-server/license.lic \
  posit/workbench:${PWB_VERSION}-ubuntu-22.04
```

Access Workbench at `http://localhost:8787`.

## Image Variants

Two variants are available:

| Variant | Description |
|---------|-------------|
| `std` (Standard) | Opinionated image, runs out of the box |
| `min` (Minimal) | Small image you can extend with desired dependencies, *will not run as is* |

## Image Tags

Images are published to:
- Docker Hub: `docker.io/posit/workbench`
- GitHub Container Registry: `ghcr.io/posit-dev/workbench`

Tag formats:
- `2025.09.2-418.pro4` - Full version (standard variant, Ubuntu 22.04)
- `2025.09.2-418.pro4-ubuntu-22.04-std` - Explicit OS and variant
- `2025.09.2-418.pro4-ubuntu-24.04-min` - Ubuntu 24.04 minimal variant
- `latest` - Latest stable release (standard variant, Ubuntu 22.04)

## Configuration

### License Activation

A valid license is required. Choose one method:

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
| `PWB_TESTUSER`        | Test user name (default: `rstudio`)                                 |
| `PWB_TESTUSER_PASSWD` | Test user password (default: `rstudio`)                             |
| `PWB_TESTUSER_UID`    | Test user UID (default: `10000`)                                    |
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
