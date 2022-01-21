SUMMARY = "Recipe to configure QT webkit enviornment"
LICENSE = "CLOSED"


# Add source names
SRC_URI += "\
        file://eglfs_config.json \
"

# Indicate that the json file is a configuration file
CONFFILES_${PN} = "${sysconfdir}/eglfs_config.json"

do_install() {
        install -d ${D}${sysconfdir}
        install -m 0644 ${WORKDIR}/eglfs_config.json ${D}${sysconfdir}/
}


# make sure to ship the files as part of the package group
FILES_${PN} += "${sysconfdir}/eglfs_config.json"
