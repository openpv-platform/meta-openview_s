# appending to base-files recipe found in openembedded-core/meta/recipes-core/base-files/

FILESEXTRAPATHS_prepend := "${THISDIR}/files/:"

SRC_URI += " \
           file://hlio-rcd-profile \
           "

do_install_append() {
    rm ${D}${sysconfdir}/profile
    install -m 0644 ${WORKDIR}/hlio-rcd-profile ${D}${sysconfdir}/profile
}


# rm ${D}${sysconfdir}/profile