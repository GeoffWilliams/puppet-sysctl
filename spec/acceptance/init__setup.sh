#!/bin/bash
rm /sbin/sysctl
ln -s /testcase/spec/mock/sysctl /sbin/sysctl
rm /sbin/dracut
ln -s /testcase/spec/mock/dracut /sbin/dracut