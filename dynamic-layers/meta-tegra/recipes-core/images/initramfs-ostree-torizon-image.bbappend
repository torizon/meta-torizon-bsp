PACKAGE_INSTALL:append = " \
    tegra-firmware-xusb \
    kernel-module-nvme \
"

PACKAGE_INSTALL:append:tegra234 = " \
    kernel-module-pcie-tegra194 \
    kernel-module-phy-tegra194-p2u \
    kernel-module-tegra-xudc \
    kernel-module-ucsi-ccg \
"

PACKAGE_INSTALL:append:tegra264 = " \
    nv-kernel-module-pcie-tegra264 \
    nv-kernel-module-ufs-tegra \
"

# IMAGE_FSTYPES is hardcoded to "cpio.gz" in the base recipe, bypassing
# meta-tegra's INITRAMFS_FSTYPES mechanism that would normally add this.
# do_image_tegraflash_tar needs the .cboot-wrapped variant.
IMAGE_FSTYPES:append:tegra = " cpio.gz.cboot"
