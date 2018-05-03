@test "ensure absent removed file" {
    ! test -f /etc/sysctl.d/80-puppet-net.ipv6.conf.default.disable_ipv6.conf
}

@test "ensure absent deleted file since its puppet manged, no renaming to .nouse" {
    ! test -f /etc/sysctl.d/80-puppet-net.ipv6.conf.default.disable_ipv6.conf.nouse
}

@test "initrd rebuilt" {
    test -f /tmp/testcase/dracut_executed
}