require 'puppet/parameter/boolean'

Puppet::Type.newtype(:sysctl) do
  @doc = "Manage sysctl parameter with Puppet"

  ensurable

  newproperty(:value) do
    desc "The value to set the kernel tuning parameter to"
    isrequired
  end

  newproperty(:defined_in) do
    desc "File containing this settings definition"
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

  newparam(:rebuild_initrd_cmd) do
    desc "Command to run to rebuild initrd (default is autodetect)"
    defaultto("dracut -v -f")
  end

  newparam(:name) do
    desc "The name of the kernel tuning parameter to set"
  end

  # see "title patterns" - https://www.craigdunn.org/2016/07/composite-namevars-in-puppet/
  def self.title_patterns
    [
        # just a regular title (no '=') - assign it to the name field
        [ /(^([^\=]*)$)/m,
          [ [:name] ] ],

        # Title is in form key=value - assign LHS of = to name, RHS to value
        [ /^([^=]+)=(.*)$/,
          [ [:name], [:value] ]
        ]
    ]
  end

end