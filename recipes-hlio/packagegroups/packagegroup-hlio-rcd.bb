SUMMARY = "Components for esp-hosted"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

PACKAGE_ARCH = "${MACHINE_ARCH}"

inherit packagegroup

PACKAGES = "\
            packagegroup-hlio-rcd \
            "

RDEPENDS_packagegroup-hlio-rcd = "\
    esp-hosted \
    python3-can \
    python3-pip \
    python3-protobuf \
    type-c-role-switch \
    rs485-example \
    "
