#@PDQTest
include sysctl::initrd

sysctl { "net.ipv6.conf.default.disable_ipv6=1":
  autoflush_ipv6 => false,
}