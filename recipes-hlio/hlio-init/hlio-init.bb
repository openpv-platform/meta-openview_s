SUMMARY = "Hlio custom init script"
LICENSE = "CLOSED"

SRC_URI = "file://hlio-init.sh \
           "

RDEPENDS:${PN} += "bash psplash-drm"

do_install:append() {
    # Custom init script
    install -d ${D}${base_sbindir}
    install ${WORKDIR}/hlio-init.sh ${D}${base_sbindir}
}

FILES:${PN} += "${base_sbindir}"
