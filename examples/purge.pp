#@PDQTest
include sysctl::initrd

resources { "sysctl":
  purge => true,
}

sysctl { "net.ipv4.conf.all.accept_source_route":
  value => 0,
}