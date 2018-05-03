[![Build Status](https://travis-ci.org/GeoffWilliams/puppet-sysctl.svg?branch=master)](https://travis-ci.org/GeoffWilliams/puppet-sysctl)
# sysctl

#### Table of Contents

1. [Description](#description)
1. [Features](#features)
1. [Usage - Configuration options and additional functionality](#usage)
1. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
1. [Limitations - OS compatibility, etc.](#limitations)
1. [Development - Guide for contributing to the module](#development)

## Description

Manage sysctl kernel tuning with Puppet. This is a native type and provider
that scans the contents of `/etc/sysctl.d`.
 
The module has its own naming convention for files in this directory:
    
*   Name of setting used as filename, eg `net.ipv4.conf.all.accept_source_route`
    will be saved as `/etc/sysctl.d/80-puppet-net.ipv4.conf.all.accept_source_route.conf`
*   One setting per file, in regular `sysctl` format, eg:
    ```
    net.ipv4.conf.all.accept_source_route=0
    ```
*   Files obeying the above convention are `ensure=>present`
*   All other files in the directory will be scanned for entries and any found
    will be `ensure=>absent` since puppet isn't managing them yet
    they are being explicitly set

It's possible to enumerate the list of current settings using 
`puppet resource sysctl` which will give output like this:

```puppet
sysctl { 'net.ipv4.conf.all.accept_source_route':
  ensure     => 'present',
  defined_in => '/etc/sysctl.d/80-puppet-net.ipv4.conf.all.accept_source_route.conf',
  value      => '0',
}
sysctl { 'net.netfilter.nf_conntrack_max':
  ensure     => 'present',
  defined_in => '/etc/sysctl.d/myrules.conf',
  value      => '65536',
}
```

In this case the module is managing `net.ipv4.conf.all.accept_source_route` but not
`net.netfilter.nf_conntrack_max` which is managed in a user created file
`/etc/sysctl.d/myrules.conf`. If we decide to take ownership of this rule 
(`ensure=>present`) then the file defining the old setting will be renamed
`.conf` to `.conf.nouse`. This disables the file without deleting it which
is useful since user defined files can hold more then one setting.

## Features

* Scans `/etc/sysctl.d/*.conf` for rules
* Runs `sysctl -w` when a rule is added
* Flushes IPv4 and IPv6 rules when a rule matching `/ipv4/` or `/ipv6/` is updated (optional)
* Rebuild the initrd when any rules updated (optional)
* Supports resource purging for unmanaged rules
* Files created by puppet prefixed `80-puppet-` for identification


## Usage

### Simple (long form)

```puppet
sysctl { "net.ipv4.conf.all.accept_source_route":
  ensure => present,
  value  => 0,
}
```

* Runs `sysctl -w net.ipv4.conf.all.accept_source_route=0`
* Writes the setting to `/etc/net.ipv4.conf.all.accept_source_route.conf` for activation on boot
* Flushes the IPv4 rules
* Rebuilds initrd

### Simple (short form)

```puppet
sysctl { "net.ipv4.conf.all.accept_source_route=0":
  ensure => present,
}
```

* Functionally equivalent to long form
* Title must match `key=value`

### Resource purging

```puppet
resources { "sysctl":
  purge => true,
}

sysctl { "net.ipv4.conf.all.accept_source_route":
  value => 0,
}
```

Puppet will purge all unmanaged settings from `/etc/sysctl.d`:
* Existing puppet managed files will be removed
* Existing non-puppet managed files will be renamed
* Only the sysctl settings in the catalog will continue to exist
* You must _reboot_ to restore default settings

### Stop managing a setting

```puppet
sysctl { "net.ipv4.conf.all.accept_source_route":
  ensure => absent,
}

```

### Don't flush IPv4 on rule change (per resource)


### Don't flush IPv6 on rule change (per resource)
### Don't rebuild initrd on rule change (per resource)
### Use an alternate command to rebuild initrd


## Reference
[generated documentation](https://rawgit.com/GeoffWilliams/puppet-sysctl/master/doc/index.html).

Reference documentation is generated directly from source code using [puppet-strings](https://github.com/puppetlabs/puppet-strings).  You may regenerate the documentation by running:

```shell
bundle exec puppet strings
```

## Limitations
* Not supported by Puppet, Inc.

## Development

PRs accepted :)

## Testing
This module supports testing using [PDQTest](https://github.com/declarativesystems/pdqtest).


Test can be executed with:

```
bundle install
make
```

See `.travis.yml` for a working CI example
