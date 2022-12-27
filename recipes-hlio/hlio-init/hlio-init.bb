SUMMARY = "Hlio custom init script"
LICENSE = "Enovation-Proprietary"
LIC_FILES_CHKSUM = "file://${STM32MP_META_HLIO_RCD_BASE}/licenses/Enovation-Controls-License.rtf;md5=7a35371310afae6d2edc9c24089f674f"

SRC_URI = "file://hlio-init.sh \
           "

RDEPENDS:${PN} += "bash psplash-drm"

do_install:append() {
    # Custom init script
    install -d ${D}${base_sbindir}
    install ${WORKDIR}/hlio-init.sh ${D}${base_sbindir}
}

FILES:${PN} += "${base_sbindir}"
