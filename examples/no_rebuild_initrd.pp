#@PDQTest

# no rebuild if you don't include the class...
# include sysctl::initrd
sysctl { "net.ipv6.conf.default.disable_ipv6=1": }