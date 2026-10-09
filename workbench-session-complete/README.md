<a href="https://posit.co/products/enterprise/workbench">
<picture>
  <source media="(prefers-color-scheme: dark)" srcset="https://cdn.posit.co/platform/containers/logos/logo_workbenchtag-reverse.svg">
  <source media="(prefers-color-scheme: light)" srcset="https://cdn.posit.co/platform/containers/logos/logo_workbenchtag-fullcolor.svg">
  <img alt="Posit Workbench Logo" src="https://cdn.posit.co/platform/containers/logos/logo_workbenchtag-fullcolor.svg">
</picture>
</a>

# Posit Workbench Session Complete

A [Workbench](https://docs.posit.co/ide/server-pro/) session image that carries its own session components, so Workbench can launch sessions from it **without** a `workbench-session-init` init container alongside it.

It is a [`workbench-session`](https://github.com/posit-dev/images-workbench/tree/main/workbench-session) image with a full Workbench installation layered on top. The session components come along with that installation.

[![GitHub Repository](https://img.shields.io/badge/github-repo?logo=github&color=grey)](https://github.com/posit-dev/images-workbench/tree/main/workbench-session-complete)

> [!IMPORTANT]
> Installing all of Workbench to obtain the session components is **not** the efficient way to do this. `workbench-session-init` exists precisely to ship just those components, and on Kubernetes it remains the recommended approach. This image exists for consumers that cannot run an init container, and mirrors the long-standing [`r-session-complete`](https://github.com/rstudio/rstudio-docker-products/tree/main/r-session-complete) image on a modern `workbench-session` base.

## Quick reference

| | |
|---|---|
| **Maintained by** | [the Posit Docker team](https://github.com/posit-dev/images) |
| **Where to get help** | [GitHub Issues](https://github.com/posit-dev/images-workbench/issues), [Images Discussion Board](https://github.com/posit-dev/images/discussions), [the Posit Community Forum](https://forum.posit.co/c/posit-professional-hosted), [Posit Support](https://support.posit.co/hc/en-us) |
| **Where to file issues** | [https://github.com/posit-dev/images-workbench/issues](https://github.com/posit-dev/images-workbench/issues) |
| **Source** | [https://github.com/posit-dev/images-workbench](https://github.com/posit-dev/images-workbench) |
| **License** | [MIT](https://github.com/posit-dev/images-workbench/blob/main/LICENSE.md) |
| **Product documentation** | [Posit Workbench documentation](https://docs.posit.co/ide/server-pro/), [Kubernetes integration guide](https://docs.posit.co/ide/server-pro/integration/kubernetes.html) |

## How this differs from the standard session images

On Kubernetes, Workbench normally assembles a session container from two images at launch time:

1. The Job Launcher attaches an `emptyDir` volume, mounted at `/mnt/init` in an init container and at `/usr/lib/rstudio-server` in the session container.
2. The `workbench-session-init` init container copies the subset of `/opt/session-components` that the requested `PWB_SESSION_TYPE` needs into `/mnt/init`.
3. The `workbench-session` container starts and finds the components at `/usr/lib/rstudio-server`.

This image collapses that into one image: a full Workbench install puts the components at `/usr/lib/rstudio-server` at **build** time, so step 1 and 2 are unnecessary.

| | `workbench-session` | `workbench-session-complete` |
|---|---|---|
| Session components | Delivered at runtime by `workbench-session-init` | Baked in at `/usr/lib/rstudio-server` |
| Init container required | Yes | No |
| Session types supported | Whichever `PWB_SESSION_TYPE` the init container staged | All of them, from one image |
| Component layout | `bin/<distro>/rsession` (multi-distro tarball) | `bin/rsession` (flat, from the deb) |
| Size | Smaller | Substantially larger — see [Caveats](#caveats) |

> [!NOTE]
> The component layout difference is load-bearing. The `workbench-session-init` tarball nests per-distro binaries under `bin/jammy/`, `bin/noble/`, `bin/resolute/` and so on; the Workbench deb installs a single flat set at `bin/`. Anything that reads these paths must expect the flat form.

## Usage

Configure Workbench to launch sessions from this image and do **not** configure a session-init container. In `rserver.conf`, leave `launcher-sessions-init-container-image-name` unset; if it is set, Workbench will attach an init container whose `emptyDir` mount at `/usr/lib/rstudio-server` will **mask** the components baked into this image.

The [Workbench Helm chart](https://docs.posit.co/helm/charts/rstudio-workbench/README.html) supports this pattern directly via `components.enabled`, which turns off init-container component delivery entirely:

```yaml
session:
  image:
    repository: "ghcr.io/posit-dev/workbench-session-complete"
    tag: "2026.09.0-ubuntu-26.04"

components:
  # No init containers are configured; session.image must be self-contained.
  enabled: false
```

This is the same switch the chart documents for the classic `rstudio/r-session-complete` image — `workbench-session-complete` is the modern, `workbench-session`-based equivalent.

> [!WARNING]
> Set `components.enabled: false`, not `components.sessionInit.enabled: false` (which is not a chart value). Leaving init-container delivery on gives the session pod an `emptyDir` mounted at `/usr/lib/rstudio-server`, which **masks** the components baked into this image.

## Image registry

Posit publishes the image to Docker Hub and GitHub Container Registry:

- `docker.io/posit/workbench-session-complete`
- `ghcr.io/posit-dev/workbench-session-complete`

> [!NOTE]
> This image is a rolling release. Only the latest Workbench release is built and maintained; when a new Workbench version ships, the previous version's tags stop receiving rebuilds.

## Image variants

| Variant | Description |
|---------|-------------|
| `std` (Standard) | Standard `workbench-session` base plus a full Workbench install. |
| `min` (Minimal)  | Minimal `workbench-session` base plus a full Workbench install. Fewer system and optional packages. |

## Image tags

Tags follow `{version}-{os}[-{variant}]`. The following are valid examples:

- `2026.09.0-ubuntu-26.04`: Standard variant on Ubuntu 26.04
- `2026.09.0-ubuntu-26.04-std`: Standard variant (explicit)
- `2026.09.0-ubuntu-26.04-min`: Minimal variant
- `latest`: Most recent Standard build on the default OS
- `ubuntu-26.04`, `std`, `min`: Most recent build of that OS or variant

The version is the **Workbench** version, and it is the exact apt version pin used for the `rstudio-server` package. It is not an R/Python coordinate — those come from whichever `workbench-session` base build the tag resolves to.

## Architectures

Posit publishes this image for `linux/amd64` only.

`linux/arm64` is not merely out of scope. The `rstudio-server` postinst hardcodes the multiarch triplet when it repoints the NSS module symlink:

```shell
ln -sf /usr/lib/rstudio-server/bin/libnss_pwb.so /usr/lib/x86_64-linux-gnu/libnss_pwb.so.2
```

On `arm64` that symlink would be written to a path the loader does not read, silently leaving `libnss_pwb.so.2` pointed at the base image's zero-byte placeholder and the `pwb` NSS module inert.

## Operating systems

Ubuntu 26.04 only.

## Installed software

Everything from the `workbench-session` base (R, Python, Jupyter, Quarto, TinyTeX, Posit Pro Drivers) plus:

| Component | Path |
|-----------|------|
| Workbench / session components | `/usr/lib/rstudio-server` |
| `rsession` and per-type session launchers | `/usr/lib/rstudio-server/bin` |
| Positron Server | `/usr/lib/rstudio-server/bin/positron-server` |
| VS Code (`pwb-code-server`) | `/usr/lib/rstudio-server/bin/pwb-code-server` |
| Bundled Quarto (used internally by the session components) | `/usr/lib/rstudio-server/bin/quarto` |
| Quarto on `PATH` (the base image's pinned build) | `/opt/quarto` |

> [!NOTE]
> There are two Quarto installations. `quarto` on `PATH` resolves to the base image's `/opt/quarto`, which is the version Bakery pins and tests. The Workbench deb's bundled copy stays at `/usr/lib/rstudio-server/bin/quarto` for the session components' own use. This deliberately differs from `r-session-complete`, which symlinks the bundled copy onto `PATH`.

## Caveats

### Image size

A full Workbench install adds roughly 4.5&nbsp;GB to the base. The Standard variant is around 15&nbsp;GB uncompressed and the Minimal variant around 13&nbsp;GB. Most of that is IDE payload: Positron Server, `pwb-code-server`, the bundled Quarto, and the Copilot language server.

If image size matters more than avoiding an init container, use `workbench-session` with `workbench-session-init` instead.

### `libcap2` is an undeclared dependency of the Workbench deb

`rsession` and 22 other binaries under `/usr/lib/rstudio-server` link against `libcap.so.2`, but the `rstudio-server` package does not list `libcap2` in its `Depends`. Installing the deb's declared dependencies is therefore not sufficient to get a working `rsession`.

The Containerfile installs `libcap2` explicitly. This gap is invisible on the Standard variant (whose package set pulls `libcap2` in incidentally) and on `r-session-complete` (whose `product-base-pro` base already has it); on the Minimal variant it caused `rsession` to fail at exec time with `libcap.so.2: cannot open shared object file`. The `workbench-binaries-shared-libs-resolve` goss check guards against the next such gap.

### The `rstudio-server` account's UID/GID is not pinned

The deb postinst creates the account with `useradd -r -U rstudio-server`, letting `useradd` pick the next free system id, so the value depends on what the base image leaves free and can move on a base rebuild.

It is left unpinned to stay faithful to `r-session-complete`, which also lets the postinst choose. Note that the uid/gid 999 convention used by the [`workbench`](https://github.com/posit-dev/images-workbench/tree/main/workbench) image cannot simply be copied here: in the `workbench-session` base, gid 999 is already taken by `systemd-journal`. Pin it explicitly if anything in your deployment depends on a stable numeric owner.

### Inert sysv init links are present

With no init system in the build container, the postinst falls through to its sysv branch and creates `/etc/init.d/rstudio-{server,launcher}` plus `/etc/rc{2,3,4,5}.d/S01rstudio-*`. Nothing in a container runs sysv `rc.d`, so these are inert, and `r-session-complete` produces the same artifacts from the same postinst.

What matters is that no server is started and no server state is captured at build time. The `install_workbench.sh` patches remove the postinst's service-start and license-initialization steps, and the goss suite asserts that no secure cookie key, launcher keypair, session RPC key, or `rstudio.sqlite` is baked into the image.

### Security

Review this image before using it in production. Organizations with specific Common Vulnerabilities and Exposures (CVE) or vulnerability requirements can rebuild it to meet their security standards.

### Version compatibility

The Workbench version in this image must match your Workbench server version. Mismatched versions can cause session startup failures or unexpected behavior.

## Documentation

- [Posit Workbench documentation](https://docs.posit.co/ide/server-pro/)
- [Job Launcher overview](https://docs.posit.co/ide/server-pro/admin/job_launcher/job_launcher.html)
- [Kubernetes integration guide](https://docs.posit.co/ide/server-pro/integration/kubernetes.html)
- [`workbench-session`](https://github.com/posit-dev/images-workbench/tree/main/workbench-session) and [`workbench-session-init`](https://github.com/posit-dev/images-workbench/tree/main/workbench-session-init)
