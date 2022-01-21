PACKAGECONFIG = " \
    fetchapi \
    indexeddb \
    mediasource \
    video \
    webaudio \
    webcrypto \
    woff2 \
    gst_gl \
    remote-inspector \
    openjpeg \
    unified-builds \
    service-worker \
    ${@bb.utils.contains('DISTRO_FEATURES', 'systemd', 'systemd', '' ,d)} \
    qtwpe \
    "
