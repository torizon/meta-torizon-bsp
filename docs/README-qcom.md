Common Torizon OS for Qualcomm machines
=======

Supported machines:
 * `ventuno-q` - Arduino VENTUNO Q (Qualcomm QCS8300 / Dragonwing IQ-8275), from
   [meta-qcom-arduino](https://github.com/qualcomm-linux/meta-qcom-arduino)

Boot flow: XBL -> UEFI -> systemd-boot -> UKI -> OSTree. There is no U-Boot; the OSTree
integration (BLS entries with boot counting, `qcomflash` image) comes from the
`sota_qcom` class of meta-updater.

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
$ curl https://storage.googleapis.com/git-repo-downloads/repo > ~/bin/repo
$ chmod a+x ~/bin/repo
```
3. Initialize and sync the Torizon repositories in an empty working directory:
```
$ mkdir ~/yocto-workdir && cd ~/yocto-workdir
$ repo init -u https://github.com/torizon/manifest.git -b wrynose-8.x.y -m torizon/qcom/integration.xml
$ repo sync
```
> [!IMPORTANT]
> Until an official release, only `integration.xml` (external layers pinned) and
> `next.xml` (all layers on branch HEAD) are available for Qualcomm machines.

Build
======
1. Start the build container in the work directory:
```
$ docker run --rm -it --name=crops -v ~/yocto-workdir:/workdir --workdir=/workdir torizon/crops:wrynose-8.x.y /bin/bash
```
2. Set up the environment and build:
```
$$ git config --global user.email "you@example.com"
$$ git config --global user.name "Your Name"
$$ MACHINE=ventuno-q source setup-environment build-ventuno-q
$$ bitbake torizon-docker
```
The flashable package is
`build-ventuno-q/deploy/images/ventuno-q/torizon-docker-ventuno-q.qcomflash.tar.gz`.

Flash the Device
======
The board is flashed in Emergency Download (EDL) mode with
[qdl](https://github.com/linux-msm/qdl). Flashing erases the whole eMMC.

1. Unpack the package on the host connected to the board:
```
$ tar xzf torizon-docker-ventuno-q.qcomflash.tar.gz
$ cd torizon-docker-ventuno-q
```
2. Enter EDL mode:
    1. Disconnect all cables from the board (power, USB-C, serial).
    2. Bridge pin 1 (`GND`) and pin 2 (`FORCE_BOOT`) of the `JCTL` header with a jumper.
       See the [VENTUNO Q full pinout](https://docs.arduino.cc/resources/pinouts/ABX00181-full-pinout.pdf).
    3. Connect power, then connect the USB-C port to the host.

   The host must detect the board as `05c6:9008`:
```
$ lsusb -d 05c6:9008
```
3. Flash:
```
$ qdl -s emmc prog_firehose_ddr.elf rawprogram0.xml rawprogram1.xml patch0.xml patch1.xml
```

Boot
======
1. Disconnect all cables, remove the `JCTL` jumper, connect Ethernet and HDMI, then power
   the board on.
2. The serial console is `ttyMSM0` at 115200 baud, on the `JCTL` header. The `JCTL` pins
   are 1.8 V logic only: use a 1.8 V USB-to-UART adapter. Disconnect it before a power
   cycle and reconnect it after power-on: if it stays connected, it can back-power the
   board, which then does not boot.
3. Log in as `torizon`; the default password is `torizon` and must be changed at first
   login.
