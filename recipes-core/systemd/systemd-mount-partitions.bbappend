FILESEXTRAPATHS:prepend := "${THISDIR}/files/:"

MOUNT_OPTS_FILE = "mount-opts"

SRC_URI:append = " \
    file://${MOUNT_OPTS_FILE}.sh \
    "

do_install:append() {
    if [ -n "${MOUNT_PARTITIONS_LIST} " ]; then
        sed -i "s/<PERSISTFS_LABEL>/${PERSISTFS_LABEL}/g" ${WORKDIR}/${MOUNT_OPTS_FILE}.sh
        install -d ${D}/${sysconfdir}
        install -m 755 ${WORKDIR}/${MOUNT_OPTS_FILE}.sh ${D}/${sysconfdir}/
    fi
}
