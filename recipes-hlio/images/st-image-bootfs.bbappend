# an append file to filter out st specific splash screen

# filter out st splashscreen package 
PACKAGE_INSTALL := "${@oe.utils.str_filter_out('u-boot-stm32mp-splash', '${PACKAGE_INSTALL}', d)}"

# add in device tree binary overlays

PACKAGE_INSTALL += "\
    dtb-overlays \
    "

PACKAGE_INSTALL:${ESP_HOSTED_VERSION} += "\
    esp-hosted \
    "