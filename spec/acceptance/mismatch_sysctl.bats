
@test "sysctl.d entry created - file + value" {
  grep 'net.ipv4.conf.all.accept_source_route=0' /etc/sysctl.d/80-puppet-net.ipv4.conf.all.accept_source_route.conf
}

@test "sysctl -w fired for long form testcase - value" {
  grep 'net.ipv4.conf.all.accept_source_route=0' /tmp/testcase/net.ipv4.conf.all.accept_source_route.conf
}

@test "initrd was rebuilt" {
  ls /tmp/testcase/dracut_executed
}

@test "ipv4 rules were flushed" {
  ls /tmp/testcase/dracut_executed
}