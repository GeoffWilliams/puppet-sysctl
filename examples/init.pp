#@PDQTest
sysctl { "net.ipv4.conf.all.accept_source_route":
  value => 0,
}