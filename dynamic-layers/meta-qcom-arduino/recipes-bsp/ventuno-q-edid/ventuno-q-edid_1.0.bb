SUMMARY = "VENTUNO Q: default HDMI EDID (1920x1080@60)"
DESCRIPTION = "Workaround: the HDMI EDID of the monitor is not read, so the \
display falls back to 1024x768. The kernel loads this EDID instead \
(drm.edid_firmware in ventuno-q.inc)."
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

SRC_URI = "file://1080p60.bin"

S = "${UNPACKDIR}"

COMPATIBLE_MACHINE = "ventuno-q"
PACKAGE_ARCH = "${MACHINE_ARCH}"

do_install() {
    install -D -m 0644 ${S}/1080p60.bin ${D}${nonarch_base_libdir}/firmware/edid/1080p60.bin
}

FILES:${PN} = "${nonarch_base_libdir}/firmware/edid"
