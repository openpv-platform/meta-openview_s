# Building the RCD image with the meta-webkit layer
A few requirments must be satisfied in order to properly build any image that contains a recipe from the meta-webkit layer
1. First, make sure that your system has the updated repo manifest xml that includes the path to fetch the meta-webkit repository from github. If you do not have the updated manifest xml file then you must use repo update and repo sync to pull in the meta-webkit layer into your layers directory.
2. After cloning the webkit repository through repo, you must make sure that the layer is included in your bitbake layers. To verify this, source the open embedded environment setup script and run the command:
    `bitbake-layers show-layers`
And verify that the meta-webkit layer is present. If it is not, then you will need to manually add the layer by running the command:
    `bitbake-layers add-layer ../layers/meta-webkit/`
After that completes, run the show layers command again and verify that meta-webkit is now found by the bitbake tool.

# Building the qt-simple-browser recipe
In order to build the QT simple browser recipe verify that you have included the packagegroup containing all the QT S.B. dependencies. This packagroup is called: 
    `packagegroup-hlio-webkit`
So verify that it is included in the image you want to build.
