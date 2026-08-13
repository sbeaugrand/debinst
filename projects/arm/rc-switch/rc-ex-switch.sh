#!/bin/bash
if [ "$1" == 1 ]; then
    echo 0x15ec2e7 22987495 couloir 1
    echo "5e c2 e7" | sudo ./rc-switch.py
elif [ "$1" == 2 ]; then
    echo 0x15ec2e7 22987495 salon
    echo "5e c2 e7" | sudo ./rc-switch.py
elif [ "$1" == 3 ]; then
    echo 0x15ec2e7 22987495 chambre 3
    echo "5e c2 e7" | sudo ./rc-switch.py
else
    echo 0x15ec2e7 22987495
    echo "5e c2 e7" | sudo ./rc-switch.py
fi
