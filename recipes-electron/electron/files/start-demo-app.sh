#!/bin/sh

export DISPLAY=:0
export WAYLAND_DISPLAY=wayland-0

cd /usr/local/electron
./electron app --no-sandbox

