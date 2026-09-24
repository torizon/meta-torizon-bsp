# meta-torizon-bsp

`meta-torizon-bsp` is the BSP-adaptation layer for Torizon OS. It contains the
machine, SoC, and vendor-BSP integration needed to build and run Torizon OS on
supported hardware, together with the build-environment setup scripts and
hardware-specific build guides.

It depends on the distro layer
[`meta-torizon`](https://github.com/torizon/meta-torizon), which defines the
board-independent Torizon OS distribution policy and image recipes. Together,
the two layers provide the metadata for these Torizon OS flavors:

- **Torizon**: built on top of Toradex's BSP.
- **Common Torizon**: built on top of BSPs from third parties.

## Architecture and migration

See [Architecture & Migration](./docs/architecture-migration.md) for the split's
rationale, the responsibility of each layer, and the steps required to migrate
an existing `meta-toradex-torizon` build.

## Building Torizon OS

To build Torizon OS for Toradex hardware, see
[Build Torizon OS from Source With Yocto Project/OpenEmbedded](https://developer.toradex.com/knowledge-base/build-torizoncore).

## Building Common Torizon OS

Start with the machine-specific build instructions below:

| SoC vendor | Platform / board | Documentation | Pre-built images |
| :--------- | :--------------- | :------------ | :--------------- |
| Intel | x86-64 | [README-x86.md](./docs/README-x86.md) | [Common Torizon OS for x86 machines](https://developer.toradex.com/software/toradex-embedded-software/toradex-download-links-torizon-linux-bsp-wince-and-partner-demos/#torizon-os-for-x86-machines) |
| MediaTek | ADLINK LEC-MTK-i1200 | [README-genio.md](./docs/README-genio.md) | N/A |
| NVIDIA | Jetson Orin Nano | [README-nvidia.md](./docs/README-nvidia.md) | N/A |
| NXP | i.MX 95 Verdin EVK and FRDM i.MX 93 | [README-nxp.md](./docs/README-nxp.md) | One-off Common Torizon images for [i.MX 95 Verdin EVK](https://artifacts.toradex.com/artifactory/legacy-oe-prod-frankfurt/i.MX95_EVKImage-Torizon_OS_7.0.0/) and [FRDM i.MX 93](https://artifacts.toradex.com/artifactory/legacy-oe-prod-frankfurt/i.MX93_FRDM-Torizon_OS_7.5.0/) |
| Renesas | RZ/V2L EVKIT | [README-rzv2l.md](./docs/README-rzv2l.md) | N/A |
| STMicroelectronics | STM32MP1/STM32MP2 | [README-stm32mp.md](./docs/README-stm32mp.md) | N/A |
| Synaptics | Astra SL1680/Luna SL1680 | [README-syn.md](./docs/README-syn.md) | N/A |
| Texas Instruments | AM62x/AM62L/AM62P SK EVM and BeagleY-AI | [README-ti.md](./docs/README-ti.md) | [Common Torizon OS for TI machines](https://developer.toradex.com/software/toradex-embedded-software/toradex-download-links-torizon-linux-bsp-wince-and-partner-demos/#torizon-os-for-ti-machines) |

If your machine is not listed above, or if you prefer a manual setup, use the
following general process:

1. Clone both Torizon OS layers and their common dependencies:

   ```bash
   git clone https://github.com/torizon/meta-torizon.git -b wrynose-8.x.y
   git clone https://github.com/torizon/meta-torizon-bsp.git -b wrynose-8.x.y
   git clone https://github.com/uptane/meta-updater.git -b wrynose
   git clone https://git.yoctoproject.org/meta-virtualization -b wrynose
   ```

2. Download the BSP and remaining dependencies required by your machine. The
   machine-specific guides above provide the exact repositories and revisions.
3. Source `meta-torizon-bsp/scripts/setup-environment` using a supported
   `MACHINE`, or follow the environment setup supplied by your vendor BSP.
4. Ensure `meta-torizon`, `meta-torizon-bsp`, and their dependencies are present
   in `conf/bblayers.conf`.
5. Set `DISTRO = "common-torizon"` in `conf/local.conf` when building Common
   Torizon OS.
6. Build one of the available Torizon OS images:

   - `torizon-docker`
   - `torizon-minimal`
   - `torizon-podman` (**experimental**)

See [docs/setup-environment.md](./docs/setup-environment.md) for the
build-environment setup architecture and instructions for adding support for a
new vendor or board.

## Reporting issues

If you encounter an issue while using or developing Torizon OS, open an issue
in the relevant layer repository or create a Technical Support topic in the
[Toradex Developer Community](https://community.toradex.com/).

## Contributing

You may actively fix issues and bugs or port Common Torizon to new devices. See
[CONTRIBUTING.md](./docs/CONTRIBUTING.md) for the contribution workflow and
commit-message requirements.

## Development process

Torizon OS is maintained by the Toradex R&D team. Development happens in the
`meta-torizon` and `meta-torizon-bsp` repositories through issues, pull
requests, and discussions. These repositories are also used by Toradex's
internal CI/CD infrastructure.

Some commits and pull requests from Toradex team members may reference internal
ticket identifiers, for example `Related-to: TOR-3705`.

## License

All metadata is MIT licensed unless otherwise stated. Source code and binaries
included in the tree for individual recipes are under the license stated in
each recipe (`.bb` file), unless otherwise stated.

This README document is Copyright (C) 2019-2025 Toradex AG.
