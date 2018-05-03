@test "initrd was not rebuild" {
    ! -f /tmp/testcase/dracut_executed
}