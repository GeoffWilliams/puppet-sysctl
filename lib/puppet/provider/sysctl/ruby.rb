Puppet::Type.type(:sysctl).provide(:sysctl, :parent => Puppet::Provider) do
  desc "Support for sysctl on RHEL"

  commands :cmd => "sysctl"

  PUPPET_PREFIX = "80-puppet-"

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

  def self.get_filename(name)
    "/etc/sysctl.d/#{PUPPET_PREFIX}#{name}.conf"
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

  def remove_definitions(skip_puppet_rules=true)
    @property_hash[:defined_in] and @property_hash[:defined_in].reject { |f|
      # reject our own files unless we were asked to delete everything
      skip_puppet_rules and File.basename(f) =~ /^#{PUPPET_PREFIX}/
    }.each { |f|
      f_nouse = "#{f}.nouse"
      if File.basename(f) =~ /^#{PUPPET_PREFIX}/
        # managed by puppet already - delete
        File.unlink(f)
      else
        # otherwise just disable by renaming to .nouse
        FileUtils.mv(f, f_nouse, force: true)
      end
      # Requires user action so its a warning...
      Puppet.warning("Disabled sysctl setting #{@resource[:name]} by moving #{f} to #{f_nouse} - you must reboot to restore the default")
    }
  end

  def create()

    # sysctl -w
    execute([command(:cmd), "-w", "#{@resource[:name]}=#{@resource[:value]}"])

    remove_definitions()

    # save setting to 80-puppet-*.conf file
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
    remove_definitions(false)

    # even though we may have touched ipv4/6 rules, there is no point flushing because
    # the default value to flush is unknowable - reboot!

    rebuild_initrd
  end

  
  def self.instances
    # for a systemctl setting to be "managed" we need an entry in a file and also
    # a matching directive

    active = {}
    sysctl_values = {}

    # corresponding entries from sysctl -a that are managed by puppet
    execute([command(:cmd), "-a" ]).to_s.split("\n").reject { |line|
      line =~ /^\s*$/ or line !~ /=/
    }.each { |line|
      split = line.split('=')
      if split.count == 2
        name = split[0].strip
        value = split[1].strip
        sysctl_values[name] = value

        file = self.get_filename(name)
        if File.exist?(file)
          s = File.read(file).split("=")
          value_saved =
              if s.count == 2
                s[1].strip.gsub(/\n/,"")
              else
                nil
              end

          active[name] = {:ensure => :present, :value => value, :value_saved => value_saved, :defined_in => [file]}
        end
      end
    }

    # scan every place we are allowed to define entries
    Dir.glob([
                 "/run/sysctl.d/*.conf",
                 "/etc/sysctl.d/*.conf",
                 "/usr/local/lib/sysctl.d/*.conf",
                 "/usr/lib/sysctl.d/*.conf",
                 "/lib/sysctl.d/*.conf",
                 "/etc/sysctl.conf"
      ]
    ).reject { |file|
      # reject our own files. There is a link 99-sysctl.conf -> /etc/sysctl.conf so we are scanning that too
      file =~ /#{PUPPET_PREFIX}/
    }.each { |file|
      File.readlines(file).reject {|line|
        # skip entirely whitespace or comment lines
        line =~ /^(s*|\s*#.*)$/
      }.each { |line|
        split = line.split("=")
        if split.count == 2
          key = split[0].strip
          value_saved = split[1].strip

          # it's possible for same setting to be defined in multiple files - we need to capture this so that all of them
          # can be moved out of the way
          if active.key?(key)
            active[key][:defined_in] << file
            active[key][:value_saved] = value_saved
          else
            active[key] = {:ensure => :present, :value => sysctl_values[key], :value_saved => value_saved, :defined_in => [file]}
          end
        end

      }
    }

    active.collect { |k,v|
      new({
          :name => k,
          :ensure => v[:ensure],
          :value => v[:value],
          :value_saved => v[:value_saved],
          :defined_in => v[:defined_in]
          })
    }

  end

end
