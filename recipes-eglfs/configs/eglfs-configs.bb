SUMMARY = "Recipe to configure QT webkit enviornment"
LICENSE = "Enovation-Proprietary"
LIC_FILES_CHKSUM = "file://${STM32MP_META_HLIO_RCD_BASE}/licenses/Enovation-Controls-License.rtf;md5=7a35371310afae6d2edc9c24089f674f"


# Add source names
SRC_URI += "\
        file://eglfs_config.json \
"

# Indicate that the json file is a configuration file
CONFFILES:${PN} = "${sysconfdir}/eglfs_config.json"

do_install() {
        install -d ${D}${sysconfdir}
        install -m 0644 ${WORKDIR}/eglfs_config.json ${D}${sysconfdir}/
}


# make sure to ship the files as part of the package group
FILES:${PN} += "${sysconfdir}/eglfs_config.json"
