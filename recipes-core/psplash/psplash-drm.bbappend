# disabling psplash service. weston will handle splash screen
SYSTEMD_AUTO_ENABLE:${PN} = "disable"

# Files in psplash-drm folder are kept in case we need to add
# psplash back into system