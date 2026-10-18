#!/bin/bash
grep --color=auto -P -n "[^\x00-\x7F]" $*
