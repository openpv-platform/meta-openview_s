DESCRIPTION = "A custom recipe to give users general BSP info on the current running RCD Image"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

SRC_URI = " \
        file://bsp-info \
        file://bsp-description \
        file://bsp-version \
    "

RDEPENDS_bsp-info = "bash"
INFO_PATH = "${D}${datadir}/bsp-info"


do_install() {
    install -d ${D}${bindir}
    install -m 755 ${WORKDIR}/${PN} ${D}${bindir}

    install -d ${INFO_PATH}
    install -m 0644 ${WORKDIR}/bsp-description ${INFO_PATH}/bsp-description
    install -m 0644 ${WORKDIR}/bsp-version ${INFO_PATH}/bsp-version

}

FILES_${PN} += "${bindir}"
FILES_${PN} += "${datadir}"
