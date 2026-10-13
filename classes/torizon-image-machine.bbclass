# Machine-specific image settings lifted out of meta-torizon.

# from classes/image_type_torizon.bbclass : OTA u-boot binary per machine
UBOOT_BINARY_OTA:apalis-imx6 = "u-boot-with-spl.imx"
UBOOT_BINARY_OTA:colibri-imx6 = "u-boot-with-spl.imx"
UBOOT_BINARY_OTA:colibri-imx6ull-emmc = "u-boot.imx"
UBOOT_BINARY_OTA:colibri-imx7-emmc = "u-boot.imx"
UBOOT_BINARY_OTA:apalis-imx8 = "imx-boot"
UBOOT_BINARY_OTA:colibri-imx8x = "imx-boot"
UBOOT_BINARY_OTA:verdin-imx8mm = "imx-boot"
UBOOT_BINARY_OTA:verdin-imx8mp = "imx-boot"
UBOOT_BINARY_OTA:verdin-am62 = " \
    firmware-verdin-am62-gp.bin:gp \
    firmware-verdin-am62-hs-fs.bin:hs-fs \
    firmware-verdin-am62-hs.bin:hs \
"
UBOOT_BINARY_OTA:verdin-am62p = " \
    firmware-verdin-am62px-hs-fs.bin:hs-fs \
    firmware-verdin-am62px-hs.bin:hs \
"
UBOOT_BINARY_OTA:aquila-am69 = "u-boot.img"
UBOOT_BINARY_OTA:toradex-smarc-imx8mp = "u-boot.bin"
UBOOT_BINARY_OTA:toradex-smarc-imx95 = "u-boot.bin"
UBOOT_BINARY_OTA:qemuarm64 = "u-boot.bin"

# disable for now while we investigate build issues
UBOOT_BINARY_OTA_IGNORE:aquila-am69 = "1"
UBOOT_BINARY_OTA_IGNORE:aquila-imx95 = "1"
UBOOT_BINARY_OTA_IGNORE:toradex-smarc-imx8mp = "1"
UBOOT_BINARY_OTA_IGNORE:toradex-smarc-imx95 = "1"
UBOOT_BINARY_OTA_IGNORE:verdin-imx95 = "1"
UBOOT_BINARY_OTA_IGNORE:genericx86-64 = "1"
UBOOT_BINARY_OTA_IGNORE:lino-imx93 = "1"
UBOOT_BINARY_OTA_IGNORE:toradex-osm-imx93 = "1"

# from classes/image_type_torizon.bbclass : TorizonCore Builder signing

def is_hab_signed_bootloader_and_fit_enabled(d):
    if d.getVar('TDX_IMX_HAB_ENABLE') == '1' and d.getVar('UBOOT_SIGN_ENABLE') == '1':
        return '1'

    return '0'

TCB_SIGNING_SUPPORT:verdin-imx8mp ?= "${@is_hab_signed_bootloader_and_fit_enabled(d)}"
TCB_SIGNING_FILELIST:verdin-imx8mp ?= "uboot_config bl31* lpddr4_pmu_train_* u-boot.dtb u-boot-nodtb.bin spl/ u-boot-dtbs/"
TCB_SIGNING_SUPPORT:verdin-imx8mm ?= "${@is_hab_signed_bootloader_and_fit_enabled(d)}"
TCB_SIGNING_FILELIST:verdin-imx8mm ?= "uboot_config bl31* lpddr4_pmu_train_* u-boot.dtb u-boot-nodtb.bin spl/ u-boot-dtbs/"

# from classes/torizon_base_image_type.inc
# '^metadata_csum' is needed to allow uboot save env to ext4 filesystem
EXTRA_IMAGECMD:ota-ext4:qemuarm64 = "-O ^64bit,^metadata_csum -L otaroot -i 4096 -t ext4"



# from recipes-images/images/torizon-base.inc : per-machine rootfs content

# Base packages for Toradex modules. 'tdx' is a MACHINEOVERRIDE contributed by
# the machine confs in meta-toradex-bsp.
CORE_IMAGE_BASE_INSTALL:append:tdx = " \
    apparmor \
    alsa-ucm-conf \
    set-hostname \
    tdx-info \
    udev-toradex-rules \
"

# Packages that install firmwares/kernel modules that must be present
# in the rootfs. Firmware blobs, generally speaking, cannot be loaded
# from containers as their kernel module counterparts generally expect
# the files to be in an specific directory (generally /lib/firmware)

CORE_IMAGE_BASE_INSTALL:append:mx8-nxp-bsp = " \
    kernel-module-imx-gpu-viv \
"

CORE_IMAGE_BASE_INSTALL:append:am62xx = " \
    ti-img-rogue-driver \
"

CORE_IMAGE_BASE_INSTALL:append:verdin-am62p = " \
    ti-img-rogue-driver \
"

CORE_IMAGE_BASE_INSTALL:append:aquila-am69 = " \
    ti-img-rogue-driver \
    ti-edgeai-firmware \
"

# This does not compile succesfully on master
#CORE_IMAGE_BASE_INSTALL:append:mx8mp-nxp-bsp = " \
#    kernel-module-isp-vvcam \
#"

CORE_IMAGE_BASE_INSTALL:append:mx95-nxp-bsp = " \
    ${@bb.utils.contains("DISTROOVERRIDES", "common-torizon-distro", "mali-imx", "",d)} \
    ${@bb.utils.contains("BBFILE_COLLECTIONS", "imx-machine-learning", "neutron", "",d)} \
"

CORE_IMAGE_BASE_INSTALL:append:verdin-imx95 = " \
    mali-imx \
"

CORE_IMAGE_BASE_INSTALL:append:toradex-smarc-imx95 = " \
    mali-imx \
"

# Userspace driver stack for the Arm Ethos-U microNPU integrated in the
# i.MX93. The Cortex-M33 firmware (ethos-u-firmware) is already added via
# MACHINE_FIRMWARE in the machine conf and the kernel driver (CONFIG_ETHOSU)
# is built-in; this pulls in the userspace stack needed to dispatch inferences.
CORE_IMAGE_BASE_INSTALL:append:mx93-nxp-bsp = " \
    ethos-u-driver-stack \
"

# due to limited hardware resources, remove Colibri iMX6 Solo 256MB
# from the list of supported IDs in the Tezi image
TORADEX_PRODUCT_IDS:remove:colibri-imx6 = "0014 0016"
