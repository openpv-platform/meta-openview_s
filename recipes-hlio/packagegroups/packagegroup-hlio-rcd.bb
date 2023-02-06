SUMMARY = "Components for esp-hosted"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

PACKAGE_ARCH = "${MACHINE_ARCH}"

inherit packagegroup

PROVIDES = "${PACKAGES}"
PACKAGES = "\
            packagegroup-hlio-rcd \
            packagegroup-hlio-rcd-custom \
            packagegroup-hlio-rcd-debugging \
            packagegroup-hlio-rcd-tools-network \
            packagegroup-hlio-rcd-tools-python3 \
            packagegroup-hlio-rcd-qt5-support \
            packagegroup-hlio-rcd-development-support \
            "

RDEPENDS:packagegroup-hlio-rcd = "\
    packagegroup-hlio-rcd-custom \
    packagegroup-hlio-rcd-debugging \
    packagegroup-hlio-rcd-tools-network \
    packagegroup-hlio-rcd-tools-python3 \
    packagegroup-hlio-rcd-qt5-support \
    packagegroup-hlio-rcd-development-support \
    "

SUMMARY:packagegroup-hlio-rcd-custom = "Custom tools for RCD added by HCEE team."
RDEPENDS:packagegroup-hlio-rcd-custom = "\
    esp-hosted \
    esp-support \
    type-c-role-switch-bin \
    can-utils \
    can-standby-enable-bin \
    hlio-init \
    hlio-first-boot \
    hlio-startup-config \
    bsp-info    \
    lcd-config \
    lmsensors-dev \
    "



SUMMARY:packagegroup-hlio-rcd-debugging = "Tools for debugging user space applications on the RCD"
RDEPENDS:packagegroup-hlio-rcd-debugging = "\
    ldd \
    gdb \
    gdbserver \
    systemd-analyze \
    "


SUMMARY:packagegroup-hlio-rcd-tools-network = "Network tools for connectivity and debugging with Visual studio"
RDEPENDS:packagegroup-hlio-rcd-tools-network = "\
    nfs-utils \
    openssh-sftp-server \
    openssh-sftp \
    "

SUMMARY:packagegroup-hlio-rcd-tools-python3 = "Python3 specific tools"
RDEPENDS:packagegroup-hlio-rcd-tools-python3 = "\
    python3-can \
    python3-protobuf \
    python3-pyserial \
    "

# reference: .../layers/meta-st/meta-st-openstlinux/recipes-samples/images/st-example-image-qtwayland.bb
RDEPENDS:packagegroup-hlio-rcd-qt5-support = "\
    packagegroup-framework-sample-qt    \
    qtwayland                           \
    qtwayland-plugins                   \
    openstlinux-qt-wayland              \
    "

SUMMARY:packagegroup-hlio-rcd-development-support = "Packages for Ahsoka supported development environments"
RDEPENDS:packagegroup-hlio-rcd-development-support = "\
    icu \
    libicudata \
    zeromq \
    cppzmq-dev \
    protobuf \
    jsoncpp \
    libgpiod-dev \
    "
