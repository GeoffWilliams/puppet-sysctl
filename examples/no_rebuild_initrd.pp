#@PDQTest

sysctl { "net.ipv6.conf.default.disable_ipv6=1":
  rebuild_initrd => false,
}