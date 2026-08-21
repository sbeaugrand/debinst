#!/bin/bash
last -R | grep boot | head -n 2 | tail -n 1 | sed "s/.*boot/Last:/"
