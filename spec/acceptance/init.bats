# BATS test file to run after executing 'examples/init.pp' with puppet.
#
# For more info on BATS see https://github.com/sstephenson/bats

# Tests are really easy! just the exit status of running a command...
@test "sysctl.d entry created for testcase" {
  ls /etc/sysctl.d/net.ipv4.conf.all.accept_source_route.conf
}

@test "sysctl executed for testcase" {
  ls /tmp/net.ipv4.conf.all.accept_source_route.conf
}