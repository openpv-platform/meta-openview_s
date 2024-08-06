# CMakeList.txt : Cairo interop library with kmsdrm backend build. 
#
# Ahsoka.GLES

cmake_minimum_required (VERSION 3.8)

# Set up project target
project (BootDisplayApp VERSION 1.0 DESCRIPTION "Cairo Interop library for creating a Cairo GLES context with kmsdrm backend")

include(FindPkgConfig)

pkg_check_modules(KMSDRM libdrm gbm egl)

include_directories( Cairo Touch DRM "${KMSDRM_INCLUDE_DIRS}"  )
message (KMS_INCLUDE ${KMSDRM_INCLUDE_DIRS})
set(SOURCES
    Cairo/cairo-gles-drm.c
    Cairo/CairoContext.c
    Touch/Touch.c
    Touch/TouchDevice.c
    DRM/common.c
    DRM/drm-legacy.c
    DRM/drm-common.c
    BootDisplayApp/main.cpp
)

# add the target Library
add_executable(BootDisplayApp ${SOURCES})

set_target_properties("BootDisplayApp" PROPERTIES LIBRARY_OUTPUT_DIRECTORY ./Install/)
set_target_properties("BootDisplayApp" PROPERTIES RUNTIME_OUTPUT_DIRECTORY ./Install/)
set_target_properties("BootDisplayApp" PROPERTIES PREFIX "")

# Link 3rd party libraries into executable target
set(CMAKE_EXE_LINKER_FLAGS " -lEGL -lGLESv2 -lcairo -lpthread -ldrm -lgbm ")

target_link_libraries(BootDisplayApp PRIVATE cairo EGL GLESv2 gbm drm)