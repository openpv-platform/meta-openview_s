
SUMMARY = ""
HOMEPAGE = "https://github.com/hhk7734/python3-gpiod"
AUTHOR = "Hyeonki Hong <hhk7734@gmail.com>"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://LICENSE.txt;md5=fc4e57275d8c245894e576844466f725"

SRC_URI = "https://files.pythonhosted.org/packages/9e/e0/5c1cefacae2f503d09a0cbcee4be3fdc012d8a9a638764f8af1e4eed3633/gpiod-1.5.1.tar.gz"
SRC_URI[md5sum] = "0e04a9bcc6aa65d7d8d0d5be3d729c6a"
SRC_URI[sha256sum] = "023e007f1c884bd9775d9c286c16d82cb4a79c7f1a033259437d7619bf7d1956"

S = "${WORKDIR}/gpiod-1.5.1"

RDEPENDS:${PN} = ""

inherit setuptools3
