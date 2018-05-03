#!/bin/bash
/testcase/spec/acceptance/test_setup.sh

# create a settings file so that there is something to remove
echo net.ipv6.conf.default.disable_ipv6=1 > /etc/sysctl.d/80-puppet-net.ipv6.conf.default.disable_ipv6.conf
