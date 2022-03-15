# Recipe created by recipetool
# This is the basis of a recipe and may need further editing in order to be fully functional.
# (Feel free to remove these comments when editing.)

# WARNING: the following LICENSE and LIC_FILES_CHKSUM values are best guesses - it is
# your responsibility to verify that the values are complete and correct.
#
# The following license files were not able to be identified and are
# represented as "Unknown" below, you will need to check them yourself:
#   LICENSE
#   host/host_common/include/LICENSES/GPL-2.0
#   host/host_common/LICENSES/GPL-2.0
#   common/protobuf-c/LICENSE
#   common/LICENSES/GPL-2.0
#
# NOTE: multiple licenses have been detected; they have been separated with &
# in the LICENSE value for now since it is a reasonable assumption that all
# of the licenses apply. If instead there is a choice between the multiple
# licenses then you should change the value to separate the licenses with |
# instead of &. If there is any doubt, check the accompanying documentation
# to determine which situation is applicable.
LICENSE = "GPLv2"
LIC_FILES_CHKSUM = "file://LICENSE;md5=8264535c0c4e9c6c335635c4026a8022"

FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

SRC_URI = "gitsm://github.com/espressif/esp-hosted.git;protocol=https \
           file://0001-Update-Makefile-for-Yocto.patch;striplevel=5 \
           "

BUILDTAG_esp-hosted ?= "release/v0.4"

PV = "0.3.2+git${SRCPV}"
SRCREV = "${BUILDTAG_esp-hosted}"
# The following commit was what we used for v0.3, preserved for reference
# SRCREV = "80ef3f61ce64e568484e195426a44b8b5cc5ee55"

S = "${WORKDIR}/git/host/linux/host_driver/esp32"

inherit module

EXTRA_OEMAKE_append_task-install = " -C ${STAGING_KERNEL_DIR} M=${S}"

RDEPENDS_${PN} = " \
                  esp-systemd \
                  esp-support \
                  "
