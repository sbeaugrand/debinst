#!/bin/bash
# git clone https://github.com/gphalkes/t3highlight.git
# vi t3highlight/src.util/data/esc.style
echo -e "12 \033[34;1m \t keyword         \033[0m"
echo -e " 5 \033[35m   \t string          \033[0m"
echo -e "13 \033[35;1m \t string-escape   \033[0m"
echo -e " 2 \033[32m   \t comment         \033[0m"
echo -e " 6 \033[36m   \t number          \033[0m"
echo -e " 3 \033[33m   \t misc            \033[0m"
echo -e "10 \033[32;1m \t comment-keyword \033[0m"
echo -e " 4 \033[34m   \t variable        \033[0m"
echo -e " 9 \033[31;1m \t error           \033[0m"
echo -e "10 \033[32;1m \t addition        \033[0m"
echo -e " 9 \033[31;1m \t deletion        \033[0m"
