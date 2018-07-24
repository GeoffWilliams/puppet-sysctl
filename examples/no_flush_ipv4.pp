#@PDQTest
include sysctl::initrd

sysctl { "net.ipv4.conf.all.accept_source_route=1":
  autoflush_ipv4 => false,
}