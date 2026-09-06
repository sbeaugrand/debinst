if [ -f `basename $0` ]; then
    dir=.
else
    dir=..
    cd ..
fi
make help

echo "# Test" | grep --color ".*"
echo "$dir/client.py  # with local IP 192.168.1.10"
echo "$dir/plot.py"
echo
