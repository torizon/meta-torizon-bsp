Setup
======
1. Set up the default git user and e-mail:
```
$ git config --global user.email "you@example.com"
$ git config --global user.name "Your Name"
```
2. Install the repo utility to the development host:
```
$ mkdir ~/bin
$ PATH=~/bin:$PATH
$ curl http://commondatastorage.googleapis.com/git-repo-downloads/repo > ~/bin/repo
$ chmod a+x ~/bin/repo
```
3. Create a working directory for the Yocto build, go into that directory:
```
$ cd ~
$ mkdir ~/yocto-workdir
$ cd ~/yocto-workdir
```
4. Initialize the Torizon repository:
```
$ repo init -u https://git.toradex.com/toradex-manifest.git -b wrynose-7.x.y -m common-torizon/nvidia/integration.xml
```
> [!IMPORTANT]
> Until an official release of Common Torizon OS for NVIDIA Jetson Orin Nano, only the `integration.xml` manifest is suitable for end-users to build. After an official release, users will be able to use the `default.xml` manifest.

Note that `integration.xml` is a development manifest that may contain unfinished features and should therefore be considered unstable.

5. Sync the repositories:
```
$ repo sync
```

Build
======
1. Use the Docker container provided by Toradex to setup the build environment in the work directory `~/yocto-workdir` prepared in previous steps:
```
$ docker run --rm -it --name=crops -v ~/yocto-workdir:/workdir --workdir=/workdir torizon/crops:wrynose-7.x.y /bin/bash
```
2. Repeat the step of configuring the Git user name and e-mail:
```
$$ git config --global user.email "you@example.com"
$$ git config --global user.name "Your Name"
```
3. In the Docker console set up the environment for the target NVIDIA Jetson machine: `MACHINE=<MACHINE> source setup-environment [BUILDDIR]`, where `MACHINE` is one of the following:
 * `jetson-orin-nano-devkit` - Jetson Orin Nano DevKit with SD card boot option
 * `jetson-orin-nano-devkit-nvme` - Jetson Orin Nano DevKit with NVME SSD boot option
 * `jetson-agx-thor-devkit` - Jetson AGX Thor DevKit (T5000)
 * `jetson-agx-thor-t4000` - Jetson AGX Thor (T4000)

`BUILDDIR` is the directory where you would like to to store the build files. For example:
```
$$ MACHINE=jetson-orin-nano-devkit-nvme source setup-environment build-jetson-orin-nano
```
4. Build the Torizon images:
```
$$ bitbake torizon-docker
```

Flash the Device
======
1. When the build completes, a `.tegraflash-tar.zst` package appears in the deploy directory (`<builddir>/deploy/images/<machine>/`). It bundles the NVIDIA initrd installer (a special Linux+initrd launched on the target over USB), the bootloader image for the QSPI flash, and the OSTree-based Torizon rootfs image. Flashing is done with the `initrd-flash` script from the unpacked package. For the underlying flashing mechanism and full board-specific hardware details (recovery-mode entry, cabling, and port locations), refer to NVIDIA's official [Jetson Developer Kit flashing guide](https://docs.nvidia.com/jetson/archives/r38.2/DeveloperGuide/IN/QuickStart.html#to-flash-the-jetson-developer-kit-operating-software).

2. Unpack the package into an empty directory:
```
$ mkdir -p ~/flashing && cd ~/flashing
$ tar --zstd -xf <builddir>/deploy/images/<machine>/torizon-docker-<machine>.tegraflash-tar.zst
```

3. **Verify the extracted rootfs image before flashing.**

> [!WARNING]
> **Always check the extracted rootfs image before you flash.** The rootfs
> `.ota-ext4` is a large sparse image, and a truncated or interrupted extraction
> — a missing `zstd` binary, not enough free disk space, or a `tar` that
> mishandles sparse files — **silently** produces a short file. That file
> **flashes without any error**, but the target then **fails to boot**,
> hanging with:
>
> ```
> EXT4-fs error (device nvme0n1p1): ext4_get_journal_inode: inode #8: comm mount: iget: checksum invalid
> EXT4-fs (nvme0n1p1): no journal found
> ```
>
> because the journal lies past the truncation point. This failure is easy to
> misattribute to the flashing tool or the host — it is neither. Run the
> check below and **confirm it passes before flashing**:
>
> ```
> $ e2fsck -fn torizon-docker.ota-ext4
> ```
>
> It must complete with **no errors**. If it reports a corrupt journal or a
> short read, the extraction is incomplete: re-extract (make sure `zstd` is
> installed and there is enough free disk space) and check again before
> continuing.

4. Connect the target's USB-C flashing port to the host and put the board into Force Recovery mode. The port location and the recovery procedure differ by carrier board:

 * **Jetson Orin Nano DevKit:** this carrier enters recovery via a header jumper rather than a button:
     1. Ensure the developer kit is powered off.
     2. Install a jumper across the `FORCE_RECOVERY` (`FC_REC`) and `GND` pins — contacts `9-10` of the `J14` button header.
     3. Connect the USB-C port to the host and power on the board.

    See the [Jetson Orin Nano Developer Kit Carrier Board Specification](https://developer.nvidia.com/downloads/assets/embedded/secure/jetson/orin_nano/docs/jetson_orin_nano_devkit_carrier_board_specification_sp.pdf) for the header pinout.
 * **Jetson AGX Thor DevKit:** connect the flashing cable to the USB-C port at **`J81`**, then put the board into Force Recovery mode:
     1. Ensure the developer kit is powered off.
     2. Press and hold the **Force Recovery** button.
     3. Press, then release the **Power** button.
     4. Release the **Force Recovery** button.

    See NVIDIA's [Jetson AGX Thor flashing guide](https://docs.nvidia.com/jetson/archives/r38.2/DeveloperGuide/IN/QuickStart.html#to-flash-the-jetson-developer-kit-operating-software) for the authoritative procedure and board details.

Confirm the host detects the board in recovery mode:
```
$ lsusb -d 0955:
```

5. Run the flashing script from the unpacked directory:
```
$ sudo ./initrd-flash
```

Boot
======
1. Use the TTL to USB converter cable to connect the serial console (refer to JetsonHacks video: https://www.youtube.com/watch?v=Kwpxhw41W50).

2. Remove the recovery mode jumper and power the target board on.

3. From the serial console terminal, monitor the target boot sequence:
```
Jetson System firmware version v36.4.4 date 1970-01-01T00:00:00+00:00
ESC   to enter Setup.
...
Common Torizon OS 7.5.0-devel-20251205093706+build.0 jetson-orin-nano-devkit-nvme ttyTCU0

jetson-orin-nano-devkit-nvme login:

```
4. Login to the board using the `torizon/torizon` credentials.

Run NVIDIA containers
======

These images do not include the NVIDIA container runtime (`nvidia-container-toolkit`). To use the GPU from a container, pass the required device nodes in yourself and provide the matching NVIDIA L4T userspace (CUDA, EGL/GLES, etc.) inside the container image, since the Torizon host does not ship any GPU userspace.

The GPU device nodes differ by machine, because the GPU and its kernel driver differ:

 * Jetson Orin Nano (Tegra234) exposes the Tegra `nvgpu` nodes: `/dev/nvhost-*`, `/dev/nvgpu/*` and `/dev/nvmap`.
 * Jetson AGX Thor (Tegra264) exposes the standard NVIDIA driver nodes: `/dev/nvidia*` (for example `/dev/nvidia0`, `/dev/nvidiactl`, `/dev/nvidia-uvm`).

List what is actually present on the target before running a container:

```
$ ls /dev/nvidia* /dev/nvhost* /dev/nvgpu /dev/nvmap 2>/dev/null
```

Pass the nodes your workload needs into the container. For example, on the Jetson Orin Nano:

```
sudo docker run -it --rm --network=host \
  --device /dev/nvhost-gpu --device /dev/nvhost-ctrl-gpu \
  --device /dev/nvhost-as-gpu --device /dev/nvhost-ctrl \
  --device /dev/nvmap --device /dev/nvgpu \
  <your-cuda-image>
```

Adjust the device list to match what the command above lists on your target.
