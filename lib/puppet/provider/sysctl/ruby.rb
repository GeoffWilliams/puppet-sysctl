Puppet::Type.type(:sysctl).provide(:sysctl, :parent => Puppet::Provider) do
  desc "Support for sysctl on RHEL"

  commands :cmd => "sysctl"

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

  def rebuild_initrd()
    # https://access.redhat.com/solutions/2798411
    if @resource[:rebuild_initrd]
      Puppet.notice("Rebuilding initrd - this may take some time")
      execute(@resource[:rebuild_initrd_cmd])
    end
  end

  def create()
    execute([command(:cmd), "-w", "#{@resource[:name]}=#{@resource[:value]}"])
    File.open(self.get_filename(@resource[:name]), 'w') { |file| file.write(to_file(@resource[:name], @resource[:value])) }

    if @resource[:autoflush_ipv4] and @resource[:name] =~ /ipv4/
      Puppet.notice("Flusihing IPV4 rules")
      execute([command(:cmd), "-w", "net.ipv4.route.flush=1"])
    end

    if @resource[:autoflush_ipv6] and @resource[:name] =~ /ipv6/
      Puppet.notice("Flusihing IPV6 rules")
      execute([command(:cmd), "-w", "net.ipv6.route.flush=1"])
    end

    rebuild_initrd
  end

  def destroy()
    defined_in = @property_hash[:defined_in]
    defined_in_nouse = "#{defined_in}.nouse"
    if File.exist?(defined_in)
      FileUtils.mv(defined_in, defined_in_nouse, force: true)
    end

    # Requires user action so its a warning...
    Puppet.warning("Disabled sysctl setting #{@resource[:name]} by moving #{defined_in} to #{defined_in_nouse} - you must reboot to restore the default")

    rebuild_initrd
  end

  
  def self.instances
    # for a systemctl setting to be "managed" we need an entry in a file and also
    # a matching directive

    active = {}
    sysctl_keys = []

    # corresponding entries from sysctl -a (ensure=> present)
    execute([command(:cmd), "-a" ]).to_s.split("\n").reject { |line|
      line =~ /^\s*$/ or line !~ /=/
    }.each { |line|
      split = line.split('=')
      if split.count == 2
        name = split[0].strip
        value = split[1].strip
        sysctl_keys << name

        file = self.get_filename(name)
        if File.exist?(file)
          active[name] = {:ensure => :present, :value => value, :defined_in => file}
        end
      end
    }

    # items found in u
    Dir.glob("/etc/sysctl.d/*.conf").reject { |file|
      # reject our own files. There is a link 99-sysctl.conf -> /etc/sysctl.conf so we are scanning that too
      sysctl_keys.include?(File.basename(file).gsub(/.conf$/,""))

    }.each { |file|
      File.readlines(file).reject {|line|
        # skip entirely whitespace or comment lines
        line =~ /^(s*|\s*#.*)$/
      }.each { |line|
        split = line.split("=")
        if split.count == 2
          key = split[0].strip
          value = split[1].strip

          active[key] = {:ensure => :present, :value => value, :defined_in => file}
        end

      }
    }

    active.collect { |k,v|
      new({
          :name => k,
          :ensure => v[:ensure],
          :value => v[:value],
          :defined_in => v[:defined_in]
          })
    }


  end

end
