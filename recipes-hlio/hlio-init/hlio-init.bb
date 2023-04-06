SUMMARY = "Hlio custom init script"
LICENSE = "Enovation-Proprietary"
LIC_FILES_CHKSUM = "file://${STM32MP_META_HLIO_RCD_BASE}/licenses/Enovation-Controls-License.rtf;md5=7a35371310afae6d2edc9c24089f674f"

SRC_URI = " file://hlio-init.sh \
            file://early-weston.sh \
            file://assign-can.sh \
           "

RDEPENDS:${PN} += "bash weston dtb-overlays"

do_install:append() {
    # install Custom init script
    install -d ${D}${base_sbindir}
    install ${WORKDIR}/hlio-init.sh ${D}${base_sbindir}/hlio-init.sh
    
    # install early weston script
    install ${WORKDIR}/early-weston.sh ${D}${base_sbindir}/early-weston.sh

    # install helper function to allow switching CAN peripheral from A7->M4 and vice versa
    install -m 755 ${WORKDIR}/assign-can.sh ${D}${base_sbindir}/assign-can.sh
}

FILES:${PN} += "${base_sbindir}/hlio-init.sh \
                ${base_sbindir}/early-weston.sh \
                ${base_sbindir}/assign-can.sh "
