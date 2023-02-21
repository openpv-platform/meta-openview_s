DEPENDS:append = " extra-cmake-modules wayland wayland-utils wayland-native libxkbcommon"
EXTRA_OECMAKE += " -DGLFW_USE_WAYLAND=1"