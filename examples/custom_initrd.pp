#@PDQTest

sysctl { "net.ipv6.conf.default.disable_ipv6=1":
  rebuild_initrd_cmd => "/bin/echo custom > /tmp/testcase/initrd_cmd",
}