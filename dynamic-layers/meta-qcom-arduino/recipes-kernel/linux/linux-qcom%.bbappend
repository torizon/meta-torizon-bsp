# Torizon's required kernel settings. linux-qcom merges .cfg fragments, not the
# .scc files the include adds, so the raw fragments are added for the machines
# here: torizon.cfg always, the composefs ones when the distro enables them.
require recipes-kernel/linux/linux-torizon.inc
SRC_URI:append:ventuno-q = " file://torizon.cfg"
SRC_URI:append:ventuno-q:cfs-support = " file://composefs.cfg"
SRC_URI:append:ventuno-q:cfs-signed = " file://composefs-fsverity.cfg"

# linux-qcom checks the kernel out without a branch on purpose (meta-qcom
# ef0de951: the Qualcomm kernel branches are rewritten at every tag, so the
# recipes pin tagged commits with nobranch=1). The deploy step of
# linux-torizon.inc records the branch for the OSTree metadata and fails on a
# detached checkout: give it a local branch named after the upstream one the
# tag comes from (qcom-6.18.y for 6.18). Same commit, no file changes.
LINUX_QCOM_SCMBRANCH ?= "qcom-${@'.'.join(d.getVar('PV').split('.')[:2])}.y"
linux_qcom_scmbranch() {
	git --git-dir=${S}/.git symbolic-ref -q HEAD >/dev/null ||
		git --git-dir=${S}/.git --work-tree=${S} checkout -q -B ${LINUX_QCOM_SCMBRANCH}
}
do_deploy[prefuncs] += "linux_qcom_scmbranch"

FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI:append:ventuno-q = " file://0001-arm64-dts-qcom-monaco-arduino-monza-power-the-wlan-bt-module.patch \
    file://0002-arm64-dts-qcom-monaco-arduino-monza-enable-the-USB-link-to-the-MCU.patch \
    file://0003-misc-fastrpc-drop-leftover-invoke-contexts-on-release.patch \
    file://0004-net-stmmac-qcom-ethqos-configure-the-SerDes-for-the-interface-mode.patch \
    file://ventuno-q-edid.cfg \
"
