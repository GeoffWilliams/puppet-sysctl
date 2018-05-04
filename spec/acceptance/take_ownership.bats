@test "user defined file renamed" {
    ls -l /etc/sysct.d/take_ownership.conf.nouse
}

@test "puppet managed file created" {
    ls -l /etc/sysctl.d/80-puppet-net.ipv4.igmp_qrv.conf
}