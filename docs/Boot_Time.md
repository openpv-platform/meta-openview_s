# Boot Time Measurements
- S.Livingston
- 09/30/2022
- Dunfell: 7c17ab0a80ccce6b635531613b86acc9211f3319
- Kirkstone:

- Both with the addition of:
    - systemd-bootchart to packagegroup
    - CONFIG_SCHEDSTATS=y to Kernel config

# Boot Time
- Measurements taken with [grabserial](https://github.com/tbird20d/grabserial)
- `grabserial -d /dev/ttyUSB0 -b 115200 -t -o "%" -e 30`
- Measurements are taking 3 runs and averaging, rounding to nearest 0.1s.

## Time until  
`Starting kernel ...`
- Dunfell
    - 0.8s
- Dunfell w/o Bootchart
    - 0.65s
- Kirkstone with Optee
    - 1.6s
- Kirkstone with Optee as module (noOptee)
    - 1.6s

## Time until:  
`/sbin/hlio-init.sh: line 53:    72 Killed                  $PATHDIR/psplash-drm $PATHSPLASHDIR/splash.* $PATHBACKDIR/default.* -w`
- Dunfell
    - 14.3s
- Dunfell w/o Bootchart
    - 13.1s
- Kirkstone with Optee
    - 12.3s
- Kirkstone with Optee as module (noOptee)
    - 12.4s
- Kirkstone with Optee w/o Bootchart
    - 11.5s

## Time until:  
`stm32mp1-hlio-rcd login: root (automatic login)`
- Dunfell
    - 17.5s
- Dunfell w/o Bootchart
    - 16.4s
- Kirkstone with Optee
    - 19.5s
- Kirkstone with Optee as module (noOptee)
    - 19.6s
- Kirkstone with Optee w/o Bootchart
    - 17.8s

## Time until:  
`root@stm32mp1-hlio-rcd:~#`
- Dunfell
    - 18.7s
- Dunfell w/o Bootchart
    - 17.1s
- Kirkstone with Optee
    - 24.7s (Anomalous 25.39s)
- Kirkstone with Optee as module (noOptee)
    - 24.5s
- Kirkstone with Optee w/o Bootchart
    - 22.5s

## Total to prompt, normal build
- Dunfell
    - 17.1s
- Kirkstone
    - 22.5s

## systemd-analyze
- root@stm32mp1-hlio-rcd:~# `systemd-analyze time`
- Kirkstone
  ```
  Startup finished in 1.241s (kernel) + 14.789s (userspace) = 16.031s 
  multi-user.target reached after 10.821s in userspace
  ```
- Dunfell
  ```
  Startup finished in 926ms (kernel) + 16.110s (userspace) = 17.037s 
  multi-user.target reached after 13.147s in userspace
  ```

## Notes
- Created systemd-plot.svg with command `systemd-analyze plot > systemd-plot.svg`
- Created systemd-dot.svg with
  - command `systemd-analyze dot > systemd-analyze.dot` on RCD 
  - followed by `dot -Tsvg systemd-analyze.dot > systemd-dot-final.svg` on host 
    - after installing graphviz with `sudo apt install graphviz`
  - This output is too complicated - best to use dot with a specific pattern, e.g.
    - `systemd-analyze dot 'avahi-daemon.*' > avahi.dot`