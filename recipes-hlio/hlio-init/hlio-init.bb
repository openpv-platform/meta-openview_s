SUMMARY = "Hlio custom init script"
LICENSE = "CLOSED"

SRC_URI = "file://hlio-init.sh \
           "

RDEPENDS_${PN} += "bash psplash-drm"

do_install_append() {
    # Custom init script
    install -d ${D}${base_sbindir}
    install ${WORKDIR}/hlio-init.sh ${D}${base_sbindir}
}

FILES_${PN} += "${base_sbindir}"
