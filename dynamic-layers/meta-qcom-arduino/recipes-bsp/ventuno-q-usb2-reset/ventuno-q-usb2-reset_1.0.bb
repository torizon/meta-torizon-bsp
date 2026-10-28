SUMMARY = "VENTUNO Q: restart the MCU USB controller (usb_2) once at boot"
DESCRIPTION = "Workaround: usb_2, which carries the link to the STM32 MCU, \
comes up unable to detect devices (cause unknown). Rebinding the controller \
once, late in boot, fixes it."
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

SRC_URI = " \
    file://ventuno-q-usb2-reset \
    file://ventuno-q-usb2-reset.service \
"

S = "${UNPACKDIR}"

inherit systemd

COMPATIBLE_MACHINE = "ventuno-q"
PACKAGE_ARCH = "${MACHINE_ARCH}"

SYSTEMD_SERVICE:${PN} = "ventuno-q-usb2-reset.service"

do_install() {
    install -D -m 0755 ${S}/ventuno-q-usb2-reset ${D}${libexecdir}/ventuno-q-usb2-reset
    install -D -m 0644 ${S}/ventuno-q-usb2-reset.service ${D}${systemd_system_unitdir}/ventuno-q-usb2-reset.service
}
