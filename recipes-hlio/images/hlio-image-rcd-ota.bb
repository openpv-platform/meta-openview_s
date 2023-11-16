SUMMARY = "RCD-OTA-image recipe"
LICENSE = "Enovation-Proprietary"
LIC_FILES_CHKSUM = "file://${STM32MP_META_HLIO_RCD_BASE}/licenses/Enovation-Controls-License.rtf;md5=7a35371310afae6d2edc9c24089f674f"

# overlay the st-image-weston recipe
include recipes-st/images/st-image.inc

inherit core-image

IMAGE_FSTYPES = "cpio"

# IMAGE_LINGUAS = "en-us"
IMAGE_LINGUAS = ""

# No tsv file
ENABLE_FLASHLAYOUT_CONFIG = "0"

IMAGE_ROOTFS_MAXSIZE = "131072"

IMAGE_FEATURES += "\
    ssh-server-dropbear \
    hwcodecs            \
    "

#
# INSTALL addon packages
#
CORE_IMAGE_EXTRA_INSTALL += " \
    \
    ${@bb.utils.contains('COMBINED_FEATURES', 'optee', 'packagegroup-optee-core', '', d)} \
    \
    ${@bb.utils.contains('COMBINED_FEATURES', 'tpm2', 'packagegroup-security-tpm2', '', d)} \
    \
    packagegroup-framework-core-base \
    packagegroup-framework-core \
    \
    packagegroup-hlio-ota \
    "

# Probably need some from the following - add specific to packagegroup-hlio-ota:
# packagegroup-framework-tools
# packagegroup-hlio-rcd