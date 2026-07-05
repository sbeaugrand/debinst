#!/bin/bash
# -q  --quiet
#     --show-progress
# -E  --adjust-extension
# -r  --recursive
# -k  --convert-links
# -p  --page-requisites
# -np --no-parent
wget -q --show-progress -E -r -k -p -np $*
