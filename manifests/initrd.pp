# @summary Rebuild initrd after all sysctl rules applied
#
# Puppet types an providers are currently unable to batch operations. Easiest way to make
# sure the initrd is only updated once is therefore to put something in the catalogue and
# refer to it which leads to this workaround. Make sure to include this class to satisfy
# the redhat requirement to rebuild the initrd when sysctl settings change.
#
# @see https://access.redhat.com/solutions/2798411
#
# @param rebuild_initrd_cmd Command to run to rebuild initrd
# @param enabled Set `false` to disable the initrd rebuild
class sysctl::initrd(
  String  $rebuild_initrd_cmd = "/usr/sbin/dracut -v -f",
  Boolean $enabled            = true,
) {

  if $enabled {
    exec { "sysctl_rebuild_initrd":
      command     => $rebuild_initrd_cmd,
      refreshonly => true,
    }

    Sysctl <||> ~> Exec["sysctl_rebuild_initrd"]
  }
}