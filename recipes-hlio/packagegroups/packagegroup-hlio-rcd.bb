SUMMARY = "Components for esp-hosted"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

PACKAGE_ARCH = "${MACHINE_ARCH}"

inherit packagegroup

PROVIDES = "${PACKAGES}"
PACKAGES = "\
            packagegroup-hlio-rcd \
            packagegroup-hlio-rcd-debugging \
            packagegroup-hlio-rcd-tools-audio \
            packagegroup-hlio-rcd-tools-core \
            packagegroup-hlio-rcd-tools-kernel \
            packagegroup-hlio-rcd-tools-network \
            packagegroup-hlio-rcd-tools-python3 \
            packagegroup-hlio-rcd-core-display \
            packagegroup-hlio-rcd-core-fs \
            "

#   gpio
#   can-standby-enable-bin
RDEPENDS_packagegroup-hlio-rcd = "\
    esp-hosted \
    type-c-role-switch-bin \
    rs485-example \
    packagegroup-hlio-rcd-debugging \
    packagegroup-hlio-rcd-tools-audio \
    packagegroup-hlio-rcd-tools-core \
    packagegroup-hlio-rcd-tools-kernel \
    packagegroup-hlio-rcd-tools-network \
    packagegroup-hlio-rcd-tools-python3 \
    packagegroup-hlio-rcd-core-display \
    packagegroup-hlio-rcd-core-fs \
    "

SUMMARY_packagegroup-hlio-rcd-debugging = "Framework tools components for debugging the application on the distribution"
RDEPENDS_packagegroup-hlio-rcd-debugging = "\
    ldd             \
    gdb             \
    systemd-analyze \
    "

SUMMARY_packagegroup-hlio-rcd-tools-audio = "Framework tools components for audio, copied over to rcd"
RDEPENDS_packagegroup-hlio-rcd-tools-audio = "\
    ${@bb.utils.contains('DISTRO_FEATURES', 'pulseaudio', 'pulseaudio', '', d)}                     \
    ${@bb.utils.contains('DISTRO_FEATURES', 'pulseaudio', 'pulseaudio-server', '', d)}              \
    ${@bb.utils.contains('DISTRO_FEATURES', 'pulseaudio', 'pulseaudio-misc', '', d)}                \
    ${@bb.utils.contains('DISTRO_FEATURES', 'pulseaudio', 'pulseaudio-module-combine-sink', '', d)} \
    ${@bb.utils.contains('DISTRO_FEATURES', 'pulseaudio bluetooth', 'pulseaudio-module-bluetooth-discover', '', d)} \
    ${@bb.utils.contains('DISTRO_FEATURES', 'pulseaudio bluetooth', 'pulseaudio-module-bluetooth-policy', '', d)}   \
    ${@bb.utils.contains('DISTRO_FEATURES', 'pulseaudio bluetooth', 'pulseaudio-module-bluez5-device', '', d)}      \
    ${@bb.utils.contains('DISTRO_FEATURES', 'pulseaudio bluetooth', 'pulseaudio-module-bluez5-discover', '', d)}    \
    "

# Packages removed from the packagegroup-framework-tools-core packagegroup that this is based off of
SUMMARY_packagegroup-hlio-rcd-tools-core = "Framework tools components for core, copied over to rcd"
RDEPENDS_packagegroup-hlio-rcd-tools-core = "\
    libiio-iiod     \
    libiio-tests    \
    lrzsz           \
    util-linux      \
    util-linux-lscpu\
    kbd             \
    bc              \
    sysstat         \
    ntp             \
    systemtap       \
    gptfdisk        \
    bzip2           \
    wget            \
    xz              \
    rng-tools       \
    rt-tests        \
    \
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
    \
    nfs-utils       \
    ldd             \
    gdb             \
    nodejs          \
    "

# Packages removed from the packagegroup-hlio-rcd-tools-kernel packagegroup that this is based off of
#   evtest
#   memtester
#   util-linux
#   util-linux-fdisk
SUMMARY_packagegroup-hlio-rcd-tools-kernel = "Framework tools components for kernel, copied over to rcd"
RDEPENDS_packagegroup-hlio-rcd-tools-kernel = "\
    cpufrequtils    \
    sysfsutils      \
    dosfstools      \
    mmc-utils       \
    blktool         \
    mtd-utils-ubifs \
    sysprof         \
    \
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
#   ${@bb.utils.contains('DISTRO_FEATURES', 'wayland', 'weston-examples', '', d)}
#   ${@bb.utils.contains_any('DISTRO_FEATURES', '${GTK3DISTROFEATURES}', 'gtk+3-demo', '', d)}
#   ${@bb.utils.contains('DISTRO_FEATURES', 'x11 wayland', 'xclock', '', d)}
#   ${@bb.utils.contains('DISTRO_FEATURES', 'x11 wayland', 'xinput', '', d)}
#   ${@bb.utils.contains('DISTRO_FEATURES', 'x11 wayland', 'xkbcomp', '', d)}
#   ${@bb.utils.contains('DISTRO_FEATURES', 'x11 wayland', 'xterm', '', d)}
#   ${@bb.utils.contains('DISTRO_FEATURES', 'x11 wayland', 'xeyes', '', d)}
SUMMARY_packagegroup-hlio-rcd-core-display = "Framework core components for display, copied over to rcd"
RDEPENDS_packagegroup-hlio-rcd-core-display = "\
    libdrm          \
    \
    ${@bb.utils.contains('DISTRO_FEATURES', 'wayland', 'weston', '', d)}                        \
    ${@bb.utils.contains('DISTRO_FEATURES', 'wayland', 'weston-init', '', d)}                   \
    ${@bb.utils.contains_any('DISTRO_FEATURES', '${GTK3DISTROFEATURES}', 'gtk+3', '', d)}       \
    \
    ${@bb.utils.contains('DISTRO_FEATURES', 'x11 wayland', 'weston-xwayland', '', d)}       \
    ${@bb.utils.contains('DISTRO_FEATURES', 'x11 wayland', 'xserver-xorg-xwayland', '', d)} \
    ${@bb.utils.contains('DISTRO_FEATURES', 'x11 wayland', 'libx11-locale', '', d)}         \
    ${@bb.utils.contains('DISTRO_FEATURES', 'x11 wayland', 'libx11', '', d)}                \
    ${@bb.utils.contains('DISTRO_FEATURES', 'x11 wayland', 'libxcb', '', d)}                \
    ${@bb.utils.contains('DISTRO_FEATURES', 'x11 wayland', 'libxcursor', '', d)}            \
    ${@bb.utils.contains('DISTRO_FEATURES', 'x11 wayland', 'xf86-input-evdev', '', d)}      \
    ${@bb.utils.contains('DISTRO_FEATURES', 'x11 wayland', 'xf86-input-mouse', '', d)}      \
    ${@bb.utils.contains('DISTRO_FEATURES', 'x11 wayland', 'xf86-input-keyboard', '', d)}   \
    ${@bb.utils.contains('DISTRO_FEATURES', 'x11 wayland', 'xorg-minimal-fonts', '', d)}    \
    "

SUMMARY_packagegroup-hlio-rcd-core-fs = "Framework core components for filesystem, copied over to rcd"
RDEPENDS_packagegroup-hlio-rcd-core-fs = "\
    ${@bb.utils.contains('DISTRO_FEATURES', 'systemd', 'systemd-mount-partitions', '', d)} \
    ${@bb.utils.contains('DISTRO_FEATURES', 'systemd', 'userfs-cleanup-package', '', d)} \
    "

