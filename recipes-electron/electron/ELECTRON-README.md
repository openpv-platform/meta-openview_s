# Additional Notes

## Install Additional libraries Needed For HLIO Image.

* libcups.so.2
* libnss3.so

## Once Installed, library path needs to be updated.

### Set the LD_LIBRARY_PATH variable to installation directory.
$ LD_LIBRARY_PATH=/usr/lib/arm-linux-gnueabihf/

### Lastly, export the path.
$ export LD_LIBRARY_PATH

## Running the electron app.

### First, copy the app into the electron prebuilt binaries directory.
cp app/ /usr/bin/electronappinit.d/electron-v15.1.2-linux-armv7l/ 

### Lastly, Run the app.
./electron app --no-sandbox --enable-features=UseOzonePlatform --ozone-platform=wayland