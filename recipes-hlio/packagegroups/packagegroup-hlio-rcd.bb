SUMMARY = "Components for esp-hosted"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

PACKAGE_ARCH = "${MACHINE_ARCH}"

inherit packagegroup

PROVIDES = "${PACKAGES}"
PACKAGES = "\
            packagegroup-hlio-rcd \
            packagegroup-hlio-rcd-tools-core \
            packagegroup-hlio-rcd-tools-kernel \
            packagegroup-hlio-rcd-tools-network \
            packagegroup-hlio-rcd-tools-python3 \
            packagegroup-hlio-rcd-core-display \
            packagegroup-hlio-rcd-core-fs \
            "

#   gpio
RDEPENDS_packagegroup-hlio-rcd = "\
    esp-hosted \
    rs485-example \
    packagegroup-hlio-rcd-tools-core \
    packagegroup-hlio-rcd-tools-kernel \
    packagegroup-hlio-rcd-tools-network \
    packagegroup-hlio-rcd-tools-python3 \
    packagegroup-hlio-rcd-core-display \
    packagegroup-hlio-rcd-core-fs \
    "

# Packages removed from the packagegroup-framework-tools-core packagegroup that this is based off of
#   libiio-iiod
#   libiio-tests
#   lrzsz
#   util-linux
#   util-linux-lscpu
#   kbd
#   bc
#   sysstat
#   ntp
#   systemtap
#   gptfdisk
#   bzip2
#   wget
#   xz
#   rng-tools
#   rt-tests
SUMMARY_packagegroup-hlio-rcd-tools-core = "Framework tools components for core, copied over to rcd"
RDEPENDS_packagegroup-hlio-rcd-tools-core = "\
    ckermit         \
    coreutils       \
    libgpiod        \
    libgpiod-tools  \
    ${@bb.utils.contains('DISTRO_FEATURES', 'usbgadget', 'usbotg-gadget-config', '', d)} \
    grep            \
    file            \
    e2fsprogs       \
    e2fsprogs-resize2fs \
    minicom         \
    apt-openstlinux \
    tar             \
    cracklib        \
    db              \
    sqlite3         \
    stm32-ddr-tools \
    procps          \
    "

# Packages removed from the packagegroup-hlio-rcd-tools-kernel packagegroup that this is based off of
#   evtest
#   memtester
#   util-linux
#   util-linux-fdisk
SUMMARY_packagegroup-hlio-rcd-tools-kernel = "Framework tools components for kernel, copied over to rcd"
RDEPENDS_packagegroup-hlio-rcd-tools-kernel = "\
    can-utils       \
    i2c-tools       \
    strace          \
    usbutils        \
    \
    mtd-utils       \
    v4l-utils       \
    pciutils        \
    "

# Packages removed from the packagegroup-framework-tools-network packagegroup that this is based off of
#   openssh-sftp
#   packagegroup-core-full-cmdline-extended
SUMMARY_packagegroup-hlio-rcd-tools-network = "Framework tools components for network, copied over to rcd"
RDEPENDS_packagegroup-hlio-rcd-tools-network = "\
    ethtool         \
    iproute2        \
    curl            \
    tcpdump         \
    ${@bb.utils.contains('DISTRO_FEATURES', 'wifi', 'iw', '', d)}                       \
    ${@bb.utils.contains('DISTRO_FEATURES', 'wifi', 'wpa-supplicant', '', d)}           \
    ${@bb.utils.contains('DISTRO_FEATURES', 'wifi', 'hostapd', '', d)}                  \
    ${@bb.utils.contains('DISTRO_FEATURES', 'wifi', 'wireless-regdb-static', '', d)}    \
    ${@bb.utils.contains('DISTRO_FEATURES', 'systemd', 'dhcp-client', '', d)}                       \
    ${@bb.utils.contains('DISTRO_FEATURES', 'systemd', 'systemd-networkd-configuration', '', d)}    \
    usbip uhubctl   \
    bridge-utils    \
    "

SUMMARY_packagegroup-hlio-rcd-tools-python3 = "Framework tools components for python3, copied over to rcd"
RDEPENDS_packagegroup-hlio-rcd-tools-python3 = "\
    python3-pip         \
    python3-protobuf    \
    python3-datetime    \
    python3-dateutil    \
    python3-distutils   \
    python3-email       \
    python3-fcntl       \
    python3-io          \
    python3-logging     \
    python3-misc        \
    python3-numbers     \
    python3-pycairo     \
    python3-pygobject   \
    python3-pyparsing   \
    python3-shell       \
    python3-stringold   \
    python3-threading   \
    python3-unittest    \
    python3-pyyaml      \
    python3-pexpect     \
    python3-evdev       \
    python3-can         \
    python3-pyserial    \
    "

#   libdrm-tests
SUMMARY_packagegroup-hlio-rcd-core-display = "Framework core components for display, copied over to rcd"
RDEPENDS_packagegroup-hlio-rcd-core-display = "\
    libdrm          \
    "

SUMMARY_packagegroup-hlio-rcd-core-fs = "Framework core components for filesystem, copied over to rcd"
RDEPENDS_packagegroup-hlio-rcd-core-fs = "\
    ${@bb.utils.contains('DISTRO_FEATURES', 'systemd', 'systemd-mount-partitions', '', d)} \
    ${@bb.utils.contains('DISTRO_FEATURES', 'systemd', 'userfs-cleanup-package', '', d)} \
    "

