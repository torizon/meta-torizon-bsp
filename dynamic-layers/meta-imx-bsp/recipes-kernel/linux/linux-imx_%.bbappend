require recipes-kernel/linux/linux-torizon.inc

FILESEXTRAPATHS:prepend:mx6-generic-bsp := "${THISDIR}/files:"
SRC_URI:append:mx6-generic-bsp = " file://torizon-container.cfg"

SRC_URI:append:imx6sxsabresd = " file://0001-ARM-dts-imx6sx-sdb-reva-reset-through-the-internal-wa.patch"
