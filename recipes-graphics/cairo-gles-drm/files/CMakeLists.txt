# CMakeList.txt : Cairo interop library with kmsdrm backend build. 
#
# Ahsoka.GLES

cmake_minimum_required (VERSION 3.8)

# Set up project target
project ("cairo-gles-drm" VERSION 1.0 DESCRIPTION "Cairo Interop library for creating a Cairo GLES context with kmsdrm backend")

# Set the Linker flags that will link neccesary 3rd party libraries into our shared lib
# TODO: Not sure I need -lEGL
# TODO: Look up cairo, glesv2, egl & drm same as SDL2 example in https://wiki.libsdl.org/SDL2/README/cmake?
set(CMAKE_SHARED_LINKER_FLAGS " -lEGL -lGLESv2 -lcairo -lpthread -ldrm ")

include(FindPkgConfig)

pkg_check_modules(KMSDRM libdrm gbm egl)

include_directories( Cairo Touch drm-gbm "${KMSDRM_INCLUDE_DIRS}")

set(SOURCES
    cairo-gles-drm.c
    Cairo/CairoContext.c
    Touch/Touch.c
    Touch/TouchDevice.c
    drm-gbm/common.c
    drm-gbm/drm-legacy.c
    drm-gbm/drm-common.c
)

# add the target Library
add_library(cairo-gles-drm SHARED ${SOURCES})

set_target_properties("cairo-gles-drm" PROPERTIES LIBRARY_OUTPUT_DIRECTORY ./Install/)
set_target_properties("cairo-gles-drm" PROPERTIES RUNTIME_OUTPUT_DIRECTORY ./Install/)
set_target_properties("cairo-gles-drm" PROPERTIES PREFIX "")


# Link 3rd party libraries into executable target
set(CMAKE_EXE_LINKER_FLAGS " -lEGL -lGLESv2 -lcairo -ldrm ")

# Set the executable target
add_executable(CairoLibTests Tests/SharedLibTests.c)

target_link_libraries(CairoLibTests PRIVATE cairo-gles-drm cairo GLESv2)
