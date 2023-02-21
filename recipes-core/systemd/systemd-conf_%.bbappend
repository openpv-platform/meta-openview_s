FILESEXTRAPATHS:prepend := "${THISDIR}/files/:"

SRC_URI += " \
    file://80-can0.network \
    file://80-can1.network \
    "

do_install:append() {
    install -d ${D}${sysconfdir}/systemd/network
    install -m 0644 ${WORKDIR}/80-can0.network ${D}${sysconfdir}/systemd/network
    install -m 0644 ${WORKDIR}/80-can1.network ${D}${sysconfdir}/systemd/network
}

FILES:${PN} += "${sysconfdir}/systemd/network/80-can0.network ${sysconfdir}/systemd/network/80-can1.network"