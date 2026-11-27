FILESEXTRAPATHS:prepend := "${THISDIR}/${BPN}:"

SRC_URI += " \
    file://torizon-fastlogo.py \
    file://torizonlogo-white.png \
"

inherit python3native

# Swap the vendor logo pictures for the Torizon one before the vendor
# do_compile:append signs the blob. Only sl1680 (and Luna, which carries the
# sl1680 override): the converter handles UYVY pictures, and sl2619's are RGB24.
DEPENDS:append:sl1680 = " python3-pillow-native"

do_compile:prepend:sl1680 () {
    blob="${S}/configs/product/${SYNA_SDK_CONFIG_NAME}/fastlogo.subimg.gz"
    if [ -f "${blob}" ]; then
        nativepython3 ${UNPACKDIR}/torizon-fastlogo.py ${UNPACKDIR}/torizonlogo-white.png "${blob}"
    else
        bbnote "no vendor fastlogo at ${blob}, keeping the vendor logo"
    fi
}
