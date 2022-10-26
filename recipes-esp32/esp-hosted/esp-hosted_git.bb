# Recipe created by recipetool
# This is the basis of a recipe and may need further editing in order to be fully functional.
# (Feel free to remove these comments when editing.)

require conf/include/esp-hosted-srcrev.inc

LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://LICENSE;md5=8264535c0c4e9c6c335635c4026a8022"

FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI = "gitsm://github.com/espressif/esp-hosted.git;protocol=https;branch=master \
           file://0001-Update-Makefile-for-Yocto.patch;striplevel=5 \
           "

PV = "${ESP_HOSTED_PV}+git${SRCPV}"
SRCREV = "${ESP_HOSTED_SRCREV}"

S = "${WORKDIR}/git/host/linux/host_driver/esp32"

inherit module

EXTRA_OEMAKE:append:task-install = " -C ${STAGING_KERNEL_DIR} M=${S}"

RDEPENDS:${PN} = " \
                  esp-systemd \
                  esp-support \
                  "
