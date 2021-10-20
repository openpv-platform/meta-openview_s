SUMMARY = "Recipe to manage the installation of the electron hello world dependencies."
LICENSE = "CLOSED"

# Update revision each time updates (features, and large changes only) are made
PR = "r1"

# Add source names
SRC_URI += "\
        file://electron-v15.1.2-linux-armv7l \
        file://app \
        file://start-demo-app.sh \
"

# do_configure[noexec] = "1"
# do_compile[noexec] = "1"

# S the location in the Build Directory where unpacked recipe source code resides. By default, this directory is ${WORKDIR}/${BPN}-${PV}, 
# where ${BPN} is the base recipe name and ${PV} is the recipe name. If the source tarball extracts the code to a directory named anything other than ${BPN} - ${PV},
# or if the source code is fetched from an SCM such as Git or Subversion, then you must set S in the recipe so that the OpenEmbedded system knows where to find 
# the unpacked source.
S = "${WORKDIR}"


# do_install copies files that are to be packaged into the holding area ${D}. This task runs with the current working directory set to ${B}, which is the 
# compilation directory. Some methods of copying files, notably when using the recursive cp command, can preserve the UID and/or GID of the original file, 
# which is usually not what you want.
# Safer methods for installing files: 
#       * The 'install' utility.
#       * The 'cp' command with the '--no-preserve=ownership' option.
#       * The 'tar' command with the '--no-same-owner" option. 
do_install() {
        # install directories if not present
        install -d ${D}${prefix}/local/
        install -d ${D}${prefix}/local/weston-start-at-startup/

        # using cp because install will not copy a directory 
        cp -r ${S}/electron-v15.1.2-linux-armv7l/ ${D}${prefix}/local/electron/
        cp -r ${S}/app/ ${D}${prefix}/local/electron/

        # using install to add execution permisions via -m 755 switch
        install -m 0755 ${S}/start-demo-app.sh ${D}${prefix}/local/weston-start-at-startup/
}


# make sure to ship the files as part of the package group
FILES_${PN} += "${prefix}/local/electron/"
FILES_${PN} += "${prefix}/local/weston-start-at-startup/"


RDEPENDS_${PN} += " nss \
                    cups \
                    alsa-lib \
                    libxshmfence \
                    nspr \
                    libx11 \
                    glib-2.0 \
                    gtk+3 \
                    atk \
                    cairo \
                    pango \
                    expat \
                    libxkbcommon \
                    libdrm \
                    libxcb \
                    cups-lib \
                    libxcomposite \
                    libxdamage \
                    libxext \
                    libxrandr \
                    libxfixes \
                    gdk-pixbuf \
                    at-spi2-core \
                    at-spi2-atk \
                    dbus-lib \
                "


# TODO: libgbm is not included as a runtime dependecy yet for version issues.
#       Once corrected, remove from both RDEPENDS & RPROVIDES
RDEPENDS_${PN} += " libgbm.so.1 \
        "

RPROVIDES_${PN} += " libgbm.so.1 \
        "