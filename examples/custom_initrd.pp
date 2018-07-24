#@PDQTest
class { "sysctl::initrd":
  rebuild_initrd_cmd => "/bin/echo custom > /tmp/testcase/initrd_cmd",
}
sysctl { "net.ipv6.conf.default.disable_ipv6=1": }