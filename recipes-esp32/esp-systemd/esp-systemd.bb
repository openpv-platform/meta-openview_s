# 
DESCRIPTION = "ESP32 module startup: Create the device node, verify and update firmware, start up module."
LICENSE = "CLOSED"

SRC_URI = " \
            file://esp-devnode.service \
            file://esp-firmware.service \
            "

S = "${WORKDIR}"

inherit systemd

RDEPENDS_${PN} = " \
                  esp-hosted \
                  esp-support \
                  "

SYSTEMD_PACKAGES = "${PN}"
SYSTEMD_SERVICE_${PN} = "esp-devnode.service esp-firmware.service"
SYSTEMD_AUTO_ENABLE_${PN} = "enable"

do_install() {
    install -d ${D}${systemd_unitdir}/system
    install -m 0644 ${WORKDIR}/esp-devnode.service ${D}${systemd_unitdir}/system
    install -m 0644 ${WORKDIR}/esp-firmware.service ${D}${systemd_unitdir}/system
}
