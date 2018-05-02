#@PDQTest

# long form
sysctl { "net.ipv4.conf.all.accept_source_route":
  ensure => present,
  value  => 0,
}

# short form
sysctl { "net.ipv6.conf.default.disable_ipv6=1": }