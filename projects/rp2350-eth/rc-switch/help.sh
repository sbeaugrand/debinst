if [ -f `basename $0` ]; then
    dir=.
else
    dir=..
    cd ..
fi
make help

echo "# Test" | grep --color ".*"
echo "nc 192.168.1.200 1000  # with local IP 192.168.1.10"
echo
echo "# NTP clock" | grep --color ".*"
echo "cmake .. -DNTP_CLOCK=ON  # + PICO_SDK_PATH and PICO_BOARD"
echo
