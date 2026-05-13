<a href="https://posit.co/products/enterprise/workbench">
<picture>
  <source media="(prefers-color-scheme: dark)" srcset="https://cdn.posit.co/platform/containers/logos/logo_workbenchtag-reverse.svg">
  <source media="(prefers-color-scheme: light)" srcset="https://cdn.posit.co/platform/containers/logos/logo_workbenchtag-fullcolor.svg">
  <img alt="Posit Workbench Logo" src="https://cdn.posit.co/platform/containers/logos/logo_workbenchtag-fullcolor.svg">
</picture>
</a>

# Posit Workbench container image

This container image provides [Workbench](https://docs.posit.co/ide/server-pro/), an integrated development environment for data science teams that supports R, Python, and VS Code.

[![GitHub Repository](https://img.shields.io/badge/github-repo?logo=github&color=grey)](https://github.com/posit-dev/images-workbench)
[![GitHub Workflow Status](https://img.shields.io/github/actions/workflow/status/posit-dev/images-workbench/production.yml?branch=main)](https://github.com/posit-dev/images-workbench/actions/workflows/production.yml)
[![Latest Version](https://img.shields.io/docker/v/posit/workbench?sort=semver&label=latest)](https://hub.docker.com/r/posit/workbench/tags)
![Docker Hub Pulls](https://img.shields.io/docker/pulls/posit/workbench)
![Docker Image Size](https://img.shields.io/docker/image-size/posit/workbench/latest)

> [!NOTE]
> These images are in preview as Posit migrates container images from <a href="https://github.com/rstudio/rstudio-docker-products">rstudio/rstudio-docker-products</a>. The previous images remain supported.

> [!TIP]
> Deploying on Kubernetes? Try the <a href="https://docs.posit.co/helm/charts/rstudio-workbench/README.html">Posit Workbench Helm chart</a>!

## Related images

For Kubernetes deployments, Workbench uses these images together. See the [repository README](https://github.com/posit-dev/images-workbench#deploying-on-kubernetes) for Helm configuration.

| Image | Description | Docker Hub | GitHub Container Registry |
|:------|:------------|:-----------|:--------------------------|
| `workbench-session` | Session images for Kubernetes (R and Python version matrix) | [posit/workbench-session](https://hub.docker.com/r/posit/workbench-session) | [posit-dev/workbench-session](https://github.com/posit-dev/images-workbench/pkgs/container/workbench-session) |
| `workbench-session-init` | Init container providing session runtime components | [posit/workbench-session-init](https://hub.docker.com/r/posit/workbench-session-init) | [posit-dev/workbench-session-init](https://github.com/posit-dev/images-workbench/pkgs/container/workbench-session-init) |
| `workbench-positron-init` | Init container providing Positron IDE components | [posit/workbench-positron-init](https://hub.docker.com/r/posit/workbench-positron-init) | [posit-dev/workbench-positron-init](https://github.com/posit-dev/images-workbench/pkgs/container/workbench-positron-init) |

## Quick reference

| |                                                                                                                                                                                                                                                          |
|---|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| **Maintained by** | [the Posit Docker team](https://github.com/posit-dev/images)                                                                                                                                                                                             |
| **Where to get help** | [GitHub Issues](https://github.com/posit-dev/images-workbench/issues), [Images Discussion Board](https://github.com/posit-dev/images/discussions), [the Posit Community Forum](https://forum.posit.co/c/posit-professional-hosted), [Posit Support](https://support.posit.co/hc/en-us) |
| **Where to file issues** | [https://github.com/posit-dev/images-workbench/issues](https://github.com/posit-dev/images-workbench/issues)                                                                                                                                             |
| **Source** | [https://github.com/posit-dev/images-workbench](https://github.com/posit-dev/images-workbench)                                                                                                                                                           |
| **License** | [MIT](https://github.com/posit-dev/images-workbench/blob/main/LICENSE.md)                                                                                                                                                                                |
| **Product documentation** | [Posit Workbench documentation](https://docs.posit.co/ide/server-pro/)                                                                                                                                                                                   |

## How to use this image

### Quick start

```bash
PWB_VERSION="latest"  # or a specific version like "2026.04.0"
PWB_IMAGE="ghcr.io/posit-dev/workbench"  # or docker.io/posit/workbench
PWB_LICENSE_FILE_HOST_PATH="/path/to/license.lic"
PWB_LICENSE_FILE_PATH="/etc/rstudio-server/license.lic"  # this is the default path for the `PWB_LICENSE_FILE_PATH` container environment variable, included for illustrative purposes
PWB_DATA_STORAGE_HOST_PATH="/path/to/data"
PWB_HOME_STORAGE_HOST_PATH="/path/to/home"
docker run -d \
  --name workbench \
  -p 8787:8787 \
  -e PWB_TESTUSER=posit \
  -e PWB_TESTUSER_PASSWD=posit \
  -e PWB_LICENSE_FILE_PATH=${PWB_LICENSE_FILE_PATH} \
  -v ${PWB_LICENSE_FILE_HOST_PATH}:${PWB_LICENSE_FILE_PATH} \
  -v ${PWB_DATA_STORAGE_HOST_PATH}:/var/lib/rstudio-server \
  -v ${PWB_HOME_STORAGE_HOST_PATH}:/home \
  ${PWB_IMAGE}:${PWB_VERSION}
```

Access Workbench at `http://localhost:8787`. Log in with username `posit` and password `posit`.

### With a custom configuration file

```bash
PWB_VERSION="latest"  # or a specific version like "2026.04.0"
PWB_IMAGE="ghcr.io/posit-dev/workbench"  # or docker.io/posit/workbench
PWB_LICENSE_FILE_HOST_PATH="/path/to/license.lic"
PWB_CONFIG_HOST_PATH="/path/to/rstudio"
docker run -d \
  --name workbench \
  -p 8787:8787 \
  -v ${PWB_LICENSE_FILE_HOST_PATH}:/etc/rstudio-server/license.lic \
  -v ${PWB_CONFIG_HOST_PATH}:/etc/rstudio:ro \
  ${PWB_IMAGE}:${PWB_VERSION}
```

### With Docker Compose

```yaml
services:
  workbench:
    image: docker.io/posit/workbench:latest  # or ghcr.io/posit-dev/workbench:latest
    ports:
    - "8787:8787"
    environment:
      PWB_TESTUSER: posit
      PWB_TESTUSER_PASSWD: posit
    volumes:
    - /path/to/license.lic:/etc/rstudio-server/license.lic
    - /path/to/rstudio:/etc/rstudio:ro
    - workbench-home:/home
    - workbench-shared:/var/lib/rstudio-server
    restart: unless-stopped

volumes:
  workbench-home:
  workbench-shared:
```

## Image variants

Two variants are available:

| Variant          | Description                                                                                                                                                                                                                       |
|------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| Standard (`std`) | Opinionated image, runs out of the box. Bundles Workbench with one R version, one Python version, Quarto, Posit Professional Drivers, and the Job Launcher.                                                                       |
| Minimal (`min`)  | Small image you can extend with the dependencies you need. Does not include R, Python, or Quarto, and cannot run RStudio, JupyterLab, and other dependent features as-is. Use this variant as a starting point for custom images. |

Each tagged image bundles a fixed set of dependencies. Both variants ship the `YYYY.MM` release of Workbench at the latest patch release available when the image was built. The `std` variant additionally ships one R version and one Python version, locked to the latest available at build time. The Containerfiles in this repository under `workbench/<version>/` document the exact versions in any tag. No arguments are overridden at build time.

See [extending examples](https://github.com/posit-dev/images-examples/tree/main/extending) for how to build on the Minimal image.

## Image tags

Posit publishes images to:
- Docker Hub: `docker.io/posit/workbench`
- GitHub Container Registry: `ghcr.io/posit-dev/workbench`

Ubuntu 24.04 is the default OS.

Tag formats where `YYYY.MM.P` is any supported Workbench version:
- `YYYY.MM.P` - Latest OS, standard variant
- `YYYY.MM.P-ubuntu-24.04` - Explicit OS, standard variant
- `YYYY.MM.P-ubuntu-24.04-std` - Explicit OS and variant
- `YYYY.MM.P-ubuntu-24.04-min` - Minimal variant
- `latest` - Latest version, default OS, standard variant

## Architectures

Posit publishes Workbench images for `linux/amd64` only. `linux/arm64` builds remain in developer preview until Workbench supports ARM in production.

## Environment variables

| Variable               | Description                                                                                                                                     |
|------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------|
| `PWB_LICENSE`          | License key for activation                                                                                                                      |
| `PWB_LICENSE_SERVER`   | URL of floating license server                                                                                                                  |
| `PWB_LICENSE_FILE_PATH`| Path to license file (default: `/etc/rstudio-server/license.lic`)                                                                               |
| `PWB_LAUNCHER`         | Enable the Job Launcher (default: `true`)                                                                                                       |
| `PWB_LAUNCHER_TIMEOUT` | Launcher startup timeout in seconds (default: `10`)                                                                                             |
| `PWB_TESTUSER`         | Test user name. If empty, the image creates no test user.                                                                                       |
| `PWB_TESTUSER_PASSWD`  | Test user password                                                                                                                              |
| `PWB_TESTUSER_UID`     | Test user UID (default: `10000` when `PWB_TESTUSER` is set)                                                                                     |
| `PWB_STARTUP_DEBUG`    | Set to `1` for verbose startup logging                                                                                                          |
| `PWB_DIAGNOSTIC_ENABLE`| When true, run `rstudio-server verify-installation` before server start and write results to `$PWB_DIAGNOSTIC_DIR/verify.log` (default: `false`) |
| `PWB_DIAGNOSTIC_DIR`   | Directory for diagnostic logs (default: `/var/log/rstudio`)                                                                                     |
| `PWB_EXIT_AFTER_VERIFY`| When `PWB_DIAGNOSTIC_ENABLE=true`, exit after running verification instead of starting the server (default: `false`)                            |

If you are migrating from `rstudio/rstudio-workbench`, see [Environment variables](#environment-variables-1) under the migration guide for the legacy `RSW_` names and deprecation timeline.

## Exposed ports

| Port | Description                   |
|------|-------------------------------|
| 8787 | HTTP web interface            |
| 5559 | Job Launcher (needed for OHE) |

## Volumes

For persistent data, add these volume mounts to your `docker run` command:

```bash
-v /data/workbench-home:/home \
-v /data/rstudio-server:/var/lib/rstudio-server \
-v /data/rstudio-server-config:/etc/rstudio
```

| Mount Point               | Description                                                            |
|---------------------------|------------------------------------------------------------------------|
| `/home`                   | User home directories. Mount to persist user files between restarts.   |
| `/var/lib/rstudio-server` | Session data and database                                              |
| `/etc/rstudio`            | Configuration files                                                    |

## Configuration

### License activation

Workbench requires a [product license](https://docs.posit.co/licensing/licensing-faq.html). If you don't have a license yet, request a free 30-day trial at [posit.co/trial-license](https://posit.co/trial-license/).

Posit recommends activating with a license file. Choose one method:

#### Option 1: License file (recommended)

Mount the license file to any path in the container and set `PWB_LICENSE_FILE_PATH` to that path. The default search path is `/etc/rstudio-server/license.lic`, so mounting to that path does not require setting the environment variable. The environment variable is only included for illustrative purposes below.

```bash
docker run -v /path/to/license.lic:/etc/rstudio-server/license.lic -e PWB_LICENSE_FILE_PATH=/etc/rstudio-server/license.lic ...
```

To ensure correct permissions on the license file, set the owner and mode on the host before mounting:

```bash
sudo chown 999:999 /path/to/license.lic
sudo chmod 0600 /path/to/license.lic
```

If the license file does not successfully activate, the container fails to start under most circumstances. See the [Licensing FAQ](https://docs.posit.co/licensing/licensing-faq.html) for usage and troubleshooting information.

#### Option 2: License key

```bash
docker run -e PWB_LICENSE="your-license-key" ...
```

License key activations can leak when a container shuts down ungracefully, consuming an activation slot that cannot be recovered through normal means. To help preserve license state across container restarts, mount these directories to persistent storage:

- `/var/lib/.local`
- `/var/lib/.prof`
- `/var/lib/rstudio-workbench`

The license manager hardware-locks these state files to a single host; they do not transfer between machines. Mounting these paths reduces the chance of a leak but does not eliminate it. To avoid the leak risk entirely, use a license file (Option 1). See the [License keys](#license-keys) caveat for more detail.

#### Option 3: Floating license server

```bash
docker run -e PWB_LICENSE_SERVER="http://license-server:8989" ...
```

Floating license activations can also leak on ungraceful shutdown. To help preserve license state across container restarts, mount this directory to persistent storage:

- `/var/lib/.TurboFloat`

State files are hardware-locked and not transferable between hosts. To avoid the leak risk entirely, use a license file (Option 1).

### User provisioning

By default, Workbench creates a test user controlled by the `PWB_TESTUSER`, `PWB_TESTUSER_PASSWD`, and `PWB_TESTUSER_UID` environment variables. If `PWB_TESTUSER` is empty, no test user is created.

#### LDAP, Active Directory, and sssd

The image installs `sssd` and starts it by default with a placeholder configuration. To provision users from a directory (LDAP server, Active Directory, etc.), mount your own configuration file into `/etc/sssd/conf.d/`.

Example `sssd.conf`:

```ini
[sssd]
config_file_version = 2
domains = LDAP

[domain/LDAP]
id_provider = ldap
auth_provider = ldap
chpass_provider = ldap
sudo_provider = ldap
# ... more configuration
```

Then run the container with the configuration mounted:

```bash
# sssd requires strict file permissions
chmod 600 sssd.conf

docker run -d \
  -p 8787:8787 -p 5559:5559 \
  -v /path/to/license.lic:/etc/rstudio-server/license.lic \
  -v $PWD/sssd.conf:/etc/sssd/conf.d/sssd.conf \
  ghcr.io/posit-dev/workbench:latest
```

For custom authentication or session behavior with PAM, you might also need to modify the PAM configuration files in the container. See the [Workbench admin guide](https://docs.posit.co/ide/server-pro/admin/authenticating_users/authenticating_users.html) for more information.

### Custom configuration

Mount a custom configuration directory or file:

```bash
docker run -v /path/to/rstudio:/etc/rstudio ...
```

Or mount a single file:

```bash
docker run -v /path/to/rserver.conf:/etc/rstudio/rserver.conf ...
```

Changes take effect when the container is restarted. See the [configuration documentation](https://docs.posit.co/ide/server-pro/reference/rserver_conf.html) for available options.

If you replace `rserver.conf` with your own file, keep `server-health-check-enabled=1` so the [health check](#health-check) endpoint works.

## Health check

The image declares a Docker [`HEALTHCHECK`](https://docs.docker.com/reference/dockerfile/#healthcheck) that polls the Workbench `/health-check` endpoint:

```dockerfile
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -fsS http://localhost:8787/health-check || exit 1
```

The endpoint requires `server-health-check-enabled=1` in `rserver.conf`. The bundled configuration sets this by default, so no action is required unless you mount your own `rserver.conf`.

When the container is healthy, `docker ps` reports `healthy` in the status column and the endpoint returns `200 OK` with a plain-text dump of server diagnostics. To inspect the response directly:

```bash
docker exec <container> curl -fsS http://localhost:8787/health-check
```

To disable the built-in health check, run the container with `--no-healthcheck` or override it in your orchestrator.

## Process management

Workbench runs several services inside the container under [`supervisord`](http://supervisord.org/). `supervisord` exits the container if any required service exits, so the container fails fast on startup errors.

> [!NOTE]
> Running multiple services in a single container is generally an anti-pattern. The image uses this approach as a workaround until Workbench can handle users and supporting processes in a more container-friendly way.

The image manages these services:

- **Workbench**: the main server process. The startup configuration mounts at `/startup/base`.
- **Job Launcher**: enables Positron, RStudio, JupyterLab, and VS Code sessions, as well as integration with job schedulers like Slurm and Kubernetes. Enabled by default. The startup configuration mounts at `/startup/launcher`. To disable, mount an empty volume over `/startup/launcher`.
- **sssd**: provides user provisioning when connected to an LDAP directory or other user store. Enabled by default with a placeholder domain that does nothing. To use your own directory, mount required `.conf` files into `/etc/sssd/conf.d/` (see [User provisioning](#user-provisioning)). To disable entirely, mount an empty volume over `/startup/user-provisioning/`.
- **custom**: to run additional services inside the container, mount supervisord configuration files into `/startup/custom/`. `supervisord` starts and manages them alongside the built-in services. In Kubernetes, `initContainers` or sidecar containers are often a better fit.

## User

The container starts as `root` and Workbench drops privileges to the `rstudio-server` user (UID and GID `999`) for the server process.

## Examples

### Running with persistent home directories and configuration

```bash
docker run -d \
  --name workbench \
  -p 8787:8787 -p 5559:5559 \
  -v /data/workbench-home:/home \
  -v /path/to/rstudio:/etc/rstudio \
  -v /path/to/license.lic:/etc/rstudio-server/license.lic \
  -e PWB_TESTUSER=posit \
  -e PWB_TESTUSER_PASSWD=posit \
  ghcr.io/posit-dev/workbench:latest
```

Open `http://localhost:8787` and log in as `posit`.

## Migrating from legacy image

This image replaces the legacy [`rstudio/rstudio-workbench`](https://hub.docker.com/r/rstudio/rstudio-workbench) image. Workbench itself is unchanged. The application reads `/etc/rstudio/rserver.conf`, listens on `8787`, runs the Job Launcher on `5559`, and runs as the `rstudio-server` user (UID/GID `999`). Data and configuration volume mount points are unchanged. The differences are in how the image is published and configured.

### Image references

The legacy image was published as `rstudio/rstudio-workbench` on Docker Hub and `ghcr.io/rstudio/rstudio-docker-products/rstudio-workbench` on GHCR, tagged by OS (`jammy`, `ubuntu2204`, `jammy-<version>`, `ubuntu2204-<version>`) for `linux/amd64` only. Update your image reference to one of the new locations and pick a tag that pins to your desired Workbench version, OS, and variant. See [Image tags](#image-tags) and [Architectures](#architectures).

### Variants

The legacy image shipped a single variant containing two versions of R and two versions of Python alongside many extraneous system packages. The Standard (`std`) variant is closest to the legacy image. It ships with one version of R, one version of Python, and a reduced set of system packages required for Workbench to run. The Minimal (`min`) variant has no equivalent in the legacy image. See [Image variants](#image-variants).

### Environment variables

License, launcher, and test user environment variables use the `PWB_` prefix:

| New variable           | Legacy variable        |
|------------------------|------------------------|
| `PWB_LICENSE`          | `RSW_LICENSE`          |
| `PWB_LICENSE_SERVER`   | `RSW_LICENSE_SERVER`   |
| `PWB_LICENSE_FILE_PATH`| `RSW_LICENSE_FILE_PATH`|
| `PWB_LAUNCHER`         | `RSW_LAUNCHER`         |
| `PWB_LAUNCHER_TIMEOUT` | `RSW_LAUNCHER_TIMEOUT` |
| `PWB_TESTUSER`         | `RSW_TESTUSER`         |
| `PWB_TESTUSER_PASSWD`  | `RSW_TESTUSER_PASSWD`  |
| `PWB_TESTUSER_UID`     | `RSW_TESTUSER_UID`     |

The image accepts the legacy `RSW_` names as a fallback during the deprecation window.

> [!NOTE]
> Posit supports legacy `RSW_` variables but plans to deprecate them after 2026. For more details and updates, see the <a href="https://docs.posit.co/ide/server-pro/news/">Workbench release notes</a>. For future deployments, always use the `PWB_` prefix to ensure forward compatibility.

### Privileged mode

The legacy image documented `docker run --privileged` for some examples. This image does not require `--privileged`.

### What did not change

- Application port (`8787`)
- Job Launcher port (`5559`)
- Configuration directory (`/etc/rstudio`)
- License file default path (`/etc/rstudio-server/license.lic`)
- Service user (`rstudio-server`, UID/GID `999`)
- Process management with `supervisord` and the `/startup/{base,launcher,user-provisioning,custom}` mount points

## Caveats

### Security

Review these images before using them in production. Organizations with specific Common Vulnerabilities and Exposures (CVE) or vulnerability requirements can rebuild these images to meet their security standards.

Posit rebuilds published images weekly for Posit product editions under active support to pull in operating system patches.

### License keys

License keys used in containers risk activation slot loss if the container does not shut down gracefully. The license deactivates on container exit, but ungraceful shutdowns (crashes, `docker kill`) can leave the activation slot consumed on the Posit license server.

To ensure proper license deactivation, use a sufficient stop timeout for both `docker run` and `docker stop`:

```bash
docker run -d --stop-timeout 120 -e PWB_LICENSE="your-license-key" ...
docker stop --time 120 <container>
```

For production deployments, use license files rather than license keys.

### Hardware locking

Workbench hardware-locks license state files to a specific machine. Changes to MAC addresses, hostnames, or container orchestration platforms, such as Kubernetes, can invalidate the license state, requiring reactivation.

To preserve license state across container restarts, mount these directories to persistent storage:

* License key
  * `/var/lib/.local`
  * `/var/lib/.prof`
  * `/var/lib/rstudio-woorkbench`
* Floating license
  * `/var/lib/.TurboFloat`

Files in these directories are hardware-locked and not transferable between hosts. Gracefully shut down containers and allow license deactivation before changing host hardware or firmware (for example, upgrading a network card or updating BIOS). Apply the same caution before changing container resources (for example, the network driver or allocated CPU cores).
