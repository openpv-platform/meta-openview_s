# an append file to filter out st specific splash screen and replace with hlio splash screen

# filter out st splashscreen package 
PACKAGE_INSTALL := "${@oe.utils.str_filter_out('u-boot-stm32mp-splash', '${PACKAGE_INSTALL}', d)}"

# add in our hlio spalsh screen package

PACKAGE_INSTALL += "\
    u-boot-hlio-splashscreen \
    "