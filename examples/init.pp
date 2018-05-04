#@PDQTest

# long form
sysctl { "net.ipv4.conf.all.accept_source_route":
  ensure => present,
  value  => 0,
}

# short form
sysctl { "net.ipv6.conf.default.disable_ipv6=1": }


# default setting made explict should be saved to file
sysctl {"net.ipv4.ip_default_ttl=64":}