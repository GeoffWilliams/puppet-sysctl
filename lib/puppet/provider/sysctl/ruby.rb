Puppet::Type.type(:sysctl).provide(:sysctl, :parent => Puppet::Provider) do
  desc "Support for sysctl on RHEL"

  commands :cmd => "sysctl",
           :dracut => "dracut"

  def self.prefetch(resources)
    instances.each do |prov|
      if resource = resources[prov.name]
        resource.provider = prov
      end
    end
  end

  def flush
    @property_hash.clear
  end


  mk_resource_methods

  def initialize(value={})
    super(value)
    @property_flush = {}
  end

  def exists?
    @property_hash[:ensure] == :present
  end


  # def value=(value)
  #   @property_flush[:value] = value
  # end


  def self.get_filename(name)
    "/etc/sysctl.d/#{name}.conf"
  end

  def get_filename(name)
    self.class.get_filename(name)
  end

  def to_file(name, value)
    "#{name}=#{value}"
  end


  def create()
    execute([command(:cmd), "-w", "#{@resource[:name]}=#{@resource[:value]}"])
    File.open(self.get_filename(@resource[:name]), 'w') { |file| file.write(to_file(@resource[:name], @resource[:value])) }

    # https://access.redhat.com/solutions/2798411
    if @resource[:rebuild_initrd]
      execute([command(:dracut), "-v", "-f"])
    end

    if @resource[:autoflush_ipv4] and @resource[:name] =~ /ipv4/
      execute([command(:cmd), "-w", "net.ipv4.route.flush=1"])
    end

    if @resource[:autoflush_ipv6] and @resource[:name] =~ /ipv6/
      execute([command(:cmd), "-w", "net.ipv6.route.flush=1"])
    end
  end

  def destroy()
    if File.exist?(self.get_filename(@resource[:name]))
      File.delete(self.get_filename(@resource[:name]))
    end
    logger.warn("Removed sysctl setting #{@resource[:name]} but you must reboot to restore the default")
  end




  def self.instances
    # for a systemctl setting to be "managed" we need an entry in a file and also
    # a matching directive

    active = {}

    execute([command(:cmd), "-a" ]).to_s.split("\n").reject { |line|
      line =~ /^\s*$/ or line !~ /=/
    }.each { |line|
      split = line.split('=')
      if split.count == 2
        name = split[0].strip
        value = split[1].strip

        if File.exist?(self.get_filename(name))
          active[name] = value
        end
      end
    }

    active.collect { |k,v|
      new({
          :name => k,
          :ensure => :present,
          :value => v,
          })
    }


  end

end
