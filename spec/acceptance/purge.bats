@test "sysctl.d entry created for testcase" {
  ls /etc/sysctl.d/80-puppet-net.ipv4.conf.all.accept_source_route.conf
}

@test "suprious testcase entries purged" {
  ! ls /etc/sysctl.d/?.conf
}