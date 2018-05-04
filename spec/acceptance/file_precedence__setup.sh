#!/bin/bash
/testcase/spec/acceptance/test_setup.sh

# make a bunch of different overrides
mkdir -p /run/sysctl.d/
mkdir -p /usr/local/lib/sysctl.d/
echo "net.ipv4.conf.all.accept_source_route=1" > /run/sysctl.d/override.conf
echo "net.ipv4.conf.all.accept_source_route=2" > /etc/sysctl.d/override.conf
echo "net.ipv4.conf.all.accept_source_route=3" > /usr/local/lib/sysctl.d/override.conf
echo "net.ipv4.conf.all.accept_source_route=4" > /usr/lib/sysctl.d/override.conf
echo "net.ipv4.conf.all.accept_source_route=5" > /lib/sysctl.d/override.conf
echo "net.ipv4.conf.all.accept_source_route=6" > /etc/sysctl.conf
