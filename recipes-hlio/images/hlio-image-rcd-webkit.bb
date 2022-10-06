SUMMARY = "Helios Engineering Low Cost Display image based on ST wayland image with basic Wayland support (if enabled in distro)."
LICENSE = "Proprietary"

# overlay the st-image-weston recipe
include recipes-st/images/st-image.inc
inherit core-image features_check

# Include wayland graphics framework
# REQUIRED_DISTRO_FEATURES = "wayland"

IMAGE_LINGUAS = "en-us"

# Add image features
#   eclipse-debug
#   tools-profile
IMAGE_FEATURES += "\
    splash              \
    ssh-server-dropbear \
    hwcodecs            \
    package-management  \
    "

#
# INSTALL addon packages
#
CORE_IMAGE_EXTRA_INSTALL += " \
    resize-helper \
    \
    ${@bb.utils.contains('COMBINED_FEATURES', 'optee', 'packagegroup-optee-core', '', d)} \
    \
    ${@bb.utils.contains('COMBINED_FEATURES', 'tpm2', 'packagegroup-security-tpm2', '', d)} \
    \
    packagegroup-framework-core-base \
    packagegroup-framework-tools-base \
    packagegroup-framework-core \
    packagegroup-framework-tools \
    packagegroup-framework-core-extra \
    packagegroup-hlio-rcd \
    \
    packagegroup-hlio-rcd-webkit \
    "

# removed packagegroups
#   packagegroup-st-demo
#   packagegroup-framework-core-base
#   packagegroup-framework-tools-base
#   packagegroup-framework-core
#   packagegroup-framework-tools
#   ${@bb.utils.contains('COMBINED_FEATURES', 'optee', 'packagegroup-optee-test', '', d)}
#   packagegroup-framework-core-extra
