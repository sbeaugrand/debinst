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
