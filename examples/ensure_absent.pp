#@PDQTest

# remove setting that exists
sysctl { "net.ipv6.conf.default.disable_ipv6=1":
  ensure => absent,
}


# remove a setting that doesn't exist (and is invalid)
sysctl { "not.here":
  ensure => absent,
}

# remove a setting that doesn't exist
sysctl { "net.ipv4.conf.all.accept_source_route":
  ensure => absent,
}