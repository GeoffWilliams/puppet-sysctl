#!/bin/bash
/testcase/spec/acceptance/test_setup.sh
echo "net.ipv4.igmp_qrv=2" > /etc/sysctl.d/take_ownership.conf