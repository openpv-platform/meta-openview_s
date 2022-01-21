SUMMARY = "Helios Engineering Low Cost Display image based on ST wayland image with basic Wayland support (if enabled in distro)."
LICENSE = "Proprietary"

# overlay the st-image-weston recipe
include recipes-st/images/st-image.inc
inherit core-image features_check


# Include wayland graphics framework
REQUIRED_DISTRO_FEATURES = "wayland"

IMAGE_LINGUAS = "en-us"

# Add image features
IMAGE_FEATURES += "\
    splash              \
    package-management  \
    ssh-server-dropbear \
    hwcodecs            \
    tools-profile       \
    eclipse-debug       \
    "

#
# INSTALL addon packages
#
CORE_IMAGE_EXTRA_INSTALL += " \
    resize-helper \
    \
    packagegroup-framework-core-base    \
    packagegroup-framework-tools-base   \
    \
    packagegroup-framework-core         \
    packagegroup-framework-tools        \
    \
    packagegroup-framework-core-extra   \
    \
    ${@bb.utils.contains('COMBINED_FEATURES', 'optee', 'packagegroup-optee-core', '', d)} \
    ${@bb.utils.contains('COMBINED_FEATURES', 'optee', 'packagegroup-optee-test', '', d)} \
    \
    ${@bb.utils.contains('COMBINED_FEATURES', 'tpm2', 'packagegroup-security-tpm2', '', d)} \
    \
    packagegroup-hlio-rcd \
    \
    packagegroup-hlio-webkit \
    "

# removed packagegroups
#   packagegroup-st-demo