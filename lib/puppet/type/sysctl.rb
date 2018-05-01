require 'puppet/parameter/boolean'

Puppet::Type.newtype(:sysctl) do
  @doc = "Manage sysctl parameter with Puppet"

  ensurable do
    desc "Ensure the kernel tuning parameter"
    defaultvalues
    defaultto(:present)
  end

  newparam(:value) do
    desc "The value to set the kernel tuning parameter to"
    isrequired
  end

  newparam(:autoflush_ipv4) do
    desc "run sysctl -w net.ipv4.route.flush=1 when needed"
    defaultto(true)
  end

  newparam(:autoflush_ipv6) do
    desc "run sysctl -w net.ipv6.route.flush=1 when needed"
    defaultto(true)
  end

  newparam(:rebuild_initrd) do
    desc "rebuild initrd after chaning rules"
    defaultto(true)
  end

  newparam(:name) do
    desc "The name of the kernel tuning parameter to set"
  end

end