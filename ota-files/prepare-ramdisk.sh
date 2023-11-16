#!/bin/bash -

# Build the cpio artifact first:
#   Source environment with correct DISTRO & MACHINE:
#     `DISTRO=hlio-rcd-ota MACHINE=stm32mp1-hlio-rcd-ota source layers/meta-st/scripts/envsetup.sh`
#   Build image:
#     `bitbake hlio-image-rcd-ota`
#   Output:
#     {build-path}/tmp-glibc/deploy/images/stm32mp1-hlio-rcd-ota/
# Run this script from the same console
#   - environment sourced as above
#   - starting path in build directory above tmp-glibc or supply full path to cpio in $1
# Output:
#   - uImage-ota = Kernel image
#   - uRamdisk = Full ram disk
# Deployed into:
#   - ../layers/meta-st/meta-hlio-rcd/ota-files/deploy
#   - or specify full path in $2

zipFile="rcd-ota.rootfs.cpio.gz"

cpioImageFile="./tmp-glibc/deploy/images/stm32mp1-hlio-rcd-ota/hlio-image-rcd-ota-hlio-rcd-ota-stm32mp1-hlio-rcd-ota.cpio"
deployDir="../layers/meta-st/meta-hlio-rcd/ota-files/deploy/"
if [ $# -eq 2 ]; then
    cpioImageFile="$1"
    deployDir="$2"
fi

if [ -f "$cpioImageFile" ] || [ -L "$cpioImageFile" ]; then
    # Create target deploy directory if it does not exist
    if [ ! -d "$deployDir" ]; then
        echo "Creating deploy directory '$deployDir'"
        mkdir -p "$deployDir"
    fi
    # echo "Extract Kernel image from cpio as uImage-ota."
    # cpio -i --to-stdout boot/uImage-5.15.24-rt31 < "$cpioImageFile" > uImage-ota
    echo "Copy Kernel image to deploy directory."
    pathToKernel="$( dirname $cpioImageFile )/kernel"
    cp "$pathToKernel/uImage" "$deployDir/uImage-ota"
    echo "gzip cpio file"
    gzip < "$cpioImageFile" > "$zipFile"
    echo "Make uRamdisk image"
    mkimage -A arm -O linux -T ramdisk -d "$zipFile" uRamdisk
    echo "Remove gzip binary."
    rm "$zipFile"
    echo "Moving outputs to deploy directory."
    mv uRamdisk "$deployDir"
    echo "Output ready. Run deploy script and run ota script on rcd to boot to ota."
else
    echo "Error: '$cpioImageFile' does not exist."
    exit 1
fi
