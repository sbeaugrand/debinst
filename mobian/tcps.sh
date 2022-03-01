#!/bin/bash
tcpstat -o '%S %N\n' | awk '
BEGIN {
    sum = 0;
}
{
    if ($2 != "0") {
        sum += int($2);
        print strftime("%H:%M:%S", $1), sum, $2
    }
}'
