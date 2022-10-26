# New manifest
- Manually modified manifest to match v4.0.2 ecosystem [kirkstone-mp1-v22.07.27](https://github.com/STMicroelectronics/oe-manifest/commit/134fd08b4113f1f8d38c17302523fdb31c601297)
- branch in our manifest repository: develop/sl-migrate-4.0
  - TODO: Tag once merged into the main branch
- Reproduced with repo with:
  - `repo init -u git@ssh.dev.azure.com:v3/HeliosEngineering/Right%20Cost%20Display/hlio-rcd-manifest -b develop/sl-migrate-4-0`
  - TODO: This manifest currently grabs our layer meta-hlio-rcd from the head of branch: develop/sl-migrate-openSTLinux-4-0

# Issues encountered with Migration:

## Build PC Prerequisites
  - ST does not seem to publish a centralized Migration Note. Yocto has one. Several gotchas were from changes made by ST, only documented sporadically throughout their latest documentation.
    - One of these is pre-requisites needed for the build machine. These changed with some additions, so it is best to consult the latest [PC Prerequisites](https://wiki.st.com/stm32mpu/wiki/PC_prerequisites#Installing_extra_packages)

## Distro & Machine include files changed by ST
  - We modified this now to include these files directly from ST layers (path is relative to layer)
  - Distro conf file can delete or add distro features without modifying included files

## Distro & Machine .conf files needed to be updated with similar changes in their original files.
  - Note where the original sources were copied from, as they come from different layers.

## template files
- bblayers.conf.sample and local.conf.sample had to be modified based on original files
  - Created patch files and placed these in the template folder for future reference.

## recipe changes based on Yocto changes
  - Was able to use some yocto scripts, and yocto keeps good [migration notes](https://docs.yoctoproject.org/4.0.2/migration-guides/migration-4.0.html#migration-notes-for-4-0-kirkstone)
  - Most intensive manual effort was replacing all _ with : for append, prepend and ${PN} modifiers.

## Linux patches
  - hycon patch became unnecessary
  - Atmel patch did not succeed
    - Both Atmel patches basically had to create from scratch
    - Originally Fetched v3.5 from git and replaced source to create primary upgrade patch
      - Also tested with the default Atmel driver in the Kernel
    - Decided to keep v3.5, both show errors
      - `Direct firmware load for maxtouch.cfg failed with error -2` - Berni says expected with our setup.
      - mxt_start:  Starting/Stopping - Also okay acc'd to Berni
    - See [further notes](#Atmel-patch-notes).
    - Device tree (inverted characteristic) the documentation is now yaml, the source changes done manually.
  - usb-c patch created patch-fuzz
    - Looks like this patch (from Jonathan) is no longer necessary as the existing code checks the DT for role-switch-default-mode

## Linux Kernel Config
  - Major issue with configuration settings - conflict between TEE_REMOTEPROC and OPTEE
    - Currently resolved by making them all default, but have not measured boot time.
    - TODO: Decide whether to keep all or remove all
    - See [further notes](#linux-kernel-config-notes).

## U-Boot configuration issues
- Siara did a patch for configs/stm32mp15_trusted_defconfig which failed. This is a config file in which later values overwrite previous values, so I changed this patch to add changes at the end - which should make the patch more robust.
- Also turns out ST changed the defconfig file being used - warning on [ST U-Boot](https://wiki.st.com/stm32mpu/wiki/STM32MP15_U-Boot#STM32MP15x_lines_support). No longer configs/stm32mp15_trusted_defconfig but instead configs/stm32mp15_defconfig. So I moved the patched values to this config, which resulted in new issues.
  - Note: This is determined by u-boot config, specifically in meta-st/meta-st-stm32mp/conf/machine/include/st-machine-common-stm32mp.inc, in UBOOT_CONFIG[trusted_stm32mp15].
  - Frustrating that I have yet to find ST migration notes, instead changes like this are peppered throughout their documentation.
- New Issues with config changes:
  - Build issue with scmi clk
    - Caused by removing TEE, so I removed `CONFIG_TEE=n` from the patch.
  - Build issue with stm32mp1.c in function board_late_init()
    - Caused by removing VIDEO_LCD_RAYDIUM_RM68200, so I removed `CONFIG_VIDEO_LCD_RAYDIUM_RM68200=n`. 
  - Also added `CONFIG_VIDEO_LCD_ROCKTECH_HX8394=n` as unneeded.
- See [further notes](#U-Boot-configuration-issues-notes).

## tf-a did not build 
- existing dts file includes a file that no longer exists
  - stm32mp157a-right_cost_display-mx-fw-config.dts --> #include <dt-bindings/soc/stm32mp1-tzc400.h>
- Had to install the latest version of cubeMX, load the .ioc file, migrate and generate code.
- Used the diff in the device tree files to manually update the originals in only the specific ways required for the update

## u-boot and tf-a patches
- Had to re-do the memory patches due to changes and failed patches. In tf-a, debug logging also seems to have changed.

## esp support recipe
- Resolved by using specific SHA instead of a tag for SRCREV
- Error related to fetching
```
Exception: bb.fetch2.FetchError: Fetcher failure: Recipe uses a floating tag/branch without a fixed SRCREV yet doesn't call bb.fetch2.get_srcrev() (use SRCPV in PV for OE).

ERROR: Logfile of failure stored in: /home/storage/Projects/hlio-rcd-dist/build-hliorcd-stm32mp1-hlio-rcd/tmp-glibc/work/cortexa7t2hf-neon-vfpv4-ostl-linux-gnueabi/esp-support/1.0-r0/temp/log.do_packagedata.27837
ERROR: Task (/home/storage/Projects/hlio-rcd-dist/layers/meta-st/meta-hlio-rcd/recipes-esp32/esp-support/esp-support.bb:do_packagedata) failed with exit code '1'
```

## sysctl.conf
- recipes-extended/procps overwrites /etc/sysctl.conf with our version
  - This is currently only to reduce the swappiness setting
- Since this is not a patch but a replacement, it is necessary to verify that the original file has not changed:
  - From the layers directory:
    `diff ./meta-st/meta-hlio-rcd/recipes-extended/procps/procps/sysctl.conf ./openembedded-core/meta/recipes-extended/procps/procps/sysctl.conf`

## u-boot-stm32mp-extlinux
- Had to rename recipe
  - Warning "No recipes in default available for u-boot-stm32mp-extlinux.bbappend"
- HOWEVER,
  - The original recipe duplicated an STM32MP class only to modify two variables
  - This created a problem because the class changed between versions of the STM32MP ecosystem
  - Instead, I replaced the bbappend recipe to simply set these two variables and let the orignal class do the work. In general, we need to try to duplicate as few ST provided files as possible since every new ecosystem may change those originals. Cf sysctl.conf and the machine/distro include files.
- See [further notes](#u-boot-stm32mp-extlinux-notes).

## esp32 auto-detect of device not working
- systemd service error: `stm32mp1-hlio-rcd esp32_init.sh[852]: /lib/esp32/tools/esp32_init.sh: line 38: can't create /sys/devices/platform/soc/48004000.sdmmc/manual_detect_card_change: nonexistent directory`
- Turns out name of directory changed from 48004000.sdmmc to 48004000.mmc
  - Changed esp32_init.sh script

## Other recipe changes
- Removed protobuf recipe as no longer needed for esp32, newer version already included in oe core
- Removed rs485 example recipe - no longer needed and quicker than fixing a build issue

## Start of bitbake:
- Two notes starting a build were also present in the previous ecosystem:
  - `NOTE: /home/slivings/Projects/hlio-rcd-dist/layers/meta-st/meta-st-openstlinux/recipes-st/images/st-image-resize-initrd.bb: ENABLE_PARTITIONS_IMAGE not enabled`
    - This is expected - see comment in recipe
  - `NOTE: Multiple providers are available for runtime virtual/wpebackend (wpebackend-fdo, wpebackend-rdk)  Consider defining a PREFERRED_RPROVIDER entry to match virtual/wpebackend`
    - This was resolved by setting the preferred provider to wpebackend-fdo

## app auto-start
- This was resolved by adding a class that creates the symlinks during the build. This class is borrowed from the old ecosystem and was removed with this ecosystem, but we still seem to need it.
  - See classes/image-gcnano-link.bbclass and inherited in conf/machine/stm32mp1-hlio-rcd.conf
  - Note: The original assumed a symlink for the base library but our build produces a binary file in the lib directory, so the class was modified appropriately.
- Moved libraries to /usr/lib and eliminate /vendor by adding `ST_VENDORFS = "0"` to machine config
  - soft link still not automatically created, but manual creation works at startup
- See [further notes](#app-auto-start-notes).

## Running WiFi fails to run dhcp client
- dhclient is no longer included in openembedded, instead dhcpcd should be used. But we should use systemd.networkd instead for all dhcp settings.
- TODO: Update hardware verification app to use systemd-networkd and discard the shell script `rcd-wifi-station-dhcp.sh`

## x11 mesa-gl and xserver-xorg build issues
- Eliminating x11 as Distro Feature avoids problem, but x11 seems to be necessary
- mesa-gl configure:
  - `mesa-gl` seems to be fixed by adding gallium to PACKAGECONFIG
    - `PACKAGECONFIG:class-target:append = " gallium"` via bbappend
- Subsequent error after resolving mesa-gl was with `xserver-xorg`
  - Seems to be resolved by bbappend:
    - `DEPENDS:append = " libxshmfence"`
- See [further notes](#x11-mesa-gl-and-xserver-xorg-build-issues-notes).

## Display Issue
- Weston is now run under weston user, resulting in:
  ```
  Apr 28 17:47:56 openView start.sh[807]: Authorization required, but no authorization protocol specified
  Apr 28 17:47:56 openView Ahsoka.Installe[807]: cannot open display: :0
  ```
- Resolved with changes to Ahsoka, 
  - add "export XDG_RUNTIME_DIR=/run/user/`id -u weston" to start scripts
  - add WAYLAND_DISPLAY to LinuxDotNetProfile.sh:
    ```
    WESTON_RUNTIME_DIR=/run/user/`id -u weston`
    if [ -e $WESTON_RUNTIME_DIR/wayland-0 ]; then
          export WAYLAND_DISPLAY=wayland-0
      else
          if [ -e $WESTON_RUNTIME_DIR/wayland-1 ]; then
              export WAYLAND_DISPLAY=wayland-1
          fi
    fi
    ```
- According to [ST](https://wiki.st.com/stm32mpu/wiki/STM32_MPU_ecosystem_release_change_notification_%E2%80%93_V4.0.0#User_space_and_applications), should be able to resolve with `su -l weston -c "<command>"` but Ahsoka depends on root user execution.
- Originally tried to resolve with change to /etc/profile.d/weston_profile.sh
  - Add new weston_profile.sh to files under weston-init recipe.
  - This removes check for user and allows all users to source the weston profile variables.
- But sourcing this weston_profile.sh causes other issues.

## webkit build issue
- Certain package config options were removed from wpewebkit, so these were removed and one added (mediastream)
  ```
  WARNING: wpewebkit-2.36.4-r0 do_configure: QA Issue: wpewebkit: invalid PACKAGECONFIG: fetchapi [invalid-packageconfig]
  WARNING: wpewebkit-2.36.4-r0 do_configure: QA Issue: wpewebkit: invalid PACKAGECONFIG: indexeddb [invalid-packageconfig]
  WARNING: wpewebkit-2.36.4-r0 do_configure: QA Issue: wpewebkit: invalid PACKAGECONFIG: systemd [invalid-packageconfig]
  ```
- Originally saw issue with mesa vs mesa-gl - originally resolved with taking out Distro Feature X11 (conflicts with Weston?), but ultimately not seen after other changes.
  ```
  ERROR: Nothing RPROVIDES 'libgles2' (but /home/slivings/Projects/hlio-rcd-dist-v4.0/layers/meta-webkit/recipes-browser/wpewebkit/wpewebkit_2.36.6.bb RDEPENDS on or otherwise requires it)
  mesa RPROVIDES libgles2 but was skipped: PREFERRED_PROVIDER_virtual/libgl set to mesa-gl, not mesa
  ```

## Unresolved issues
### openSSL call to RSA.FromXmlString() takes 2.5s compared to 0.4s in Dunfell

## Additional Notes
### Atmel patch notes
- [&#2191; Back](#linux-patches)
- From v3.5, both an error and start/stop of atmel_mxt_ts 
  ```
  [   18.243612] atmel_mxt_ts 0-004a: Warning: reset-gpios not found or undefined
  [   18.253026] atmel_mxt_ts 0-004a: Family: 166 Variant: 6 Firmware V1.0.AB Objects: 36
  [   18.276374] atmel_mxt_ts 0-004a: Enabling RETRIGEN feature
  [   18.276862] atmel_mxt_ts 0-004a: RETRIGEN Enabled feature
  [   18.285558] atmel_mxt_ts 0-004a: RETRIGEN enabled
  [   18.286063] stm32f7-i2c 5c002000.i2c: STM32F7 I2C-0 bus adapter
  ```
**[   18.286176] atmel_mxt_ts 0-004a: Direct firmware load for maxtouch.cfg failed with error -2**
  ```
  [   18.287356] atmel_mxt_ts 0-004a: Initialized power cfg: ACTV 255, IDLE 32
  [   18.287949] atmel_mxt_ts 0-004a: RETRIGEN enabled
  [   18.287979] atmel_mxt_ts 0-004a: mxt_config: Registering devices
  [   18.291885] atmel_mxt_ts 0-004a: Touchscreen size {x,y} = {799,479}
  [   18.292351] input: Atmel maXTouch Touchscreen as /devices/platform/soc/5c002000.i2c/i2c-0/0-004a/input/input0
  [   19.366074] atmel_mxt_ts 0-004a: mxt_start:  Starting . . .
  [   19.482314] atmel_mxt_ts 0-004a: mxt_stop:  Stopping . . .
  [   19.654601] atmel_mxt_ts 0-004a: mxt_start:  Starting . . .
  [   19.781330] atmel_mxt_ts 0-004a: mxt_stop:  Stopping . . .
  [   19.927068] atmel_mxt_ts 0-004a: mxt_start:  Starting . . .
  [   20.042274] atmel_mxt_ts 0-004a: mxt_stop:  Stopping . . .
  ```
- The default Kernel driver only shows the error -2 but perhaps an argument from silence

### U-Boot configuration issues Notes
- [&#2191; Back](#U-Boot-configuration-issues)
- Build issue with scmi clk, multiple undefined references, e.g.:
  ```
  | arm-ostl-linux-gnueabi-ld.bfd: drivers/clk/clk_scmi.o: in function `scmi_clk_gate':
  | /home/slivings/Projects/hlio-rcd-dist/build-hliorcd-stm32mp1-hlio-rcd/workspace/sources/u-boot-stm32mp/drivers/clk/clk_scmi.c:73: undefined reference to `devm_scmi_process_msg'
  ```
  - Caused by removing TEE, so I removed `CONFIG_TEE=n` from the patch.
- Build issue with stm32mp1.c in function board_late_init()
  ```
  | arm-ostl-linux-gnueabi-ld.bfd: board/st/stm32mp1/stm32mp1.o: in function `board_late_init':
  | /home/slivings/Projects/hlio-rcd-dist/build-hliorcd-stm32mp1-hlio-rcd/workspace/sources/u-boot-stm32mp/board/st/stm32mp1/stm32mp1.c:920: undefined reference to `_u_boot_list_2_driver_2_rm68200_panel'
  ```

### Linux Kernel Config Notes
- [&#2191; Back](#linux-kernel-config)
- Original Build
    ```
    | make: Entering directory '/home/slivings/Projects/hlio-rcd-dist-v4.0/build-hliorcd-stm32mp1-hlio-rcd/tmp-glibc/work/stm32mp1_hlio_rcd-ostl-linux-gnueabi/linux-stm32mp/5.15.24-stm32mp-r1-r0/build'
    |   SYNC    include/config/auto.conf.cmd
    |   GEN     Makefile
    | 
    | WARNING: unmet direct dependencies detected for TEE_REMOTEPROC
    |   Depends on [n]: REMOTEPROC [=y] && OPTEE [=n]
    |   Selected by [m]:
    |   - STM32_RPROC [=m] && ARCH_STM32 [=y] && REMOTEPROC [=y]
    ```
- Tried restoring TEE and OPTEE as modules
  - This essentially was removing "CONFIG_TEE is not set" which was at end of optimization fragment
    - but CONFIG_NVMEM_STM32_ROMEM had multiple undefined reference errors:
      ```
      | arm-ostl-linux-gnueabi-ld.bfd: drivers/nvmem/stm32-romem.o: in function `stm32_bsec_pta_remove':
      | stm32-romem.c:(.text+0x3c): undefined reference to `tee_client_close_session'
      | arm-ostl-linux-gnueabi-ld.bfd: stm32-romem.c:(.text+0x44): undefined reference to `tee_client_close_context'
      | arm-ostl-linux-gnueabi-ld.bfd: drivers/nvmem/stm32-romem.o: in function `stm32_bsec_pta_probe':
      | stm32-romem.c:(.text+0x94): undefined reference to `tee_client_open_context'
      | arm-ostl-linux-gnueabi-ld.bfd: stm32-romem.c:(.text+0xe4): undefined reference to `tee_client_open_session'
      | arm-ostl-linux-gnueabi-ld.bfd: stm32-romem.c:(.text+0x180): undefined reference to `tee_client_close_context'
      | arm-ostl-linux-gnueabi-ld.bfd: drivers/nvmem/stm32-romem.o: in function `stm32_bsec_pta_read':
      | stm32-romem.c:(.text+0x27c): undefined reference to `tee_shm_alloc'
      | arm-ostl-linux-gnueabi-ld.bfd: stm32-romem.c:(.text+0x2b0): undefined reference to `tee_client_invoke_func'
      | arm-ostl-linux-gnueabi-ld.bfd: stm32-romem.c:(.text+0x2d4): undefined reference to `tee_shm_free'
      | arm-ostl-linux-gnueabi-ld.bfd: stm32-romem.c:(.text+0x304): undefined reference to `tee_shm_get_va'
      | arm-ostl-linux-gnueabi-ld.bfd: drivers/nvmem/stm32-romem.o: in function `.LANCHOR1':
      | stm32-romem.c:(.data+0x70): undefined reference to `tee_bus_type'
      ```
    - Set this to a module as well, but it has a different error compiling as a module
      ```
      | FATAL: modpost: drivers/nvmem/nvmem_stm32_romem: struct of_device_id is not terminated with a NULL entry!
      ```

### u-boot-stm32mp-extlinux Notes
- [&#2191; Back](#u-boot-stm32mp-extlinux)
- Diff from old st to new st code (non trivial changes):
```diff
slivings@ubuntu:~/Projects$ diff old-hlio-rcd-dist/layers/meta-st/meta-st-stm32mp/classes/extlinuxconf-stm32mp.bbclass hlio-rcd-dist/layers/meta-st/meta-st-stm32mp/classes/extlinuxconf-stm32mp.bbclass 
77c77
< UBOOT_EXTLINUX_CONSOLE ??= "console=${console}"
---
> UBOOT_EXTLINUX_CONSOLE ??= "console=${console},${baudrate}"
101c101
<             splashscreen_name = localdata.getVar('UBOOT_SPLASH_IMAGE')
---
>             splashscreen_name = localdata.getVar('UBOOT_EXTLINUX_SPLASH')
103c103
<                 bb.warn('UBOOT_SPLASH_IMAGE not defined')
---
>                 bb.warn('UBOOT_EXTLINUX_SPLASH not defined')
146c146
<                     kernel_image = kernel_image + '#conf@' + label + '.dtb'
---
>                     kernel_image = kernel_image + '#conf-' + label + '.dtb'
246,247c246,247
<                     if d.getVar('UBOOT_EXTLINUX_DEFAULT_LABEL_%s' % config):
<                         bb.note(">>> Specific configuration for UBOOT_EXTLINUX_DEFAULT_LABEL var detected for %s label: %s" % (config, d.getVar('UBOOT_EXTLINUX_DEFAULT_LABEL_%s' % config)))
---
>                     if d.getVar('UBOOT_EXTLINUX_DEFAULT_LABEL:%s' % config):
>                         bb.note(">>> Specific configuration for UBOOT_EXTLINUX_DEFAULT_LABEL var detected for %s label: %s" % (config, d.getVar('UBOOT_EXTLINUX_DEFAULT_LABEL:%s' % config)))
264a265,273
>                     socname_list =  d.getVar('STM32MP_SOC_NAME')
>                     if socname_list and len(socname_list.split()) > 0:
>                         for soc in socname_list.split():
>                             if config.find(soc) > -1:
>                                 if d.getVar('UBOOT_EXTLINUX_SPLASH:%s' % soc):
>                                     splash = d.getVar('UBOOT_EXTLINUX_SPLASH:%s' % soc)
>                                     bb.note(">>> Specific configuration for SPLASH Screen detected with configuration: %s" % config)
>                                     bb.note(">>> Set UBOOT_EXTLINUX_SPLASH to %s" % splash)
>                                     d.setVar('UBOOT_EXTLINUX_SPLASH', splash)
276c285
< do_create_multiextlinux_config[vardeps] += "${@' '.join(['UBOOT_EXTLINUX_%s_%s' % (v, l) for v in d.getVar('UBOOT_EXTLINUX_TARGET_VARS').split() for l in d.getVar('UBOOT_EXTLINUX_TARGETS').split()])}"
---
> do_create_multiextlinux_config[vardeps] += "${@' '.join(['UBOOT_EXTLINUX:%s:%s' % (v, l) for v in d.getVar('UBOOT_EXTLINUX_TARGET_VARS').split() for l in d.getVar('UBOOT_EXTLINUX_TARGETS').split()])}"
278,280c287,289
< UBOOT_EXTLINUX_LABELS_CONFIGURED = "${@' '.join(dict.fromkeys(' '.join('%s' % d.getVar('UBOOT_EXTLINUX_LABELS_%s' % o) for o in d.getVar('UBOOT_EXTLINUX_TARGETS').split()).split()))}"
< UBOOT_EXTLINUX_LABELS_CONFIGURED += "${@' '.join(dict.fromkeys(' '.join('%s' % d.getVar('UBOOT_EXTLINUX_TARGETS_EXTRA_CONFIG_%s' % o) for o in d.getVar('UBOOT_EXTLINUX_TARGETS').split()).split()))}"
< do_create_multiextlinux_config[vardeps] += "${@' '.join(['UBOOT_EXTLINUX_%s_%s' % (v, l) for v in d.getVar('UBOOT_EXTLINUX_LABELS_VARS').split() for l in d.getVar('UBOOT_EXTLINUX_LABELS_CONFIGURED').split()])}"
---
> UBOOT_EXTLINUX_LABELS_CONFIGURED = "${@' '.join(dict.fromkeys(' '.join('%s' % d.getVar('UBOOT_EXTLINUX_LABELS:%s' % o) for o in d.getVar('UBOOT_EXTLINUX_TARGETS').split()).split()))}"
> UBOOT_EXTLINUX_LABELS_CONFIGURED += "${@' '.join(dict.fromkeys(' '.join('%s' % d.getVar('UBOOT_EXTLINUX_TARGETS_EXTRA_CONFIG:%s' % o) for o in d.getVar('UBOOT_EXTLINUX_TARGETS').split()).split()))}"
> do_create_multiextlinux_config[vardeps] += "${@' '.join(['UBOOT_EXTLINUX:%s:%s' % (v, l) for v in d.getVar('UBOOT_EXTLINUX_LABELS_VARS').split() for l in d.getVar('UBOOT_EXTLINUX_LABELS_CONFIGURED').split()])}"
```
- Looking at startup:
  - After first boot:
    ```
    root@stm32mp1-hlio-rcd:~# cat /boot/extlinux/extlinux.conf 
    TIMEOUT 0
    LABEL Hlio-RCD
      KERNEL /uImage
      FDTDIR /
      APPEND root=PARTUUID=491f6117-415d-4f53-88c9-6e0de54deac6 rootwait rw quiet init="/sbin/hlio-init.sh"  console=ttySTM0,115200
    root@stm32mp1-hlio-rcd:~# cat /proc/cmdline 
    root=PARTUUID=491f6117-415d-4f53-88c9-6e0de54deac6 rootwait rw quiet   console=ttySTM0,115200
    ```
  - After second boot:
    ```
    root@stm32mp1-hlio-rcd:~# cat /proc/cmdline
    root=PARTUUID=491f6117-415d-4f53-88c9-6e0de54deac6 rootwait rw quiet init="/sbin/hlio-init.sh"  console=ttySTM0,115200
    ```


### app auto-start Notes
- [&#2191; Back](#app-auto-start)
- Service fails with:
  ```
  pr 28 17:53:36 stm32mp1-hlio-rcd systemd[1]: Started Automatically start app upon boot.
  Apr 28 17:53:37 stm32mp1-hlio-rcd bash[806]: Failed to stop weston@root.service: Unit weston@root.service not loaded.
  Apr 28 17:53:43 stm32mp1-hlio-rcd bash[820]: Server started on port 8999
  Apr 28 17:53:43 stm32mp1-hlio-rcd bash[820]: Browser:  QStandardPaths: XDG_RUNTIME_DIR not set, defaulting to '/tmp/runtime-root'
  Apr 28 17:53:49 stm32mp1-hlio-rcd bash[820]: Browser:  Couldn't open libGLESv2.so.2: libGLESv2.so.2: cannot open shared object file: No such file or directory
  Apr 28 17:53:50 stm32mp1-hlio-rcd bash[820]: Browser:
  Apr 28 17:53:50 stm32mp1-hlio-rcd bash[820]: (process:1189): GLib-CRITICAL **: 17:53:50.093: Failed to set scheduler settings: Operation not permitted
  ```
- Running manually webkit fails in the same way with:
  - First kill process of qt-wpe-simple-browser
  - Then run start.sh from root home
  ```
  root@stm32mp1-hlio-rcd:~# ./start.sh
  Failed to stop weston@root.service: Unit weston@root.service not loaded.
  Server started on port 8999
  Browser:  QStandardPaths: XDG_RUNTIME_DIR not set, defaulting to '/tmp/runtime-root'

  Browser:  Couldn't open libGLESv2.so.2: libGLESv2.so.2: cannot open shared object file: No such file or directory
  ```
- Manually create softlink to the .so which does exist:
  ```
  root@stm32mp1-hlio-rcd:/# find . -name libGLE*
  ./vendor/lib/libGLESv1_CM.so
  ./vendor/lib/libGLESv2.so
  root@stm32mp1-hlio-rcd:/vendor/lib# ln -s libGLESv2.so libGLESv2.so.2
  ```
  - This works for a manual start, but for some reason still does not work for the auto-start service.
  - For auto-start, it worked to create soft link in the /usr/lib directory instead:
    - `root@stm32mp1-hlio-rcd:/usr/lib# ln -s /vendor/lib/libGLESv2.so libGLESv2.so.2`

- Looking into why the library naming is wrong, found this difference from old ecosystem:
  - The conf/machine/include/gpu_vivante.inc file from ST previously had:
    ```
    # create gcnano link (some links are remove by image generation)
    inherit image-gcnano-link
    ```
  - And meta-st/meta-st-stm32mp/classes/image-gcnano-link.bbclass had:
    ```
    gcnano_create_link() {
      ...
        # link requested:
        # libGLESv2.so.2 -> /vendor/lib/libGLESv2.so
        if [ ! -L ${IMAGE_ROOTFS}${libdir}/libGLESv2.so.2 ];
        then
            LINK=$(readlink ${IMAGE_ROOTFS}${libdir}/libGLESv2.so)
            ln -s $LINK ${IMAGE_ROOTFS}${libdir}/libGLESv2.so.2
        fi
    ```
  - Tried restoring this but the link does not get created

- Looking into why the library naming is wrong, also found this recipe:
  - meta-st-openstlinux/recipes-samples/weston-cube/weston-cube_git.bb
    ```
    do_install () {
      install -d ${D}${prefix}/local/demo/bin
      install -m 0755 ${B}/weston-st-egl-cube-tex ${D}${prefix}/local/demo/bin/
      # Fix wrong library name in bin file
      if [ ${PREFERRED_PROVIDER_virtual/egl} = "mesa" ]; then
          patchelf --replace-needed libEGL.so libEGL.so.1 ${D}${prefix}/local/demo/bin/weston-st-egl-cube-tex
      fi
      if [ ${PREFERRED_PROVIDER_virtual/libgles2} = "mesa" ]; then
          patchelf --replace-needed libGLESv2.so libGLESv2.so.2 ${D}${prefix}/local/demo/bin/weston-st-egl-cube-tex
      fi
    }
    ```
- Service originally exited with failure - probably related to needing the webkit version:
  ```
  root@stm32mp1-hlio-rcd:~# systemctl status app-start.service
  × app-start.service - Automatically start app upon boot
      Loaded: loaded (/lib/systemd/system/app-start.service; enabled; vendor preset: disabled)
      Active: failed (Result: exit-code) since Thu 2022-04-28 17:47:56 UTC; 52s ago
      Process: 802 ExecStart=bash -c ~/start.sh (code=exited, status=7)
    Main PID: 802 (code=exited, status=7)

  Apr 28 17:47:56 stm32mp1-hlio-rcd bash[823]:     at onErrorNT (node:internal/child_process:477:16)
  Apr 28 17:47:56 stm32mp1-hlio-rcd bash[823]:     at processTicksAndRejections (node:internal/process/task_queues:83:21) {
  Apr 28 17:47:56 stm32mp1-hlio-rcd bash[823]:   errno: -2,
  Apr 28 17:47:56 stm32mp1-hlio-rcd bash[823]:   code: 'ENOENT',
  Apr 28 17:47:56 stm32mp1-hlio-rcd bash[823]:   syscall: 'spawn qt-wpe-simple-browser',
  Apr 28 17:47:56 stm32mp1-hlio-rcd bash[823]:   path: 'qt-wpe-simple-browser',
  Apr 28 17:47:56 stm32mp1-hlio-rcd bash[823]:   spawnargs: [ 'http://localhost:8999' ]
  Apr 28 17:47:56 stm32mp1-hlio-rcd bash[823]: }
  Apr 28 17:47:56 stm32mp1-hlio-rcd systemd[1]: app-start.service: Main process exited, code=exited, status=7/NOTRUNNING
  Apr 28 17:47:56 stm32mp1-hlio-rcd systemd[1]: app-start.service: Failed with result 'exit-code'.
  ```

### x11 mesa-gl and xserver-xorg build issues Notes
- [&#2191; Back](#x11-mesa-gl-and-xserver-xorg-build-issues)
- mesa-gl configure:
  - from [github](https://github.com/intel/external-mesa/blob/master/meson.build)
    ```
    if with_glx != 'disabled'
      if not (with_platform_x11 and with_any_opengl)
        error('Cannot build GLX support without X11 platform support and at least one OpenGL API')
      elif with_glx == 'gallium-xlib'
        if not with_gallium
          error('Gallium-xlib based GLX requires at least one gallium driver')
    ```
  - We pass environment:
    - `bitbake -e mesa-gl | grep ^GALLIUMDRIVERS`
      ```
      GALLIUMDRIVERS="swrast"
      GALLIUMDRIVERS:x86-x32=""
      GALLIUMDRIVERS_LLVM="r300,nouveau"
      GALLIUMDRIVERS_RADEONSI=""
      ```
  - Invocation of meson:
    ```
    Executing meson -Dshared-glapi=enabled -Dglx-read-only-text=true -Dplatforms=x11 -Ddri3=disabled -Degl=disabled -Delf-tls=false -Dgallium-drivers= -Dllvm=disabled -Dgbm=disabled -Dgles1=disabled -Dgles2=disabled -Dlmsensors=disabled -Dgallium-opencl=disabled -Dopencl-spirv=false -Dopengl=true -Dosmesa=false -Dlibunwind=disabled -Dgallium-va=disabled -Dgallium-vdpau=disabled -Dvulkan-drivers= -Dgallium-xa=disabled -Dgallium-xvmc=disabled...
    ```
- ST Weston Image does not build mesa-gl
  - This was a bit of a red herring. I added X11 to the ST Weston Distro features and glmark2 now requires mesa-gl.
- Looks like glmark2 is requiring mesa-gl
  ```
  bitbake -g hlio-image-rcd-base
  grep mesa task-depends.dot 
  "glmark2.do_package" -> "mesa-gl.do_packagedata"
  ```
- Whereas in the ST provided Weston build it requires gcnano-userland-multi-binary-stm32mp
  ```
  bitbake -g st-image-weston
  grep glmark2 task-depends.dot
  "glmark2.do_package" -> "gcnano-userland-multi-binary-stm32mp.do_packagedata"
  ```
- Comparing preferred providers:
  - New Build:
  ```
  slivings@ubuntu:~/Projects/hlio-rcd-dist/build-hliorcd-stm32mp1-hlio-rcd$ bitbake -e | grep ^PREFERRED_PROVIDER | grep gcnano
  PREFERRED_PROVIDER_virtual/egl="gcnano-userland-multi-binary-stm32mp"
  PREFERRED_PROVIDER_virtual/libgbm="gcnano-userland-multi-binary-stm32mp"
  PREFERRED_PROVIDER_virtual/libgles1="gcnano-userland-multi-binary-stm32mp"
  PREFERRED_PROVIDER_virtual/libgles2="gcnano-userland-multi-binary-stm32mp"
  slivings@ubuntu:~/Projects/hlio-rcd-dist/build-hliorcd-stm32mp1-hlio-rcd$ bitbake -e | grep ^PREFERRED_PROVIDER | grep mesa
  PREFERRED_PROVIDER_nativesdk-mesa="nativesdk-mesa"
  PREFERRED_PROVIDER_virtual/libgl="mesa-gl"
  PREFERRED_PROVIDER_virtual/libgl-native="mesa-native"
  PREFERRED_PROVIDER_virtual/libgles3="mesa"
  PREFERRED_PROVIDER_virtual/mesa="mesa-gl"
  PREFERRED_PROVIDER_virtual/nativesdk-libgl="nativesdk-mesa"
  ```
- Error Message building mesa-gl
  ```
  ERROR: mesa-gl-2_22.0.0-r0 do_configure: meson failed
  ERROR: mesa-gl-2_22.0.0-r0 do_configure: ExecutionError('/home/slivings/Projects/hlio-rcd-dist-v4.0/build-hliorcd-stm32mp1-hlio-rcd/tmp-glibc/work/cortexa7t2hf-neon-vfpv4-ostl-linux-gnueabi/mesa-gl/2_22.0.0-r0/temp/run.do_configure.1456191', 1, None, None)
  ERROR: Logfile of failure stored in: /home/slivings/Projects/hlio-rcd-dist-v4.0/build-hliorcd-stm32mp1-hlio-rcd/tmp-glibc/work/cortexa7t2hf-neon-vfpv4-ostl-linux-gnueabi/mesa-gl/2_22.0.0-r0/temp/log.do_configure.1456191
  .
  .
  .
  | Checking if "-mtls-dialect=gnu2" runs: YES
  | 
  | ../mesa-22.0.0/meson.build:555:6: ERROR: Problem encountered: xlib based GLX requires at least one gallium driver
  | 
  ```
- Subsequent error with `xserver-xorg`
  - Config error
    ```
    | ../xorg-server-21.1.3/meson.build:434:11: ERROR: Problem encountered: DRI3 requested, but xshmfence not found
    | 
    | A full log can be found at /home/slivings/Projects/hlio-rcd-dist/build-hliorcd-stm32mp1-hlio-rcd/tmp-glibc/work/cortexa7t2hf-neon-vfpv4-ostl-linux-gnueabi/xserver-xorg/2_21.1.3-r0/build/meson-logs/meson-log.txt
    | ERROR: meson failed
    | WARNING: exit code 1 from a shell command.
    ERROR: Task (/home/slivings/Projects/hlio-rcd-dist/layers/openembedded-core/meta/recipes-graphics/xorg-xserver/xserver-xorg_21.1.3.bb:do_configure) failed with exit code '1'
    ```

## Misc.
- Builds of large packages were failing for me due to resource limitations.
  - Running bitbake with the following limits threads and parallel compiles:
    - `BB_NUMBER_THREADS=16 PARALLEL_MAKE="-j 4" bitbake wpewebkit`
- Get a list of packages and package dependencies:
  - `bitbake -g [image]`
    - Produces pn-buildlist and task-depends.dot
  - `bitbake -g [package] && cat task-depends.dot | grep -v -e '-native' | grep -v digraph | grep -v -e '-image' | awk '{print $1}' | sort | uniq`
    - A concise text dump of all of the dependencies of a package. Includes both runtime and compile-time dependencies.
- My version of last command to only display one of each:
  - `bitbake -g [package] && cat task-depends.dot | grep -v -e '-native' | grep -v digraph | grep -v -e '-image' | awk '{print $1}' | grep 'package"' | sort | uniq`
