# @PDQTest

# sysctl has wrong value
sysctl { "net.ipv4.conf.all.accept_source_route":
  ensure => present,
  value  => 0,
}