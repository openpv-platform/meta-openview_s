SUMMARY = "Install fw_env.conf"
LICENSE = "Enovation-Proprietary"
LIC_FILES_CHKSUM = "file://${STM32MP_META_HLIO_RCD_BASE}/licenses/Enovation-Controls-License.rtf;md5=7a35371310afae6d2edc9c24089f674f"

#THISAPPENDFILESDIR:prepend := "${THISDIR}/files/:"
FILESEXTRAPATHS:prepend := "${THISDIR}/files/:"

SRC_URI:append = " \
                file://fw_env.config \
                "

# S = "${WORKDIR}"

do_install:append () {
    install -d ${D}${sysconfdir}
    install -m 0644 ${WORKDIR}/fw_env.config ${D}${sysconfdir}/fw_env.config
}

FILES:${PN} += "${sysconfdir}/fw_env.config"
