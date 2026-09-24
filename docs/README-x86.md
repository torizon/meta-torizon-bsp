Setup
======
1. If you don't have the `repo` tool installed, please refer to [Build Torizon OS From Source with Yocto Project](https://developer.toradex.com/torizon/in-depth/build-torizoncore-from-source-with-yocto-projectopenembedded/#download-metadata).
2. Initialize and sync the repo manifest for x86:
```bash
$ mkdir common-torizon; cd common-torizon
$ repo init -u https://github.com/torizon/manifest.git -b wrynose-8.x.y -m torizon/x86/release.xml
$ repo sync -j 10
```
> Manifests for Wrynose are still under development

We **strongly recommend** using the `release.xml` manifest. The `integration.xml` and `next.xml` are development manifests used internally and they might be unstable.
`release.xml` is the manifest used for our releases, so they are reliable.
> [!IMPORTANT]  
> Common Torizon OS is only available on branches `scarthgap-7.x.y` or newer!

Alternatively, you can manually clone all layers one by one. Refer to the section _Manual Setup_ at the end of this document to learn how.

Build
======
1. Source `setup-environment`:
```bash
$ MACHINE=intel-corei7-64 . setup-environment build-corei7-64
```
This will create a build folder named `build-corei7-64`, where all build artifacts will be stored.

2. Inside the build directory, start the build e.g.:
```bash
$ bitbake torizon-docker
```

All artifacts should be inside `build-corei7-64/deploy/images/intel-corei7-64`, including the `.wic` file.

Test on Virtual Box
======
Setup a virtual machine to test the image built, using the generated `.wic.vdi` or `.wic.vmdk`.

Below is a script for setting up a virtual machine inside Virtual Box, called `Common-Torizon`:
```bash
# Setup new machine Common-Torizon
VBoxManage createvm --name Common-Torizon --ostype "Linux_64" --register --basefolder "$HOME/CommonTorizonVBoxVM"
VBoxManage modifyvm Common-Torizon --firmware efi64
# Attempt at serial connection (cant communicate but can inspect serial logs via 'tail -f /tmp/serial')
VBoxManage modifyvm Common-Torizon --cpus 2 --memory 2048 --vram 256 --graphicscontroller vmsvga --uart1 0x3F8 4 --uartmode1 file /tmp/serial

VBoxManage storagectl Common-Torizon --name "SATA Controller" --add sata --bootable on
VBoxManage storageattach Common-Torizon --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium "torizon-docker-intel-corei7-64.wic.vdi"
# Port forwarding for SSH on port 2222
VBoxManage modifyvm Common-Torizon --nat-pf1=ssh,tcp,,2222,,3791 --nat-pf2=ssh_tor,tcp,,2223,,22

VBoxManage startvm Common-Torizon
```

Test on QEMU
======

Run using QEMU:

```bash
$ qemu-system-x86_64 -drive if=virtio,file=torizon-docker-intel-corei7-64.wic,format=raw -no-reboot -cpu host -nic user,hostfwd=tcp::2222-:22 -machine pc -vga virtio -m 4096 -bios /usr/share/ovmf/OVMF.fd -enable-kvm -serial pty
```

---

Manual Setup
======
1. Create your build folder structure. Something like:
```bash
$ mkdir common-torizon; cd common-torizon
$ mkdir layers; cd layers
```
2. Clone the layers needed to build x86 Common Torizon:  
  * Download openembedded-core and bitbake
```bash
$ git clone https://git.openembedded.org/openembedded-core -b wrynose oe-core
$ git clone https://git.openembedded.org/bitbake -b 2.18 oe-core/bitbake
```
  * Download `meta-yocto`:
```bash
$ git clone https://git.yoctoproject.org/meta-yocto -b wrynose
```
  * Download `meta-intel`, `meta-torizon`, and `meta-torizon-bsp`:
```bash
$ git clone https://git.yoctoproject.org/meta-intel -b wrynose
$ git clone https://github.com/torizon/meta-torizon.git -b wrynose-8.x.y
$ git clone https://github.com/torizon/meta-torizon-bsp.git -b wrynose-8.x.y
```
  * Download the Torizon OS layers' dependencies:
```bash
$ git clone https://github.com/uptane/meta-updater.git -b wrynose
$ git clone https://git.yoctoproject.org/meta-virtualization -b wrynose
$ git clone https://git.yoctoproject.org/meta-security -b wrynose

```
  * And finally, download `meta-updater` and `meta-virtualization` dependency: 
```bash
$ git clone https://github.com/openembedded/meta-openembedded -b wrynose
```
  * Go back into our top folder `common-torizon`
  * Create a symlink to our `setup-environment`:
```bash
$ ln -s layers/meta-torizon-bsp/scripts/setup-environment setup-environment
```
