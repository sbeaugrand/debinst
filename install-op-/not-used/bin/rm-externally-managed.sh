#!/bin/bash
pyver=`python3 -c '
import sys
print("{}.{}".format(sys.version_info.major, sys.version_info.minor))
'`

file=/usr/lib/python$pyver/EXTERNALLY-MANAGED
if [ -f $file ]; then
    echo sudo mv $file $file.bak
    eval sudo mv $file $file.bak
fi
