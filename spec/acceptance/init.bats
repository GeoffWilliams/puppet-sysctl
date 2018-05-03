@test "sysctl.d entry created for long form testcase - file + value" {
  grep 'net.ipv4.conf.all.accept_source_route=0' /etc/sysctl.d/80-puppet-net.ipv4.conf.all.accept_source_route.conf
}

@test "sysctl -w fired for long form testcase - value" {
  grep 'net.ipv4.conf.all.accept_source_route=0' /tmp/testcase/net.ipv4.conf.all.accept_source_route.conf
}


@test "sysctl.d entry created for short form testcase - file + value" {
  grep 'net.ipv6.conf.default.disable_ipv6=1' /etc/sysctl.d/80-puppet-net.ipv6.conf.default.disable_ipv6.conf
}

@test "sysctl -w fired for long form testcase - value" {
  grep 'net.ipv4.conf.all.accept_source_route=0' /tmp/testcase/net.ipv4.conf.all.accept_source_route.conf
}


@test "initrd was rebuilt" {
  ls /tmp/testcase/dracut_executed
}

@test "initrd rebuild command was run with correct arguments" {
  grep '\-v \-f' /tmp/testcase/dracut_executed
}

@test "flush ipv4 fired" {
  ls /tmp/testcase/flush_ipv6
}

@test "flush ipv6 fired" {
  ls /tmp/testcase/flush_ipv6
}
