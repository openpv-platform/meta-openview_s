SUMMARY = "Hlio first boot"
LICENSE = "CLOSED"

SRC_URI = "file://${PN} \
           file://${PN}.service \
           file://extlinux.conf \
           "

inherit systemd
SYSTEMD_AUTO_ENABLE = "enable"
SYSTEMD_SERVICE_${PN} = "${PN}.service"

RDEPENDS_${PN} += "bash psplash-drm hlio-init"

do_install_append() {
    # Service and first boot script
    install -d ${D}${systemd_unitdir}/system
    install -m 0644 ${WORKDIR}/${PN}.service ${D}${systemd_unitdir}/system

    install -d ${D}${bindir}
    install -m 0644 ${WORKDIR}/${PN} ${D}${bindir}

    # modified extlinux conf 
    install -d ${D}${datadir}/${PN}
    install -m 0644 ${WORKDIR}/extlinux.conf ${D}${datadir}/${PN}
}

FILES_${PN} += "${systemd_unitdir} ${bindir} ${datadir}"
