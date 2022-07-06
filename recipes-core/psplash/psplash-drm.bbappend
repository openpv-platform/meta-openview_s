# Change the Files path for the procps directory with the one that is in our repository.
FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

DEPENDS += "gdk-pixbuf"

SRC_URI += " \
        file://splash.jpg \
    "

SPLASH_PATH = "${D}${datadir}/psplash"

do_install_append() {
    install -d ${SPLASH_PATH}
    install -m 755 ${WORKDIR}/splash.jpg ${SPLASH_PATH}
    install -m 755 ${WORKDIR}/splash.jpg ${SPLASH_PATH}/default.jpg  
}

FILES_${PN} += "${datadir}"