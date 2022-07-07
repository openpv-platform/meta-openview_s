# require linux-add-custom-dtsi.inc

THISAPPENDFILESDIR := "${THISDIR}/${PN}"
FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

# file://0005-Input-add-Hycon-HY46XX-Touchscreen-controller.patch comes from the following link:
#   https://patchwork.kernel.org/project/linux-input/list/?series=466405&state=%2A&archive=both
SRC_URI_append = " \
   file://0001-Add-hlio-specific-dtsi.patch \
   file://0002-Modify-SDIO-core-memcpy-to-copy-mis-aligned-buffers.patch \
   file://0004-Set-initial-state-of-USB-C-dual-role-based-on-dts.patch \
   file://0005-Input-add-Hycon-HY46XX-Touchscreen-controller.patch \
   file://0006-fix-1s-reset-delay-and-checksum-on-old-firmware.patch \
   file://0007-Added-support-to-manually-force-card-detection-sdio.patch \
   file://0008-Updated-the-atmel-driver-source-code.patch \
   file://0009-Updated-the-atmel-driver-add-invert-support.patch \
   "

# The following idea is adapted from: 
# https://www.yoctoproject.org/pipermail/yocto/2019-May/045121.html
# This moves our source device tree file to the working source directory prior 
# to building the device tree. The generically named .dtsi file is included by 
# the primary device tree file. The source file to copy is based on the selected
# RCD_LCD - set by default to "atmel" or manually by user in local.conf
###############################################################################
do_add_platform_dtsi() {
   # Copy the rcd specific device tree for ST DK2 development
	echo 'cp -f "${THISAPPENDFILESDIR}/stm32mp15xx-hlio-rcd.dtsi" "${STAGING_KERNEL_DIR}/arch/arm/boot/dts"'
	cp -f "${THISAPPENDFILESDIR}/stm32mp15xx-hlio-rcd.dtsi" \
             "${STAGING_KERNEL_DIR}/arch/arm/boot/dts"
   # Copy the rcd LCD specific device tree
   echo 'cp -f "${THISAPPENDFILESDIR}/rcd-atmel.dtsi" "${THISAPPENDFILESDIR}/rcd-hycon.dtsi" "${STAGING_KERNEL_DIR}/arch/arm/boot/dts"'
   if [ ${RCD_LCD} = "hycon" ]; then
      cp -f "${THISAPPENDFILESDIR}/rcd-hycon.dtsi" \
                "${STAGING_KERNEL_DIR}/arch/arm/boot/dts/rcd-lcd.dtsi";
   else
      cp -f "${THISAPPENDFILESDIR}/rcd-atmel.dtsi" \
                "${STAGING_KERNEL_DIR}/arch/arm/boot/dts/rcd-lcd.dtsi";
   fi
}

addtask add_platform_dtsi before do_configure after do_patch 

# The following sections were created based on the knowledge from here:
#   https://www.yoctoproject.org/docs/2.4.1/kernel-dev/kernel-dev.html#configuring-the-kernel

# These are additional fragments to add definitions to the defconfig that is going to be used to build the kernel
KERNEL_CONFIG_FRAGMENTS += "${WORKDIR}/fragments/fragment_01_enable_j1939.cfg \
                            ${WORKDIR}/fragments/fragment_03_enable_hycon_touch.cfg \
                            ${WORKDIR}/fragments/fragment_04_major_kernel_cleanup.cfg \
                            ${WORKDIR}/fragments/fragment_05_remove_debug.cfg \
                            ${WORKDIR}/fragments/fragment_06_optimization.cfg \
                            ${WORKDIR}/fragments/fragment_07_add_nfsd.cfg \
                            ${WORKDIR}/fragments/fragment_08_add_atmel_mxt_touch_driver.cfg \
                            "

SRC_URI_append = "file://fragments/fragment_01_enable_j1939.cfg \
                  file://fragments/fragment_03_enable_hycon_touch.cfg \
                  file://fragments/fragment_04_major_kernel_cleanup.cfg \
                  file://fragments/fragment_05_remove_debug.cfg \
                  file://fragments/fragment_06_optimization.cfg \
                  file://fragments/fragment_07_add_nfsd.cfg \
                  file://fragments/fragment_08_add_atmel_mxt_touch_driver.cfg \
                  "

SRC_URI_class-devupstream += "file://fragments/fragment_01_enable_j1939.cfg \
                              file://fragments/fragment_03_enable_hycon_touch.cfg \
                              file://fragments/fragment_04_major_kernel_cleanup.cfg \
                              file://fragments/fragment_05_remove_debug.cfg \
                              file://fragments/fragment_06_optimization.cfg \
                              file://fragments/fragment_07_add_nfsd.cfg \
                              file://fragments/fragment_08_add_atmel_mxt_touch_driver.cfg \
                              "