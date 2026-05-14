cd ..
make help

echo "# Test" | grep --color ".*"
echo "nc 192.168.1.200 1000  # with local IP 192.168.1.10"
echo
