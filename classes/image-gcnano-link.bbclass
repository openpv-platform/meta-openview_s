# Usage: add INHERIT += "image-gcnano-link" to your conf file
# Original source of this file was in previous ecosystem and removed in v4.0, but we seem to need it
# This reference to vendor is obsoleted by setting ST_VENDORFS = "0" in the machine config
# We are using /usr/lib - the default ${libdir} path
GCNANO_USERLAND_VENDOR_DIR ?= "/vendor"
GCNANO_USERLAND_OUTPUT_LIBDIR = "${@'${GCNANO_USERLAND_VENDOR_DIR}/lib' if d.getVar('GCNANO_USERLAND_USE_VENDOR_DIR') == '1' else '${libdir}'}"

gcnano_create_link() {
    if [ -L ${IMAGE_ROOTFS}${libdir}/libEGL.so ];
    then
        # link requested:
        # libEGL.so.1 -> /usr/lib/libEGL.so
        if [ ! -L ${IMAGE_ROOTFS}${libdir}/libEGL.so.1 ];
        then
            LINK=$(readlink ${IMAGE_ROOTFS}${libdir}/libEGL.so)
            ln -s $LINK ${IMAGE_ROOTFS}${libdir}/libEGL.so.1
        fi
        # link requested:
        # libgbm.so.1 -> /usr/lib/libgbm.so
        if [ ! -L ${IMAGE_ROOTFS}${libdir}/libgbm.so.1 ];
        then
            LINK=$(readlink ${IMAGE_ROOTFS}${libdir}/libgbm.so)
            ln -s $LINK ${IMAGE_ROOTFS}${libdir}/libgbm.so.1
        fi
        # link requested:
        # libGLESv2.so.2 -> /usr/lib/libGLESv2.so
        if [ ! -L ${IMAGE_ROOTFS}${libdir}/libGLESv2.so.2 ];
        then
            # Seems to be the binary file, not a link, so this was changed from readlink
            # LINK=$(readlink ${IMAGE_ROOTFS}${libdir}/libGLESv2.so)
            if [ -f ${IMAGE_ROOTFS}${libdir}/libGLESv2.so ];
            then
                ln -s libGLESv2.so ${IMAGE_ROOTFS}${libdir}/libGLESv2.so.2
            fi
        fi
    fi
}

IMAGE_PREPROCESS_COMMAND += "gcnano_create_link;"
