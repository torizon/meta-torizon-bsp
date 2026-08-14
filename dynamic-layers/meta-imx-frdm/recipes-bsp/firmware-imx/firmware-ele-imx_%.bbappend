# The recipe's do_install guards installing the optional extended SECO
# firmware with `[ -e ${S}/${SECOEXT_FIRMWARE_NAME} ]`, but on mx93
# SECOEXT_FIRMWARE_NAME is unset (empty), so that path collapses to
# `${S}/` — a directory that always exists — and `install` then fails
# trying to install a directory as a regular file.
do_install() {
    install -d ${D}${nonarch_base_libdir}/firmware/imx/ele
    install -m 0644 ${S}/${SECO_FIRMWARE_NAME} ${D}${nonarch_base_libdir}/firmware/imx/ele
    if [ -n "${SECOEXT_FIRMWARE_NAME}" ] && [ -e ${S}/${SECOEXT_FIRMWARE_NAME} ]; then
        install -m 0644 ${S}/${SECOEXT_FIRMWARE_NAME} ${D}${nonarch_base_libdir}/firmware/imx/ele
    fi
}
