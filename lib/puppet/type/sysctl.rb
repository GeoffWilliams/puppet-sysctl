require 'puppet/parameter/boolean'

Puppet::Type.newtype(:sysctl) do
  @doc = "Manage sysctl parameter with Puppet"

  ensurable do
    defaultvalues

    defaultto(:present)

    # we need the insync? for puppet to make right decision on whether to run the provider or not - if we leave it up
    # to provider.exists? then puppet resource command broken for files that are mismatched, they always show as ensure
    # absent even though puppet is somewhat aware of them
    def insync?(is)
      (is == :present and should == :present and (provider.value == provider.value_saved)) or
      (is == :absent and should == :absent)

    end
  end

  newproperty(:value) do
    desc "The value the kernel tuning parameter to"
    isrequired
  end

  newproperty(:defined_in) do
    desc "File containing this settings definition"
  end

  newproperty(:value_saved) do
    desc "The value the kernel tuning parameter _should_ be set to (from file)"
  end

  newparam(:autoflush_ipv4) do
    desc "run sysctl -w net.ipv4.route.flush=1 when needed"
    defaultto(true)
  end

  newparam(:autoflush_ipv6) do
    desc "run sysctl -w net.ipv6.route.flush=1 when needed"
    defaultto(true)
  end

  # Disabled due to https://github.com/GeoffWilliams/puppet-sysctl/issues/1
  # newparam(:rebuild_initrd) do
  #   desc "rebuild initrd after chaning rules"
  #   defaultto(true)
  # end

  # newparam(:rebuild_initrd_cmd) do
  #   desc "Command to run to rebuild initrd (default is autodetect)"
  #   defaultto("dracut -v -f")
  # end

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