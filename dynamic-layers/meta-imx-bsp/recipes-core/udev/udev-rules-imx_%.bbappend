# Temporary workaround, drop once nxp-imx/meta-imx#56 is merged:
# https://github.com/nxp-imx/meta-imx/pull/56
#
# meta-freescale checksums an SPDX line at the top of 10-imx.rules, but
# meta-imx replaces the file with one that has no such line, so
# do_populate_lic fails the license checksum.

do_unpack[postfuncs] += "udev_rules_imx_add_spdx"

udev_rules_imx_add_spdx() {
    rules="${UNPACKDIR}/10-imx.rules"
    if head -n 1 "$rules" | grep -q 'SPDX-License-Identifier'; then
        bbwarn "10-imx.rules already has an SPDX line," \
               "drop this udev-rules-imx bbappend."
    else
        sed -i '1i # SPDX-License-Identifier: MIT' "$rules"
    fi
}
