FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

SRC_URI_append = " \
   file://0001-Update-device-tree-to-use-sdmmc3-for-esp32.patch \
   file://0002-Apply-device-tree-changes-to-157f.patch \
   file://0003-Device-Tree-SDIO-if-Restore-default-25Mhz-freq.patch \
   file://0004-Modify-SDIO-core-memcpy-to-copy-mis-aligned-buffers.patch \
   file://0005-Add-debug-messages-to-mmc-and-modify-trace-msgs.patch \
   "
