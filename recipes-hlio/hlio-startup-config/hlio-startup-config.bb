SUMMARY = "Hlio Startup Config"
LICENSE = "CLOSED"

SRC_URI = "file://${BPN}.sh \
           file://${BPN}.service \
           "

inherit systemd
SYSTEMD_AUTO_ENABLE = "enable"
SYSTEMD_SERVICE_${PN} = "${PN}.service"

RDEPENDS_${PN} += "bash"

do_install_append() {
    # Service and first boot script
    install -d ${D}${systemd_unitdir}/system
    install -m 0644 ${WORKDIR}/${PN}.service ${D}${systemd_unitdir}/system

    install -d ${D}${bindir}
    install -m 0755 ${WORKDIR}/${PN}.sh ${D}${bindir}
}

FILES_${PN} += "${systemd_unitdir} ${bindir}"
