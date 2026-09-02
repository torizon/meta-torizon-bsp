FILESEXTRAPATHS:prepend := "${THISDIR}/${BPN}:"
SRC_URI += " \
  file://x86/fstab \
  file://beagley-ai/fstab \
"

do_install:append:intel-x86-common() {
	# Replace fstab with our own for Intel Core i7-64
	install -m 644 ${UNPACKDIR}/x86/fstab ${D}${sysconfdir}/fstab
}

do_install:append:beagley-ai() {
	install -d ${D}/boot/vendor_boot
    install -m 644 ${UNPACKDIR}/beagley-ai/fstab ${D}${sysconfdir}/fstab
}

remove_dev_root_from_fstab() {
  # Get rid of the /dev/root entry in fstab to avoid errors from
  # systemd-remount-fs.
  sed -i -e '\#^ */dev/root#d' ${D}${sysconfdir}/fstab
}

BASE_FILES_POSTFUNCS = ""
BASE_FILES_POSTFUNCS:cfs-support = "remove_dev_root_from_fstab"

do_install[postfuncs] += " ${BASE_FILES_POSTFUNCS}"
