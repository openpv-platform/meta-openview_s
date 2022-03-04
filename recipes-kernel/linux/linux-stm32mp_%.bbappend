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
KERNEL_CONFIG_FRAGMENTS += "${WORKDIR}/fragments/fragment_01_enable_j1939.cfg \
                            ${WORKDIR}/fragments/fragment_03_enable_hycon_touch.cfg \
                            ${WORKDIR}/fragments/fragment_04_major_kernel_cleanup.cfg \
                            "

SRC_URI_append = "file://fragments/fragment_01_enable_j1939.cfg \
                  file://fragments/fragment_03_enable_hycon_touch.cfg \
                  file://fragments/fragment_04_major_kernel_cleanup.cfg \
                  "

SRC_URI_class-devupstream += "file://fragments/fragment_01_enable_j1939.cfg \
                              file://fragments/fragment_03_enable_hycon_touch.cfg \
                              file://fragments/fragment_04_major_kernel_cleanup.cfg \
                              "
