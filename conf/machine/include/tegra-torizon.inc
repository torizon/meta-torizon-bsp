TEGRA_ESSENTIAL_EXTRA_RDEPENDS:remove = " \
  l4t-launcher-extlinux \
"

OSTREE_KERNEL_ARGS:append = " ${KERNEL_ARGS} root=/dev/${TNSPEC_BOOTDEV} rootfstype=ext4 rootwait"

IMAGE_TEGRAFLASH_KERNEL = "${DEPLOY_DIR_IMAGE}/tegra-minimal-initramfs-${MACHINE}.cboot"
IMAGE_TEGRAFLASH_FS_TYPE:tegra = "ota-ext4"

BBMASK += "meta-tegra/external/sota/recipes-bsp/uefi/edk2-firmware-tegra_%.bbappend"

do_image_tegraflash_tar[depends] += " tegra-minimal-initramfs:do_image_complete"

MACHINE_EXTRA_RDEPENDS:remove = " tegra-redundant-boot"

# meta-tegra uses A/B layout, we don't want it here.
HAS_REDUNDANT_PARTITION_LAYOUT_EXTERNAL = "0"

PREFERRED_PROVIDER_u-boot-fw-utils = "u-boot-fw-utils-tegra-emul"
PREFERRED_RPROVIDER_u-boot-fw-utils = "u-boot-fw-utils-tegra-emul"
