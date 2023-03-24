#!/bin/bash
echo
echo "==> xrandr <=="
xrandr | grep -m 1 connected
echo
echo "==> xdpyinfo <=="
xdpyinfo | grep -B 2 resolution
echo
