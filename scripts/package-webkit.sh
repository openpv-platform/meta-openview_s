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
tar -cvf "$pwd/webkit.tar" ./ttf-dejavu-*.deb 
cd ../cortexa7t2hf-neon-vfpv4/
tar --append --file="$pwd/webkit.tar" ./brotli_1.0.9*.deb \
                                      ./eglfs-configs_1.0*.deb \
                                      ./libharfbuzz-icu0_4.0.1*.deb \
                                      ./lcms_2.13.1*.deb \
                                      ./libtasn1-6_4.18.0*.deb \
                                      ./libwpe-1.0-1_1.12.0*.deb \
                                      ./libxslt_1.1.35*.deb \
                                      ./openjpeg_2.4.0*.deb \
                                      ./qt-wpe-simple-browser_0.1*.deb \
                                      ./woff2_1.0.2*.deb \
                                      ./libwpebackend-fdo-1.0-1_1.12.0*.deb \
                                      ./wpewebkit_2.36.4*.deb \
                                      ./wpewebkit-qtwpe-qml-plugin_2.36.4*.deb \
                                      ./wpewebkit-web-inspector-plugin_2.36.4*.deb
popd
