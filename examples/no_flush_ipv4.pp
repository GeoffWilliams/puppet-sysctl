#@PDQTest

sysctl { "net.ipv4.conf.default.disable_ipv4=1":
  autoflush_ipv4 => false,
}