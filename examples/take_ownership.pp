# take ownership of a setting that is already defined in a hand-built file
include sysctl::initrd
sysctl { "net.ipv4.igmp_qrv=2": }