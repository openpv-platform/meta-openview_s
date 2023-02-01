# Recipe created by recipetool
# This is the basis of a recipe and may need further editing in order to be fully functional.
# (Feel free to remove these comments when editing.)

require conf/include/esp-hosted-srcrev.inc

LICENSE = "GPL-2.0-only"
LIC_FILES_CHKSUM = "${ESP_LIC_FILES_CHKSUM}"

FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI = "gitsm://github.com/espressif/esp-hosted.git;protocol=https;branch=master \
           ${ESP_MAKEFILE_PATCH} \
           "

PV = "${ESP_HOSTED_PV}+git${SRCPV}"
SRCREV = "${ESP_HOSTED_SRCREV}"

S = "${WORKDIR}/git/${ESP_S_PATH}"

inherit module

EXTRA_OEMAKE:append:task-install = " -C ${STAGING_KERNEL_DIR} M=${S}"

RDEPENDS:${PN} = " \
                  esp-systemd \
                  esp-support \
                  "
