FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI:append = " \
    file://timesyncd.conf.in \
    "

do_compile:prepend() {
    # Copy all the new files in place of the files that exist in the existing repository.
    cp ${WORKDIR}/timesyncd.conf.in ${S}/src/timesync/timesyncd.conf.in
}