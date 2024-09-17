#!/bin/bash
du -b | awk '{ printf "%12d %s\n", $1, $2 }' | LC_ALL=C sort
