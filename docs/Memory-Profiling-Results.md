## Base system

The "Base system" refers to the unit with nothing running at all, the desktop environment has been disabled, any of the
background services that aren't necessary for running a basic system have been disabled and are no longer running on the
system.

### Results

- `ps` Memory usage: 23.2M
  - Base system etc.   ?%
  - systemd-udevd    1.0%
  - systemd-logind   1.2%
  - systemd-timesyn  1.3%
  - systemd-resolve  1.4%
  - systemd-network  1.6%
  - systemd-journal  2.2%
  - systemd          2.2%
- `free` Memory usage total: 30.8M

There is a number system services that are being run by the base system, but I've refraied from listing all of them
because the sheer number of services would take up the majority of this document and wouldn't really gleam any
interesting information to the reader.

## Weston environment

The "Weston environment" referred to here would be all the components that would come along with a installation of the
weston package, this includes any processes for handling keyboard inputs, the desktop environment, and any other process
that weston spawns when it is running.

### Results

- `ps` Memory usage: 37.9M
  - Weston          10.3%
  - Weston-keyboard  3.4%
  - Weston-desktop   4.1%
- `systemd` Memory usage on restart of service: 26.2M
- `systemd` Memory usage on fresh boot of service: 30.5M
  - Of the two memory usage profiles listed for systemd, the "Memory usage on fresh boot of service" is the most
    accurate one in my opinion.
- `free` Memory usage total: 55.2M

This was one of the only processes that I was able to document the memory usage through systemd because it was the only
one that had a systemd script to start it up. This is likely something that could be done for all examples of processes,
but I didn't have the patience to go through and make a systemd script for each one of the processes that I was testing
today.

## Ahsoka demo

The "Ahsoka demo" referred to here is the thermostat application that was provided to us by Jakes team. It is a simple
"Crank"? application that is running on top of the weston desktop environment and using pretty minimal resources.

### Results

- `ps` Memory usage: 62.9M
  - Ahsoka.Demo.SBI 21.4%
  - sbengine         8.1%
- `free` Memory usage total: 84.3M

## Simple Browser touch example

The "Simple Browser touch example" refers to a simple html web-app that is run using the `qt-wpe-simple-browser`. This
is ONLY running the simple browser and does not include the underlying node system that would be run by the example ST4
application that was developed by HCEE.

### Results

- `ps` Memory usage: 56.5% (but not really, actually about 25.3%)
  - WPENetworkProce 10.4%
  - qt-wpe-simple-b 20.8%
  - WPEWebProcess   25.3%
- `free` Memory usage total: 76.8M

The addition of the percentages for each one of the processes that are under the umbrella of the `qt-wpe-simple-browser`
add up to 56.5%, but it doesn't appear that the application is actually taking up that amount of memory on the system.
My theory is that the top process, `WPEWebProcess`, is actually the parent of the other two and that their memory usage
is encompassed within the memory usage of the `WPEWebProcess`.