SUMMARY = "Hlio first boot"
LICENSE = "Enovation-Proprietary"
LIC_FILES_CHKSUM = "file://${STM32MP_META_HLIO_RCD_BASE}/licenses/Enovation-Controls-License.rtf;md5=7a35371310afae6d2edc9c24089f674f"

SRC_URI = "file://${BPN} \
           file://${BPN}.service \
           file://extlinux.conf \
           "

inherit systemd
SYSTEMD_AUTO_ENABLE = "enable"
SYSTEMD_SERVICE:${BPN} = "${BPN}.service"

RDEPENDS:${PN} += "bash psplash-drm hlio-init"

do_install:append() {
    # Service and first boot script
    install -d ${D}${systemd_unitdir}/system
    install -m 0644 ${WORKDIR}/${PN}.service ${D}${systemd_unitdir}/system

    install -d ${D}${bindir}
    install -m 0644 ${WORKDIR}/${PN} ${D}${bindir}

    # modified extlinux conf 
    install -d ${D}${datadir}/${PN}
    install -m 0644 ${WORKDIR}/extlinux.conf ${D}${datadir}/${PN}
}

FILES:${PN} += "${systemd_unitdir} ${bindir} ${datadir}"
