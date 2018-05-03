#@PDQTest

# file under /etc/sysct.d has wrong value, sysctl value is correct
sysctl { "net.ipv4.conf.all.accept_source_route":
  ensure => present,
  value  => 0,
}