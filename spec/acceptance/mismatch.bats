
@test "sysctl.d entry created - file + value" {
  grep 'bogus.mismatch.value=100' /etc/sysctl.d/80-puppet-bogus.mismatch.value.conf
}

@test "sysctl -w fired for long form testcase - value" {
  grep 'bogus.mismatch.value=100' /tmp/testcase/bogus.mismatch.value.conf
}


@test "initrd was rebuilt" {
  ls /tmp/testcase/dracut_executed
}