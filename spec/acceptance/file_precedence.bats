@test "/run/sysctl.d/override.conf renamed" {
    ls /run/sysctl.d/override.conf.nouse
}

@test "/etc/sysctl.d/override.conf renamed" {
    ls /etc/sysctl.d/override.conf.nouse
}

@test "/usr/local/lib/sysctl.d/override.conf renamed" {
    ls /usr/local/lib/sysctl.d/override.conf.nouse
}

@test "/usr/lib/sysctl.d/override.conf renamed" {
    ls /usr/lib/sysctl.d/override.conf.nouse
}

@test "/lib/sysctl.d/override.conf renamed" {
    ls /lib/sysctl.d/override.conf.nouse
}

@test "/etc/sysctl.conf renamed" {
    ls /etc/sysctl.conf.nouse
}

@test "puppet managed setting file created" {
    ls /etc/sysctl.d/80-puppet-net.ipv4.conf.all.accept_source_route.conf
}