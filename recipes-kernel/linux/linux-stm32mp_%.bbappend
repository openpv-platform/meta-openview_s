# require linux-add-custom-dtsi.inc

THISAPPENDFILESDIR := "${THISDIR}/${PN}"
FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

SRC_URI_append = " \
   file://0001-Add-hlio-specific-dtsi.patch \
   file://0002-Modify-SDIO-core-memcpy-to-copy-mis-aligned-buffers.patch \
   file://0003-Add-debug-messages-to-mmc-and-modify-trace-msgs.patch \
   file://0004-Set-initial-state-of-USB-C-dual-role-based-on-dts.patch \
   "

# The following idea is adapted from: 
# https://www.yoctoproject.org/pipermail/yocto/2019-May/045121.html
# This moves our source device tree file to the working source directory prior 
# to building the device tree. The .dtsi file is included by the dev kit device
# tree (accomplished by the patch above)
###############################################################################
do_add_platform_dtsi() {
	echo 'cp -f "${THISAPPENDFILESDIR}/stm32mp15xx-hlio-rcd.dtsi" "${STAGING_KERNEL_DIR}/arch/arm/boot/dts"'
	cp -f "${THISAPPENDFILESDIR}/stm32mp15xx-hlio-rcd.dtsi" \
             "${STAGING_KERNEL_DIR}/arch/arm/boot/dts"
}

addtask add_platform_dtsi before do_configure after do_patch 

# The following sections were created based on the knowledge from here:
#   https://www.yoctoproject.org/docs/2.4.1/kernel-dev/kernel-dev.html#configuring-the-kernel

# These are additional fragments to add definitions to the defconfig that is going to be used to build the kernel
KERNEL_CONFIG_FRAGMENTS += "${WORKDIR}/fragments/fragment_01_enable_j1939.cfg"

SRC_URI_append = "file://fragments/fragment_01_enable_j1939.cfg"

SRC_URI_class-devupstream += "file://fragments/fragment_01_enable_j1939.cfg"

# NOTE: This is how you should add more fragments if you want to add more. If you don't do it this way there is a chance
#  that the python script won't successfully parse all the separate files and corectly pull them into the configuration.
#  PLEASE MAKE SURE THAT YOU DELETE THIS COMMENT ONCE A SECOND FILE IS ADDED, THIS IS ONLY HERE BECAUSE IT ISN'T
#  INHERENTLY OBVIOUS HOW OTHER FRAGMENT FILES WOULD BE ADDED
#KERNEL_CONFIG_FRAGMENTS += "${WORKDIR}/fragments/fragment_01_enable_j1939.cfg \
#                            ${WORKDIR}/fragments/fragment_02_other_config.cfg"
#SRC_URI_append = "file://fragments/fragment_01_enable_j1939.cfg \
#                  file://fragments/fragment_02_other_config.cfg"
#SRC_URI_class-devupstream += "file://fragments/fragment_01_enable_j1939.cfg \
#                              file://fragments/fragment_02_other_config.cfg"
