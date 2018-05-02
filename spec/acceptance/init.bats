@test "sysctl.d entry created for long form testcase - file created" {
  ls /etc/sysctl.d/net.ipv4.conf.all.accept_source_route.conf
}

@test "sysctl.d entry created for long form testcase - value" {
  grep 'net.ipv4.conf.all.accept_source_route=0' /etc/sysctl.d/net.ipv4.conf.all.accept_source_route.conf
}


@test "sysctl.d entry created for short form testcase - file created" {
  ls /etc/sysctl.d/net.ipv6.conf.default.disable_ipv6.conf
}

@test "sysctl.d entry created for short form testcase - value" {
  grep 'net.ipv6.conf.default.disable_ipv6=1' /etc/sysctl.d/net.ipv6.conf.default.disable_ipv6.conf
}


@test "sysctl executed for testcase" {
  ls /tmp/net.ipv4.conf.all.accept_source_route.conf
}

@test "initrd was rebuilt" {
  ls /tmp/dracut_executed
}

@test "initrd rebuild command was run with correct arguments" {
  grep '\-v \-f' /tmp/dracut_executed
}