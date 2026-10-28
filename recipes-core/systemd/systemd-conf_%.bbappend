do_install:append:aquila-am69() {
	sed -i '/^RuntimeWatchdogSec=/d' ${D}${systemd_unitdir}/system.conf.d/10-${BPN}.conf
}

# qcom_wdt accepts at most 32 s: with the oe-core default (60 s), systemd cannot
# arm the watchdog for reboot, so a hang during reboot is never reset.
do_install:append:qcom() {
	echo "RebootWatchdogSec=30s" >> ${D}${systemd_unitdir}/system.conf.d/10-${BPN}.conf
}
