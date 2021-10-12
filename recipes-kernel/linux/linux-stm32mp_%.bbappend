FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

SRC_URI_append = " \
   file://0001-Update-device-tree-to-use-sdmmc3-for-esp32.patch \
   file://0002-Apply-device-tree-changes-to-157f.patch \
   file://0003-Device-Tree-SDIO-if-Restore-default-25Mhz-freq.patch \
   file://0004-Modify-SDIO-core-memcpy-to-copy-mis-aligned-buffers.patch \
   file://0005-Add-debug-messages-to-mmc-and-modify-trace-msgs.patch \
   file://0006-Updated-the-hlio-rcb.dtsi-to-configure-can.patch \
   "

# The following sections were created based on the knowledge from here:
#   https://www.yoctoproject.org/docs/2.4.1/kernel-dev/kernel-dev.html#configuring-the-kernel

# This is an additional fragment to add definitions to the defconfig that is going to be used to build the kernel
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
