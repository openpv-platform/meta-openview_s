require conf/include/esp-hosted-srcrev.inc

DESCRIPTION = "ESP32 module startup: Create the device node, verify and update firmware, start up module."
LICENSE = "Enovation-Proprietary"
LIC_FILES_CHKSUM = "file://${STM32MP_META_HLIO_RCD_BASE}/licenses/Enovation-Controls-License.rtf;md5=7a35371310afae6d2edc9c24089f674f"

SRC_URI = " \
            file://esp-devnode.service \
            file://esp-firmware.service \
            "

S = "${WORKDIR}"

inherit systemd

RDEPENDS:${PN} = " \
                  esp-hosted \
                  esp-support \
                  "

SYSTEMD_PACKAGES = "${PN}"
SYSTEMD_SERVICE:${PN} = "esp-devnode.service esp-firmware.service"
SYSTEMD_AUTO_ENABLE:${PN} = "enable"

do_install() {
    sed -i "s/FIRMWARE_VERSION/${ESP_HOSTED_PV}/g" ${WORKDIR}/esp-firmware.service
    install -d ${D}${systemd_unitdir}/system
    install -m 0644 ${WORKDIR}/esp-devnode.service ${D}${systemd_unitdir}/system
    install -m 0644 ${WORKDIR}/esp-firmware.service ${D}${systemd_unitdir}/system
}
