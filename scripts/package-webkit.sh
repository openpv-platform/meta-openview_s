#!/bin/bash -

# Run this script from your build directory after building the webkit image
# ../layers/meta-st/meta-hlio-rcd/scripts/package-webkit.sh
# Output is webkit.tar

# Packages that are added by the webkit build
# brotli
# eglfs-configs
# harfbuzz-icu [libharfbuzz-icu0]
# lcms
# libtasn1
# libwpe
# libxslt
# openjpeg
# packagegroup-hlio-rcd-webkit
# qt-wpe-simple-browser
# ttf-dejavu-common
# ttf-dejavu-sans
# ttf-dejavu-sans-mono
# ttf-dejavu-serif
# woff2
# wpebackend-fdo [libwpebackend-fdo]
# wpewebkit
# wpewebkit-qtwpe-qml-plugin
# wpewebkit-web-inspector-plugin

pwd="$PWD"

pushd tmp-glibc/deploy/deb/all/
tar -cvf "$pwd/webkit.tar" ./ttf-dejavu-sans-mono_2.37-r7.1_all.deb \
                           ./ttf-dejavu-serif_2.37-r7.1_all.deb \
                           ./ttf-dejavu-sans_2.37-r7.1_all.deb \
                           ./ttf-dejavu-common_2.37-r7.1_all.deb
cd ../cortexa7t2hf-neon-vfpv4/
tar --append --file="$pwd/webkit.tar" ./brotli_1.0.9-r0.2_armhf.deb \
                                      ./eglfs-configs_1.0-r0.3_armhf.deb \
                                      ./libharfbuzz-icu0_4.0.1-r0.10_armhf.deb \
                                      ./lcms_2.13.1-r0.2_armhf.deb \
                                      ./libtasn1-6_4.18.0-r0.2_armhf.deb \
                                      ./libwpe-1.0-1_1.12.0-r0.10_armhf.deb \
                                      ./libxslt_1.1.35-r0.7_armhf.deb \
                                      ./openjpeg_2.4.0-r0.2_armhf.deb \
                                      ./qt-wpe-simple-browser_0.1-r0.14_armhf.deb \
                                      ./woff2_1.0.2-r0.2_armhf.deb \
                                      ./libwpebackend-fdo-1.0-1_1.12.0-r0.11_armhf.deb \
                                      ./wpewebkit_2.36.4-r0.18_armhf.deb \
                                      ./wpewebkit-qtwpe-qml-plugin_2.36.4-r0.18_armhf.deb \
                                      ./wpewebkit-web-inspector-plugin_2.36.4-r0.18_armhf.deb
popd
