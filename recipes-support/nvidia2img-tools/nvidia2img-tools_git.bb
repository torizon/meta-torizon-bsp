SUMMARY = "nvidia2img Tools"
DESCRIPTION = "Python zipapp tools for converting between raw disk images and the Nvidia image format"
HOMEPAGE = "https://gitlab.com/toradex/rd/torizon-core/nvidia2img"

LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://LICENSE;md5=f8119945852ced49987c9fa5b98500d0"

PV = "1.0.0+git"
SRC_URI = "git://gitlab.com/toradex/rd/torizon-core/nvidia2img.git;protocol=https;branch=main"
SRCREV = "5d1393699173a8ebe5a3afcf093e1bac5e4435d5"
SRCREV:use-head-next = "${AUTOREV}"

inherit deploy python3native nopackages

do_configure[noexec] = "1"

SCRIPTS = "tegra2img img2tegra"

do_compile() {
    for script in ${SCRIPTS}; do
        ${PYTHON} build.py ${script}
    done
}

NVIDIA_DEPLOY = "${DEPLOYDIR}/${BPN}"

do_deploy() {
    install -d ${NVIDIA_DEPLOY}
    for script in ${SCRIPTS}; do
        install -m 755 ${B}/${script}.pyz ${NVIDIA_DEPLOY}
    done
}

addtask deploy before do_build after do_compile

COMPATIBLE_MACHINE = "(tegra)"
INHIBIT_DEFAULT_DEPS = "1"
