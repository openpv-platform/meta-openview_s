FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI:append = " \
    file://timesyncd.conf.in \
    "

do_compile:prepend() {
    # Copy all the new files in place of the files that exist in the existing repository.
    cp ${WORKDIR}/timesyncd.conf.in ${S}/src/timesync/timesyncd.conf.in
}

do_install:append() {
    #Remove this service useless for our needs
    rm -f ${D}/${rootlibexecdir}/systemd/system-generators/systemd-debug-generator
    rm -f ${D}/${rootlibexecdir}/systemd/system-generators/systemd-hibernate-resume-generator
}
