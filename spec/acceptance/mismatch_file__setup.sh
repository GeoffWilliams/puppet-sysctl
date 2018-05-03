#!/bin/bash
/testcase/spec/acceptance/test_setup.sh

# good value in sysctl
sysctl -w "net.ipv4.conf.all.accept_source_route=0"

# bad value in file
echo "net.ipv4.conf.all.accept_source_route=111" > /etc/sysctl.d/80-puppet-net.ipv4.conf.all.accept_source_route.conf